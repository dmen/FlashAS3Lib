package com.gmrmarketing.metrx.photobooth2017
{
	import flash.events.*;
	import flash.display.*;	
	import flash.geom.*;
	import flash.media.*;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.dynamicflash.util.Base64;
	import flash.utils.*;
	import com.adobe.images.JPEGEncoder;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class TakePhoto extends EventDispatcher
	{
		public static const COMPLETE:String = "takePhotoComplete";
		public static const SHOW_WHITE:String = "showWhiteFlash";
		public static const HIDDEN:String = "takePhotoHidden";
		
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		
		private var cam:Camera;
		private var theVideo:Video;
		private var camData:BitmapData;
		private var displayData:BitmapData;
		private var display:Bitmap;
		private var overlay:BitmapData;
		private var overlayBadge:BitmapData;
		private var camTimer:Timer;
		
		private var camScaler:Matrix;
		private var badge:MovieClip;
		private var userPic:String;//b64 encoded string
		private var tim:TimeoutHelper;
		
		
		public function TakePhoto()
		{
			clip = new mcTakePhoto();
			
			camTimer = new Timer(1000 / 24); //24 fps cam update
			camTimer.addEventListener(TimerEvent.TIMER, camUpdate);
			
			cam = Camera.getCamera();
			cam.setMode(1280, 865, 24);
			theVideo = new Video(1280, 865);
			
			camData = new BitmapData(942, 529);//for camera to draw into in camUpdate()
			
			displayData = new BitmapData(942, 496, false, 0x000000);	//display size - same size as overlay	
			display = new Bitmap(displayData, "auto", true);
			display.smoothing = true;
			display.x = 888;
			display.y = 256;
			
			overlay = new photoOverlay(); //942x496
			
			camScaler = new Matrix();
			camScaler.scale(.736, .736);//scales 1280x720 to 942x529
			
			tim = TimeoutHelper.getInstance();
			
			theVideo.attachCamera(cam);	
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			_container = c;
		}
		
		
		/**
		 * 
		 * @param	rank one of rookie, weekend, legend
		 */
		public function show(rank:String):void
		{
			if (!_container.contains(clip)){
				_container.addChild(clip);
			}
			
			if (!clip.contains(display)) {
				clip.addChild(display);
			}						
			
			switch(rank){
				case "rookie":
					badge = new mcResultRookie();
					overlayBadge = new badgeRookie();
					break;
				case "weekend":
					badge = new mcResultWeekend();
					overlayBadge = new badgeWeekend();
					break;
				case "legend":
					badge = new mcResultLegend();
					overlayBadge = new badgeLegend();
					break;
			}
			
			if (!clip.contains(badge)){
				clip.addChild(badge);
			}
			
			badge.scaleX = badge.scaleY = 0;// .35;
			badge.x = 460;
			badge.y = 295;
			
			clip.x = 0;
			clip.tread.x = 1920;
			clip.heroPose.alpha = 0;
			clip.btnTake.visible = true;
			clip.btnTake.alpha = 0;
			
			clip.countdown.visible = false;//3-2-1
			clip.btnRetake.visible = false;
			clip.btnSave.visible = false;
			
			
			display.alpha = 0;
			
			TweenMax.to(clip.tread, .5, {x:216, ease:Expo.easeOut});
			TweenMax.to(clip.heroPose, .5, {alpha:1, delay:.2});
			TweenMax.to(clip.btnTake, .5, {alpha:1, delay:.3});
			TweenMax.to(badge, .5, {scaleX:.35, scaleY:.35, ease:Back.easeOut, onComplete:startTheCam});
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip, .5, {x: -1920, onComplete:kill});
		}
		
		
		public function kill():void
		{
			//theVideo.attachCamera(null);
			
			if(badge){
				if (clip.contains(badge)){
					clip.removeChild(badge);
				}
			}
			if (clip.contains(display)) {
				clip.removeChild(display);
			}
			
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
			
			camTimer.reset();
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, showCountdown);
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, doRetake);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, doSave);
			
			dispatchEvent(new Event(HIDDEN));
		}
		
		
		private function startTheCam():void
		{
			camTimer.start();//call camUpdate()
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, showCountdown, false, 0, true);
			TweenMax.to(display, 1, {alpha:1, delay:1});			
		}
		
		
		private function camUpdate(e:TimerEvent):void
		{		
			//draw 1280x720 from theVideo into 942x529 camData
			camData.draw(theVideo, camScaler, null, null, null, true);
			
			//copyPixel from camData and overlays into displayData - displayData is 942x496
			displayData.copyPixels(camData, new Rectangle(0, 16, 942, 496), new Point(0, 0));		
			displayData.copyPixels(overlay, new Rectangle(0, 0, 942, 496), new Point(0, 0));		
			displayData.copyPixels(overlayBadge, new Rectangle(0, 0, 171, 143), new Point(682, 88));		
		}
		
		
		private function showCountdown(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, showCountdown);
			clip.btnTake.visible = false;
			
			clip.countdown.visible = true;
			clip.countdown.alpha = 0;
			clip.countdown.orange.x = -802;
			TweenMax.to(clip.countdown, .5, {alpha:1, onComplete:startCountdown});
		}
		
		
		private function startCountdown():void
		{
			TweenMax.to(clip.countdown.orange, .3, {x: -502, ease:Back.easeOut, delay:.5});//3
			TweenMax.to(clip.countdown.orange, .3, {x: -302, ease:Back.easeOut, delay:1.6});//2
			TweenMax.to(clip.countdown.orange, .3, {x: -34, ease:Back.easeOut, delay:2.7, onComplete:doWhite});//1
		}
		
		
		private function doWhite():void
		{
			dispatchEvent(new Event(SHOW_WHITE));
		}
		
		
		/**
		 * called from Main when the white flash shows - stops camTimer to freeze display
		 */
		public function takePic():void
		{
			camTimer.reset();
		}
		
		
		/**
		 * userPic is created in doSave()
		 */
		public function get pic():String
		{
			return userPic;
		}
		
		
		/**
		 * called from Main.showFlash()
		 */
		public function reviewPic():void
		{
			clip.countdown.visible = false;
			clip.btnRetake.visible = true;
			clip.btnSave.visible = true;
			clip.btnRetake.alpha = 0;
			clip.btnSave.alpha = 0;
			TweenMax.to(clip.btnRetake, .5, {alpha:1});
			TweenMax.to(clip.btnSave, .5, {alpha:1});
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, doRetake, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, doSave, false, 0, true);
		}
		
		
		private function doRetake(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, doRetake);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, doSave);
			
			clip.btnRetake.visible = false;
			clip.btnSave.visible = false;
			
			clip.btnTake.visible = true;
			clip.btnTake.alpha = 0;
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, showCountdown, false, 0, true);
			TweenMax.to(clip.btnTake, .5, {alpha:1, delay:.3});
			
			camTimer.start();
		}
		
		
		private function doSave(e:MouseEvent):void
		{			
			tim.buttonClicked();
			
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, doRetake);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, doSave);
			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		public function encode():void
		{
			var jpeg:ByteArray = getJpeg(displayData);
			userPic = getBase64(jpeg);		
		}
		
		
		private function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		
		private function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPEGEncoder = new JPEGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
	}
	
}