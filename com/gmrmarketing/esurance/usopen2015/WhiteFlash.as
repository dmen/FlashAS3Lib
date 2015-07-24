package com.gmrmarketing.esurance.usopen2015
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;	
	
	
	public class WhiteFlash extends EventDispatcher
	{
		public static const FLASH_COMPLETE:String = "flashComplete";
		
		private var clip:Sprite;
		private var myContainer:DisplayObjectContainer;
		
		
		public function WhiteFlash(w:int, h:int)
		{
			clip = new Sprite();
			clip.graphics.beginFill(0xFFFFFF, 1);
			clip.graphics.drawRect(0, 0, w, h);
			clip.graphics.endFill();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}			
			clip.alpha = 1;
			TweenMax.to(clip, .5, { alpha:0, onComplete:done } );
		}
		
		
		private function done():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			dispatchEvent(new Event(FLASH_COMPLETE));
		}
	}
	
}