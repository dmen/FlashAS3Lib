package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import com.greensock.TweenMax;
	
	public class Particle2 extends Sprite
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
		public function Particle2(pClip:BitmapData)
		{	
			lifeTime = 6000 + Math.random() * 7000;
			endTime = new Date().valueOf() + lifeTime;
			
			bit = new Bitmap(pClip);
			bit.x = -bit.width * .5;//center
			bit.y = -bit.height * .5;
			
			addChild(bit);//add to this sprite
			
			startAlpha = .3 + Math.random() * .5;
			alphaVel = startAlpha / lifeTime;
			alpha = startAlpha;
			
			scaleVel = .005 + Math.random() * .005;			
			
			bit.cacheAsBitmap = true;
			
			alpha = 0;
			TweenMax.to(this, .25, { alpha:startAlpha, onComplete:startUpdating } );
		}
		
		
		private function startUpdating():void
		{
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function update(e:Event):void
		{
			var millsRemaining:Number = endTime - new Date().valueOf();//5,4,3,2,1
			alpha = startAlpha - ((lifeTime - millsRemaining) * alphaVel);		
			
			scaleX += scaleVel;
			scaleY += scaleVel;	
			
			scaleVel *= .999;
			
			if (alpha <= 0) {
				removeEventListener(Event.ENTER_FRAME, update);
				removeChild(bit);
				parent.removeChild(this);
			}
		}
	}
	
}