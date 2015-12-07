package com.gmrmarketing.holiday2015
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.filters.DropShadowFilter;
	
	
	public class Countdown extends EventDispatcher
	{
		public static const COMPLETE:String = "countdownComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var curCount:int;
		
		
		public function Countdown()
		{
			clip = new mcCountdown();
			clip.filters = [new DropShadowFilter(0, 0, 0, .8, 12, 12, 1, 2)];
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
			
			curCount = 3;
			clip.theText.text = "3";
			clip.scaleX = clip.scaleY = 0;
			clip.alpha = 0;
			clip.x = 1670;
			clip.y = 380;
			
			TweenMax.to(clip, 1, { scaleX:2.5, scaleY:2.5, alpha:.8, onComplete:scaleDown } );
		}
		
		
		private function scaleDown():void
		{
			TweenMax.to(clip, .5, { alpha:0, scaleX:2, scaleY:2, onComplete:scaleUp } );
		}
		
		
		private function scaleUp():void
		{
			curCount--;
			if (curCount == 0) {
				dispatchEvent(new Event(COMPLETE));
			}else{
				clip.theText.text = String(curCount);
				clip.scaleX = clip.scaleY = 0;
				TweenMax.to(clip, 1.25, { scaleX:2.5, scaleY:2.5, alpha:.8, onComplete:scaleDown } );
			}
		}
	}
	
}