package com.gmrmarketing.smartcar
{
	import flash.display.MovieClip;
	import com.gmrmarketing.website.VPlayer;
	import flash.events.Event;
	
	public class ScreenSaver extends MovieClip
	{
		private var player:VPlayer;
		
		public function ScreenSaver()
		{
			player = new VPlayer();
			player.autoSizeOff();
			player.showVideo(this);
			player.setVidSize( { width:1920, height:1080 } );
			
			player.addEventListener(VPlayer.STATUS_RECEIVED, traceStatus);
			
			playVid();
		}
		
		private function playVid():void
		{
			player.playVideo("assets/smart-attractorloop-907a.f4v");
		}
		
		private function traceStatus(e:Event):void
		{
			if (player.getStatus() == "NetStream.Play.Stop") {
				playVid();
			}
		}
		
		
	}
	
}