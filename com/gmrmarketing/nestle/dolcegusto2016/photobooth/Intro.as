package com.gmrmarketing.nestle.dolcegusto2016.photobooth
{
	import flash.events.*;
	import flash.display.*;	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	
	
	public class Intro extends EventDispatcher
	{
		public static const INTRO_TIMEOUT_SHOW:String = "introTimedOutShow";
		public static const INTRO_TIMEOUT_HIDE:String = "introTimedOutHide";
		public static const COMPLETE:String = "introComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var timeout:Timer;
		
		
		public function Intro()
		{
			clip = new mcIntro();			
			timeout = new Timer(30000, 1);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}	
			
			clip.alpha = 1;//hide() fades it out
			clip.btnStart.arrow.x = 0;
			clip.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, startClicked, false, 0, true);
			
			clip.bigOrange.orange.scaleX = clip.bigOrange.orange.scaleY = 0;
			clip.bigOrange.theText.alpha = 0;
			clip.bigOrange.arrow.alpha = 0;
			clip.theTitle.alpha = 0;
			clip.btnStart.width = clip.btnStart.height = 0;
			
			TweenMax.to(clip.theTitle, .5, {alpha:1, delay:.5});
			TweenMax.to(clip.btnStart, .4, {width:365, height:365, ease:Back.easeOut, delay:.4});
			TweenMax.to(clip.bigOrange.orange, .4, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.75});
			TweenMax.to(clip.bigOrange.theText, 1, {alpha:1, delay:.85});
			TweenMax.to(clip.bigOrange.arrow, 1, {alpha:1, delay:1});
			
			timeout.reset();
			timeout.addEventListener(TimerEvent.TIMER, timedOut, false, 0, true);
			timeout.start();
			
			animateArrow();
		}
		
		
		/**
		 * called if the intro screen times out
		 * @param	e
		 */
		private function timedOut(e:TimerEvent):void
		{
			timeout.removeEventListener(TimerEvent.TIMER, timedOut);
			
			dispatchEvent(new Event(INTRO_TIMEOUT_SHOW));
			
			timeout.addEventListener(TimerEvent.TIMER, timeoutImageTimedOut, false, 0, true);
			timeout.delay = 5000;
			timeout.reset();
			timeout.start();
		}
		
		
		private function timeoutImageTimedOut(e:TimerEvent):void
		{
			timeout.removeEventListener(TimerEvent.TIMER, timeoutImageTimedOut);
			hideTimeoutImage();
		}
		
		
		/**
		 * called by user clicking timeout image/screen
		 * remove image and show intro/video selector again
		 * @param	e
		 */
		private function hideTimeoutImage(e:MouseEvent = null):void
		{			
			dispatchEvent(new Event(INTRO_TIMEOUT_HIDE));
			
			timeout.removeEventListener(TimerEvent.TIMER, timeoutImageTimedOut);
			timeout.delay = 30000;
			timeout.reset();			
			timeout.addEventListener(TimerEvent.TIMER, timedOut, false, 0, true);
			timeout.start();
			
			
		}
		
		
		public function hide():void
		{
			timeout.reset();
			timeout.removeEventListener(TimerEvent.TIMER, timedOut);
			timeout.removeEventListener(TimerEvent.TIMER, timeoutImageTimedOut);
			
			TweenMax.to(clip, .5, {alpha:0, onComplete:killClip});
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, startClicked);			
			
			TweenMax.killDelayedCallsTo(animateArrow);
			//TweenMax.killTweensOf(clip.btnStart.arrow);
		}
		
		
		private function killClip():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, startClicked);			
			timeout.reset();
			timeout.removeEventListener(TimerEvent.TIMER, timedOut);
			TweenMax.killDelayedCallsTo(animateArrow);
		}
		
		
		private function startClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(COMPLETE));		
		}		
		
		
		/**
		 * called at end of show()
		 */
		private function animateArrow():void
		{
			clip.btnStart.arrow.x = -80;
			TweenMax.to(clip.btnStart.arrow, .75, {x:0, ease:Elastic.easeOut});
			TweenMax.delayedCall(2, animateArrow);
		}		
	
	}
	
}