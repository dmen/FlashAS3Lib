package com.gmrmarketing.sap.boulevard.avatar
{
	import flash.display.*;
	import flash.events.*;	
	
	public class Rfid_touch extends EventDispatcher
	{
		public static const CLICKED:String = "screenClicked";
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Rfid_touch()
		{
			clip = new mcRfid_touch();
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
			clip.addEventListener(MouseEvent.MOUSE_DOWN, screenClicked, false, 0, true);
		}
		
		
		public function hide():void
		{
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, screenClicked);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function screenClicked(e:MouseEvent):void
		{			
			dispatchEvent(new Event(CLICKED));
		}
		
	}
	
}