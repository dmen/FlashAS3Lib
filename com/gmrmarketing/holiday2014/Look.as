package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Look
	{
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		
		
		public function Look():void
		{
			clip = new mcLook();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
			}
			
			clip.x = 1366;
			clip.y = 900;
			clip.alpha = 1;
			TweenMax.to(clip, .5, { y:800, ease:Back.easeOut } );
			TweenMax.to(clip, .5, { alpha:0, delay:1, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
		}
	}
	
}