package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	
	
	public class ControllerInGame 
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		public function ControllerInGame()
		{
			clip = new mcInGame(); //lib
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
		}
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
	}
	
}