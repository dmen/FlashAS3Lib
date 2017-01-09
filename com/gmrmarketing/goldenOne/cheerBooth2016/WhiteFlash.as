package com.gmrmarketing.goldenOne.cheerBooth2016
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class WhiteFlash
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		public function WhiteFlash()
		{
			clip = new mcWhiteFlash();//just a white rect
		}
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		/**
		 * called from Main.startCountdownFinished()
		 */
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			clip.alpha = 1;
			TweenMax.to(clip, 1, {alpha:0, onComplete:kill});
		}
		
		private function kill():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
		}
	}
	
}