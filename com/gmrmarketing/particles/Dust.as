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
		private const mult:Number = 1 / 500;
		
		
		public function Dust()
		{
			ang = 0;
			angInc = .005 + Math.random() * .02;
			alpha = 0;
			
			graphics.beginFill(0xFFFFFF, .05 + Math.random() * .1);
			
			xVel = .05 + Math.random() * .25;
			if (Math.random() < .5) {
				xVel *= -1;
			}
			yVel = .05 + Math.random() * .25;			
			
			if (Math.random() < .5) {
				graphics.drawCircle(0, 0, 1 + Math.random() * 2);
			}else {
				var s:Number = .5 + Math.random() * .3;
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
				x = 1030;
			}
			if (x > 1030) {
				x = 0;
			}
			if (y > 772) {
				y = 20;
			}
			
			alpha = y * mult > 1 ? 1 : y * mult;
		}
		
	}
	
}