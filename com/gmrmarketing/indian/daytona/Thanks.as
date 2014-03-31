package com.gmrmarketing.indian.daytona
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import flash.utils.Timer;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const DONE:String = "thanksComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Thanks()
		{
			clip = new thanks();
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
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:startRemove } );
		}
		
		
		private function startRemove():void
		{
			var a:Timer = new Timer(5000, 1);
			a.addEventListener(TimerEvent.TIMER, remove, false, 0, true);
			a.start();
		}
		
		
		private function remove(e:TimerEvent):void
		{
			dispatchEvent(new Event(DONE));
		}
		
		
		public function kill():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
	}
	
}