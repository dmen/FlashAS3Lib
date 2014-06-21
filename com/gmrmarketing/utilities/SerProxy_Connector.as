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
	import flash.net.Socket;
	import flash.utils.*;
	import flash.events.*;
	
	public class SerProxy_Connector extends EventDispatcher
	{
		public static const CLOSED:String = "Connection with Serproxy closed";
		public static const CONNECTED:String = "Connection with Serproxy established";
		public static const SENT:String = "Message sent";
		public static const SER_ERROR:String = "Error:Check that SerProxy is running";
		
		private var socket:Socket;
		private var socketStatus:Boolean;//true if connected to serproxy
		

		public function SerProxy_Connector()
		{
			socket = new Socket();			
			socket.addEventListener(Event.CONNECT, connected);
			socket.addEventListener(Event.COMPLETE, bytesSent);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			socket.addEventListener(Event.CLOSE, closed);			
			
			socketStatus = false;
		}

		
		/**
		 * Connects to SerProxy if the socket is not connected
		 * Disconnects if the socket is already connected
		 * 
		 * @param	localhost IP address of localHost normally 127.0.0.1
		 * @param	port Port SerProxy is configured to use. Set in serproxy.cfg like: net_port1=5331
		 */
		public function connect(localHost:String = "127.0.0.1", port:int = 5331):void
		{
			if(socketStatus){
				socket.close();							
			}else{
				socket.connect(localHost, port);				
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
			socket.writeBytes(ba);
			socket.flush();  
		}
		
		
		private function connected(e:Event):void 
		{
			socketStatus = true;
			dispatchEvent(new Event(CONNECTED));
		}

		
		private function bytesSent(e:Event):void
		{
			dispatchEvent(new Event(SENT));
		}

		
		private function onError(e:IOErrorEvent):void 
		{ 
			dispatchEvent(new Event(SER_ERROR));
		}

		
		private function closed(e:Event):void 
		{
			socketStatus = false;
			dispatchEvent(new Event(CLOSED));
		}

	}
	
}