package com.gmrmarketing.indian.daytona
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class Intro extends EventDispatcher
	{
		public static const INTRO_CLICKED:String = "intro_clicked";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Intro()
		{
			clip = new intro(); //lib clip
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
				clip.alpha = 0;
				TweenMax.to(clip, 1, { alpha:1 } );
			}
			clip.addEventListener(MouseEvent.MOUSE_DOWN, introClicked, false, 0, true);
		}
		
		
		public function hide():void		
		{
			if (container.contains(clip)) {
				TweenMax.to(clip, 1, { alpha:0, onComplete:kill } );
			}
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, introClicked);
		}
		
		
		private function kill():void
		{
			container.removeChild(clip);
		}
		
		
		private function introClicked(e:MouseEvent):void
		{
			clip.removeEventListener(MouseEvent.CLICK, introClicked);
			dispatchEvent(new Event(INTRO_CLICKED));
		}
		
	}
	
}