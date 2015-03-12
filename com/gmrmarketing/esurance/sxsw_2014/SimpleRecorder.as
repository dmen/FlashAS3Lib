package com.gmrmarketing.esurance.sxsw_2014
{
	import flash.display.*
	import flash.events.*
	import flash.net.*;	
	import flash.media.*;
	import flash.utils.Timer;	
	import flash.media.H264VideoStreamSettings;
	import flash.media.H264Level;
	import flash.media.H264Profile;
	
	
	public class SimpleRecorder extends MovieClip  
	{	
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;		
		private var cam:Camera;
		private var mic:Microphone;
		
		
		public function SimpleRecorder()
		{			
			cam = Camera.getCamera();
			cam.setQuality(0,100);//bandwidth, quality
			cam.setMode(640, 352, 29.97, false);//width, height, fps, favorArea
			cam.setKeyFrameInterval(12);
			mic = Microphone.getMicrophone();	
			
			vidConnection = new NetConnection();
			vidConnection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);	
			vidConnection.connect("rtmp://localhost/esurance");
			vidConnection.client = this;
		}
		
		
		private function statusHandler(e:NetStatusEvent):void
		{
			if (e.info.code == "NetConnection.Connect.Success")
			{		
				vidStream = new NetStream(vidConnection);
				vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };				
				beginRecording();
			}
		}
		
		
		private function beginRecording():void
		{
			var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
			h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_3_1);
			h264Settings.setMode(640, 352, 29.97); 
			
			mic.setSilenceLevel(0);			
			mic.rate = 44; //KHz
			
			vidStream.attachCamera(cam);
			vidStream.attachAudio(mic);
			
			vidStream.videoStreamSettings = h264Settings;
			vidStream.publish("mp4:test.f4v", "record");
			
			var metaData:Object = new Object();
			metaData.codec = vidStream.videoStreamSettings.codec;
			metaData.profile = h264Settings.profile;
			metaData.level = h264Settings.level;
			metaData.fps = cam.fps;
			metaData.bandwith = cam.bandwidth;
			metaData.height = cam.height;
			metaData.width = cam.width;
			metaData.keyFrameInterval = cam.keyFrameInterval;
			
			vidStream.send("@setDataFrame", "onMetaData", metaData);	
			
			btn.addEventListener(MouseEvent.MOUSE_DOWN, stopRecording);
		}
		
		
		private function stopRecording(e:MouseEvent = null):void
		{			
			btn.removeEventListener(MouseEvent.MOUSE_DOWN, stopRecording);			
			
			vidStream.attachCamera(null);
			vidStream.attachAudio(null);			
			vidStream.close();
			
			//close the connection to FMS - fixes problem with 10 connection max
			vidConnection.close();
		}		
		
		
		private function metaDataHandler(infoObject:Object):void
		{}

		
		private function cuePointHandler(infoObject:Object):void
		{}
		
	}
	
}