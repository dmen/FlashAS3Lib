package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import flash.events.*;
	
	
	public class RetakeEmail extends EventDispatcher
	{
		public static const RETAKE:String = "retakePressed";
		public static const CANCEL:String = "cancelPressed";
		public static const EMAIL:String = "emailPressed";
		
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		
		
		public function RetakeEmail():void
		{
			clip = new mcRetakeEmail();
			clip.x = 0;
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
			clip.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, doCancel, false, 0, true);
			clip.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, doEmail, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, doRetake);
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, doCancel);
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, doEmail);
		}
		
		
		private function doRetake(e:MouseEvent):void
		{
			dispatchEvent(new Event(RETAKE));
		}
		
		
		private function doCancel(e:MouseEvent):void
		{
			dispatchEvent(new Event(CANCEL));
		}
		
		
		private function doEmail(e:MouseEvent):void
		{
			dispatchEvent(new Event(EMAIL));
		}
	}
	
}