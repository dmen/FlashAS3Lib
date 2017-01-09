/**
 * Controls the Philips Bridge Hue lights, the DMX
 * controller for the background (using serproxy)
 * and the audio for the given mood
 */
package com.gmrmarketing.nestle.dolcegusto2016.photobooth
{
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;	
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	
	
	
	public class MoodControl extends EventDispatcher
	{
		public static const LOG_READY:String = "logEntryReady";
		
		private const LOCALHOST:String = "127.0.0.1";//loopback address to talk to serproxy		
		private const DMX_SEND_TIME:int = 500; //ms to run the motor for
		private const DMX_PAUSE_TIME:int = 5000; //ms to pause when activating the motor more than once		
		
		private var myMood:String;//current mood - paris,beach,woods
		private var myIP:String;//IP of the Hue Bridge
		private var myUser:String;//user string from the Bridge
		private var baseURL:String;//Bridge API URL constructed from IP and User
		
		private var moodSound:Sound;//library sound for the mood
		private var moodSoundChannel:SoundChannel;
		
		private var socket:Socket;//connection to serproxy for DMX controller
		private var socketStatus:Boolean;//true if connected to serproxy
		private var myPort:int;//port number for serproxy - set in init()
		private var backgroundMoving:Boolean;//true when the 2 second on interval is running
		
		private var numLights:int;//number of lights - set in moodColor() - used by turnOffLights()
		
		private var bgStates:Array = ["paris", "beach", "woods"];
		private var bgIndex:int;//index of current background - assumed to always start on paris
		private var numTurns:int; //number of times to activate bg to get it to display the right image
		
		private var logEntry:String;
		
		
		
		public function MoodControl()
		{
			socketStatus = false;
			
			socket = new Socket();
			socket.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			socket.addEventListener(Event.CONNECT, doSocketConnect );//called when the socket connects
			socket.addEventListener(Event.CLOSE, doSocketClose );//called if the socket is closed... should never be called
			socket.addEventListener(Event.COMPLETE, onReady);//called when byteArray has been sent
		}
		
		
		/**
		 * Called from Main.showIntro()
		 * once config.json has been loaded
		 * Builds the baseURL to call light functions with
		 * @param	ip Bridge IP
		 * @param	user Key from the Bridge
		 * @param	port number serproxy is listening on
		 */
		public function init(ip:String, user:String, port:int):void		
		{
			myIP = ip;
			myUser = user;
			myPort = port;
			
			backgroundMoving = false;
			myMood = "paris";
			bgIndex = 0;
			
			baseURL = "http://" + ip + "/api/" + user + "/";
			
			doLog("MoodControl.init = myMood = paris, bgIndex = 0");
			
			connectToSerproxy();//for dmx connection
		}
		
		
		/**
		 * sets the string mood name - beach,paris,woods
		 * called from main.hideCalc right before the booth is displayed
		 * call this before playMoodSound() or advanceBG()
		 */
		public function set mood(m:String):void
		{
			doLog("MoodControl.set mood - mood set to: " + m);
			myMood = m;
			if(moodSoundChannel){
				TweenMax.to(moodSoundChannel, 0, {volume:1});
			}
		}
		
		
		public function get mood():String
		{
			return myMood;
		}
		
		
		private function doLog(m:String):void
		{
			logEntry = m;
			dispatchEvent(new Event(LOG_READY));
		}
		
		
		public function get log():String
		{
			return logEntry;
		}
		
		
		/**
		 * mc is an array of three x,y color arrays
		 * called from main.hideCalc() right before the takePhoto screen is displayed
		 */
		public function set moodColor(mc:Array):void
		{
			doLog("MoodControl.set moodColor()");
			numLights = mc.length;
			
			for (var i:int = 0; i < numLights; i++){
				setLightColor(mc[i], i + 1);
			}
		}
		
		
		
		/**
		 * Called from Main.restart()
		 */
		public function turnOffLights():void
		{
			if (!numLights){
				numLights = 3;
			}
			for (var i:int = 0; i < numLights; i++){
				lightOff(i + 1);//1,2,3
			}
		}
		
		
		/**
		 * Called from Main.restart()
		 */
		public function turnOffSound():void
		{
			TweenMax.to(moodSoundChannel, 2, {volume:0});
			//moodSound.stop();
		}
		
		
		/**
		 * called from Main when app is closed
		 */
		public function disconnect():void
		{
			if(socketStatus){
				socket.close();
			}
		}
		
		
		/**
		 * plays the sound associated with the mood
		 *  called from main.hideCalc() right before the takePhoto screen is displayed
		 */
		public function playMoodSound():void
		{
			switch(myMood){
				case "paris":
					moodSound = new soundParis();
					break;
				case "beach":
					moodSound = new soundBeach();
					break;
				case "woods":
					moodSound = new soundWoods();
					break;
			}
			doLog("MoodControl.playMoodSound for: " + myMood);
			moodSoundChannel = moodSound.play();
			//moodSound.play();
		}
		
		
		/**
		 * calculates the number of turns needed to get to myMood image
		 * and then starts the motor
		 * bgStates array is - paris,beach,woods
		 * Be sure to set the mood first
		 */
		public function advanceBG():void
		{			
			//get the index of where we need to go
			var newIndex:int = bgStates.indexOf(myMood);
			
			
			if (newIndex < bgIndex){
				numTurns = newIndex + 1;
			}else{
				numTurns = newIndex - bgIndex;
			}
			
			doLog("MoodControl.advanceBG() - turning to: " + myMood + " numTurns: " + numTurns);
			
			if(numTurns > 0){
				turnOnDMX();
			}
		}
		
		
		public function doAdvance():void
		{
			doLog("MoodControl.doAdvance()");
			
			if (!backgroundMoving && socketStatus){
				doLog("sending ON");
				backgroundMoving = true;
				
				sendDMX(0xFF);//send ON
				
				var a:Timer = new Timer(DMX_SEND_TIME, 1);//500ms
				a.addEventListener(TimerEvent.TIMER, turnOffDMX2, false, 0, true);
				a.start();
				
			}
		}
		
		
		private function turnOnDMX(e:TimerEvent = null):void
		{
			if(!backgroundMoving && socketStatus){
				backgroundMoving = true;
				
				doLog("MoodControl.turnOnDMX - turning - backgroundMoving = true");
				sendDMX(0xFF);//send ON
				
				var a:Timer = new Timer(DMX_SEND_TIME, 1);//500ms
				a.addEventListener(TimerEvent.TIMER, turnOffDMX, false, 0, true);
				a.start();
				
			}
		}
		
		private function turnOffDMX(e:TimerEvent):void
		{
			sendDMX(0x00);
			var b:Timer = new Timer(3000, 1);
			b.addEventListener(TimerEvent.TIMER, bgMovingFalse, false, 0, true);
			b.start();
			
			bgIndex++;
			if (bgIndex >= bgStates.length){
				bgIndex = 0;//back to paris
			}
			doLog("MoodControl.turnOffDMX - bgIndex advanced to: " + bgIndex);
			
			numTurns--;
			if (numTurns > 0){	
				doLog("MoodControl.need to turn again... pausing 5sec");
				var a:Timer = new Timer(DMX_PAUSE_TIME, 1);//5000ms
				a.addEventListener(TimerEvent.TIMER, turnOnDMX, false, 0, true);
				a.start();				
			}
		}
		
		private function turnOffDMX2(e:TimerEvent):void
		{
			doLog("MoodControl.turnOffDMX2()");
			sendDMX(0x00);
			
			var a:Timer = new Timer(3000, 1);
			a.addEventListener(TimerEvent.TIMER, bgMovingFalse, false, 0, true);
			a.start();
		}
		
		
		/**
		 * called after 3 seconds whenever the bg moves
		 * @param	e
		 */
		private function bgMovingFalse(e:TimerEvent):void
		{
			doLog("MoodControl.bgMovingFalse()");
			backgroundMoving = false;
		}
		
		
		
		private function sendDMX(byteToSend:int):void
		{
			var _length:int = 512;
			var _channels:Vector.<uint> = new Vector.<uint>();
			var _incChannels:int = _length+1;
					
			var BYTE_HEADER:int = int(0x7E);
			var BYTE_PACKET_START:int = 6;
			var BYTE_PACKET_LENGTH:int = _incChannels & 255;
			var BYTE_HALF_UNIVERSES:int = (_incChannels >> 8) & 255;
			var BYTE_END:int = int(0xE7);
			var BYTE_CHANNELS_START:int = 0;
			
			var byteSender:ByteArray = new ByteArray();	
			byteSender.writeByte(BYTE_HEADER);					//7E start byte
			byteSender.writeByte(BYTE_PACKET_START); 			//packet start
			byteSender.writeByte(BYTE_PACKET_LENGTH);			//Packet length ...
			byteSender.writeByte(BYTE_HALF_UNIVERSES);			//length / 256
			
			byteSender.writeByte(BYTE_CHANNELS_START); 			//Channel data start	
			
			//first 508 channels get 0's
			for(var i:int = 0; i < 508; i++)
			{				
				byteSender.writeByte(0x00);				
			}
			
			//write byteToSend to 509
			byteSender.writeByte(byteToSend);
			
			//write FF to 10 11 and 12 to keep the other channels on all the time
			byteSender.writeByte(0xFF);
			byteSender.writeByte(0xFF);
			byteSender.writeByte(0xFF);
			
			byteSender.writeByte(BYTE_END); 					//E7 End by
			
			socket.writeBytes(byteSender);
			socket.flush();
		}
		
		
		private function connectToSerproxy():void
		{
			doLog("MoodControl.connectToSerproxy()");
			
			if(!socketStatus){
				socket.connect(LOCALHOST, myPort);				
			}
		}
		
		
		private function onReady(e:Event):void
		{
		}

		
		/**
		 * IO Error on the socket - Serproxy connection
		 * @param	e
		 */
		private function errorHandler(e:IOErrorEvent):void 
		{    
			doLog("MoodControl.errorHandler - IOError - socketStatus is now false");
			socketStatus = false;
		}
		
		
		private function doSocketConnect(e:Event):void 
		{
			doLog("MoodControl.doSocketConnect() - serproxy connected - socketStatus is true");
			socketStatus = true;
		}
		
		
		private function doSocketClose(e:Event):void 
		{
			doLog("MoodControl.doSocketClose() - socketStatus is now false");
			socketStatus = false;
		}

		
		private function setLightColor(hueXY:Array, lightNum:int):void
		{
			doLog("set light color: "+ lightNum.toString()+ " xy:[" + hueXY[0] + "," + hueXY[1] + "]");
			
			var req:URLRequest = new URLRequest(baseURL + "lights/" + lightNum.toString() + "/state");
			req.method = URLRequestMethod.PUT;
			
			req.data = "{\"on\":true, \"xy\":[" + hueXY[0] + "," + hueXY[1] + "],\"bri\":254}";			
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, lightSetError, false, 0, true);
			//lo.addEventListener(Event.COMPLETE, imagePosted, false, 0, true);
			lo.load(req);
		}
		
		
		private function lightOff(lightNum:int):void
		{
			var req:URLRequest = new URLRequest(baseURL + "lights/" + lightNum.toString() + "/state");
			req.method = URLRequestMethod.PUT;
			
			req.data = "{\"on\":false}";
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, lightSetError, false, 0, true);
			//lo.addEventListener(Event.COMPLETE, imagePosted, false, 0, true);
			lo.load(req);
		}
		
		private function lightSetError(e:IOErrorEvent):void
		{
			//bridge not avail... whatever... don't care
			doLog("MoodControl.lightSetError");
		}
		
	}
	
}