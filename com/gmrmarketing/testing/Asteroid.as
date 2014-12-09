package com.gmrmarketing.testing
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	
	public class Asteroid extends Shape
	{
		private var myRadius:uint;
		private var xVel:Number;
		private var yVel:Number;
		private const BUFFER:uint = 35;
		
		public function Asteroid(radius:uint = 5)
		{
			myRadius = radius;
			xVel = .5 + Math.random() * 2;
			yVel = .5 + Math.random() * 2;
			if (Math.random() < .5) {
				xVel *= -1;
			}
			if (Math.random() < .5) {
				yVel *= -1;
			}
			draw();
			//addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function draw():void
		{
			var angleStep:Number = .5;
			var curAngle:Number = 0;
			
			var radiusVar:Number = Math.random() * 25;
			var xPos:Number = (myRadius + radiusVar) * Math.cos(curAngle);
			var yPos:Number = (myRadius + radiusVar) * Math.sin(curAngle);
			var initX = xPos;
			var initY = yPos;
			
			//var aTexture:BitmapData = new AsTexture(;
			
			//graphics.lineStyle(1, 0xFFFFFF, 1);
			//graphics.beginBitmapFill(new wcTex(171,166),null, true, true);
			graphics.beginFill(0x803a0d0, .3);
			graphics.moveTo(initX, initY);
			
			while (curAngle < Math.PI * 2)
			{
				xPos = (myRadius + radiusVar) * Math.cos(curAngle);
				yPos = (myRadius + radiusVar) * Math.sin(curAngle);
				if (Math.random() < .8) {
					radiusVar = Math.random() * 15;
				}
				graphics.lineTo(xPos, yPos);
				curAngle += angleStep;
			}
			graphics.lineTo(initX, initY);
			graphics.endFill();			
		}
		
		private function loop(e:Event)
		{
			x += xVel;
			y += yVel;
			if (x < 0 - BUFFER) { x = stage.stageWidth + BUFFER; }
			if (x > stage.stageWidth + BUFFER) { x = 0 - BUFFER; }
			if (y < 0 - BUFFER) { y = stage.stageHeight + BUFFER; }
			if (y > stage.stageHeight + BUFFER) { y = 0 - BUFFER;}
		}
		
	}
	
}