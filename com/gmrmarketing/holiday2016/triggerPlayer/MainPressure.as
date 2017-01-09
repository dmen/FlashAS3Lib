package com.gmrmarketing.holiday2016.triggerPlayer
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.ui.*;
	import flash.media.Video;
	
	
	public class MainPressure extends MovieClip
	{
		private const LOCALHOST:String = "127.0.0.1";//loopback address to talk to serproxy
		private var threshold:int;
		private var socket:Socket;//connection to serproxy for DMX controller
		private var socketStatus:Boolean;//true if connected to serproxy
		private var readBuffer:String = "";
		private var waitingToStart:Boolean; //true once the sensor threshold is below
		private var startTimer:Timer;//satrted when the sensor is weighted
		private var resetTimer:Timer;//started when the sensor is unweighted
		private var config:MovieClip;
		
		private var nc:NetConnection;
		private var ns:NetStream;
		private var vClient:Object;
		private var video:Video;
		private var isVideoPlaying:Boolean;
		private var isSensorReset:Boolean;
		
		
		public function MainPressure()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			//Mouse.hide();			
			
			waitingToStart = false;			
			socketStatus = false;
			
			socket = new Socket();
			socket.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			socket.addEventListener(Event.CONNECT, doSocketConnect );//called when the socket connects
			socket.addEventListener(Event.CLOSE, doSocketClose );//called if the socket is closed... should never be called
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			
			startTimer = new Timer(60, 1);
			startTimer.addEventListener(TimerEvent.TIMER, startVideo);
			
			resetTimer = new Timer(5000, 1);
			resetTimer.addEventListener(TimerEvent.TIMER, sensorReset);
			
			config = new mcConfig();
			addChild(config);
			config.thresh.addEventListener(Event.CHANGE, threshChanged, false, 0, true);
			config.time.addEventListener(Event.CHANGE, timeChanged, false, 0, true);
			
			nc = new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			
			vClient = new Object();
			vClient.onCuePoint = cuePointHandler;
			vClient.onMetaData = metaDataHandler;
			
			ns.client = vClient;
			
			video = new Video(1920, 1080);
			video.attachNetStream(ns);
			addChildAt(video, 0);
			
			isVideoPlaying = false;//true if currently playing
			isSensorReset = true; //ready to play 'again'

			connectToSerproxy();
			threshChanged();
			timeChanged();
		}
		
		
		private function connectToSerproxy():void
		{
			if(!socketStatus){
				socket.connect(LOCALHOST, 5331);				
			}
		}
		
		
		private function errorHandler(e:IOErrorEvent):void 
		{    
			trace("IOError - socketStatus is now false");
			socketStatus = false;
		}
		
		
		private function doSocketConnect(e:Event):void 
		{
			trace("serproxy connected - socketStatus is now true");
			socketStatus = true;
		}
		
		
		private function doSocketClose(e:Event):void 
		{
			trace("doSocketClose() - socketStatus is now false");
			socketStatus = false;
		}
		
		
		private function socketDataHandler(e:ProgressEvent):void
		{
			var ind:int;
			var sensorDistance:int;
			
			readBuffer += socket.readUTFBytes(socket.bytesAvailable); 
			
			//the # is the delimiter from the arduino
			ind = readBuffer.indexOf("#");			
			if (ind != -1){				
				
				sensorDistance = parseInt(readBuffer.substr(0, ind));
				config.dist.text = sensorDistance.toString();
				readBuffer = "";				
				
				if (sensorDistance > threshold){
					//sensor is weighted
					if (!startTimer.running){						
						startTimer.start();
						resetTimer.reset();
					}
					
				}else{					
					//sensor is not weighted
					//if (startTimer.running){
						startTimer.reset();
						resetTimer.start();
					//}
				}				
			}
		}
		

		/**
		 * called after 5 seconds if the reset timer times out
		 * 
		 * @param	e
		 */
		private function sensorReset(e:TimerEvent):void
		{
			isSensorReset = true;
		}
		
		
		/**
		 * called if startTimer reaches it's timeout
		 * @param	e
		 */
		private function startVideo(e:TimerEvent = null):void
		{			
			if(isSensorReset){
			
				if (!isVideoPlaying){
					if (!contains(video)){
						addChildAt(video, 0);
					}
					ns.play("assets/video.mp4");
					isVideoPlaying = true;
					isSensorReset = false;
				}
			}
		}
		
		
		private function netStatusHandler(e:NetStatusEvent):void 
		{
			if (e.info.code == "NetStream.Play.Stop") {
				isVideoPlaying = false;
				if (contains(video)){
					removeChild(video);
				}
			}
		}
		
		
		private function threshChanged(e:Event = null):void
		{
			threshold = parseInt(config.thresh.text);
		}
		
		
		private function timeChanged(e:Event = null):void
		{		
			if(config.time.text != ""){
				startTimer.delay = parseInt(config.time.text);
			}
		}
		
		
		private function cuePointHandler(infoObject:Object):void 
		{
			trace("cuePoint");
		}
		
		
		private function metaDataHandler(infoObject:Object):void
		{
			trace("metaData");
		}
		
	}
	
}