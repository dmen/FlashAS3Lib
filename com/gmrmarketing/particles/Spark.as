package com.gmrmarketing.particles
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.utils.getTimer;
	
	public class Spark extends MovieClip
	{
		private var velocity:Number;
		
		private var initTime:Number;
		private var elapsed:Number;
		
		private var launchAngle:Number;
		
		private var gl:GlowFilter;
		
		private var negator:int;
		
		private var alph:Number;
		
		
		public function Spark(initX:int, initY:int, deltaX:int)
		{
			//gl = new GlowFilter(0xff9900, 1, 6, 6, 9, 2, false, false);
			
			x = initX;
			y = initY;
			
			scaleX = scaleY = .5 + Math.random();
			
			velocity = deltaX / 5;
			
			//filters = [gl];
			
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		
		
		private function update(e:Event):void
		{			
			x += velocity;
			y += 5;
			
			alpha -= .07;
			
			if (alpha <= 0) {
				removeEventListener(Event.ENTER_FRAME, update);
				parent.removeChild(this);
				filters = [];
			}
		}
		
		
	}
	
}