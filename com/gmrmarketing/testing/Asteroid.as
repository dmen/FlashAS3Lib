package com.gmrmarketing.testing
{
	import flash.display.*;
	import flash.events.*;
	
	public class Asteroid extends Sprite
	{
		private var myRadius:int;
		private var xVel:Number;
		private var yVel:Number;
		private const BUFFER:int = 35;
		private var stageWidth:int;
		private var stageHeight:int;
		
		
		public function Asteroid(radius:int = 10)
		{
			myRadius = radius;
			xVel = .25 + Math.random() * .5;
			yVel = .25 + Math.random() * .5;
			if (Math.random() < .5) {
				xVel *= -1;
			}
			if (Math.random() < .5) {
				yVel *= -1;
			}
			draw();
			addEventListener(Event.ENTER_FRAME, loop);
			addEventListener(Event.ADDED_TO_STAGE, setWidthHeight);
		}
		
		
		private function draw():void
		{
			var angleStep:Number = .5;
			var curAngle:Number = 0;
			
			var radiusVar:Number = Math.random() * 5;
			var xPos:Number = (myRadius + radiusVar) * Math.cos(curAngle);
			var yPos:Number = (myRadius + radiusVar) * Math.sin(curAngle);
			var initX = xPos;
			var initY = yPos;
			
			//var aTexture:BitmapData = new AsTexture(;
			
			graphics.lineStyle(1, 0xFFFFFF, 1);
			//graphics.beginBitmapFill(new wcTex(171,166),null, true, true);
			//graphics.beginFill(0x803a0d0, .3);
			graphics.moveTo(initX, initY);
			
			while (curAngle < 6.28)
			{
				xPos = (myRadius + radiusVar) * Math.cos(curAngle);
				yPos = (myRadius + radiusVar) * Math.sin(curAngle);
				if (Math.random() < .8) {
					radiusVar = Math.random() * 5;
				}
				graphics.lineTo(xPos, yPos);
				curAngle += angleStep;
			}
			graphics.lineTo(initX, initY);
			
			//graphics.endFill();			
		}
		private function setWidthHeight(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, setWidthHeight);
			stageWidth = stage.stageWidth;
			stageHeight = stage.stageHeight;
		}
		
		private function loop(e:Event)
		{
			x += xVel;
			y += yVel;
			if (x < 0 - BUFFER) { x = stageWidth + BUFFER; }
			if (x > stageWidth + BUFFER) { x = 0 - BUFFER; }
			if (y < 0 - BUFFER) { y = stageHeight + BUFFER; }
			if (y > stageHeight + BUFFER) { y = 0 - BUFFER;}
		}
		
	}
	
}