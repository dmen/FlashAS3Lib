package com.gmrmarketing.comcast.university.ipad2013
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;
	
	
	public class Intro extends EventDispatcher
	{
		public static const INTRO_SHOWING:String = "introShowing";
		public static const PLAY_PRESSED:String = "playPressed";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Intro()
		{
			clip = new mcIntro();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, playClicked, false, 0, true);
			
			clip.y = clip.height;//put at screen bottom
			TweenMax.to(clip, 1, { y:0, onComplete:showing } );//tween up to show
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(INTRO_SHOWING));
		}
		
		
		public function hide():void
		{
			TweenMax.killTweensOf(clip.btnPlay);
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			clip.btnPlay.removeEventListener(MouseEvent.MOUSE_DOWN, playClicked);
		}
		
		
		private function playClicked(e:MouseEvent):void
		{
			TweenMax.from(clip.btnPlay, .2, { alpha:1 } );
			dispatchEvent(new Event(PLAY_PRESSED));
		}
		
	}
	
}