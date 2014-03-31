package com.gmrmarketing.holiday2012
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.events.EventDispatcher;	
	
	public class Thanks extends EventDispatcher
	{
		public static const DONE:String = "DONE_SHOWING";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Thanks()
		{
			clip = new mc_thanks();
			clip.x = 619;
			clip.y = 354;
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
			TweenMax.to(clip, 1, { alpha:1 } );
			TweenMax.to(clip, 1, { alpha:0, delay:4, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			dispatchEvent(new Event(DONE));
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
	}
	
}