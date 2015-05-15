package com.gmrmarketing.empirestate.ilny
{
	import flash.events.*;
	import flash.display.*;
	
	
	public class Intro extends EventDispatcher
	{
		public static const COMPLETE:String = "introComplete";
		private var myClip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var imageContainer:Sprite;
		
		
		public function Intro()
		{
			myClip = new mcIntro();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		public function get clip():MovieClip
		{
			return myClip;
		}
		
		public function show():void
		{
			if (!myContainer.contains(myClip)) {
				myContainer.addChild(myClip);
			}
			
			myClip.addEventListener(MouseEvent.MOUSE_DOWN, introClicked);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(myClip)) {
				myContainer.removeChild(myClip);
			}
		}
		
		
		private function introClicked(e:MouseEvent):void
		{
			myClip.removeEventListener(MouseEvent.MOUSE_DOWN, introClicked);
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}