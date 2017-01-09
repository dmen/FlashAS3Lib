/**
 * A single particle
 * Add a bunch of these to a container
 */
package com.gmrmarketing.particles
{
	import com.desuade.thirdparty.zip.CRC32;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;
	
	public class Snow extends Sprite
	{
		private var xVel:Number;
		private var yVel:Number;
		private var ang:Number;
		private var angInc:Number;
		private const mult:Number = 1 / 500;
		//screen extents
		private var leftSide:int;
		private var topSide:int;
		private var rightSide:int;
		private var bottomSide:int;
		private var frameTimer:Timer;
		
		public function Snow(particle:Bitmap, alph:Number, scale:Number, xV:Number, yV:Number, angleInc:Number)
		{
			ang = 0;
			angInc = angleInc;
			alpha = alph;			
			xVel = xV;
			yVel = yV;
			scaleX = scaleY = scale;
			
			setBounds();
			
			particle.cacheAsBitmap = true;
			
			addChild(particle);		
			//frameTimer = new Timer(1000 / 60);
			//frameTimer.addEventListener(TimerEvent.TIMER, update);
			//frameTimer.start();
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		public function get theAlpha():Number
		{
			return alpha;
		}
		
		
		public function setBounds(l:int = -30, t:int = -30, r:int = 1950, b:int = 1110):void
		{
			leftSide = l;
			topSide = t;
			rightSide = r;
			bottomSide = b;
		}		
		
		
		private function update(e:Event):void
		{
			ang += angInc;
			if (ang > 6.28) {
				ang = 0;
			}
			
			x += xVel + Math.cos(ang);
			y += yVel + Math.sin(ang);
			
			if (x < leftSide) {
				x = rightSide;
			}
			if (x > rightSide) {
				x = leftSide;
			}
			if (y < topSide){
				y = bottomSide;
			}
			if (y > bottomSide) {
				y = topSide;
			}		
		}
		
	}
	
}