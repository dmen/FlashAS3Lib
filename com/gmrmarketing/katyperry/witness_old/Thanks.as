package com.gmrmarketing.katyperry.witness
{
	import flash.events.*;
	import flash.display.*;
	import flash.utils.Timer;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const SHOWING:String = "thanksShowing";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Thanks()
		{
			clip = new thanks();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);				
			}
			
			var a:Timer = new Timer(500, 1);
			a.addEventListener(TimerEvent.TIMER, itsShowing, false, 0, true);
			a.start();
		}
		
		
		private function itsShowing(e:TimerEvent):void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
		}		
		
	}
	
}