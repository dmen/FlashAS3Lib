package com.gmrmarketing.comcast.nascar.sanshelmet
{
	import flash.display.*;
	import com.greensock.TweenMax;
	import flash.events.*;
	

	public class Thanks extends EventDispatcher
	{
		public static const SHOWING:String = "showing";
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
			clip.alpha = 0;
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		public function hide():void
		{	
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
	}
	
}