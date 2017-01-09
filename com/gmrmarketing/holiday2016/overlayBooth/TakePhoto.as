package com.gmrmarketing.holiday2016.overlayBooth
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class TakePhoto extends EventDispatcher
	{
		public static const COMPLETE:String = "takePhotoComplete";
		public static const SHOW_WHITE:String = "showWhiteFlash";
		public static const HIDDEN:String = "takeHidden";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var bar:ButtonBar;
		private var cam:Camera;
		private var theVideo:Video;
		private var camData:BitmapData;
		private var displayData:BitmapData;
		private var overlay:Bitmap;
		private var display:Bitmap;
		private var camTimer:Timer;
		
		private var newOverlay:BitmapData;
		private var tmh:TimeoutHelper;
		
		
		public function TakePhoto()
		{
			clip = new mcTakePhoto();
			bar = new ButtonBar();
			
			camTimer = new Timer(1000 / 24); //24 fps cam update
			camTimer.addEventListener(TimerEvent.TIMER, camUpdate);
			
			cam = Camera.getCamera();
			cam.setMode(1280, 865, 24);
			theVideo = new Video(1280, 865);
			
			camData = new BitmapData(1280, 865);//full size for camera to draw into
			
			displayData = new BitmapData(870, 865, false, 0x000000);	//display size - same size as overlays	
			display = new Bitmap(displayData, "auto", true);			
			display.x = 537;
			display.y = 57;
			
			overlay = new Bitmap(new BitmapData(870,865,true,0x00000000)); 
			overlay.smoothing = true;
			overlay.x = 537;
			overlay.y = 57;
			
			tmh = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
			bar.container = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			if (!clip.contains(display)) {
				clip.addChild(display);
			}
			if (!clip.contains(overlay)) {
				clip.addChild(overlay);
			}
			
			clip.alpha = 1;
			display.alpha = 0;
			
			bar.show();
			bar.addEventListener(ButtonBar.COUNT_COMPLETE, showWhite, false, 0, true);			
			
			//clip.share.alpha = 0;			
			clip.highlighter.x =-200;			
			
			clip.t1.scaleX = clip.t1.scaleY = 0;
			clip.t2.scaleX = clip.t2.scaleY = 0;
			clip.t3.scaleX = clip.t3.scaleY = 0;
			clip.t4.scaleX = clip.t4.scaleY = 0;
			clip.t5.scaleX = clip.t5.scaleY = 0;
			clip.t6.scaleX = clip.t6.scaleY = 0;
			clip.chooseFrame.scaleY = 0;
			
			clip.fernSide.alpha = 0;
			clip.fern.gotoAndStop(1);
			clip.fern.scaleY = 0;
			TweenMax.to(clip.fernSide, 2, {alpha:1, delay:.5});
			
			TweenMax.to(clip.t1, .4, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.1});
			TweenMax.to(clip.t2, .4, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.2});
			TweenMax.to(clip.t3, .4, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.3});
			TweenMax.to(clip.t4, .4, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.4});
			TweenMax.to(clip.t5, .4, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.5});
			TweenMax.to(clip.t6, .4, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.6});
			TweenMax.to(clip.chooseFrame, .4, {scaleY:1, ease:Back.easeOut, delay:.7,onComplete:startTheCam});
			//TweenMax.to(clip.share, 2, {alpha:1, delay:2});
			
			clip.t1.addEventListener(MouseEvent.MOUSE_DOWN, overlay1, false, 0, true);
			clip.t2.addEventListener(MouseEvent.MOUSE_DOWN, overlay2, false, 0, true);
			clip.t3.addEventListener(MouseEvent.MOUSE_DOWN, overlay3, false, 0, true);
			clip.t4.addEventListener(MouseEvent.MOUSE_DOWN, overlay4, false, 0, true);
			clip.t5.addEventListener(MouseEvent.MOUSE_DOWN, overlay5, false, 0, true);
			clip.t6.addEventListener(MouseEvent.MOUSE_DOWN, overlay6, false, 0, true);
			
			theVideo.attachCamera(cam);			
		}
		
		
		private function startTheCam():void
		{
			camTimer.start();//call camUpdate()
			TweenMax.to(display, 1, {alpha:1, delay:.1});
			clip.fern.gotoAndPlay(2);
			TweenMax.to(clip.fern, 1.5, {scaleY:1, ease:Back.easeOut});
			overlay1();
		}
		
		
		public function hide():void
		{
			bar.removeEventListener(ButtonBar.RETAKE, retakePhoto);
			bar.removeEventListener(ButtonBar.EMAIL, sendToEmail);
			TweenMax.to(clip, 1, { alpha:0, onComplete:hidden } );
			bar.hide();
		}
		
		public function kill():void
		{
			bar.removeEventListener(ButtonBar.RETAKE, retakePhoto);
			bar.removeEventListener(ButtonBar.EMAIL, sendToEmail);
			bar.killBar();
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}				
			}
			
			overlay.bitmapData.dispose();
			theVideo.attachCamera(null);
			camTimer.reset();
		}
		
		
		private function hidden():void
		{			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}				
			}
			overlay.bitmapData.dispose();
			theVideo.attachCamera(null);
			camTimer.reset();
			
			dispatchEvent(new Event(HIDDEN));
		}
		
		
		private function camUpdate(e:TimerEvent):void
		{		
			camData.draw(theVideo, null, null, null, null, true);
			displayData.copyPixels(camData, new Rectangle(205, 0, 870, 865), new Point(0, 0));			
		}
		
		
		/**
		 * returns a copy of display data - with the overlay
		 */
		public function get pic():BitmapData
		{
			var im:BitmapData = new BitmapData(870, 865);			
			im.copyPixels(displayData, new Rectangle(0, 0, 870, 865), new Point(0, 0));				
			im.copyPixels(overlay.bitmapData, new Rectangle(0, 0, 870, 865), new Point(0, 0), null, null, true);
			/*
			var newSize:BitmapData = new BitmapData(864, 865);
			var m:Matrix = new Matrix();
			m.scale(.9931, 1);
			newSize.draw(im, m, null, null, null, true);
			*/
			return im;
		}
		
		
		/**
		 * called from Main.showWhite()
		 * removes the camera timer to effectivey show the "taken" photo
		 */
		public function showReview():void
		{
			//tell button bar to show review
			//put a flag that stops camUpdate and just displays the one image
			camTimer.stop();
			
			bar.showRetake();
			bar.addEventListener(ButtonBar.RETAKE, retakePhoto, false, 0, true);
			bar.addEventListener(ButtonBar.EMAIL, sendToEmail, false, 0, true);
		}
		
		
		/**
		 * called by ButtonBar.COUNT_COMPLETE event
		 */
		private function showWhite(e:Event):void
		{
			tmh.buttonClicked();
			dispatchEvent(new Event(SHOW_WHITE));
		}
		
		
		/**
		 * called by pressing retake photo on the button bar
		 * @param	e
		 */
		private function retakePhoto(e:Event):void
		{
			tmh.buttonClicked();
			
			bar.removeEventListener(ButtonBar.RETAKE, retakePhoto);
			bar.hideRetake();
			camTimer.start();//start calling camUpdate again			
		}
		
		
		private function sendToEmail(e:Event):void
		{
			tmh.buttonClicked();
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function overlay1(e:MouseEvent = null):void
		{
			updateHighlighter(clip.t1.x, clip.t1.y);
			TweenMax.to(overlay, .5, {alpha:0, onComplete:swapOverlays, onCompleteParams:[new over1()]});			
		}
		private function overlay2(e:MouseEvent):void
		{
			updateHighlighter(clip.t2.x, clip.t2.y);
			TweenMax.to(overlay, .5, {alpha:0, onComplete:swapOverlays, onCompleteParams:[new over2()]});
		}
		private function overlay3(e:MouseEvent):void
		{
			updateHighlighter(clip.t3.x, clip.t3.y);
			TweenMax.to(overlay, .5, {alpha:0, onComplete:swapOverlays, onCompleteParams:[new over3()]});
		}
		private function overlay4(e:MouseEvent):void
		{
			updateHighlighter(clip.t4.x, clip.t4.y);
			TweenMax.to(overlay, .5, {alpha:0, onComplete:swapOverlays, onCompleteParams:[new over4()]});
		}
		private function overlay5(e:MouseEvent):void
		{
			updateHighlighter(clip.t5.x, clip.t5.y);
			TweenMax.to(overlay, .5, {alpha:0, onComplete:swapOverlays, onCompleteParams:[new over5()]});
		}
		private function overlay6(e:MouseEvent):void
		{
			updateHighlighter(clip.t6.x, clip.t6.y);
			TweenMax.to(overlay, .5, {alpha:0, onComplete:swapOverlays, onCompleteParams:[new over6()]});
		}
		private function swapOverlays(newBMD:BitmapData):void
		{
			overlay.bitmapData = newBMD;
			overlay.smoothing = true;
			TweenMax.to(overlay, .5, {alpha:1});
		}
		
		
		private function updateHighlighter(nx:int, ny:int):void
		{
			tmh.buttonClicked();
			
			clip.highlighter.x = nx;
			clip.highlighter.y = ny;
			clip.highlighter.scaleX = clip.highlighter.scaleY = 0;
			TweenMax.to(clip.highlighter, .3, {scaleX:1, scaleY:1, ease:Back.easeOut});
		}
		
	}
	
}