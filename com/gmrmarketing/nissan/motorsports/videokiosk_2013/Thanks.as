package com.gmrmarketing.nissan.motorsports.videokiosk_2013
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import flash.utils.Timer;
	
	
	public class Thanks extends EventDispatcher 
	{
		public static const SHOWING:String = "thanksShowing";
		public static const COMPLETE:String = "thanksComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var tim:Timer;
		
		
		public function Thanks()
		{
			clip = new mcThanks();
			tim = new Timer(30000, 1);
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
			clip.addEventListener(MouseEvent.MOUSE_DOWN, close, false, 0, true);
			tim.addEventListener(TimerEvent.TIMER, timerClose, false, 0, true);
			tim.start();
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		public function hide():void
		{
			tim.stop();
			tim.removeEventListener(TimerEvent.TIMER, timerClose);
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, close);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		private function close(e:MouseEvent):void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
		private function timerClose(e:TimerEvent):void
		{
			dispatchEvent(new Event(COMPLETE));
		}
	
	}
	
}