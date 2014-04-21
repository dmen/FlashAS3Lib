package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class Countdown extends EventDispatcher
	{
		public static const COMPLETE:String = "countFinished";
		public static const START:String = "numberStarted";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Countdown()
		{
			clip = new mcCountdown();
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
			clip.n3.alpha = 1;
			clip.n2.alpha = 1;
			clip.n1.alpha = 1;
			
			dispStart();
			
			TweenMax.to(clip.n3, 1, { alpha:0 } );
			TweenMax.to(clip.n2, 1, { alpha:0, delay:1, onStart:dispStart } );
			TweenMax.to(clip.n1, 1, { alpha:0, delay:2, onStart:dispStart, onComplete:countComplete } );
		}
		
		private function dispStart():void
		{
			dispatchEvent(new Event(START));
		}
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function countComplete():void
		{
			dispatchEvent(new Event(COMPLETE));
		}		
		
	}
	
}