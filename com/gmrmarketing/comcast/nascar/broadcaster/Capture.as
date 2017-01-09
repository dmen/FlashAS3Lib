package com.gmrmarketing.comcast.nascar.broadcaster
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.media.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.GUID;	
	import flash.filesystem.File;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Capture extends EventDispatcher
	{
		public static const COMPLETE:String = "captureComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		private var vid:Video;
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;		
		private var cam:Camera;
		private var mic:Microphone;
		
		private var countdownTimer:Timer;//one second timer for counting 3-2-1 before rerding begins
		private var recordingTimer:Timer;//one second timer for counting down recording time remaining
		private var count:int;
		private var timeRemaining:int; //set in show()
		
		private var outputFileName:String;
		
		private var encode:Encode;
		
		private var tim:TimeoutHelper;
		
		
		public function Capture()
		{
			vid = new Video();//users video			
			
			countdownTimer = new Timer(1000);
			recordingTimer = new Timer(1000);
			
			encode = new Encode();
			
			clip = new mcCapture();
			clip.x = 112;
			clip.y = 90;
			
			tim = TimeoutHelper.getInstance();
			
			//USER
			cam = Camera.getCamera();
			cam.setQuality(750000, 0);//bandwidth, quality
			cam.setMode(640, 360, 24, false);//width, height, fps, favorArea
			
			mic = Microphone.getMicrophone();
			mic.setSilenceLevel(0);			
			mic.rate = 44; //KHz
			
			vidConnection = new NetConnection();
			vidConnection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);	
			vidConnection.connect("rtmp://localhost/comcastBTB");
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(whichOption:int):void
		{
			tim.buttonClicked();
			
			//outputFileName = rfid;
			
			//trace("capture.show");
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
				
				clip.addChildAt(vid, 0);
			}
			
			clip.raceClip.seek(0);
			clip.raceClip.alpha = 0; //racing video for option 3
			
			clip.recordingTime.alpha = 0;
			clip.recording.alpha = 0;//red dot upper left
			clip.beginRecording.alpha = 0;
			clip.beginRecording.scaleX = clip.beginRecording.scaleY = 0;
			clip.beginRecording.theText.text = "3";
			
			clip.theScript.alpha = 0;			
			clip.theScript.gotoAndStop(whichOption);
			
			if (whichOption == 3) {
				//show the race clip
				timeRemaining = 30; //length of sample clip
				
				vid.width = 640
				vid.height = 360;
				vid.x = 1096; 
				vid.y = 0;								
				
				clip.recordingTime.x = 1581;
				clip.recordingTime.y = 388;
				
				clip.beginRecording.x = 1310;
				clip.beginRecording.y = 0;
				
				clip.raceClip.source = "assets/raceClip_d.mp4";
				//clip.raceClip.play();
				TweenMax.to(clip.raceClip, 1, { alpha:1, delay:.5 } );
				
			}else if (whichOption == 2){
				
				//show the race clip
				timeRemaining = 16; //length of sample clip
				
				vid.width = 640
				vid.height = 360;
				vid.x = 1096; 
				vid.y = 0;								
				
				clip.recordingTime.x = 1581;
				clip.recordingTime.y = 388;
				
				clip.beginRecording.x = 1310;
				clip.beginRecording.y = 0;
				
				clip.raceClip.source = "assets/raceClip_c.mp4";
				//clip.raceClip.play();
				TweenMax.to(clip.raceClip, 1, { alpha:1, delay:.5 } );
				
			}else {
				timeRemaining = 30;
				
				vid.width = 1920
				vid.height = 1080;
				vid.x = -112; 
				vid.y = -90;
				
				clip.recordingTime.x = 1567;
				clip.recordingTime.y = 0;
				
				clip.beginRecording.x = 1288;
				clip.beginRecording.y = 0;
				
			}
			
			clip.recordingTime.theText.text = ":" + timeRemaining.toString();
			
			TweenMax.to(clip.theScript, .5, { alpha:1 } );
			TweenMax.to(clip.recordingTime, .5, { alpha:1, delay:.5 } );
			TweenMax.to(clip.beginRecording, .5, { alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, delay:1, onComplete:startCountDown } );
		}
		
		
		private function startCountDown():void
		{
			count = 3;
			countdownTimer.addEventListener(TimerEvent.TIMER, decrementCount, false, 0, true);
			countdownTimer.start();
		}
		
		
		private function decrementCount(e:TimerEvent):void
		{
			count--;
			clip.beginRecording.theText.text = count.toString();
			if (count <= 0) {
				countdownTimer.removeEventListener(TimerEvent.TIMER, decrementCount);
				countdownTimer.reset();
				TweenMax.to(clip.beginRecording, .5, { alpha:0 } );
				TweenMax.to(clip.recording, .5, { alpha:1 } );
				clip.raceClip.play();
				doRecordUser();
			}
		}
		
		
		private function initCams():void
		{/*
			//USER
			cam = Camera.getCamera();
			cam.setQuality(750000, 0);//bandwidth, quality
			cam.setMode(640, 360, 24, false);//width, height, fps, favorArea
			
			mic = Microphone.getMicrophone();
			mic.setSilenceLevel(0);			
			mic.rate = 44; //KHz
			
			vidConnection = new NetConnection();
			vidConnection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);	
			vidConnection.connect("rtmp://localhost/reesesGameday");
			
			clip.userVid.addChildAt(vid, 0);
			vid.x = 20; 
			vid.y = 20;
				*/
		}
		
		
		public function hide():void
		{
			//trace("capture.hide");
			//clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, cancelPressed);
			
			if(clip.contains(vid)){
				clip.removeChild(vid);
			}
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			/*
			//attach null to vidstream first
			if(vidStream){
				vidStream.attachAudio(null);
				vidStream.attachCamera(null);
				vidStream.close();
			}
			
			vid.attachCamera(null);
			cam = null;
			mic = null;
			vidStream = null;
			*/
			
		}
		
		
		//gets the GUID created in stopRecording and fed to encode
		//used to name to mp4 placed into the applicationStorage folder
		public function get fileName():String
		{
			return outputFileName;
		}
		
		
				
		
		//callback for vidConnection object
		private function statusHandler(e:NetStatusEvent):void
		{			
			//trace("Capture.statusHandler:", e.info.code);
			
			if (e.info.code == "NetConnection.Connect.Success")
			{		
				vidStream = new NetStream(vidConnection);
				vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };			
				
				vidStream.attachCamera(cam);
				vidStream.attachAudio(mic);	
				
				vid.attachCamera(cam);
			}
		}
		
		
		private function doRecordUser():void
		{			
			//vidStream.attachCamera(cam);
			//vidStream.attachAudio(mic);	
			vidStream.soundTransform.volume = .7;
			vidStream.publish("user", "record"); //flv
			
			myContainer.stage.addEventListener(KeyboardEvent.KEY_DOWN, checkForStopRecording, false, 0, true);
			
			recordingTimer.addEventListener(TimerEvent.TIMER, updateTimer, false, 0, true);
			recordingTimer.start();
			
			if (clip.theScript.currentFrame == 3) {
				clip.raceClip.play();
				clip.raceClip.volume = 0;
			}
		}
		
		
		/**
		 * Looks for PageUp or PageDown KeyCode from remote and cancel recording
		 * @param	e
		 */
		private function checkForStopRecording(e:KeyboardEvent):void
		{
			tim.buttonClicked();
			
			if (e.keyCode == 33 || e.keyCode == 34) {
				recordingTimer.reset();
				recordingTimer.removeEventListener(TimerEvent.TIMER, updateTimer);
				stopRecording();
			}
		}
		
		
		private function updateTimer(e:TimerEvent):void
		{
			timeRemaining--;
			clip.recordingTime.theText.text = ":" + timeRemaining.toString();
			
			if (timeRemaining <= 0) {
				
				recordingTimer.reset();
				recordingTimer.removeEventListener(TimerEvent.TIMER, updateTimer);				
				stopRecording();
			}			
		}
		
		
		private function stopRecording():void
		{
			tim.buttonClicked();
			
			myContainer.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkForStopRecording);			
			
			TweenMax.to(clip.recording, .5, { alpha:0 } );
			
			//vidStream.attachCamera(null);
			//vidStream.attachAudio(null);	
			vidStream.close();
			
			outputFileName = GUID.create();
			
			encode.addEventListener(Encode.COMPLETE, recordingComplete, false, 0, true);		
			encode.doEncode(outputFileName);
		}
		
		
		private function recordingComplete(e:Event):void
		{
			encode.removeEventListener(Encode.COMPLETE, recordingComplete);
			dispatchEvent(new Event(COMPLETE));
		}
	
		
		
		private function metaDataHandler(infoObject:Object):void
		{}

		
		private function cuePointHandler(infoObject:Object):void
		{}
		
	}
	
}