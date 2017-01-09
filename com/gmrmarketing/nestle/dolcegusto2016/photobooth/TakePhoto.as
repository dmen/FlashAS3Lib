package com.gmrmarketing.nestle.dolcegusto2016.photobooth
{
	import flash.events.*;
	import flash.display.*;
	import flash.media.*;	
	import flash.filters.DropShadowFilter;
	import flash.utils.Timer;
	import flash.geom.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class TakePhoto extends EventDispatcher 
	{
		public static const COMPLETE:String = "photoComplete";
		public static const MOVE_BG:String = "userAdvancedBackground";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		private var cam:Camera;
		private var theVideo:Video;
		private var camData:BitmapData;
		private var displayData:BitmapData;
		private var display:Bitmap;
		private var frame:BitmapData;//the paris,woods,beach overlay bitmap from the library
		private var whiteFlash:MovieClip;
		private var camTimer:Timer;
		
		private var camScaler:Matrix;
		
		private var countDownCount:int;
		
		private var userPhoto:Bitmap;//the 1584x1545 scaled version for display
		private var uPhoto:BitmapData;//unscaled photo
		
		private var timeoutHelper:TimeoutHelper;
		
		
		
		public function TakePhoto()
		{
			clip = new mcTakePhoto();
			
			camData = new BitmapData(2138, 1445);//full size for camera to draw into
			
			//full size of overlay images
			displayData = new BitmapData(1580, 1580);
			display = new Bitmap(displayData, "auto", true);			
			display.x = 587;
			display.y = 124;
			display.filters = [new DropShadowFilter(0, 0, 0x000000, 1, 45, 45, .40, 3)];
			
			//scales camera up for display within the 1580x1580 border/overlay image
			//image is 1445x1445 within the frame
			camScaler = new Matrix();
			camScaler.scale(1.6706, 1.6706); //makes 2138x1445 camera image from 1280x865 - draws into camData
			
			camTimer = new Timer(1000 / 24); //24 fps cam update
			camTimer.addEventListener(TimerEvent.TIMER, camUpdate);
			
			cam = Camera.getCamera();
			cam.setMode(1280, 865, 24);				
			
			//for display when reviewing the captured image
			userPhoto = new Bitmap();
			userPhoto.x = 587;
			userPhoto.y = 124;
			
			whiteFlash = new mcWhiteFlash();
			
			theVideo = new Video(1280, 865);
			
			timeoutHelper = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * 
		 * @param	mood paris,beach,woods - determines the overlay used
		 */
		public function show(mood:String):void
		{			
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
				//camera Bitmap - displayData - 1580x1580
				if (!myContainer.contains(display)) {
					myContainer.addChild(display);
				}
				//user photo Bitmap for review
				if (!myContainer.contains(userPhoto)){
					myContainer.addChild(userPhoto);
				}							
				//white flash
				if (!myContainer.contains(whiteFlash)){
					myContainer.addChild(whiteFlash);
				}
			}
			
			setOverlay(mood);
			
			whiteFlash.visible = false;		
			
			display.alpha = 0;
			TweenMax.to(display, .5, {alpha:1, delay:.4});			
			
			clip.btnTake.gotoAndStop(1);//reset to camera icon
			clip.btnTake.width = clip.btnTake.height = 0;
			TweenMax.to(clip.btnTake, .4, {width:350, height:350, ease:Back.easeOut, delay:.5});
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, beginCountdown, false, 0, true);
			clip.btnRedo.width = clip.btnRedo.height = 0;//hide redo initially
			
			clip.btnForward.width = clip.btnForward.height = 0;
			TweenMax.to(clip.btnForward, .4, {width:220, height:220, ease:Back.easeOut, delay:.6});
			clip.btnForward.addEventListener(MouseEvent.MOUSE_DOWN, forwardPressed, false, 0, true);
			
			userPhoto.bitmapData = new BitmapData(1580, 1580, true, 0x00000000);
			
			theVideo.attachCamera(cam);
			camTimer.start();//call camUpdate()
			
			timeoutHelper.buttonClicked();
		}
		
		
		public function setOverlay(mood:String):void
		{
			//set the frame image - 1580x1580
			switch(mood){
				case "paris":
					frame = new overlayParis();
					break;
				case "beach":
					frame = new overlayBeach();
					break;
				case "woods":
					frame = new overlayWoods();
					break;
			}
		}
		
		
		public function hide():void
		{		
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, beginCountdown);
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, photoComplete);			
			clip.btnRedo.removeEventListener(MouseEvent.MOUSE_DOWN, beginCountdown);
			clip.btnForward.removeEventListener(MouseEvent.MOUSE_DOWN, forwardPressed);
			
			theVideo.attachCamera(null);
			camTimer.reset();
			
			if(userPhoto.bitmapData){
				userPhoto.bitmapData.dispose();
			}
			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
				//camera
				if (myContainer.contains(display)) {
					myContainer.removeChild(display);
				}
				//user photo
				if (myContainer.contains(userPhoto)){
					myContainer.removeChild(userPhoto);
				}							
				//white flash
				if (myContainer.contains(whiteFlash)){
					myContainer.removeChild(whiteFlash);
				}
			}			
		}
		
		
		/**
		 * Called by pressing take photo button
		 * and by pressing Redo after the photo
		 * @param	e
		 */
		private function beginCountdown(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			//clear out the userphoto data
			if(userPhoto.bitmapData){
				userPhoto.bitmapData = new BitmapData(1584, 1545, true, 0x00000000);
			}
			userPhoto.alpha = 1;
			
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, beginCountdown);
			countDownCount = 1;
			countSmall();
		}
		
		
		private function countSmall():void
		{
			var del:Number = 0;
			if (countDownCount > 1){
				del = .25;
			}
			if(countDownCount < 4){
				TweenMax.to(clip.btnTake, .5, {scaleX:0, scaleY:0, ease:Back.easeIn, delay:del, onComplete:nextCount});
			}else{
				TweenMax.to(clip.btnTake, .5, {scaleX:0, scaleY:0, ease:Back.easeIn, delay:del, onComplete:countDone});
			}
		}
		
		
		private function nextCount():void
		{
			countDownCount++;
			clip.btnTake.gotoAndStop(countDownCount);
			TweenMax.to(clip.btnTake, .5, {scaleX:1, scaleY:1, onComplete:countSmall, ease:Back.easeOut});
		}
		
		
		private function countDone():void
		{
			whiteFlash.visible = true;
			whiteFlash.alpha = 1;
			TweenMax.to(whiteFlash, .75, {alpha:0, onComplete:showReview});
			
			//this is returned in get photo
			uPhoto = getCamPic();//945x945 - unscaled original
			
			//scale 945 to 1580
			var m:Matrix = new Matrix();
			m.scale(1.672, 1.672);//scale 945x945 to 1580x1580
			userPhoto.bitmapData.draw(uPhoto, m, null, null, null, true);
			userPhoto.alpha = 0;
			TweenMax.to(userPhoto, .5, {alpha:1, delay:.3});
		}
		
		
		/**
		 * Returns the 953x935 unscaled photo
		 */
		public function get photo():BitmapData
		{
			return uPhoto;
		}
		
		
		private function forwardPressed(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			dispatchEvent(new Event(MOVE_BG));
		}
		
		
		private function showReview():void
		{
			whiteFlash.visible = false;
			
			//show next arrow
			clip.btnTake.gotoAndStop(5);
			clip.btnTake.rotation = 90;
			TweenMax.to(clip.btnTake, .5, {scaleX:1, scaleY:1, rotation:0, ease:Back.easeOut});
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, photoComplete, false, 0, true);
			
			//show redo - circ arrow
			TweenMax.to(clip.btnRedo, .5, {width:220, height:220, ease:Back.easeOut, delay:.3});
			clip.btnRedo.addEventListener(MouseEvent.MOUSE_DOWN, doRedo, false, 0, true);
		}
		
		
		/**
		 * called if the redo button is pressed
		 * @param	e
		 */
		private function doRedo(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			TweenMax.to(clip.btnRedo, .4, {width:0, height:0, ease:Back.easeIn});
			clip.btnRedo.removeEventListener(MouseEvent.MOUSE_DOWN, doRedo);			
			
			TweenMax.to(userPhoto, .5, {alpha:0});//reset in beginCountdown()
			
			clip.btnTake.gotoAndStop(1);//reset to camera icon
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, photoComplete);
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, beginCountdown, false, 0, true);
		}
		
		
		/**
		 * Called when the Next button is pressed
		 * @param	e
		 */
		private function photoComplete(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, photoComplete);			
			clip.btnRedo.removeEventListener(MouseEvent.MOUSE_DOWN, doRedo);
			TweenMax.to(clip.btnTake, .3, {scaleX:0, scaleY:0, ease:Back.easeIn});
			TweenMax.to(clip.btnRedo, .3, {scaleX:0, scaleY:0, ease:Back.easeIn, delay:.1});
			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		/**
		 * returns a 945x945 bitmapData
		 *scale frame to 945x945 to make 865x865 interior
		 */
		public function getCamPic():BitmapData
		{			
			var bmd:BitmapData = new BitmapData(945, 945, false, 0xffffff);
			
			//camera image
			var camPic:BitmapData = new BitmapData(1280, 865);
			camPic.draw(theVideo, null, null, null, null, true);
			
			bmd.copyPixels(camPic, new Rectangle(198, 0, 865, 865), new Point(40, 40));
			
			//resize frame
			var m:Matrix = new Matrix();
			m.scale(0.59811, 0.59811);//scale 1580x1580 to 945x945
			var scaledFrame:BitmapData = new BitmapData(945, 945, true, 0x00000000);
			scaledFrame.draw(frame, m, null, null, null, true);
			
			bmd.copyPixels(scaledFrame, new Rectangle(0, 0, 945, 945), new Point(0, 0), null, null, true);		
			
			return bmd;
		}
		
		
		/**
		 * Draws the camera (theVideo) and frame into displayData
		 * scales it up using the camScaler matrix
		 * @param	e
		 */
		private function camUpdate(e:TimerEvent):void
		{	
			//draw 1280x865 camera into camData at 2138x1445
			camData.draw(theVideo, camScaler, null, null, null, true);
			
			//crop image from full size frame for display at 1445 x 1445 - place into 1580x1580 displayData
			displayData.copyPixels(camData, new Rectangle(330, 0, 1445, 1445), new Point(66, 66));
			
			//place frame over user image
			displayData.copyPixels(frame, new Rectangle(0, 0, 1580, 1580), new Point(0, 0), null, null, true);
		}
		
	}
	
}