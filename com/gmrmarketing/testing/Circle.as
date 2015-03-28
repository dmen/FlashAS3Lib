package com.gmrmarketing.testing
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	public class Circle extends Sprite
	{		
		private var r:int;
		private var xVel:Number;
		private var yVel:Number;
		
		public function Circle(debug:Boolean = false)
		{
			r = Math.round(3 + (Math.random() * 5));
			var alph:Number = debug == true ? 1 : 0;
			graphics.lineStyle(1, 0x58595B, alph);
			graphics.drawCircle(0, 0, r);
			
			xVel = .5 + Math.random() * 2;
			yVel = .5 + Math.random() * 2;
			
			if (Math.random() < .5) {
				xVel *= -1;
			}
			if (Math.random() < .5) {
				yVel *= .5;
			}
			addEventListener(Event.ADDED_TO_STAGE, startMoving);
		}
		
		public function startMoving(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, startMoving);
			addEventListener(Event.ENTER_FRAME, update);
		}
		public function stop():void
		{
			removeEventListener(Event.ENTER_FRAME, update);
		}
		private function update(e:Event):void
		{
			x += xVel;
			y += yVel;
			
			if (x < 0 || x > stage.stageWidth) {
				xVel *= -1;
			}
			if (y < 0 || y > stage.stageHeight) {
				yVel *= -1;
			}
		}
		public function flip():void
		{
			xVel *= -1;
			yVel *= -1;
		}
		public function get radius():int
		{
			return r;
		}
	}
	
}