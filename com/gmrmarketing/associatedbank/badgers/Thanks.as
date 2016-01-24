package com.gmrmarketing.associatedbank.badgers
{
	import flash.events.*;
	import flash.display.*;
	
	public class Thanks extends EventDispatcher
	{
		public static const COMPLETE:String = "thanksComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		public function Thanks()
		{
			clip = new mcThanks();
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
			
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextPressed, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextPressed);
		}
		
		
		private function nextPressed(e:MouseEvent):void
		{
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextPressed);
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}