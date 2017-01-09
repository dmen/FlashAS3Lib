package com.gmrmarketing.holiday2016.triggerPlayer
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.ui.*;
	import fl.video.*;
	
	
	public class Main extends MovieClip
	{
		private const LOCALHOST:String = "127.0.0.1";//loopback address to talk to serproxy
		private var threshold:int;
		private var socket:Socket;//connection to serproxy for DMX controller
		private var socketStatus:Boolean;//true if connected to serproxy
		private var readBuffer:String = "";
		private var waitingToStart:Boolean; //true once the sensor threshold is below
		private var startTimer:Timer;//satrted when the distance is below the activation distance
		
		private var config:MovieClip;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			//Mouse.hide();
			
			threshold = 50;
			waitingToStart = false;
			
			player.source = "assets/test.mp4";
			player.seek(0);
			player.fullScreenTakeOver = false;
			
			socketStatus = false;
			
			socket = new Socket();
			socket.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			socket.addEventListener(Event.CONNECT, doSocketConnect );//called when the socket connects
			socket.addEventListener(Event.CLOSE, doSocketClose );//called if the socket is closed... should never be called
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			
			startTimer = new Timer(60, 1);
			startTimer.addEventListener(TimerEvent.TIMER, startVideo, false, 0, true);
			
			config = new mcConfig();
			addChild(config);
			config.thresh.addEventListener(Event.CHANGE, threshChanged, false, 0, true);
			config.time.addEventListener(Event.CHANGE, timeChanged, false, 0, true);

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
		
		
		private function socketDataHandler(event:ProgressEvent):void
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
				
				if (sensorDistance < threshold){
					//something within the range
					if (!startTimer.running){						
						startTimer.start();
					}
					
				}else{					
					//nothing within the range
					if (startTimer.running){
						startTimer.reset();
					}
				}				
			}
		}
		

		
		/**
		 * called if startTimer reaches it's timeout
		 * @param	e
		 */
		private function startVideo(e:TimerEvent = null):void
		{			
			trace("start");
			if (!player.playing){
				player.source = "assets/test.mp4";
			player.seek(0);
				player.addEventListener(fl.video.VideoEvent.COMPLETE, videoFinished, false, 0, true);
				player.play();
			}
		}
		
		
		private function videoFinished(e:fl.video.VideoEvent):void
		{
			trace("vidDone");
			player.seek(0);
			player.stop();
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
		
	}
	
}