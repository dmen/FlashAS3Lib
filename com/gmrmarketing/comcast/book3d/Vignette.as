package com.gmrmarketing.comcast.book3d
{
	import flash.display.*;
	import com.greensock.TweenMax;
	
	
	public class Vignette
	{
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		
		public function Vignette()
		{
			clip = new mcVignette();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			clip.alpha = 0;
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			TweenMax.to(clip, 1, { alpha:.95 } );
		}
		
		
		public function hide(hideTime:int = 3):void
		{
			TweenMax.to(clip, hideTime, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
	}
	
}