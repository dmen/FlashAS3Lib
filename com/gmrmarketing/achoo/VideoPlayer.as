package com.gmrmarketing.achoo
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.NetStatusEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class VideoPlayer extends Sprite	
	{
		private var nc:NetConnection;
		private var ns:NetStream;
		private var vid:Video;
		private var netClient:Object;
		
		private var me:VideoPlayer;
		private var onTimer:Timer;
		
		public function VideoPlayer()
		{
			me = this;
						
			nc = new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			vid = new Video(1137, 768);			
			vid.attachNetStream(ns);
				
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStat);
			
			//so the compiler doesn't complain
			netClient = new Object();
			netClient.onMetaData = function(meta:Object){}
			ns.client = netClient;			
		}
		
		public function doPlay():void 
		{	
			//ns.seek(0);
			ns.play("test.flv");
			onTimer = new Timer(50, 1);
			onTimer.addEventListener(TimerEvent.TIMER, addVid);
			onTimer.start();
		}
		
		private function addVid(e:TimerEvent):void
		{
			onTimer.removeEventListener(TimerEvent.TIMER, addVid);
			me.addChild(vid);
		}
		
		
		public function removeSelf():void
		{		
			
			if (me.contains(vid)) {
				ns.seek(0);
				ns.close();			
				me.removeChild(vid);
			}
		}
		
		
		/**
		 * Dispatches a mouse click if the video ends
		 * 
		 * @param	stats Net Status Event
		 */
		private function netStat(stats:NetStatusEvent):void
		{
			var c = stats.info.code;
			if (c == "NetStream.Play.Stop") {
				removeSelf();
				dispatchEvent(new Event("videoPlaybackEnded"));
			}
		}
	}	
}