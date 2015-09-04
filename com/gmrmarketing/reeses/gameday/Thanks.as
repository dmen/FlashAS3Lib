package com.gmrmarketing.reeses.gameday
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const COMPLETE:String = "ThanksComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Thanks()
		{
			clip = new mcThanks();
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
			
			clip.tLine.scale = 0;
			clip.bLine.scaleX = 0;
			clip.thankYou.scaleY = 0;
			clip.wrap.alpha = 0;
			clip.yourVideo.alpha = 0;
			
			TweenMax.to(clip.thankYou, .5, { scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.tLine, .5, { scaleX:1, delay:.3, ease:Back.easeOut } );
			TweenMax.to(clip.bLine, .5, { scaleX:1, delay:.4, ease:Back.easeOut } );
			TweenMax.to(clip.wrap, .5, { alpha:1, delay:.5 } );
			TweenMax.to(clip.yourVideo, .5, { alpha:1, delay:.75 } );
			
			var a:Timer = new Timer(5000, 1);
			a.addEventListener(TimerEvent.TIMER, done, false, 0, true);
			a.start();
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			
		}
		
		
		private function done(e:TimerEvent):void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}