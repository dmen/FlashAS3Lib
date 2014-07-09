package com.gmrmarketing.sap.levisstadium.avatar.testing
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import com.gmrmarketing.website.VPlayer;
	import flash.events.MouseEvent;
	
	public class Intro extends EventDispatcher
	{
		public static const SHOWING:String = "introShowing";
		public static const MANUAL_START:String = "userTouchedScreen";		
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var vid:VPlayer;
		
		
		public function Intro()
		{
			clip = new mcIntro();
			vid = new VPlayer();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (container) {
				vid.showVideo(container);
				vid.playVideo("assets/attract_1.f4v");
				vid.addEventListener(VPlayer.CUE_RECEIVED, checkCue, false, 0, true);
				
				if (!container.contains(clip)) {
					container.addChild(clip);
				}
			}
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		public function hide():void
		{
			vid.simpleHide();
			vid.removeEventListener(VPlayer.CUE_RECEIVED, checkCue);
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, manualStart);
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function checkCue(e:Event):void
		{			
			vid.replay();	
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
			clip.addEventListener(MouseEvent.MOUSE_DOWN, manualStart, false, 0, true);
		}
		
		
		private function manualStart(e:MouseEvent):void
		{
			dispatchEvent(new Event(MANUAL_START));
		}
		
	}	
	
}