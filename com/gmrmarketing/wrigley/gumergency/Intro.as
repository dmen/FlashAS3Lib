package com.gmrmarketing.wrigley.gumergency
{
	import flash.display.*
	import flash.events.*;
	
	
	public class Intro extends EventDispatcher
	{
		public static const BEGIN:String = "beginAnalyzing";
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Intro()
		{
			clip = new mcIntro();
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
			container.stage.addEventListener(KeyboardEvent.KEY_DOWN, checkKey, false, 0, true);
		}
		
		
		public function hide():void
		{
			container.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkKey);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function checkKey(e:KeyboardEvent):void
		{			
			if (Keys.KEYS.indexOf(e.charCode) != -1) {
				dispatchEvent(new Event(BEGIN));
			}
		}
	}
	
}