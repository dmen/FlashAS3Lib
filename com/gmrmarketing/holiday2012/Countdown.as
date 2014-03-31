package com.gmrmarketing.holiday2012
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.media.Sound;
	
	public class Countdown extends EventDispatcher
	{
		public static const COUNT_FINISHED:String = "COUNTDOWN_COMPLETE";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var secTimer:Timer;
		private var currentCount:int;
		private var beepSound:Sound;
		private var numPics:int;
		private var curPic:int;
		
		public function Countdown()
		{
			clip = new mc_count();
			clip.x = 306;
			
			beepSound = new soundBeep();
			
			secTimer = new Timer(1000);
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show($numPics:int):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			numPics = $numPics;
			curPic = 0;
			clip.theText.text = "TAKING PICTURE 1 OF " + String(numPics);
			
			clip.y = -125;
			TweenMax.to(clip, 1, { y:9 } );
		}
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		public function start():void
		{
			currentCount = 4;
			
			clip.three.alpha = 0;
			clip.two.alpha = 0;
			clip.one.alpha = 0;
			
			curPic++;
			clip.theText.text = "TAKING PICTURE " + String(curPic) + " OF " + String(numPics);
			
			secTimer.addEventListener(TimerEvent.TIMER, decTimer, false, 0, true);
			secTimer.start();
		}
		
		
		private function decTimer(e:TimerEvent):void
		{	
			currentCount--;
			switch(currentCount) {
				case 3:
					beepSound.play();
					clip.three.alpha = .85;
					break;
				case 2:
					beepSound.play();
					clip.two.alpha = .85;
					break;
				case 1:
					beepSound.play();
					clip.one.alpha = .85;
					break;
				case 0:
					secTimer.reset();
					dispatchEvent(new Event(COUNT_FINISHED));					
					break;				
			}
			
		}
		
	}
	
}