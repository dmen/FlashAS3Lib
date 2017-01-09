package com.gmrmarketing.goldenOne.cheerBooth2016
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const COMPLETE:String = "thanksTimedOut";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var timeout:Timer;
		
		
		public function Thanks():void
		{
			clip = new mcThanks();
			timeout = new Timer(7000, 1);
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
			clip.title.x = 1920;
			clip.subTitle.x = 1920;
			
			TweenMax.to(clip.title, .5, {x:146, ease:Expo.easeOut, delay:.5});//wait for form to clear out
			TweenMax.to(clip.subTitle, .5, {x:150, ease:Expo.easeOut, delay:.6});
			
			timeout.addEventListener(TimerEvent.TIMER, timedOut, false, 0, true);
			timeout.start();
		}
		
		
		public function hide():void
		{			
			TweenMax.to(clip.title, .5, {x:-1500, ease:Expo.easeIn});
			TweenMax.to(clip.subTitle, .5, {x:-1500, ease:Expo.easeIn, delay:.1, onComplete:kill});
		}
		
		
		public function kill():void
		{
			timeout.removeEventListener(TimerEvent.TIMER, timedOut);
			timeout.reset();
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
		}
		
		
		private function timedOut(e:TimerEvent):void
		{
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}