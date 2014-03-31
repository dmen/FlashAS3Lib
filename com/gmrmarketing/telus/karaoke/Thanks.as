package com.gmrmarketing.telus.karaoke
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const THANKS_SHOWING:String = "thanksShowing";
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
			clip.btn.addEventListener(MouseEvent.MOUSE_DOWN, closeThanks, false, 0, true);
			TweenMax.to(clip, 1, { alpha:1, onComplete:thanksShowing } );
		}
		
		
		public function hide():void
		{
			clip.btn.removeEventListener(MouseEvent.MOUSE_DOWN, closeThanks);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		private function thanksShowing():void
		{
			dispatchEvent(new Event(THANKS_SHOWING));
		}
		
		
		private function closeThanks(e:MouseEvent):void
		{
			dispatchEvent(new Event(THANKS_DONE));
		}
	}
	
}