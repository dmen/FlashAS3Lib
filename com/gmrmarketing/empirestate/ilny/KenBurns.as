/**
 * Ken Burns
 * give it a list of images and a container to play them in
 */
package com.gmrmarketing.empirestate.ilny
{
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	public class KenBurns
	{
		private var myContainer:DisplayObjectContainer;
		private var myImages:Array;
		private var myDisplayTime:int = 8;//seconds to show
		private var curImage:int; //index in myImages
		private var nextTimer:Timer;
		
		
		public function KenBurns()
		{
			myImages = [];
			nextTimer = new Timer(myDisplayTime * 1000 - 500, 1);			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * i Array of BitmapData objects
		 */
		public function set images(i:Array):void
		{
			myImages = i;
			curImage = 0;
		}
		
		
		public function show():void
		{
			nextTimer.addEventListener(TimerEvent.TIMER, next);
			next();
		}
		
		
		public function stop():void
		{
			nextTimer.stop();
			nextTimer.removeEventListener(TimerEvent.TIMER, next);
			while (myContainer.numChildren) {
				myContainer.removeChildAt(0);
			}
		}
		
		
		private function next(e:TimerEvent = null):void
		{
			var b:Bitmap = new Bitmap(myImages[curImage]);
			b.smoothing = true;
			
			var s:Sprite = new Sprite();
			s.addChild(b);
			b.x = -960;
			b.y = -540;
			s.x = 960;
			s.y = 540;
			
			curImage++;
			if (curImage >= myImages.length) {
				curImage = 0;
			}
			myContainer.addChild(s);
			
			s.alpha = 0;
			TweenMax.to(s, 1, { alpha:1, onComplete:removeOld } );
			
			if (Math.random() < .5) {
				//scale it up
				s.scaleX = s.scaleY = 1;
				TweenMax.to(s, myDisplayTime, { scaleX:1.1, scaleY:1.1, ease:Linear.easeNone } );
			}else {
				//scale it down
				s.scaleX = s.scaleY = 1.1;
				TweenMax.to(s, myDisplayTime, { scaleX:1, scaleY:1, ease:Linear.easeNone } );
			}
			
			//fade in the next one 1/2 second before the current one finishes
			nextTimer.reset();			
			nextTimer.start();
		}
		
		
		private function removeOld():void
		{
			while (myContainer.numChildren > 1) {
				myContainer.removeChildAt(0);
			}
		}
		
	}
	
}