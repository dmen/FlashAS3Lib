package com.gmrmarketing.holiday2016.triggerPlayer
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.ui.*;
	import flash.net.*;
	import flash.media.Video;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class MainSensor extends MovieClip
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
		private var usingSonar:Boolean;
		
		private var sonarVideos:Array;
		private var weightVideos:Array;
		
		private var loader:URLLoader;
		private var jsonConfig:Object;
		
		
		public function MainSensor()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;					
			
			waitingToStart = false;			
			socketStatus = false;
			
			sonarVideos = ["assets/tree.mp4", "assets/tree.mp4", "assets/tree.mp4"];
			weightVideos = ["assets/column.mp4", "assets/column.mp4", "assets/column.mp4"];
			
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
			config.x = 840;
			config.y = -1080;
			config.thresh.addEventListener(Event.CHANGE, threshChanged);
			config.time.addEventListener(Event.CHANGE, timeChanged);
			config.btnSonar.addEventListener(MouseEvent.MOUSE_DOWN, useSonar);
			config.btnWeight.addEventListener(MouseEvent.MOUSE_DOWN, useWeight);
			config.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeConfig);			
			
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
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			
			connectToSerproxy();
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseJSON);
			loader.load(new URLRequest("config.json"));
		}
		
		
		private function parseJSON(e:Event):void
		{
			jsonConfig = JSON.parse(loader.data);			
			
			config.thresh.text = jsonConfig.threshold;
			config.time.text = jsonConfig.startTime;
			
			threshChanged();
			timeChanged();
			
			if (jsonConfig.sensor == "sonar"){
				useSonar();
			}else{
				useWeight();
			}
		}
		
		
		private function connectToSerproxy():void
		{
			if(!socketStatus){
				socket.connect(LOCALHOST, 5331);				
			}
		}
		
		
		private function errorHandler(e:IOErrorEvent):void 
		{    
			log("IOError - socketStatus is now false");
			log("Make sure serproxy is running");
			socketStatus = false;
		}
		
		
		private function doSocketConnect(e:Event):void 
		{
			log("serproxy connected - socketStatus is now true");
			socketStatus = true;
		}
		
		
		private function doSocketClose(e:Event):void 
		{
			log("doSocketClose() - socketStatus is now false");
			socketStatus = false;
		}
		
		
		private function socketDataHandler(e:ProgressEvent):void
		{
			var ind:int;
			var sensorValue:int;
			
			readBuffer += socket.readUTFBytes(socket.bytesAvailable); 
			
			//the # is the delimiter from the arduino
			ind = readBuffer.indexOf("#");			
			if (ind != -1){				
				
				sensorValue = parseInt(readBuffer.substr(0, ind));
				config.dist.text = sensorValue.toString();
				readBuffer = "";	
				
				if (usingSonar){
					if (sensorValue < threshold){
						log("something in range");
						if (!startTimer.running){						
							startTimer.start();
							resetTimer.reset();
						}
					}else{
						log("nothing in range");
						startTimer.reset();
						resetTimer.start();
					}
					
				}else{
					if (sensorValue > threshold){
						log("sensor is weighted");
						if (!startTimer.running){						
							startTimer.start();
							resetTimer.reset();
						}
					}else{
						log("sensor is not weighted");
						startTimer.reset();
						resetTimer.start();
					}					
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
			log("sensor reset true");
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
					ns.play(getVideo());
					isVideoPlaying = true;
					isSensorReset = false;
					log("sensor reset false");
				}
			}
		}
		
		
		private function getVideo():String
		{
			var ind:int;
			
			if (usingSonar){
				ind = Math.floor(Math.random() * sonarVideos.length);
				return sonarVideos[ind];
			}else{
				ind = Math.floor(Math.random() * weightVideos.length);
				return weightVideos[ind];
			}
			
		}
		
		
		private function netStatusHandler(e:NetStatusEvent):void 
		{
			log(e.info.code);
			if (e.info.code == "NetStream.Play.Stop") {
				isVideoPlaying = false;
				if (contains(video)){
					removeChild(video);
				}
			}
		}
		
		
		private function threshChanged(e:Event = null):void
		{
			if(config.thresh.text != ""){
				threshold = parseInt(config.thresh.text);
			}
		}
		
		
		private function timeChanged(e:Event = null):void
		{		
			if(config.time.text != ""){
				startTimer.delay = parseInt(config.time.text);
			}
		}
		
		
		private function cuePointHandler(infoObject:Object):void {}
		
		
		private function useSonar(e:MouseEvent = null):void
		{
			config.radioSonar.gotoAndStop(2);
			config.radioWeight.gotoAndStop(1);
			usingSonar = true;
		}
		
		private function useWeight(e:MouseEvent = null):void
		{
			config.radioSonar.gotoAndStop(1);
			config.radioWeight.gotoAndStop(2);
			usingSonar = false;
		}
		
		
		private function closeConfig(e:MouseEvent):void
		{
			TweenMax.to(config, .5, {y:-1080, ease:Expo.easeIn});
			Mouse.hide();
		}
		
		
		private function keyPressed(e:KeyboardEvent):void
		{
			if (e.charCode == 99){
				TweenMax.to(config, .5, {y:0, ease:Expo.easeOut});
				Mouse.show();
			}
		}	
		
		
		private function metaDataHandler(infoObject:Object):void
		{
			trace("metaData");
		}
		
		
		private function log(m:String):void
		{
			config.console.appendText(m + "\n");
			config.console.scrollV = config.console.maxScrollV;
			if (config.console.numLines > 50){
				config.console.text = "";
			}
		}
		
	}
	
}