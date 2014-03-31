package com.gmrmarketing.nissan.canada.ridedrive2013
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;	
	import com.greensock.TweenMax;
	import flash.events.*;
	import flash.utils.Timer;
	
	public class Intro extends EventDispatcher
	{		
		public static const INTRO_CLICKED:String = "introClicked";
		
		private var swapTimer:Timer;
		private var clip1:MovieClip;
		private var clip2:MovieClip;
		private var container:DisplayObjectContainer;
		private var curScreen:int;
		
		
		public function Intro()
		{
			clip1 = new mcIntro();
			clip2 = new mcIntro2();			
			
			swapTimer = new Timer(5000);
			swapTimer.addEventListener(TimerEvent.TIMER, doSwap, false, 0, true);
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function setLanguage(lang:String):void
		{
			if (lang == "en") {
				clip1.en.visible = 1;
				clip1.fr.visible = 0;
				clip2.en.visible = 1;
				clip2.fr.visible = 0;
			}else {
				clip1.en.visible = 0;
				clip1.fr.visible = 1;
				clip2.en.visible = 0;
				clip2.fr.visible = 1;
			}
		}
		
		
		/**
		 * lang will be "en" or "fr"
		 * @param	lang
		 */
		public function show():void
		{			
			container.addChild(clip2);			
			container.addChild(clip1);
			clip1.alpha = 1;
			curScreen = 1;
			clip1.addEventListener(MouseEvent.MOUSE_DOWN, introClicked, false, 0, true);			
			clip2.addEventListener(MouseEvent.MOUSE_DOWN, introClicked, false, 0, true);
			startTimer();
		}
		
		
		public function hide():void
		{
			TweenMax.killTweensOf(clip1);
			TweenMax.killTweensOf(clip2);
			swapTimer.reset();
			clip1.removeEventListener(MouseEvent.MOUSE_DOWN, introClicked);			
			clip2.removeEventListener(MouseEvent.MOUSE_DOWN, introClicked);
			if (container.contains(clip1)) {
				container.removeChild(clip1);
			}
			if (container.contains(clip2)) {
				container.removeChild(clip2);
			}
		}
		
		
		private function startTimer():void
		{
			swapTimer.start();
		}
		
		
		private function doSwap(e:TimerEvent):void
		{
			swapTimer.reset();
			if (curScreen == 1) {
				curScreen = 2;
				container.removeChild(clip2);
				container.addChild(clip2);//put it over clip1
				clip2.alpha = 0;
				TweenMax.to(clip2, 1, { alpha:1, onComplete:startTimer } );
			}else {
				curScreen = 1;
				container.removeChild(clip1);
				container.addChild(clip1);//put it over clip2
				clip1.alpha = 0;
				TweenMax.to(clip1, 1, { alpha:1, onComplete:startTimer } );
			}
		}
		
		
		private function introClicked(e:MouseEvent):void
		{			
			dispatchEvent(new Event(INTRO_CLICKED));
		}
		
	}
	
}