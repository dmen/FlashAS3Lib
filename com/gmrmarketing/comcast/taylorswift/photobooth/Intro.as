package com.gmrmarketing.comcast.taylorswift.photobooth
{
	import com.greensock.TweenMax;
	import flash.display.*;
	import flash.events.*;
	
	
	public class Intro extends EventDispatcher
	{
		public static const COMPLETE:String = "introComplete";
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
			clip.addEventListener(Event.ENTER_FRAME, updateGlow);
			clip.addEventListener(MouseEvent.MOUSE_DOWN, touched);
		}
		
		
		public function hide():void
		{
			clip.removeEventListener(Event.ENTER_FRAME, updateGlow);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function touched(e:MouseEvent):void
		{
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, touched);
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function updateGlow(e:Event):void
		{
			TweenMax.to(clip.xfin, 0, { glowFilter: { color:0x33ccff, alpha:.2 + Math.random()*.8, blurX:5, blurY:5 } } );
			TweenMax.to(clip.year, 0, { glowFilter: { color:0xff9999, alpha:.2 + Math.random()*.8, blurX:5, blurY:5 } } );
		}
		
		
	}
	
}