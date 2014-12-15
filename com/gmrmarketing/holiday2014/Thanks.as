package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const COMPLETE:String = "thanksComplete";
		
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		
		
		
		public function Thanks():void
		{
			clip = new mcThanks();//lib
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
			}
			
			clip.x = 1920;
			
			TweenMax.to(clip, .5, { x: 0, delay:.5, ease:Back.easeOut } );
			TweenMax.to(clip, .5, { x: -1920, delay:6, ease:Back.easeIn, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			dispatchEvent(new Event(COMPLETE));
			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
		}
	}
	
}