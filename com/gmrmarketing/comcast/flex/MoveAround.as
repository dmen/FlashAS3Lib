package com.gmrmarketing.comcast.flex
{	
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.plugins.*;
	
	public class MoveAround extends MovieClip
	{		
		public function MoveAround() 
		{						
		}
		
		private function doMove():void
		{			
			TweenMax.to(this, 2, { delay:1, alpha:0, onComplete:newLoc } );
		}
		
		private function newLoc():void
		{
			x = Math.min(10 + Math.random() * 1280, 1280 - 130);
			y = Math.min(10 + Math.random() * 720,720 - 50);
			TweenMax.to(this, 2, { delay:Math.random() * 10, alpha:1, onComplete:doMove } );
		}
		
		private function doGlow():void
		{			
			TweenMax.to(this, 0, {glowFilter:{color:0xFFFFFF, alpha:1, blurX:10, blurY:10 }} );
		}
		
		public function doStop():void
		{
			TweenMax.killTweensOf(this);
		}
		
		public function doStart():void
		{
			doGlow();
			doMove();
		}
	}
	
}