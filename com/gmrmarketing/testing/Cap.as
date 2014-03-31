package com.gmrmarketing.testing
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Cap extends MovieClip
	{
		private const FRICTION:Number = .94;
		private const MIN_MOTION:Number = .01;
		
		public static const CAP_MOVED:String = "capClipMoved";
		public var vx:Number = 0;
		public var vy:Number = 0;
		
		public function Cap()
		{			
			x = 380;
			y = 970;
		}
		
		private function update(e:Event):void
		{
			x += vx;
			y += vy;
			
			vx *= FRICTION;
			vy *= FRICTION;
			
			if (Math.abs(vx) < MIN_MOTION) { vx = 0; }
			if (Math.abs(vy) < MIN_MOTION) { vy = 0; }
			
			dispatchEvent(new Event(CAP_MOVED));
		}
		
		public function stopCap():void
		{
			vx = vy = 0;
			removeEventListener(Event.ENTER_FRAME, update);	
		}
		
		public function moveCap():void
		{
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);	
		}
		
	}
	
}