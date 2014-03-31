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
		private var nsAudio:NetStream;//stream going _to_ FMS
		private var cam:Camera;
		private var mic:Microphone;
		
		
		public function H264Recorder()
		{
			cam = Camera.getCamera();
			mic = Microphone.getMicrophone();
			
			cam.setQuality(0, 94);
			cam.setMode(800, 450, 24, false);
			cam.setKeyFrameInterval(12);
			
			mic.setSilenceLevel(0);
			mic.rate = 22; //KHz
		}		
		
		
		/**
		 * 
		 * @param	nc NetConnection object
		 * @param	fName File name to save video as
		 */
		public function startRecording(nc:NetConnection, fName:String):void
		{ 
			nsVideo = new NetStream(nc);
			nsAudio = new NetStream(nc);
			
			nsVideo.attachCamera(cam);
			nsAudio.attachAudio(mic);
					
			var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
			//h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_3_1);
			h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_3_1);
			//h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_2);
			//h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_1_2);		
					
			nsVideo.videoStreamSettings = h264Settings;
			//nsVideo.publish("mp4:webCam.f4v", "live");
			nsVideo.publish("mp4:" + fName + ".f4v", "record");
			nsAudio.publish("mp4:" + fName + "_audio.f4v", "record");
					
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
		}
		
		
		/**
		 * Detaches camera and mic from the netStream objects
		 */
		public function stopRecording():void
		{
			nsVideo.attachCamera(null);
			nsAudio.attachAudio(null);
			
			nsVideo.close();	
			nsAudio.close();	
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
		
	}
	
}