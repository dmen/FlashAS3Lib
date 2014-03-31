package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	public class ControllerThanks extends EventDispatcher
	{
		public static const DONE:String = "thanksComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function ControllerThanks()
		{
			clip = new mcThanks();//lib
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
			TweenMax.to(clip, 1, { alpha:1, onComplete:done } );
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function done():void
		{
			dispatchEvent(new Event(DONE));
		}
	}
	
}