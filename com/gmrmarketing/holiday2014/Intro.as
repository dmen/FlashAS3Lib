package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	public class Intro extends EventDispatcher
	{
		public static const COMPLETE:String = "introComplete";
		
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		
		
		public function Intro():void
		{
			clip = new mcIntro();//lib
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
			clip.x = 1920;
			TweenMax.to(clip, .5, { x: 0, delay:.5, ease:Back.easeOut } );
			clip.addEventListener(MouseEvent.MOUSE_DOWN, complete, false, 0, true);
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip, .5, { x: -1920, ease:Back.easeIn, onComplete:kill } );
		}
		
		
		private function kill():void
		{			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
		}
		
		
		private function complete(e:MouseEvent):void
		{
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, complete);
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}