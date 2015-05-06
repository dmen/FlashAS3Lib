package com.gmrmarketing.particles
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Dust extends Sprite
	{
		private var xVel:Number;
		private var yVel:Number;
		private var ang:Number;
		private var angInc:Number;
		
		public function Dust()
		{
			ang = 0;
			angInc = .01 + Math.random() * .02;
			
			graphics.beginFill(0xFFFFFF, .05 + Math.random() * .1);
			
			xVel = .1 + Math.random() * .5;
			if (Math.random() < .5) {
				xVel *= -1;
			}
			yVel = .1 + Math.random() * .5;			
			
			if (Math.random() < .5) {
				graphics.drawCircle(0, 0, 1 + Math.random() * 2);
			}else {
				var s:Number = .1 + Math.random() * .3;
				graphics.drawRect(0, 0, s, s);
			}
			graphics.endFill();
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function update(e:Event):void
		{
			ang += angInc;
			if (ang > 6.28) {
				ang = 0;
			}
			
			x += xVel + Math.cos(ang);
			y += yVel + Math.sin(ang);
			
			if (x < 0) {
				x = 1920;
			}
			if (x > 1920) {
				x = 0;
			}
			if (y > 1080) {
				y = 0;
			}
		}
		
	}
	
}