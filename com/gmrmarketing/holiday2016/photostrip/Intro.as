package com.gmrmarketing.holiday2016.photostrip
{
	import com.greensock.TweenMax;
	import flash.display.*;
	import flash.events.*;
	
	
	public class Intro extends EventDispatcher
	{
		public static const COMPLETE:String = "introComplete";
		public static const SHOWING:String = "introShowing";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Intro()
		{
			clip = new mcIntro();
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
			clip.addEventListener(MouseEvent.MOUSE_DOWN, touched);
			clip.alpha = 0;			
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function touched(e:MouseEvent):void
		{
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, touched);
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}