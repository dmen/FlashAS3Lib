package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	
	
	public class Countdown extends EventDispatcher
	{
		public static const COUNT_COMPLETE:String = "countComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var secTimer:Timer;
		private var currCount:int;
		
		
		public function Countdown()
		{
			clip = new mcCountdown();
			secTimer = new Timer(1000, 1);
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.alpha = 0;
			clip.numb.theText.text = "5";
			currCount = 5;
			clip.x = 1143;
			clip.y = 303;
			clip.scaleX = clip.scaleY = .3;
			TweenMax.to(clip, .75, { alpha:.8, scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:startCountdown } );
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			secTimer.reset();
		}
		
		
		private function startCountdown():void
		{
			secTimer.addEventListener(TimerEvent.TIMER, nextCount, false, 0, true);
			secTimer.start();
		}
		
		
		private function nextCount(e:TimerEvent):void
		{
			currCount--;
			clip.numb.theText.text = String(currCount);
			if (currCount == 0) {
				dispatchEvent(new Event(COUNT_COMPLETE));
			}else {
				secTimer.reset();
				secTimer.start();//call nextCount() until currCount = 0
			}
			
		}
		
	}
	
}