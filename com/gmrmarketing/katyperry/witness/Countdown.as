package com.gmrmarketing.katyperry.witness
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	
	
	public class Countdown extends EventDispatcher
	{
		public static const FLASH:String = "flashShowing";
		public static const COMPLETE:String = "countdownComplete";
		private var clip:MovieClip;
		private var white:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Countdown()
		{
			clip = new countdown();
			white = new whiteFlash();
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
			
			clip.scaleX = clip.scaleY = 4.5;
			clip.alpha = 1;
			clip.x = 960;
			clip.y = 520;
			
			clip.theText.text = "3";
			
			TweenMax.to(clip, 1.5, {scaleX:0, scaleY:0, alpha:0, onComplete:showTwo});
		}
	
		
		private function showTwo():void
		{
			clip.scaleX = clip.scaleY = 3;
			clip.alpha = 1;
			clip.theText.text = "2";
			
			TweenMax.to(clip, 1.5, {scaleX:0, scaleY:0, alpha:0, onComplete:showOne});
		}
		
		
		private function showOne():void
		{
			clip.scaleX = clip.scaleY = 3;
			clip.alpha = 1;
			clip.theText.text = "1";
			
			TweenMax.to(clip, 1.5, {scaleX:0, scaleY:0, alpha:0, onComplete:showWhite});
		}
		
		
		public function showWhite():void
		{
			dispatchEvent(new Event(FLASH));//takes the pic when the flash first appears
			
			if (!myContainer.contains(white)){
				myContainer.addChild(white);
			}
			white.alpha = 1;
			TweenMax.to(white, .5, {alpha:0, onComplete:allDone});
		}
		
		
		private function allDone():void
		{
			if(myContainer.contains(white)){
				myContainer.removeChild(white);
			}
			if(myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
		}
		
	}
	
}