package com.gmrmarketing.rbc.etransfer
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	public class Saved extends EventDispatcher
	{
		public static const SHOWING:String = "savedShowing";
		public static const PRESSED:String = "btnPressed";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		public function Saved()
		{
			clip = new mcSaved();
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
			clip.btn.addEventListener(MouseEvent.MOUSE_DOWN, btnPressed, false, 0, true);
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:savedShowing } );
		}
		
		private function savedShowing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		public function hide():void
		{
			clip.btn.removeEventListener(MouseEvent.MOUSE_DOWN, btnPressed);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		private function btnPressed(e:MouseEvent):void
		{
			dispatchEvent(new Event(PRESSED));
		}
	}
	
}