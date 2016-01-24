package com.gmrmarketing.holiday2015
{
	import flash.events.*;
	import flash.display.*;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.*;
	import flash.media.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Take extends EventDispatcher
	{
		public static const HIDDEN:String = "takePhotoHidden";
		public static const OVERLAY_CHANGED:String = "overlayChanged";
		
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		private var cam:Camera;
		private var theVideo:Video;
		private var camData:BitmapData;
		private var displayData:BitmapData;
		private var display:Bitmap;
		private var camTimer:Timer;
		
		private var theEgg:BitmapData;
		private var eggShowing:Boolean;
		
		private var overlay:Bitmap;
		private var shadowMaker:Sprite;
		
		private var tim:TimeoutHelper;
		
		public function Take():void
		{			
			clip = new mcTakePhoto();
			
			camData = new BitmapData(1280, 865);//full size for camera to draw into
			
			displayData = new BitmapData(870, 865);	//display size - same size as overlays	
			display = new Bitmap(displayData, "auto", true);			
			display.x = 537;
			display.y = 57;
			
			overlay = new Bitmap(); 
			overlay.smoothing = true;
			overlay.x = 537;
			overlay.y = 57;
			
			shadowMaker = new Sprite();
			shadowMaker.x = 537;
			shadowMaker.y = 57;
			shadowMaker.graphics.beginFill(0x000000, 1);
			shadowMaker.graphics.drawRect(0, 0, 870, 865);
			shadowMaker.graphics.endFill();			
			shadowMaker.filters = [new DropShadowFilter(0, 0, 0, .8, 45, 45, 2, 3)];
			
			camTimer = new Timer(1000 / 24); //24 fps cam update
			camTimer.addEventListener(TimerEvent.TIMER, camUpdate);
			
			cam = Camera.getCamera();
			cam.setMode(1280, 865, 24);	
			
			theVideo = new Video(1280, 865);
					
			eggShowing = false;
			
			tim = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function egg():void
		{
			eggShowing = !eggShowing;			
		}
		
		
		public function show():void
		{
			clip.alpha = 1;			
			
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
			}
			
			eggShowing = false;
			
			theVideo.attachCamera(cam);
			camTimer.start();//call camUpdate()
			
			clip.th1.scaleX = clip.th1.scaleY = 0;
			clip.th2.scaleX = clip.th2.scaleY = 0;
			clip.th3.scaleX = clip.th3.scaleY = 0;
			clip.th4.scaleX = clip.th4.scaleY = 0;
			clip.th5.scaleX = clip.th5.scaleY = 0;
			clip.th6.scaleX = clip.th6.scaleY = 0;
			
			display.alpha = 0;
			
			clip.chooseFrame.alpha = 0;
			clip.chooseFrame.y = 914;
			
			clip.share.alpha = 0;
			clip.share.y = 900;
			
			clip.highlighter.alpha = 0;
			
			TweenMax.to(clip.th1, .5, { scaleX:1, scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.th2, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:.2} );
			TweenMax.to(clip.th3, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:.4} );
			TweenMax.to(clip.th4, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:.6} );
			TweenMax.to(clip.th5, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:.8} );
			TweenMax.to(clip.th6, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:1 } );
			
			clip.th1.addEventListener(MouseEvent.MOUSE_DOWN, showOverlay1, false, 0, true);
			clip.th2.addEventListener(MouseEvent.MOUSE_DOWN, showOverlay2, false, 0, true);
			clip.th3.addEventListener(MouseEvent.MOUSE_DOWN, showOverlay3, false, 0, true);
			clip.th4.addEventListener(MouseEvent.MOUSE_DOWN, showOverlay4, false, 0, true);
			clip.th5.addEventListener(MouseEvent.MOUSE_DOWN, showOverlay5, false, 0, true);
			clip.th6.addEventListener(MouseEvent.MOUSE_DOWN, showOverlay6, false, 0, true);			
			
			if (!clip.contains(shadowMaker)) {
				clip.addChild(shadowMaker);
			}
			if (!clip.contains(display)) {
				clip.addChild(display);
			}			
			
			TweenMax.to(display, .5, { alpha:1, delay:1 } );
			
			if (!clip.contains(overlay)) {
				clip.addChild(overlay);
			}			
			
			TweenMax.to(clip.chooseFrame, .5, { y:874, alpha:1, ease:Back.easeOut, delay:1.5 } );			
			
			TweenMax.to(clip.share, .5, { y:860, alpha:1, ease:Back.easeOut, delay:1.7 } );
			
			clip.highlighter.alpha = 0;
			TweenMax.delayedCall(1, showOverlay1);
		}
		
		
		public function hide():void
		{
			display.alpha = 0;
			TweenMax.to(clip, 1, { alpha:0, onComplete:hidden } );
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
		
		
		private function showOverlay1(e:MouseEvent = null):void
		{		
			clip.highlighter.alpha = 1;
			theEgg = new dan1();
			overlay.bitmapData = new over1();
			overlay.smoothing = true;
			updateHighlight(clip.th1.x, clip.th1.y);
		}
		private function showOverlay2(e:MouseEvent = null):void
		{
			theEgg = new dan2();
			overlay.bitmapData = new over2();
			overlay.smoothing = true;
			updateHighlight(clip.th2.x, clip.th2.y);
		}
		private function showOverlay3(e:MouseEvent = null):void
		{
			theEgg = new dan3();
			overlay.bitmapData = new over3();
			overlay.smoothing = true;
			updateHighlight(clip.th3.x, clip.th3.y);
		}
		private function showOverlay4(e:MouseEvent = null):void
		{
			theEgg = new dan4();
			overlay.bitmapData = new over4();
			overlay.smoothing = true;
			updateHighlight(clip.th4.x, clip.th4.y);
		}
		private function showOverlay5(e:MouseEvent = null):void
		{
			theEgg = new dan5();
			overlay.bitmapData = new over5();
			overlay.smoothing = true;
			updateHighlight(clip.th5.x, clip.th5.y);
		}
		private function showOverlay6(e:MouseEvent = null):void
		{
			theEgg = new dan6();
			overlay.bitmapData = new over6();
			overlay.smoothing = true;
			updateHighlight(clip.th6.x, clip.th6.y);
		}
		
		
		private function updateHighlight(newX:int, newY:int):void
		{
			dispatchEvent(new Event(OVERLAY_CHANGED));
			tim.buttonClicked();
			if (clip.highlighter.x != newX) {
				TweenMax.to(clip.highlighter, .3, { x:newX, onComplete:updateHighlightY, onCompleteParams:[newY] } );
			}else {
				updateHighlightY(newY);
			}
		}
		private function updateHighlightY(newY:int):void
		{
			TweenMax.to(clip.highlighter, .3, { y:newY } );
		}
		
		//called by Main.countComplete()
		public function get pic():Array
		{
			var im:BitmapData = new BitmapData(870, 865);		
			
			//displayData.lock();
			
			//camData.draw(theVideo, null, null, null, null, true);
			
			im.copyPixels(displayData, new Rectangle(0, 0, 870, 865), new Point(0, 0));	
			
			//im.copyPixels(overlay.bitmapData, new Rectangle(0, 0, 870, 865), new Point(0, 0), null, null, true);		
			
			if (eggShowing) {
				
				im.copyPixels(theEgg, new Rectangle(0, 0,870, 865), new Point(0,0), null, null, true);
			}
			
				
			//im.copyPixels(displayData, new Rectangle(0, 0, 870, 865), new Point(0, 0));
			
			//displayData.unlock();
			
			return [im, overlay.bitmapData];
		}
		
		
		private function camUpdate(e:TimerEvent):void
		{		
			camData.draw(theVideo, null, null, null, null, true);
			displayData.copyPixels(camData, new Rectangle(205, 0, 870, 865), new Point(0, 0));		
			
			if (eggShowing) {
				displayData.copyPixels(theEgg, new Rectangle(0, 0,870, 865), new Point(0,0), null, null, true);
			}
		}		
		
	}
	
}