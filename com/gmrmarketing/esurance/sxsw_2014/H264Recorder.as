package com.gmrmarketing.esurance.sxsw_2014
{
	import flash.events.*;
	import flash.net.*;	
	import flash.media.*;
	import flash.display.*;
	import flash.text.*;
	
	
	public class H264Recorder extends EventDispatcher
	{	
		private var nsVideo:NetStream;//stream going _to_ FMS
		private var cam:Camera;
		private var mic:Microphone;
		
		
		public function H264Recorder()
		{
			cam = Camera.getCamera();
			cam.setQuality(0, 100);
			cam.setMode(640, 352, 24, false);
			cam.setKeyFrameInterval(12);
			
			mic = Microphone.getMicrophone();
			mic.setSilenceLevel(0);
			mic.rate = 44; //KHz
		}		
		
		
		/**
		 * 
		 * @param	nc NetConnection object
		 * @param	fName File name to save video as
		 */
		public function startRecording(nc:NetConnection, fName:String):void
		{ 
			nsVideo = new NetStream(nc);
			nsVideo.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };
			
			nsVideo.attachCamera(cam);
			nsVideo.attachAudio(mic);
					
			var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
			h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_3_1);
			h264Settings.setMode(640, 352, 29.97);	
					
			//nsVideo.videoStreamSettings = h264Settings;			
			//nsVideo.publish("mp4:" + fName + ".f4v", "record");
			nsVideo.publish(fName, "record");//flv
				/*	
			var metaData:Object = new Object();
			metaData.codec = nsVideo.videoStreamSettings.codec;
			metaData.profile = h264Settings.profile;
			metaData.level = h264Settings.level;
			metaData.fps = cam.fps;
			metaData.bandwith = cam.bandwidth;
			metaData.height = cam.height;
			metaData.width = cam.width;
			metaData.keyFrameInterval = cam.keyFrameInterval;
			
			nsVideo.send("@setDataFrame", "onMetaData", metaData);		
			*/
		}
		
		
		/**
		 * Detaches camera and mic from the netStream objects
		 */
		public function stopRecording():void
		{
			nsVideo.attachCamera(null);
			nsVideo.attachAudio(null);
			nsVideo.close();
		}
		
		
		/**
		 * Returns the camera object. Useful for attaching
		 * to a video object so you can see the webcam recording
		 * @return
		 */
		public function getCamera():Camera
		{
			return cam;
		}
		
		
		private function metaDataHandler(infoObject:Object):void
		{}

		
		private function cuePointHandler(infoObject:Object):void
		{}
		
	}
	
}