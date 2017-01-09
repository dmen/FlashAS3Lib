/*
	Connects to the SerProxy serial server
	SerProxy is used to allow connecting an Arduino board to 
	a USB port - and having it seen as a com port.
	
	Run SerProxy with the same baud (9600,8,N,1) as the Arduino
	and com port setup. Then use this to connect to SerProxy. 
	
	Call send to send a byteArray to the Arduino
	
	In Digital\DigitalLab\Arduino\serialBlink is serialBlink.ino
	
	Launch this on the arduino and send a newLine char to cause
	the pin 13 LED to turn on for 1sec and then turn back off
	
	Send newLine (charCode 10) in a ByteArray like so:
		
	var b:ByteArray = new ByteArray();	
	b.writeByte(10);
	serproxyConnector.send(b);
	
	
*/

package com.gmrmarketing.utilities
{	
	import adobe.utils.CustomActions;
	import flash.net.Socket;
	import flash.utils.*;
	import flash.events.*;
	
	public class SerProxy_Connector extends EventDispatcher
	{
		public static const CLOSED:String = "Connection with Serproxy closed";
		public static const CONNECTED:String = "Connection with Serproxy established";
		public static const SENT:String = "Message sent";
		public static const SER_ERROR:String = "Error:Check that SerProxy is running";
		public static const SER_LOG:String = "log message";
		
		private var socket:Socket;
		private var socketConnected:Boolean;//true if connected to serproxy
		
		private var logMessage:String = "";
		

		public function SerProxy_Connector()
		{
			socket = new Socket();			
			socket.addEventListener(Event.CONNECT, connected);
			socket.addEventListener(Event.COMPLETE, bytesSent);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			socket.addEventListener(Event.CLOSE, closed);			
			
			socketConnected = false;
			
			log("Serproxy Constructor");
		}

		
		/**
		 * Connects to SerProxy if the socket is not connected
		 * Disconnects if the socket is already connected
		 * 
		 * @param	localhost IP address of serproxy server
		 * @param	port Port SerProxy is configured to use. Set in serproxy.cfg like: net_port1=5331
		 */
		public function connect(localHost:String = "127.0.0.1", port:int = 5331):void
		{
			if (socketConnected) {
				try{
					socket.close();
				}catch (e:Error) {
					log("Serproxy.connect - Catch error - socket connected: " + e.message);
				}
				log("Serproxy.connect - socket was connected, now closed.");
			}else {
				try{
					socket.connect(localHost, port);
				}catch (e:Error) {
					log("Serproxy.connect - Catch error - socket not connected: " + e.message);
				}
				log("Serproxy.connect - socket not connected - trying to connect.");
			}
		}
		
		
		/**
		 * Sends the ByteArray to SerProxy
		 *
		 * var b:ByteArray = new ByteArray();
		 * b.writeByte(10); //writes 10 to the array which is the charCode of NewLine 
		 * 
		 * @param	ba ByteArray
		 */
		public function send(ba:ByteArray):void
		{		
			try{
				socket.writeBytes(ba);
				socket.flush();  
			}catch (e:Error) {
				log("Serproxy.send - Catch error - cannot send: " + e.errorID);
			}
		}
		
		/**
		 * Sends the String to SerProxy
		 *
		 * //writes "Hello World!" with a carriage return at the end
		 * var b:String = "Hello World!" + String.fromCharCode(13);  
		 * 
		 * @param	str String
		 */
		public function sendUtf(str:String):void
		{
			try{
				socket.writeUTFBytes(str);
				socket.flush();  
			}catch (e:Error) {
				log("Serproxy.sendUtf - Catch error - cannot send: " + e.errorID);
			}
		}
		
		public function getLogMessage():String
		{
			return logMessage;
		}
		
		private function log(m:String):void
		{
			logMessage = m;
			trace(m);
			dispatchEvent(new Event(SER_LOG));
		}
		
		
		private function connected(e:Event):void 
		{
			socketConnected = true;
			dispatchEvent(new Event(CONNECTED));
			log("Serproxy.connected - Event - socket is connected");
		}

		
		private function bytesSent(e:Event):void
		{
			dispatchEvent(new Event(SENT));
		}

		
		private function onError(e:IOErrorEvent):void 
		{ 
			log("Serproxy.onError - IOErrorEvent - socket error" + e.toString());			
			recon();
			dispatchEvent(new Event(SER_ERROR));
		}

		
		private function closed(e:Event):void 
		{
			log("Serproxy.closed - Event - socket has been closed");
			recon();
			dispatchEvent(new Event(CLOSED));
		}
		
		
		private function recon():void
		{
			log("Serproxy.recon - reconnecting in 1 sec");
			var a:Timer = new Timer(1000, 1);
			a.addEventListener(TimerEvent.TIMER, reconnect, false, 0, true);
			a.start();
		}
		
		
		private function reconnect(e:TimerEvent):void
		{
			socketConnected = false;			
			connect();
		}

	}
	
}
