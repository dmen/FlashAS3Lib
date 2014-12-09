package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;
	
	
	public class CountDown extends EventDispatcher
	{
		public static const COMPLETE:String = "countComplete";
		
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		private var timer:Timer;
		private var theCount:int;
		
		
		public function CountDown():void
		{
			timer = new Timer(1000);
			clip = new mcCount();//lib
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * shows the 3-2-1 counter
		 * covers the middle 'pose for pic' button
		 */
		public function show():void
		{
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
			}
			clip.x = 704;
			clip.y = 1003;			
			
			clip.num1.gotoAndStop(1);
			clip.num2.gotoAndStop(1);
			clip.num3.gotoAndStop(2);//show white
			
			theCount = 3;
			timer.addEventListener(TimerEvent.TIMER, decCounter, false, 0, true);
			timer.start();//calls decCounter
		}
		
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
		}
		
		
		private function decCounter(e:TimerEvent):void
		{
			theCount--;
			clip.num3.gotoAndStop(1); //blue
			
			if (theCount == 2) {
				clip.num2.gotoAndStop(2); //white
			}else if (theCount == 1) {
				clip.num2.gotoAndStop(1); //blue;
				clip.num1.gotoAndStop(2); //white
			}else if (theCount == 0) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, decCounter);
				dispatchEvent(new Event(COMPLETE));
			}
		}
		
	}
	
}