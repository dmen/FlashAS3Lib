package com.gmrmarketing.particles
{	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.utils.getTimer;
	
	public class Spark2 extends Sprite
	{
		private var velocity:Number;
		
		private var initTime:Number;
		private var elapsed:Number;
		
		private var launchAngle:Number;
		
		private var gl:GlowFilter;
		
		private var negator:int;
		
		private var alph:Number;
		
		
		public function Spark2(initX:int, initY:int)
		{
			launchAngle = Math.random() * 6.28;	
			var sl:Number = 1 + Math.random() * 4; //spark length
			
			graphics.lineStyle(2, 0xffffff, 1, false);
			graphics.moveTo(0, 0);
			graphics.lineTo(sl * Math.cos(launchAngle), sl * Math.sin(launchAngle));
			
			gl = new GlowFilter(0xffcc00, 1, 5, 5, 6, 2, false, false);
			
			x = initX;
			y = initY;
			
			negator = 1;
			if (Math.random() < .5) {
				negator = -1;
			}
			
			alph = Math.random() * .1;
			
			velocity = 4 + Math.random() * 5;
			
			filters = [gl];
			
			initTime = getTimer();
			
					
			
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		
		
		private function update(e:Event):void
		{
			elapsed = (getTimer() - initTime) / 1000;
			
			//x = velocity * time * cosine angle
			//y = velocity * time * sine angle - 1/2 * graivty * time squared
			x += ((velocity * elapsed * Math.cos(launchAngle)) * negator) * 1.6;
			y -= ((velocity * elapsed * Math.sin(launchAngle)) - (.5 * 9.81 * Math.pow(elapsed, 2)) * 1.2);
			
			alpha -= .04;
			
			if (y > stage.stageHeight || alpha <= 0) {
				removeEventListener(Event.ENTER_FRAME, update);
				parent.removeChild(this);
				filters = [];
			}
		}
		
		
	}
	
}