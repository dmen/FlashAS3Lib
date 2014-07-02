package com.gmrmarketing.rbc.etransfer
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.net.*;	
	import flash.media.*;
	import flash.events.*;
	import flash.utils.*;	
	
	
	public class Video extends EventDispatcher  
	{
		public static const VID_SHOWING:String = "videoShowing";
		public static const VID_RESET:String = "vidReset";
		public static const DONE_RECORDING:String = "doneRecording";
		public static const REVIEW:String = "readyForReview";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;	
		private var reviewConnection:NetConnection;
		private var reviewStream:NetStream;
		private var cam:Camera;
		
		private var mic:Microphone;
		//private var micBuffer:Array;
		
		private var curTime:int;
		private var recTimer:Timer;
		private var secTimer:Timer;
		
		private var guidName:String;
		private var isRecording:Boolean;
		
		private var bigPlay:MovieClip;
		private var reviewPath:String;
		
		private var count:MovieClip; //instance of countdown clip in the lib
		
		
		public function Video()
		{
			clip = new mcVideo();
			cam = Camera.getCamera();
			cam.setQuality(0, 90);//bandwidth, quality
			cam.setMode(640, 400, 30, false);//width, height, fps, favorArea
			mic = Microphone.getMicrophone();
			//micBuffer = new Array();
			recTimer = new Timer(1000);
			
			bigPlay = new mcBigPlay();
			bigPlay.x = 955;
			bigPlay.y = 633;
			count = new countdown();
			count.x = 388;
			count.y = 477;
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(guid:String):void
		{
			guidName = guid;//filename
			isRecording = false;
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			recTimer.addEventListener(TimerEvent.TIMER, updateTime, false, 0, true);
			clip.meterMask.scaleY = 1;			
				
			//hide three new - review buttons
			//these get shown when done recording
			clip.btnReview.visible = false;
			clip.btnContinue.visible = false;
			clip.btnReRecord.visible = false;
			clip.btnRev.visible = false;
			clip.btnCon.visible = false;
			clip.btnRer.visible = false;
			if (clip.contains(bigPlay)) {
				clip.removeChild(bigPlay);
			}
			
			//show start stop
			clip.btnStart.visible = true;
			clip.mcStart.visible = true;
			clip.mcStart.gotoAndStop(1); //show start recording
			
			//clip.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, beginRecording, false, 0, true);
			clip.btnRestart.addEventListener(MouseEvent.MOUSE_DOWN, doReset, false, 0, true);
			
			vidConnection = new NetConnection();
			vidConnection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);	
			vidConnection.connect("rtmp://localhost/rbc");	
			
			//for playing back the recorded local file
			reviewConnection = new NetConnection();
			reviewConnection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler2);	
			reviewConnection.connect(null); 
			
			if(reviewStream){
				clip.vidReview.attachNetStream(null);
				clip.vidReview.clear();
				//reviewStream.removeEventListener(NetStatusEvent.NET_STATUS, reviewStreamStatus);
				reviewConnection.close();
			}
			
			//show video on stage
			clip.vid.attachCamera(cam);
			
			clip.alpha = 0;
			clip.vid.alpha = 0;
			clip.blink.alpha = 0; //red recording indicator
			TweenMax.to(clip, 1, {delay:.4, alpha:1, onComplete:vidShowing } );
		}
		
		
		public function hide():void
		{
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, beginRecording);			
			clip.btnRestart.removeEventListener(MouseEvent.MOUSE_DOWN, doReset);
			
			clip.vid.attachCamera(null);
			if(vidStream){
				vidStream.attachCamera(null);
				vidStream.attachAudio(null);			
				vidStream.close();
				mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, micSampleData);
			}
			if(reviewStream){
				clip.vidReview.attachNetStream(null);
				reviewStream.removeEventListener(NetStatusEvent.NET_STATUS, reviewStreamStatus);
				reviewConnection.close();
			}
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			if (clip.contains(count)) {
				clip.removeChild(count);
			}
		}
		
		
		private function vidShowing():void
		{
			TweenMax.to(clip.meterMask, 2, {scaleY:0 } );			
			
			mic.addEventListener(SampleDataEvent.SAMPLE_DATA, micSampleData, false, 0, true);
			
			dispatchEvent(new Event(VID_SHOWING));
			TweenMax.to(clip.vid, 1, { alpha:1, delay:2 } );
		}
		
		
		private function micSampleData(e:SampleDataEvent):void
		{
			clip.meterMask.scaleY = mic.activityLevel / 100;
		}		
		
		
		private function statusHandler(e:NetStatusEvent):void
		{
			if (e.info.code == "NetConnection.Connect.Success")
			{		
				//trace("statusHandler");
				vidStream = new NetStream(vidConnection);
				vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };	
				
				clip.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, beginRecording, false, 0, true);				
				clip.btnRestart.addEventListener(MouseEvent.MOUSE_DOWN, doReset, false, 0, true);
			}
		}
		
		
		private function statusHandler2(e:NetStatusEvent):void
		{
			//trace("statusHandler2:", e.info.code);			
			if (e.info.code == "NetConnection.Connect.Success")
			{			
				reviewStream = new NetStream(reviewConnection);
				reviewStream.addEventListener(NetStatusEvent.NET_STATUS, reviewStreamStatus);
				reviewStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };	
			}
			
		}
		
		
		private function reviewStreamStatus(e:NetStatusEvent):void
		{
			//trace("reviewStreamStatus", e.info.code);
			if (e.info.code == "NetStream.Buffer.Empty") {
				reviewStream.seek(0);
				reviewStream.pause();
				addBigPlay();
			}
		}
		
		
		/**
		 * Called by clicking the begin recording button
		 * Starts the 5 sec countdown and then calls record()
		 * @param	e
		 */
		private function beginRecording(e:MouseEvent):void
		{
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, beginRecording);
			if (!clip.contains(count)) {
				clip.addChild(count);
				count.alpha = 0;
				count.theText.text = "STARTING IN 5 SECONDS";
				TweenMax.to(count, .5, { alpha:1 } );				
				
				secTimer = new Timer(1000, 5);
				secTimer.addEventListener(TimerEvent.TIMER, decrementCounter, false, 0, true);
				secTimer.start();
			}
		}
		
		
		private function decrementCounter(e:TimerEvent):void
		{						
			count.theText.text = "STARTING IN " + String(5 - secTimer.currentCount) + " SECONDS";
			if (secTimer.currentCount == 5) {
				secTimer.removeEventListener(TimerEvent.TIMER, decrementCounter);
				TweenMax.to(count, .5, { alpha:0, onComplete:killCount } );				
			}
		}
		
		
		private function killCount():void
		{
			if (clip.contains(count)) {
				clip.removeChild(count);
			}
			record();
		}
		
		
		private function record():void
		{
			TweenMax.killTweensOf(clip.vid);
			clip.vid.alpha = 1;			
				
			clip.mcStart.gotoAndStop(2); //show stop recording
			curTime = getTimer();
			//clip.mcStart.theTime.text = 15;
			recTimer.start();
			clip.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, stopRecording, false, 0, true);
			
			mic.setSilenceLevel(0);			
			mic.rate = 44; //KHz
			
			vidStream.attachCamera(cam);
			vidStream.attachAudio(mic);
			
			//vidStream.publish("mp4:" + guidName + ".f4v", "record");
			vidStream.publish(guidName, "record"); //flv
			
			isRecording = true;
			showRedBlink();
		}
		
		
		/**
		 * called by recTimer every 1 sec
		 * @param	e
		 */
		private function updateTime(e:TimerEvent):void
		{
			var timeRemaining:int = 15 - (Math.round((getTimer() - curTime) / 1000));
			clip.mcStart.theTime.text = String(timeRemaining);
			if (timeRemaining <= 0) {
				clip.mcStart.theTime.text = 0;
				stopRecording();
				//dispatchEvent(new Event(DONE_RECORDING));//calls videoDone() in main
			}
		}
		
		
		private function showRedBlink():void
		{
			TweenMax.to(clip.blink, 1, { alpha:1, onComplete:hideRedBlink } );
		}
		
		
		private function hideRedBlink():void
		{
			TweenMax.to(clip.blink, 1, { alpha:.1, onComplete:showRedBlink } );
		}
		
		
		/**
		 * Called by clicking the stop recording button
		 * Or called from updateTime() when the 15 seconds is up
		 * @param	e
		 */
		private function stopRecording(e:MouseEvent = null):void
		{			
			recTimer.reset();//stop calling updateTime()
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, stopRecording);
			
			//hide blink
			TweenMax.killTweensOf(clip.blink);
			clip.blink.alpha = 0;			
			
			isRecording = false;
			
			//hide start stop
			clip.btnStart.visible = false;
			clip.mcStart.visible = false;
			
			//show new review buttons
			clip.btnReview.visible = true;
			clip.btnContinue.visible = true;
			clip.btnReRecord.visible = true;			
			clip.btnRev.visible = true;
			clip.btnCon.visible = true;
			clip.btnRer.visible = true;
			clip.btnRev.alpha = 0;
			clip.btnCon.alpha = 0;
			clip.btnRer.alpha = 0;
			TweenMax.to(clip.btnRev, 1, { alpha:1 } );
			TweenMax.to(clip.btnCon, 1, { alpha:1 } );
			TweenMax.to(clip.btnRer, 1, { alpha:1 } );
			
			//if e == null then this was called from doReset
			//if(e != null){
				dispatchEvent(new Event(REVIEW));
			//}
		}
		
		
		public function doReview(path:String):void
		{			
			mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, micSampleData);
			TweenMax.to(clip.meterMask, 1, {scaleY:0 } );
			
			reviewPath = path;
			clip.vidReview.attachNetStream(reviewStream);
			reviewStream.play(reviewPath);
			reviewStream.pause();
			
			TweenMax.delayedCall(1, killRecordVideo);
			
			clip.btnReview.addEventListener(MouseEvent.MOUSE_DOWN, playReview, false, 0, true);
			clip.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, videoComplete, false, 0, true);
			clip.btnReRecord.addEventListener(MouseEvent.MOUSE_DOWN, redo, false, 0, true);
			
			addBigPlay();
		}
		
		
		private function killRecordVideo():void
		{
			clip.vid.attachCamera(null);
			vidStream.attachCamera(null);
			vidStream.attachAudio(null);			
			vidStream.close();
			vidConnection.removeEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			
			//close the connection to FMS - fixes problem with 10 connection max
			vidConnection.close();
		}
				
		
		private function redo(e:MouseEvent):void
		{
			clip.btnStart.visible = true;
			clip.mcStart.visible = true;
			show(guidName);
		}
		
		
		private function addBigPlay():void
		{
			bigPlay.addEventListener(MouseEvent.MOUSE_DOWN, playReview, false, 0, true);
			
			if(!clip.contains(bigPlay)){
				clip.addChild(bigPlay);
				bigPlay.alpha = 0;
				
			}
			TweenMax.to(bigPlay, .5, { alpha:1 } );
		}
		
		
		private function playReview(e:MouseEvent):void
		{
			if (clip.contains(bigPlay)) {
				bigPlay.removeEventListener(MouseEvent.MOUSE_DOWN, playReview);
				TweenMax.to(bigPlay, .5, { alpha:0, onComplete:killBigPlay } );
			}
			reviewStream.resume();		
		}
		
		
		private function killBigPlay():void
		{
			if(clip.contains(bigPlay)){
				clip.removeChild(bigPlay);
			}
		}
		
		
		private function videoComplete(e:MouseEvent):void
		{
			clip.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, videoComplete);			
			dispatchEvent(new Event(DONE_RECORDING));//calls videoDone() in main
		}
		
		
		private function metaDataHandler(infoObject:Object):void
		{}

		
		private function cuePointHandler(infoObject:Object):void
		{}
		
		
		/**
		 * Called if restart button is pressed
		 * @param	e
		 */
		private function doReset(e:MouseEvent):void
		{			
			TweenMax.killTweensOf(count);
			
			secTimer.reset();
			secTimer.removeEventListener(TimerEvent.TIMER, decrementCounter);
			
			recTimer.reset();//stop calling updateTime(
			recTimer.removeEventListener(TimerEvent.TIMER, updateTime);
			
			if(isRecording){
				stopRecording();
			}
			
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, beginRecording);
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, stopRecording);
			clip.btnRestart.removeEventListener(MouseEvent.MOUSE_DOWN, doReset);
			
			dispatchEvent(new Event(VID_RESET));
		}
	}
	
}