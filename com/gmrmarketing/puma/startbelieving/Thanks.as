package com.gmrmarketing.puma.startbelieving
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const THANKS_DONE:String = "thanksDone";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		public function Thanks()
		{
			clip = new mcThanks();
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
			TweenMax.to(clip, 1, { alpha:1, onComplete:thanksShowing } );
		}
		
		
		public function hide():void
		{			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		private function thanksShowing():void
		{
			var t:Timer = new Timer(5000, 1);
			t.addEventListener(TimerEvent.TIMER, closeThanks, false, 0, true);
			t.start();
		}
		
		
		private function closeThanks(e:TimerEvent):void
		{
			dispatchEvent(new Event(THANKS_DONE));
		}
	}
	
}