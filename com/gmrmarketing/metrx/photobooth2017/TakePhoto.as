package com.gmrmarketing.metrx.photobooth2017
{
	import flash.events.*;
	import flash.display.*;	
	import flash.geom.*;
	import flash.media.*;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
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
		private var overlay:Bitmap;
		private var camTimer:Timer;
		
		private var camScaler:Matrix;
		private var badge:MovieClip;
		
		
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
			display.x = 888;
			display.y = 256;
			
			overlay = new Bitmap(new photoOverlay()); 
			overlay.smoothing = true;
			overlay.x = 888;
			overlay.y = 256;
			
			camScaler = new Matrix();
			camScaler.scale(.736, .736);//scales 1280x720 to 942x529
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
			if (!clip.contains(overlay)) {
				clip.addChild(overlay);
			}			
			
			switch(rank){
				case "rookie":
					badge = new mcResultRookie();
					break;
				case "weekend":
					badge = new mcResultWeekend();
					break;
				case "legend":
					badge = new mcResultLegend();
					break;
			}
			
			if (!clip.contains(badge)){
				clip.addChild(badge);
			}
			
			badge.scaleX = badge.scaleY = .75;
			badge.x = 440;
			badge.y = 200;
			
			theVideo.attachCamera(cam);	
			display.alpha = 0;
			
			startTheCam();
		}
		
		
		private function startTheCam():void
		{
			camTimer.start();//call camUpdate()
			TweenMax.to(display, 1, {alpha:1, delay:.1});			
		}
		
		
		private function camUpdate(e:TimerEvent):void
		{		
			camData.draw(theVideo, camScaler, null, null, null, true);
			displayData.copyPixels(camData, new Rectangle(0, 16, 942, 496), new Point(0, 0));			
		}
	}
	
}