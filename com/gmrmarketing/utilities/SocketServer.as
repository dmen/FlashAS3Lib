/**
	Basic Socket Server for client communication
	Allows just one client to be connected
	
	Used by: Esurance SXSW 2014 glovebox
			 BCBS Find your balance game
 */
	
package com.gmrmarketing.utilities
{
	import flash.events.*;
	import flash.net.*;	
	import flash.utils.ByteArray;
	
	
	public class SocketServer extends EventDispatcher  
	{
		public static const CONNECT:String = "clientConnect";
		public static const MESSAGE:String = "messageReceived";
		public static const DISCONNECT:String = "clientDisconnected";
		
		private var server:ServerSocket;
		private var client:Socket;
		private var clientData:Object;
		private var lastMessage:String;
		
		
		/**
		 * Constuctor
		 * @param	port Configurable port from config.xml
		 */
		public function SocketServer(port:int = 1080)
		{
			lastMessage = "";
			clientData = new Object();
			
			server = new ServerSocket();
			server.bind( port );
			server.addEventListener( ServerSocketConnectEvent.CONNECT, onClientConnect );
			server.listen();
		}
		
		
		/**
		 * Called when a client socket connects to the server socket
		 * @param	e
		 */
		private function onClientConnect( e:ServerSocketConnectEvent ):void
		{
			client = e.socket;
			client.addEventListener( ProgressEvent.SOCKET_DATA, onClientSocketData, false, 0, true );
			client.addEventListener( Event.CLOSE, onClientDisconnect, false, 0, true );			
			
			clientData = new Object();
			clientData.remoteAddress = client.remoteAddress;
			clientData.remotePort = client.remotePort;
			
			dispatchEvent(new Event(CONNECT));
		}		
		
		
		/**
		 * Gets the client data object
		 * @return Object with remoteAddress and remotePort properties
		 */
		public function getClientData():Object
		{
			return clientData;
		}		
		
		
		/**
		 * Force disconnect the client
		 */
		public function disconnectClient():void
		{
			client.close();
		}
		
		
		/**
		 * Send a string to the client
		 * @param	m
		 */
		public function sendToClient(m:String):void
		{
			client.writeUTFBytes(m);
			client.flush();
		}
		
		
		/**
		 * Called when the clients sends a string to the server
		 * Dispatches a MESSAGE event - call getMessage() to 
		 * retrieve the message
		 * @param	e
		 */
		private function onClientSocketData( e:ProgressEvent ):void
		{
			var buffer:ByteArray = new ByteArray();
			client.readBytes( buffer, 0, client.bytesAvailable );
			lastMessage = buffer.toString();			
			dispatchEvent(new Event(MESSAGE));
		}
		
		
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
			dispatchEvent(new Event(DISCONNECT));
		}
		
	}
	
}