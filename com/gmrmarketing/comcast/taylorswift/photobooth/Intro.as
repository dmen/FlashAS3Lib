package com.gmrmarketing.comcast.taylorswift.photobooth
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
			clip.addEventListener(Event.ENTER_FRAME, updateGlow);
			clip.addEventListener(MouseEvent.MOUSE_DOWN, touched);
			/*
			clip.circ.alpha = 1;
			clip.circ.scaleX = clip.circ.scaleY = .5;
			*/
			clip.alpha = 0;			
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
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
			/*
			clip.circ.scaleX += .05;
			clip.circ.scaleY += .05;
			clip.circ.alpha -= .03;
			
			if (clip.circ.alpha <= 0) {
				clip.circ.alpha = 1;
				clip.circ.scaleX = clip.circ.scaleY = .5;
			}
			*/
			TweenMax.to(clip.xfin, 0, { glowFilter: { color:0x33ccff, alpha:.2 + Math.random()*.8, blurX:5, blurY:5 } } );
			TweenMax.to(clip.year, 0, { glowFilter: { color:0xff9999, alpha:.2 + Math.random()*.8, blurX:5, blurY:5 } } );
		}
		
		
	}
	
}