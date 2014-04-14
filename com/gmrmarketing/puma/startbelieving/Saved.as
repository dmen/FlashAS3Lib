package com.gmrmarketing.telus.karaoke
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	
	
	public class Saved extends EventDispatcher
	{
		public static const SAVED_SHOWING:String = "savedShowing";
		public static const SAVED_DONE:String = "savedDone";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		public function Saved()
		{
			clip = new mcSaved();
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
			clip.btn.addEventListener(MouseEvent.MOUSE_DOWN, closeSaved, false, 0, true);
			TweenMax.to(clip, 1, { alpha:1, onComplete:savedShowing } );
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		private function savedShowing():void
		{
			dispatchEvent(new Event(SAVED_SHOWING));
		}
		
		
		private function closeSaved(e:MouseEvent):void
		{
			dispatchEvent(new Event(SAVED_DONE));
		}
	}
	
}