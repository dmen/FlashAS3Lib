package com.gmrmarketing.associatedbank.mnwild
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.*;
	import flash.ui.Mouse;	
	import flash.media.Camera;
	import flash.media.Video;
	import com.greensock.TweenMax;
	import flash.utils.getTimer;
	
	
	public class TakePhoto extends EventDispatcher
	{
		public static const CAPTURE_COMPLETE:String = "captureComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var vid:Video;
		private var cam:Camera;
		private var frames:Array;
		private var frameCount:int;
		private var everyNth:int;
		private var maxFrames:int;
		private var recTime:int;
		private var startTime:Number;
		private var overlay:Bitmap;
		
		
		public function TakePhoto() 
		{			
			clip = new mcTakePhoto();
			
			vid = new Video(1280, 720);
			vid.x = 320;
			vid.y = 170;
			
			overlay = new Bitmap(new overlay1280());
			overlay.x = 320;
			overlay.y = 170;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * 
		 * @param	data Object with numSec and nth properties
		 */
		public function show(data:Object):void
		{			
			everyNth = data.nth;
			maxFrames = (30 / everyNth) * data.numSec
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			cam = Camera.getCamera();
			cam.setMode(1280, 720, 30);
			vid.attachCamera(cam);
			vid.scaleX = -1;
			
			myContainer.addChild(vid);
			myContainer.addChild(overlay);
			
			frames = [];
			
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, take, false, 0, true);
			
			clip.recIndicator.alpha = 0;//red outline
			clip.recIndicator.theText.text = String(data.numSec);
			recTime = data.numSec;
		}
		
		
		public function hide():void
		{
			TweenMax.killAll();
			
			vid.attachCamera(null);
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, take);
			if(myContainer){
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
				if (myContainer.contains(vid)) {
					myContainer.removeChild(vid);
				}
				if (myContainer.contains(overlay)) {
					myContainer.removeChild(overlay);
				}
			}
		}
		
		
		public function get framesArray():Array
		{
			return frames;
		}
		
		
		private function take(e:MouseEvent):void
		{
			TweenMax.to(clip.recIndicator, .3, { alpha:1, onComplete:fadeOutLine } );
			startTime = getTimer();
			frameCount = 0;
			clip.addEventListener(Event.ENTER_FRAME, grabFrame, false, 0, true);
		}
		
		
		private function grabFrame(e:Event):void
		{
			frameCount++;
			if (frameCount % everyNth == 0) {				
				var a:BitmapData = new BitmapData(cam.width, cam.height);
				cam.drawToBitmapData(a);
				frames.push(a);
				
				var elapsed:Number = Math.round((getTimer() - startTime) * 0.001);			
				clip.recIndicator.theText.text = String(recTime - elapsed);				
			}
			
			if (frames.length >= maxFrames) {				
				clip.removeEventListener(Event.ENTER_FRAME, grabFrame);
				dispatchEvent(new Event(CAPTURE_COMPLETE));
			}
		}
		
		
		private function fadeOutLine():void
		{
			TweenMax.to(clip.recIndicator.outline, .5, { alpha:0, onComplete:fadeInLine } );
		}
		private function fadeInLine():void
		{
			TweenMax.to(clip.recIndicator.outline, .5, { alpha:1, onComplete:fadeOutLine } );
		}
		
	}
	
}