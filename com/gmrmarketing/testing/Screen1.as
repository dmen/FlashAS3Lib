package com.gmrmarketing.testing
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	
	public class Screen1 extends EventDispatcher
	{
		public static const SHOWING:String = "thisIsShowign";
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		public function Screen1()
		{
			clip = new gg();
		}
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		public function show()
		{
			container.addChild(clip);
			TweenMax.to(clip.pete, 2, { x:"+200" } );
			dispatchEvent(new Event(SHOWING));
		}
		
	}
	
}