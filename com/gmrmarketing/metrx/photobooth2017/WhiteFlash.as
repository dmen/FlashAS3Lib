package com.gmrmarketing.metrx.photobooth2017
{
	import flash.display.*;
	import com.greensock.TweenMax;
	
	
	public class WhiteFlash
	{
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		
		
		public function WhiteFlash()
		{
			clip = new whiteFlash();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			_container = c;
		}
		
		
		public function show():void
		{
			if (!_container.contains(clip)){
				_container.addChild(clip);
			}
			clip.alpha = 1;
			TweenMax.to(clip, 1, {alpha:0, onComplete:kill});
		}
		
		
		private function kill():void
		{
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
		}
		
		
	}
	
}