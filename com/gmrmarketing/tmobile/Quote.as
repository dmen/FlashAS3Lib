package com.gmrmarketing.tmobile
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
		
	public class Quote extends MovieClip
	{
		//pixels per second
		private var pps:Number;
		
		public function Quote()
		{
			pps = 20 + Math.random() * 20;
			nextPos();
		}
		
		public function nextPos():void
		{
			var newX:int = 980 * Math.random();
			var newY:int = 768 * Math.random();
			var c:Number = Math.sqrt(Math.pow(Math.abs(newX - x), 2) + Math.pow(Math.abs(newY - y), 2));
			var s:Number = c / pps;			
			TweenMax.to(this, s, { x:newX, y:newY, ease:Linear.easeNone, onComplete:nextPos } );
		}
		
		public function kill():void
		{
			TweenMax.killTweensOf(this);
		}
	}
	
}