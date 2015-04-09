package com.gmrmarketing.miller.stc
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class TapToBegin extends EventDispatcher
	{	
		public static const COMPLETE:String = "complete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function TapToBegin()
		{
			clip = new mcBegin();
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
			myContainer.stage.addEventListener(MouseEvent.MOUSE_DOWN, begin);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function begin(e:MouseEvent):void
		{
			myContainer.stage.removeEventListener(MouseEvent.MOUSE_DOWN, begin);
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}