package com.gmrmarketing.esurance.sxsw_2015.photobooth
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Countdown extends EventDispatcher
	{
		public static const COUNT_COMPLETE:String = "countComplete";		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;		
		
		
		public function Countdown()
		{
			clip = new mcCountdown();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			clip.alpha = 0;
			clip.c3.alpha = .2;
			clip.c2.alpha = .2;
			clip.c1.alpha = .2;
			clip.x = 765;
			clip.y = 785;
			clip.scaleX = clip.scaleY = .3;
			TweenMax.to(clip, .75, { alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:startCountdown } );
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function startCountdown():void
		{
			clip.c3.alpha = 1;
			TweenMax.to(clip.c3, 1, { alpha:.2, onComplete:c2 } );
		}
		private function c2():void
		{
			clip.c2.alpha = 1;
			TweenMax.to(clip.c2, 1, { alpha:.2, onComplete:c1 } );
		}
		private function c1():void
		{
			clip.c1.alpha = 1;
			TweenMax.to(clip.c1, 1, { alpha:.2, onComplete:done } );
		}		
		
		
		private function done():void
		{			
			dispatchEvent(new Event(COUNT_COMPLETE));
		}
		
	}
	
}