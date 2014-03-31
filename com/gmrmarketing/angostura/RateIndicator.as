package com.gmrmarketing.angostura
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getTimer;
	import com.gmrmarketing.angostura.IBottle;
	import flash.display.DisplayObjectContainer;
	
	
	public class RateIndicator extends MovieClip
	{
		private var container:DisplayObjectContainer;
		private var bottle:IBottle;
		private var startTime:int;
		
		public function RateIndicator($container:DisplayObjectContainer)
		{
			container = $container;
		}		
		
		
		public function indicate($bottle:IBottle):void
		{
			if (!container.contains(this)) {
				container.addChild(this);
			}
			
			x = 20;
			y = 20;
			
			startTime = getTimer();
			bottle = $bottle;
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		
		public function stopIndicating():void
		{
			removeEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function update(e:Event):void
		{
			var elapsed:int = getTimer() - startTime;
			var poured:Number = (elapsed / 1000) * bottle.getFillRate();
			theText.text = String(poured);
		}
	}
	
}