package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;	
	
	
	public class WhiteFlash extends EventDispatcher
	{
		public static const FLASH_COMPLETE:String = "flashComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function WhiteFlash()
		{
			clip = new mcFlash();			
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
			clip.alpha = 1;
			TweenMax.to(clip, .5, { alpha:0, onComplete:done } );
		}
		
		
		private function done():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			dispatchEvent(new Event(FLASH_COMPLETE));
		}
	}
	
}