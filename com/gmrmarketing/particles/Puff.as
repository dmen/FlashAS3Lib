package com.gmrmarketing.particles
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class Puff extends MovieClip
	{
		private var alph:Number;
		private var puff:MovieClip;
		private var alphaFalloff:Number;
		private var speed:Number;
		private var scaleNum:Number;
		private var xInc:Number;
		private var puf:MovieClip;
		private var container:DisplayObjectContainer;		
		
		public function Puff($container:DisplayObjectContainer, initX:int, initY:int)
		{
			container = $container;
			
			puf = new smoke();
			
			puf.x = initX;
			puf.y = initY;
			puf.rotation = 180 * Math.random();
			puf.alpha = Math.min(1, .25 + Math.random() * .5);			
			alphaFalloff = Math.random() * .1;
			speed = Math.random() + 1.5;
			puf.scaleX = puf.scaleY = .2 + (Math.random() * .3);
			scaleNum = .01 + (Math.random() * .01);
			xInc = Math.random() * .5;
			if (Math.random() < .5) {
				xInc *= -1;
			}
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			container.addChild(puf);			
		}
		
		
		private function update(e:Event):void
		{			
			puf.y -= speed;	
			puf.x += xInc;
			puf.alpha -= .005;// alphaFalloff;
			puf.scaleX += scaleNum;
			puf.scaleY += scaleNum;			
			
			if (puf.alpha <= 0) {
				removeEventListener(Event.ENTER_FRAME, update);
				container.removeChild(puf);
				puf = null;
			}
		}
		
	}
	
}