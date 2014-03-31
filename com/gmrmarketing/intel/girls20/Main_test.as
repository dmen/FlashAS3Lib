package com.gmrmarketing.intel.girls20
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.*;	
	import flash.media.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.GUID;
	
	
	
	public class Main extends MovieClip
	{		
		private var cam:Camera;
		private var mic:Microphone;
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;
		
		private var vidTimer:Timer;
		private var curCount:int = 30;		
		
		
		
		public function Main()
		{
			vidTimer = new Timer(1000);
			vidTimer.addEventListener(TimerEvent.TIMER, decrementCount, false, 0, true);
			
			vidConnection = new NetConnection();
			vidConnection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);	
			vidConnection.connect("rtmp://localhost/intel/test");
			
			cam = Camera.getCamera();
			cam.setQuality(0,95);
			cam.setMode(600, 400, 30);
			
			//show video on stage
			vid.attachCamera(cam);
			
			mic = Microphone.getMicrophone();			
		
			btn.addEventListener(MouseEvent.CLICK, stopRecording);
		}
		
		private function statusHandler(e:NetStatusEvent):void
		{			
			if (e.info.code == "NetConnection.Connect.Success")
			{		
				vidStream = new NetStream(vidConnection);
				vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };				
				
				btnRec.addEventListener(MouseEvent.CLICK, beginRecording, false, 0, true);
			}
		}
		
		private function beginRecording(e:MouseEvent):void
		{
			mic.setSilenceLevel(0);
			
			vidStream.attachCamera(cam);
			vidStream.attachAudio(mic);
			vidStream.publish(GUID.create(), "record");
			
			vidTimer.start();
		}
		
		private function stopRecording(e:MouseEvent = null):void
		{
			vidStream.close();
			vidTimer.stop();
		}

		private function metaDataHandler(infoObject:Object):void
		{}

		private function cuePointHandler(infoObject:Object):void
		{}
		
		private function decrementCount(e:TimerEvent):void
		{
			curCount--;
			theTimer.text = String(curCount);
			if (curCount <= 0) {
				stopRecording();
			}
		}	
		
	}
	
}