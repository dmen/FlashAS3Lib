package com.gmrmarketing.esurance.sxsw_2014
{
	import flash.events.*;
	import flash.net.*;	
	import flash.media.*;
	import flash.display.*;
	import flash.text.*;
	
	
	public class FLVRecorder extends EventDispatcher
	{	
		private var nsVideo:NetStream;//stream going _to_ FMS		
		private var cam:Camera;
		private var mic:Microphone;
		
		
		public function FLVRecorder()
		{
			cam = Camera.getCamera();
			mic = Microphone.getMicrophone();
		}		
		
		
		/**
		 * 
		 * @param	nc NetConnection object
		 * @param	fName File name to save video as
		 */
		public function startRecording(nc:NetConnection, fName:String):void
		{ 
			nsVideo = new NetStream(nc);			
			nsVideo.attachCamera(cam);
			nsVideo.attachAudio(mic);					
			
			cam.setQuality(0, 82);
			cam.setMode(650, 365, 24, false);//800x450 too much for I5
			cam.setKeyFrameInterval(12);
			
			mic.setSilenceLevel(0);
			mic.rate = 11; //KHz
			
			nsVideo.publish(fName, "record");
		}
		
		
		/**
		 * Detaches camera and mic from the netStream object
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
		
	}
	
}