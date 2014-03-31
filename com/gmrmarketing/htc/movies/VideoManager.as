package com.gmrmarketing.htc.movies
{
	import flash.events.*;
	import com.gmrmarketing.website.VPlayer;
	import flash.display.DisplayObjectContainer;
	import com.gmrmarketing.htc.movies.ConfigData;
	
	public class VideoManager
	{
		private var vid:VPlayer;
		private var container:DisplayObjectContainer;
		private var index:int; //used for naming convention
		
		public function VideoManager()
		{
			vid = new VPlayer();
			index = 0;
		}
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
			vid.showVideo(container);
			vid.autoSizeOff();
			vid.setVidSize( { width:640, height:360 } );
			
			vid.addEventListener(VPlayer.STATUS_RECEIVED, checkStatus, false, 0, true);
			
			//nextVid();
			singlePlay();
		}
		
		private function singlePlay():void
		{
			vid.playVideo(ConfigData.VIDEO_PATH + ConfigData.VIDEO_STATIC_NAME);
		}
		
		
		private function nextVid():void
		{
			index++;
			if (index > ConfigData.MAX_VIDEOS) {
				index = 1;
			}
			vid.playVideo(ConfigData.VIDEO_PATH + ConfigData.VIDEO_BASE_NAME + String(index) + ".mp4");
		}
		
		
		private function checkStatus(e:Event):void
		{			
			if(vid.getStatus() == "NetStream.Play.Stop")
			{
				//nextVid();
				singlePlay();
			}
			if (vid.getStatus() == "NetStream.Play.StreamNotFound") {
				//nextVid();
				singlePlay();
			}
		}
	}
}