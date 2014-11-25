
package com.gmrmarketing.utilities
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.net.*;	
	import flash.utils.*;
	import fl.video.FLVPlayback;
	import fl.video.VideoEvent;
	
	
	public class SocketServerTest extends MovieClip  
	{
		//public static const CONNECT:String = "clientConnect";
		//public static const MESSAGE:String = "messageReceived";
		//public static const DISCONNECT:String = "clientDisconnected";
		
		private var lastMessage:String;
		private var server:ServerSocket;
		private var clients:Array;//array of Sockets
		
		private var oneFrame:BitmapData;
		private var ba:ByteArray = new ByteArray();
		
		private var updateTimer:Timer;
		
		
		/**
		 * Constuctor
		 */
		public function SocketServerTest()
		{
			clients = new Array();
			
			oneFrame = new BitmapData(640, 360); //video size			
			
			updateTimer = new Timer(33); //30 fps
			updateTimer.addEventListener(TimerEvent.TIMER, updateClients);
			
			vid.autoRewind = true;
			vid.addEventListener(fl.video.VideoEvent.AUTO_REWOUND, doLoop);
			
			server = new ServerSocket();
			server.bind( 1080 );
			server.addEventListener( ServerSocketConnectEvent.CONNECT, onClientConnect );
			server.listen();
		}
		private function doLoop(e:fl.video.VideoEvent):void
		{
			vid.play();
		}
		
		/**
		 * Called when a client socket connects to the server socket
		 * @param	e
		 */
		private function onClientConnect( e:ServerSocketConnectEvent ):void
		{
			var s:Socket = e.socket;						
			//s.addEventListener( ProgressEvent.SOCKET_DATA, onClientSocketData, false, 0, true );
			s.addEventListener( Event.CLOSE, onClientDisconnect);			
			
			var r:Rectangle = new Rectangle(32 * clients.length, 0, 32, 18);
			clients.push({socket:s, rect:r});			
			updateText();
			//dispatchEvent(new Event(CONNECT));
			
			updateTimer.start(); //calls updateClients
		}
		
		
		private function updateClients(e:TimerEvent):void
		{
			
			var client:Object;
			oneFrame.draw(vid);//vid is FLVPlayback component already on stage
			
			for (var i:int = 0; i < clients.length; i++) {
				client = clients[i];
				ba = oneFrame.getPixels(client.rect);
				
				client.socket.writeBytes(ba);
				client.socket.flush();
			}
		}
		
		
		/**
		 * Called when the clients sends a string to the server
		 * Dispatches a MESSAGE event - call getMessage() to 
		 * retrieve the message
		 * @param	e
		 */
		/*
		private function onClientSocketData( e:ProgressEvent ):void
		{
			var buffer:ByteArray = new ByteArray();
			client.readBytes( buffer, 0, client.bytesAvailable );
			lastMessage = buffer.toString();			
			dispatchEvent(new Event(MESSAGE));
		}
		*/
		
		/**
		 * Get the last client message
		 * @return String message
		 */
		public function getMessage():String
		{
			return lastMessage;
		}
		
		
		/**
		 * Called when the client disconnects
		 * Dispatces a DISCONNECT event
		 * @param	e
		 */
		private function onClientDisconnect(e:Event):void
		{
			//e.target is the socket
			e.target.removeEventListener( Event.CLOSE, onClientDisconnect)
			for (var i:int = 0; i < clients.length; i++) {
				if (clients[i].socket == e.target) {
					clients.splice(i, 1);
					break;
				}
			}
			updateText();
		}
		
		
		private function updateText():void
		{
			theText.text = "Clients: " + String(clients.length);
			theText2.text = "ba length: " + String(ba.length);
		}
		
	}
	
}