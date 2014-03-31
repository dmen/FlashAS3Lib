package com.gmrmarketing.miller.sxsw
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	import flash.events.*;
	import com.sagecollective.utilities.TimeoutHelper;
	
	
	public class Intro extends EventDispatcher
	{
		public static const INTRO_ADDED:String = "introAdded";
		public static const INTRO_CLICKED:String = "introClicked";
		
		private var timeoutHelper:TimeoutHelper;
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Intro()
		{
			timeoutHelper = TimeoutHelper.getInstance();
			clip = new intro(); //lib clip
		}
		
		
		public function show($container:DisplayObjectContainer):void
		{
			container = $container;
			
			clip.alpha = 0;
			container.addChild(clip);
			
			clip.addEventListener(MouseEvent.MOUSE_DOWN, clipClicked, false, 0, true);
			
			TweenMax.to(clip, 1, { alpha:1, onComplete:clipAdded } );
		}
		
		public function fade():void
		{
			TweenMax.to(clip, 1, { alpha:0 } );
		}
		
		public function hide():void
		{
			if (container) {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, clipClicked);
		}
		
		
		private function clipAdded():void
		{
			dispatchEvent(new Event(INTRO_ADDED));
		}
		
		
		private function clipClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(INTRO_CLICKED));
		}
	}
	
}