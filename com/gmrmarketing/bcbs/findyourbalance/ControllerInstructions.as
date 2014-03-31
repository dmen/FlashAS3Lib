package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.*;
	import flash.events.*;
	
	
	public class ControllerInstructions extends EventDispatcher
	{
		public static const READY:String = "readyPressed";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function ControllerInstructions()
		{
			clip = new mcInstructions();//lib
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
			clip.btnReady.addEventListener(MouseEvent.MOUSE_DOWN, readyPressed, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			clip.btnReady.removeEventListener(MouseEvent.MOUSE_DOWN, readyPressed);
		}
		
		
		private function readyPressed(e:MouseEvent):void
		{
			dispatchEvent(new Event(READY));
		}
	}
	
}