/**
 * A single particle
 * Add a bunch of these to a container
 */
package com.gmrmarketing.particles
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	
	public class Snow extends Sprite
	{
		private var xVel:Number;
		private var yVel:Number;
		private var ang:Number;
		private var angInc:Number;
		private const mult:Number = 1 / 500;
		private var spin:Number;
		
		
		public function Snow()
		{
			ang = 0;
			spin = .1 + Math.random() * .5;
			angInc = .005 + Math.random() * .02;
			alpha = .05 + Math.random() * .18;
			
			xVel = .05 + Math.random() * .25;
			if (Math.random() < .5) {
				xVel *= -1;
			}
			yVel = .25 + Math.random() * .25;
			
			var b:Bitmap;
			/*
			var r:Number = Math.random();
			if (r < .2) {
				b = new Bitmap( new light1());
			}else if (r < .4) {
				b = new Bitmap( new light2());
			}else if (r < .6) {
				b = new Bitmap( new light3());
			}else if (r < .8) {
				b = new Bitmap( new light4());
			}else {
				b = new Bitmap( new light5());
			}*/
			/*
			if(Math.random() < .5){
				b = new Bitmap( new light4());
			}else {
				b = new Bitmap( new light5());
			}
			*/
			b = new Bitmap( new light5());
			addChild(b);
			b.x = -25;
			b.y = -25;
			
			scaleX = scaleY = .3 + Math.random() * .7;			
			
			var fa:Number = 8 * (Math.random() + .3);
			//filters = [new BlurFilter(fa, fa, 2)];
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		public function get theAlpha():Number
		{
			return alpha;
		}
		
		private function update(e:Event):void
		{
			ang += angInc;
			if (ang > 6.28) {
				ang = 0;
			}
			
			x += xVel + Math.cos(ang);
			y += yVel + Math.sin(ang);
			
			if (x < -30) {
				x = 1950;
			}
			if (x > 1950) {
				x = -30;
			}
			if (y > 1110) {
				y = -30;
			}		
			//rotation += spin;
		}
		
	}
	
}