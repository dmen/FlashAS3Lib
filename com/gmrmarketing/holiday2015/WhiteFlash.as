package com.gmrmarketing.holiday2015
{
	import flash.display.*;
	import com.greensock.TweenMax;
	
	
	public class WhiteFlash
	{
		private var clip:Sprite;
		private var myContainer:DisplayObjectContainer;
		
		public function WhiteFlash()
		{
			clip = new Sprite();
			clip.graphics.beginFill(0xffffff, 1);
			clip.graphics.drawRect(0, 0, 1920, 1080);
			clip.graphics.endFill();
		}
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);	
			}
			clip.alpha = 1;
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