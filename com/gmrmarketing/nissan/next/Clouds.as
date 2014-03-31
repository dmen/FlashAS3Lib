package com.gmrmarketing.nissan.next
{
	import com.gmrmarketing.website.VPlayer;
	import flash.display.DisplayObjectContainer;
	import flash.events.*;

	public class Clouds
	{
		private var container:DisplayObjectContainer;
		private var vid:VPlayer;
		
		
		public function Clouds($container:DisplayObjectContainer) 
		{
			container = $container;
			vid = new VPlayer();
			vid.showVideo(container);
			vid.addEventListener(VPlayer.CUE_RECEIVED, checkStatus, false, 0, true);
			vid.playVideo("picassets/clouds.f4v");
		}
		
		
		private function checkStatus(e:Event):void
		{		
			vid.replay();
		}
		
		
		public function pause():void
		{
			vid.pauseVideo();
		}
		
		
		public function play():void
		{
			vid.resumeVideo();
		}
		
	}
	
}