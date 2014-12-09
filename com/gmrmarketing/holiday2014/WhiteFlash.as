package com.gmrmarketing.holiday2014
{
	import flash.display.*
	import com.greensock.TweenMax;
	
	public class WhiteFlash
	{
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		
		
		public function WhiteFlash():void
		{
			clip = new mcWhite();
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
			clip.alpha = 1;
			TweenMax.to(clip, 1, { alpha:0, onComplete:kill } );
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