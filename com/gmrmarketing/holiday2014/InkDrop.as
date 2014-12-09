package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import flash.events.*;
	
	public class InkDrop extends Sprite
	{
		private var bit:Bitmap;
		private var xVel:Number;
		private var yVel:Number;
		private var scaleVel:Number;
		private var alphaVel:Number;
		private var curAngle:Number;
		
		
		public function InkDrop(dropClip:BitmapData)
		{
			bit = new Bitmap(dropClip);
			bit.x = -bit.width * .5;//center
			bit.y = -bit.height * .5;
			
			addChild(bit);//add to this sprite
			
			alpha = .4 + Math.random() * .5;
			xVel = .03 + Math.random() * .5;
			yVel = -.12 - Math.random() * .5;
			if (Math.random() < .5) {
				xVel *= -1;
			}
			//if (Math.random() < .5) {
				//yVel *= -1;
			//}
			scaleVel = .005 + Math.random() * .015;
			alphaVel = .9999999999;
			curAngle = 0;
			
			cacheAsBitmap = true;
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function update(e:Event):void
		{
			alpha *= alphaVel;
			x += xVel + Math.cos(curAngle);
			y += yVel;// + Math.sin(curAngle);
			curAngle += .025;
			
			scaleX += scaleVel;
			scaleY += scaleVel;
			
			if (alpha <= 0) {
				removeEventListener(Event.ENTER_FRAME, update);
				removeChild(bit);
				parent.removeChild(this);
			}
		}
	}
	
}