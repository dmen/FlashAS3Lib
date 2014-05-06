package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	public class Thanks extends EventDispatcher
	{
		public static const SHOWING:String = "thanksShowing";
		public static const DONE:String = "thanksComplete";
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Thanks()
		{
			clip = new mcThanks();
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
			clip.btnDone.addEventListener(MouseEvent.MOUSE_DOWN, done, false, 0, true);
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		public function hide():void
		{
			clip.btnDone.removeEventListener(MouseEvent.MOUSE_DOWN, done);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		private function done(e:MouseEvent):void
		{
			clip.btnDone.removeEventListener(MouseEvent.MOUSE_DOWN, done);
			dispatchEvent(new Event(DONE));
		}
		
	}
	
}