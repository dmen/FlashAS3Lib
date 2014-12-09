package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import flash.events.*;
	
	
	public class RetakeContinue extends EventDispatcher
	{
		public static const RETAKE:String = "retakePressed";
		public static const CONTINUE:String = "continuePressed";
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		
		
		public function RetakeContinue():void
		{
			clip = new mcRetake();
			clip.x = 637;
			clip.y = 980;
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
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, doRetake, false, 0, true);
			clip.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, doContinue, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, doRetake);
			clip.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, doContinue);
		}
		
		
		private function doRetake(e:MouseEvent):void
		{
			dispatchEvent(new Event(RETAKE));
		}
		
		
		private function doContinue(e:MouseEvent):void
		{
			dispatchEvent(new Event(CONTINUE));
		}
	}
	
}