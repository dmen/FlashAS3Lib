package com.gmrmarketing.testing
{
	import flash.display.*;
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	public class WaterShape extends Sprite
	{		
		private var myColor:Number;
		
		
		public function WaterShape(bmd:BitmapData, minR:int = 2, maxR:int = 130, steps:int = 10, col:Number = 0x803a0d0)
		{			
			var r:Number = minR;
			var alphDelta:Number = 1 / steps;
			var delta:Number = (maxR - minR) / steps;
			myColor = col;
			
			var m:Matrix = new Matrix();
			m.translate(1920 * Math.random(), 1080 * Math.random());
			
			for (var i:int = 0; i < steps; i++) {
				var s:Shape = draw(r);				
				bmd.draw(s, m,  null, null, null, true);				
				r += delta;
			}
		}		
		
		
		
		
		private function draw(r:Number, alph:Number = .3):Shape
		{			
			var angleStep:Number = .5;
			var curAngle:Number = 0;
			
			var sh:Shape = new Shape();
			
			var radiusVar:Number = Math.random() * 25;
			var xPos:Number = (r + radiusVar) * Math.cos(curAngle);
			var yPos:Number = (r + radiusVar) * Math.sin(curAngle);
			var initX = xPos;
			var initY = yPos;			
			
			//graphics.lineStyle(1, 0xFFFFFF, 1);
			//graphics.beginBitmapFill(new wcTex(171,166),null, true, true);
			sh.graphics.beginFill(myColor, alph);
			sh.graphics.moveTo(initX, initY);
			
			while (curAngle < Math.PI * 2)
			{
				xPos = (r + radiusVar) * Math.cos(curAngle);
				yPos = (r + radiusVar) * Math.sin(curAngle);
				if (Math.random() < .8) {
					radiusVar = Math.random() * 15;
				}
				sh.graphics.lineTo(xPos, yPos);
				curAngle += angleStep;
			}
			sh.graphics.lineTo(initX, initY);
			sh.graphics.endFill();
			return sh;
		}
		
	}
	
}