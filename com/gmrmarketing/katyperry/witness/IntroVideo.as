package com.gmrmarketing.katyperry.witness
{
	import flash.display.*;
	import flash.events.*;	
	import flash.media.*;
	import flash.net.*;
	
	
	public class IntroVideo extends EventDispatcher
	{
		public static const COMPLETE:String = "introVideoComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var theVideo:Video;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var cbOBject:Object;
		
		
		public function IntroVideo()
		{
			clip = new introVideo();
			cbOBject = new Object();
			theVideo = new Video(1280, 720);
			theVideo.x = 320;
			theVideo.y = 180;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			if (!clip.contains(theVideo)){
				clip.addChild(theVideo);
			}
			
			nc = new NetConnection();
			nc.connect(null);
			
			ns = new NetStream(nc);
			ns.client = cbOBject;
			ns.play("assets/introVideo.mp4");
			
			theVideo.attachNetStream(ns);
			
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		}
		
		
		public function hide():void
		{
			theVideo.clear();
			nc = null;
			ns = null;
			
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			
			if (clip.contains(theVideo)){
				clip.removeChild(theVideo);
			}
		}
		
		
		private function asyncErrorHandler(event:AsyncErrorEvent):void 
		{ 
		   //ignore metadata error message
		}
		
		
		private function netStatusHandler(e:NetStatusEvent):void
		{
			if (e.info.code == "NetStream.Play.Stop") {
				dispatchEvent(new Event(COMPLETE));
			}
		}
		
	}
	
}