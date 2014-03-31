package com.gmrmarketing.testing
{
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.net.*;	
	import flash.media.*;
	import flash.events.*;
	import flash.utils.Timer;
	
	public class Capture extends MovieClip 
	{
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;		
		private var cam:Camera;
		private var mic:Microphone;
		private var recordTimer:Timer;
		private var curTime:int;
		
		
		public function Capture()
		{
			cam = Camera.getCamera();
			init();
			recordTimer = new Timer(1000);
			recordTimer.addEventListener(TimerEvent.TIMER, updateTime, false, 0, true);			
		}
		
		private function init():void
		{
			vidConnection = new NetConnection();
			vidConnection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);	
			vidConnection.connect("rtmp://localhost/telusCap");
			
			cam.setQuality(0, 84);//bandwidth, quality
			cam.setMode(640, 400, 30, false);//width, height, fps, favorArea
			
			//show video on stage
			vid.attachCamera(cam);
			
			mic = Microphone.getMicrophone();	
		}
		
		
		private function statusHandler(e:NetStatusEvent):void
		{
			if (e.info.code == "NetConnection.Connect.Success")
			{		
				vidStream = new NetStream(vidConnection);
				vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };	
				
				btn.addEventListener(MouseEvent.MOUSE_DOWN, beginRecording, false, 0, true);				
			}
		}
		
		
		private function beginRecording(e:MouseEvent):void
		{	
			status.text = "RECORDING";
			recordTimer.start();
			curTime = 0;
			
			mic.setSilenceLevel(0);			
			mic.rate = 44; //KHz
			
			vidStream.attachCamera(cam);
			vidStream.attachAudio(mic);			
			vidStream.publish("mp4:testing.f4v", "record"); //makes a sorenson flv
			//vidStream.publish("mp4:" + userGUID + ".f4v", "record");
			
			btn.removeEventListener(MouseEvent.MOUSE_DOWN, beginRecording);
			btn.addEventListener(MouseEvent.MOUSE_DOWN, stopRecording, false, 0, true);
		}
		
		/**
		 * Called by clicking the Finished button
		 * Called from decrementCount() when the 30 seconds is up
		 * @param	e
		 */
		private function stopRecording(e:MouseEvent = null):void
		{
			status.text = "STOPPED";
			recordTimer.stop();
			
			vidStream.close();
			vidStream.attachCamera(null);
			vidStream.attachAudio(null);			
			
			//close the connection to FMS - fixes problem with 10 connection max
			vidConnection.close();
		}
		
		private function updateTime(e:TimerEvent):void
		{
			curTime++; //seconds
			theTime.text = String(curTime);
		}
		
		private function metaDataHandler(infoObject:Object):void
		{}

		
		private function cuePointHandler(infoObject:Object):void
		{}
		
	}
	
}