package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	
	public class Particle extends Sprite
	{
		private var bit:Bitmap;
		private var xVel:Number;
		private var yVel:Number;
		private var scaleVel:Number;
		private var alphaVel:Number;
		private var curAngle:Number;
		private var endTime:Number;
		private var lifeTime:Number;
		
		/**
		 * 
		 * @param	pClip bitmapData of which particle to draw
		 * @param	vel Point with x,y velocity deltas
		 * @param	life milliseconds
		 */
		public function Particle(pClip:BitmapData, vel:Point, life:Number)
		{	
			lifeTime = life;
			endTime = new Date().valueOf() + lifeTime;
			
			bit = new Bitmap(pClip);
			bit.x = -bit.width * .5;//center
			bit.y = -bit.height * .5;
			
			addChild(bit);//add to this sprite
			
			alpha = 1;
			
			xVel = vel.x;
			yVel = vel.y;
			
			if (Math.random() < .5) {
				xVel *= -1;
			}
			
			//if (Math.random() < .5) {
				//yVel *= -1;
			//}
			
			scaleVel = .005 + Math.random() * .005;
			alphaVel = .9999999999;
			curAngle = 0;
			
			cacheAsBitmap = true;
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function update(e:Event):void
		{
			var b:Number = (endTime - new Date().valueOf()) / lifeTime;
			
			alpha = b;
			
			x += xVel + Math.cos(curAngle);
			y += yVel;// + Math.sin(curAngle);
			
			curAngle += .025;
			
			scaleX += scaleVel;
			scaleY += scaleVel;
			
			if (b <= 0) {
				removeEventListener(Event.ENTER_FRAME, update);
				removeChild(bit);
				parent.removeChild(this);
			}
		}
	}
	
}