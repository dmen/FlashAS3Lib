package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	
	public class Spot extends Sprite
	{
		private var bit:Bitmap;
		private var xVel:Number;
		private var yVel:Number;
		private var scaleVel:Number;
		private var startAlpha:Number;
		private var alphaVel:Number;
		private var endTime:Number;
		private var lifeTime:Number;
		
		/**
		 * 
		 * @param	pClip bitmapData of which particle to draw
		 * @param	vel Point with x,y velocity deltas
		 * @param	life milliseconds
		 */
		public function Spot(pClip:BitmapData)
		{	
			lifeTime = 6000 + Math.random() * 7000;
			endTime = new Date().valueOf() + lifeTime;
			
			bit = new Bitmap(pClip);
			bit.x = -bit.width * .5;//center
			bit.y = -bit.height * .5;
			
			addChild(bit);//add to this sprite
			
			startAlpha = .1 + Math.random() * .5;
			alphaVel = startAlpha / lifeTime;
			alpha = startAlpha;
			
			scaleVel = .0025 + Math.random() * .025;			
			
			bit.cacheAsBitmap = true;
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function update(e:Event):void
		{
			var millsRemaining:Number = endTime - new Date().valueOf();//5,4,3,2,1
			alpha = startAlpha - ((lifeTime - millsRemaining) * alphaVel);		
			
			scaleX += scaleVel;
			scaleY += scaleVel;	
			
			//scaleVel *= 1
			
			if (alpha <= 0) {
				removeEventListener(Event.ENTER_FRAME, update);
				removeChild(bit);
				parent.removeChild(this);
			}
		}
	}
	
}