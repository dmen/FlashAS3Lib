package com.gmrmarketing.holiday2016.tablePlayer
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.ui.*;
	import flash.media.Video;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	public class VideoPlayer extends Sprite
	{
		private var nc:NetConnection;
		private var ns:NetStream;
		private var vClient:Object;
		private var video:Video;
			
		
		public function VideoPlayer(fileName:String, xLoc:int, yLoc:int)
		{
			nc = new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			
			vClient = new Object();
			vClient.onCuePoint = cuePointHandler;
			vClient.onMetaData = metaDataHandler;
			
			ns.client = vClient;
			
			video = new Video(600, 600);
			video.attachNetStream(ns);
			addChild(video);
			video.x = xLoc;
			video.y = yLoc;
			
			ns.play(fileName);
		}
		
		
		private function netStatusHandler(e:NetStatusEvent):void 
		{
			if (e.info.code == "NetStream.Play.Stop") {				
				if (contains(video)){
					removeChild(video);
				}
				video.attachNetStream(null);
				ns.client = {};
				ns.close();
				ns.dispose();
				nc.close();
			}			
		}
		
		
		private function cuePointHandler(infoObject:Object):void {}
		private function metaDataHandler(infoObject:Object):void
		{
			trace("metaData");
		}
	}
	
}