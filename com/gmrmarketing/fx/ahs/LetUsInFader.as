package com.gmrmarketing.fx.ahs
{	
	import flash.display.MovieClip;
	import com.greensock.TweenLite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class LetUsInFader extends MovieClip
	{
		private const xcen:int = 376;//center of speaker image
		private const ycen:int = 254;
		
		public function LetUsInFader()
		{			
			addEventListener(Event.REMOVED_FROM_STAGE, kill);
			newOuter();
		}
		
		private function newCenter():void 
		{
			x = xcen;
			y = ycen;
			alpha = 1;
			newOuter();
		}
		
		private function newOuter():void
		{
			var radius:Number = 50 + Math.random() * 200;
			var angle:Number = Math.random() * (Math.PI * 2);
			
			TweenLite.to(this, 2 + Math.random() * 4, { alpha:0, x:xcen + (radius * Math.cos(angle)), y:ycen + (radius * Math.sin(angle)), onComplete:newCenter } );
		}
		
		private function kill(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, kill);
			TweenLite.killTweensOf(this);
		}
		
	}
	
}