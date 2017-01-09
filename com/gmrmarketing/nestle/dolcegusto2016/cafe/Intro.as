package com.gmrmarketing.nestle.dolcegusto2016.cafe
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
		public static const MACHINES:String = "machinesPressed";
		public static const FLAVORS:String = "flavorsPressed";
		public static const VIDEOS:String = "videosPressed";
		
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
			
			clip.btnMachines.bg.scaleX = clip.btnMachines.bg.scaleY = 0;
			clip.btnMachines.coffee.scaleY = 0;
			clip.btnMachines.theTitle.alpha = 0;
			clip.btnFlavors.bg.scaleX = clip.btnFlavors.bg.scaleY = 0;
			clip.btnFlavors.coffee.scaleY = 0;
			clip.btnFlavors.theTitle.alpha = 0;
			clip.btnVideos.bg.scaleX = clip.btnVideos.bg.scaleY = 0;
			clip.btnVideos.coffee.scaleY = 0;
			clip.btnVideos.theTitle.alpha = 0;
			
			clip.titleGroup.theTitle.text = "WHAT'S YOUR RELATIONSHIP WITH COFFEE?";
			clip.titleGroup.subTitle.text = "Take the quiz to get special offers";			
			clip.titleGroup.alpha = 0;
			
			clip.alpha = 1;//hide() fades it out
			clip.btnStart.arrow.x = 0;
			clip.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, startClicked, false, 0, true);
			clip.btnStart.width = clip.btnStart.height = 0;
			
			TweenMax.to(clip.btnStart, .4, {width:365, height:365, ease:Back.easeOut, delay:.4});
			TweenMax.to(clip.titleGroup, .4, {alpha:1, delay:.6});
			
			TweenMax.to(clip.btnMachines.bg, .4, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.5});
			TweenMax.to(clip.btnMachines.coffee, .4, {scaleY:1, ease:Back.easeOut, delay:.7});
			TweenMax.to(clip.btnMachines.theTitle, .4, {alpha:1, delay:.9});
			
			TweenMax.to(clip.btnFlavors.bg, .4, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.7});
			TweenMax.to(clip.btnFlavors.coffee, .4, {scaleY:1, ease:Back.easeOut, delay:.9});
			TweenMax.to(clip.btnFlavors.theTitle, .4, {alpha:1, delay:1.1});
			
			TweenMax.to(clip.btnVideos.bg, .4, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.9});
			TweenMax.to(clip.btnVideos.coffee, .4, {scaleY:1, ease:Back.easeOut, delay:1.1});
			TweenMax.to(clip.btnVideos.theTitle, .4, {alpha:1, delay:1.3});			
			
			timeout.reset();
			timeout.addEventListener(TimerEvent.TIMER, timedOut, false, 0, true);
			timeout.start();
			
			clip.btnMachines.addEventListener(MouseEvent.MOUSE_DOWN, showMachines, false, 0, true);
			clip.btnFlavors.addEventListener(MouseEvent.MOUSE_DOWN, showFlavors, false, 0, true);
			clip.btnVideos.addEventListener(MouseEvent.MOUSE_DOWN, showVideos, false, 0, true);
			
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
			
			TweenMax.to(clip, .5, {alpha:0, onComplete:killClip});
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, startClicked);
			
			clip.btnFlavors.removeEventListener(MouseEvent.MOUSE_DOWN, showFlavors);
			clip.btnMachines.removeEventListener(MouseEvent.MOUSE_DOWN, showMachines);			
			clip.btnVideos.removeEventListener(MouseEvent.MOUSE_DOWN, showVideos);
			
			TweenMax.killDelayedCallsTo(animateArrow);
			//TweenMax.killTweensOf(clip.btnStart.arrow);
		}
		
		
		public function killClip():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, startClicked);
			
			clip.btnFlavors.removeEventListener(MouseEvent.MOUSE_DOWN, showFlavors);
			clip.btnMachines.removeEventListener(MouseEvent.MOUSE_DOWN, showMachines);			
			clip.btnVideos.removeEventListener(MouseEvent.MOUSE_DOWN, showVideos);
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
		
		
		private function showMachines(e:MouseEvent):void
		{
			dispatchEvent(new Event(MACHINES));
		}
		
		
		private function showFlavors(e:MouseEvent):void
		{
			dispatchEvent(new Event(FLAVORS));
		}
		
		
		private function showVideos(e:MouseEvent):void
		{
			dispatchEvent(new Event(VIDEOS));
		}
	
	}
	
}