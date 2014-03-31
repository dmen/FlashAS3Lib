package com.gmrmarketing.esurance.sxsw_2014
{
	import flash.display.*;
	import com.greensock.TweenMax;
	import flash.media.Camera;
	
	
	public class VideoDisplay
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		public function VideoDisplay()
		{
			clip = new mcVideo();
		}
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;			
		}
		
		public function show(cam:Camera):void
		{
			if (container) {
				if (!container.contains(clip)) {
					container.addChild(clip);
				}
			}
			clip.vid.attachCamera(cam);
			showRedBlink();
		}
		
		public function hide():void
		{
			if (container) {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}
			clip.vid.attachCamera(null);
			TweenMax.killTweensOf(clip.blink);
		}
		
		private function showRedBlink():void
		{
			TweenMax.to(clip.blink, 1, { alpha:1, onComplete:hideRedBlink } );
		}
		
		
		private function hideRedBlink():void
		{
			TweenMax.to(clip.blink, 1, { alpha:.1, onComplete:showRedBlink } );
		}
		
	}
	
}