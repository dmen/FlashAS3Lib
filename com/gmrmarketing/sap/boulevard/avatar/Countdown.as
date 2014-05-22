/**
 * Countdown and white flash 
 */

package com.gmrmarketing.sap.boulevard.avatar
{
	import flash.display.*;	
	import flash.events.*;
	import com.greensock.TweenMax;
	import flash.utils.Timer;
	
	
	public class Countdown extends EventDispatcher
	{
		public static const WHITE_FLASH:String = "whiteFlashShowing";
		public static const FLASH_COMPLETE:String = "flashFadedOut";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var count:int;
		private var countTimer:Timer;
		
		
		
		public function Countdown()
		{
			clip = new mcCount();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{		
			count = 5;
			clip.numCount.theText.text = String(count);
			clip.alpha = 1;
			clip.theFlash.alpha = 0;
			countTimer = new Timer(900);
			countTimer.addEventListener(TimerEvent.TIMER, updateCount, false, 0, true);
			countTimer.start();
			
			//set bulbs to blue
			TweenMax.to(clip.bulb1, 0, { colorMatrixFilter: { saturation:1 }} );
			TweenMax.to(clip.bulb2, 0, { colorMatrixFilter: { saturation:1 }} );
			TweenMax.to(clip.bulb3, 0, { colorMatrixFilter: { saturation:1 }} );
			TweenMax.to(clip.bulb4, 0, { colorMatrixFilter: { saturation:1 }} );
			TweenMax.to(clip.bulb5, 0, { colorMatrixFilter: { saturation:1 }} );
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.x = -12; //NASCAR demo
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}			
		}
		
		
		private function updateCount(e:TimerEvent):void
		{
			count--;
			
			if (count == 4) {
				TweenMax.to(clip.bulb5, .25, { colorMatrixFilter: { saturation:0 }} );
			}
			if (count == 3) {
				TweenMax.to(clip.bulb4, .25, { colorMatrixFilter: { saturation:0 }} );
			}
			if (count == 2) {
				TweenMax.to(clip.bulb3, .25, { colorMatrixFilter: { saturation:0 }} );
			}
			if (count == 1) {
				TweenMax.to(clip.bulb2, .25, { colorMatrixFilter: { saturation:0 }} );
			}
			if (count == 0) {
				TweenMax.to(clip.bulb1, .25, { colorMatrixFilter: { saturation:0 }} );
			}
			
			clip.numCount.theText.text = String(count);
			
			if (count == 0) {				
				//clip.numCount.theText.text = "";
				countTimer.removeEventListener(TimerEvent.TIMER, updateCount);
				countTimer.stop();
				dispatchEvent(new Event(WHITE_FLASH));				
			}
		}
		
		
		public function doFlash():void
		{
			//clip.theFlash.alpha = 1;
			//TweenMax.to(clip.theFlash, .5, { alpha:0, onComplete:flashFaded } );
			TweenMax.delayedCall(.25, flashFaded);
		}
		
		
		private function flashFaded():void
		{
			dispatchEvent(new Event(FLASH_COMPLETE));
		}
		
	}
	
}