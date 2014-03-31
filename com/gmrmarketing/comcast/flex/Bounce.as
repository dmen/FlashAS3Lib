package com.gmrmarketing.comcast.flex
{	
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.plugins.*;
	
	public class Bounce extends MovieClip
	{
		private var xVel:Number;
		private var yVel:Number;
		private var glowSize:Number;
		
		public function Bounce() 
		{
			//TweenPlugin.activate([GlowFilterPlugin]);				
		}
		
		public function doStart():void
		{
			xVel = 1.3 + Math.random() * 6;
			yVel = 1.3 + Math.random() * 6;		
			doGlow();
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		public function doStop():void
		{
			TweenMax.killAll();
			removeEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(e:Event):void
		{
			if (x + width * .5 > 1366) {
				xVel = 1.3 + Math.random() * 6;
				xVel *= -1;
				
			}
			if (x + width * .5 < 0) {
				xVel = 1.3 + Math.random() * 6;
				//doGlow();
			}
			if (y + height * .5 < 0) {
				yVel = 1.3 + Math.random() * 6;
				//doGlow();
			}
			if (y + height * .5 > 768) {
				yVel = 1.3 + Math.random() * 6;
				yVel *= -1;
				//doGlow();
			}
			x += xVel;
			y += yVel;			
		}
		private function doGlow():void
		{			
			TweenMax.to(this, 0, {glowFilter:{color:0xFFFFFF, alpha:1, blurX:10, blurY:10 }} );
		}
		
	}
	
}