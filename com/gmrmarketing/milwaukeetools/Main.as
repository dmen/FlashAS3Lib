package com.gmrmarketing.milwaukeetools
{
	import flash.display.MovieClip;	
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.SecurityErrorEvent;
	import flash.display.LoaderInfo; //for flashVars
	
	public class Main extends MovieClip
	{
		private const S3_URL:String = "rtmpe://s1apoylgks09wv.cloudfront.net/cfx/st";
		private var nc:NetConnection;
		private var ns:NetStream;
		private var cl:Object; 
		private var playing:Boolean = false;
		private var lang:String;
		
		
		public function Main()
		{
			lang = loaderInfo.parameters.language;			
			
			cl = new Object();
			cl.onPlayStatus = onPlayStatus;
			cl.onMetaData = onMetaData;			

			nc = new NetConnection();
			nc.client = cl;
			
			nc.addEventListener(NetStatusEvent.NET_STATUS, status, false, 0, true);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			btn.addEventListener(MouseEvent.CLICK, playStop, false, 0, true);
			btn.theText.mouseEnabled = false;
			btn.buttonMode = true;
			
			nc.connect(S3_URL);
		}
		
		
		
		private function playStop(e:MouseEvent = null):void
		{
			playing = !playing;
			if (playing) {
				if (lang == "es"){
					btn.theText.text = "MÚSICA";
				}else {
					btn.theText.text = "MUSIC OFF";					
				}
				btn.theText.alpha = 1;
				playTrack();
			}else {
				if (lang == "es") {
					btn.theText.text = "MÚSICA";					
				}else {
					btn.theText.text = "MUSIC ON";
				}
				btn.theText.alpha = .5;
				stopTrack();
			}
		}
		
		
		
		private function status(e:NetStatusEvent):void
		{			
			if (e.info.code == "NetConnection.Connect.Success") {
				connectStream();
			}else {
				trace(e.info.code);			 
			}
		}
		
		private function connectStream():void
		{
			ns = new NetStream(nc);
			ns.client = cl;
			playStop();
		}
		
		private function stopTrack():void
		{
			ns.close();
		}
		
		private function playTrack():void
		{
			stopTrack();
			ns.play("mp3:MilwaukeeTool/Take You Down");
		}
		
		private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			trace("Security Error", e);
		}
		
		
		
		// NET CONNECTION CLIENT CALLBACKS
		public function onMetaData(info:Object):void
		{
			trace("onMetaData:", info.duration, info.framerate);
		}
		public function onPlayStatus(info:Object):void
		{			
			if (info.code == "NetStream.Play.Complete") {				
				playTrack();
			}
		}
	}
	
}