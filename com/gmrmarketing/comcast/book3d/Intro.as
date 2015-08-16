package com.gmrmarketing.comcast.book3d
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	
	
	public class Intro extends EventDispatcher 
	{
		public static const CLICKED:String = "userClicked";
		
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		
		
		public function Intro()
		{
			clip = new mcIntro();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{	
			clip.alpha = 1;
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.welcome.alpha = 0;
			clip.hlines.alpha = 0;
			clip.title.alpha = 0;
			clip.subText.alpha = 0;
			clip.btnStart.alpha = 0;
			
			clip.welcome.y -= 50;
			clip.hlines.scaleY = 1.3;
			clip.title.scaleX = 1.2;
			clip.subText.y += 50;
			
			TweenMax.to(clip.welcome, .5, { y:"50", alpha:1 } );
			TweenMax.to(clip.hlines, .5, { scaleY:1, alpha:1, delay:.4 } );
			TweenMax.to(clip.title, .5, { scaleX:1, alpha:1, delay:.8 } );
			TweenMax.to(clip.subText, .5, { y:"-50", alpha:1, delay:1.25 } );
			TweenMax.to(clip.btnStart, .5, { alpha:1, delay:1.8 } );
			
			clip.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, userClicked, false, 0, true);
		}
		
		
		public function userClicked(e:MouseEvent):void
		{
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, userClicked);
			dispatchEvent(new Event(CLICKED));
		}
		
		
		public function hide():void
		{			
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
	}
	
}