package com.gmrmarketing.utilities
{
	import com.gmrmarketing.indian.heritage.Data;
	import flash.display.*;
	import flash.events.*;
	import com.gmrmarketing.utilities.FLVtoBA;
	import flash.utils.ByteArray;
	import flash.net.*;
	import flash.geom.*;
	import flash.filesystem.*;
	
	public class VideoServer extends MovieClip 
	{
		private var vLoader:FLVtoBA;
		private var videoBytes:ByteArray;
		private var server:ServerSocket;
		private var clients:Array;//array of Sockets
		private var file:File;
		
		public function VideoServer()
		{			
			clients = new Array();			
			
			server = new ServerSocket();
			server.bind( 1080 );
			server.addEventListener( ServerSocketConnectEvent.CONNECT, onClientConnect );
			server.listen();
			
			vLoader = new FLVtoBA();
			vLoader.addEventListener(FLVtoBA.VID_LOADED, videoLoaded);
			
			btnLoad.addEventListener(MouseEvent.MOUSE_DOWN, chooseFile);
		}
		
		private function chooseFile(e:MouseEvent):void
		{
			file = new File();
            file.addEventListener(Event.SELECT, fileSelect);
            file.browseForOpen("Select video to load");
		}
		
		
		private function fileSelect(e:Event):void
		{
			vLoader.loadVideo(File(e.currentTarget).nativePath);
		}
		
		
		private function videoLoaded(e:Event):void
		{
			vLoader.removeEventListener(FLVtoBA.VID_LOADED, videoLoaded);
			
			videoBytes = new ByteArray();
			var ba:ByteArray = vLoader.getVid();
			videoBytes.writeInt(ba.length);//32bit unsigned int - 4 bytes
			videoBytes.writeBytes(ba);
			
			theText.text = "Video Bytes:" + String(ba.length);
		}
		
		
		private function onClientConnect( e:ServerSocketConnectEvent ):void
		{
			var s:Socket = e.socket;					
			s.addEventListener( ProgressEvent.SOCKET_DATA, onClientSocketData );
			s.addEventListener( Event.CLOSE, onClientDisconnect);
			
			clients.push( { socket:s, id:clients.length, hasVideo:false } );
			updateText();
			
			btn.addEventListener(MouseEvent.MOUSE_DOWN, pushVideo);
		}
		
		
		/**
		 * Called when data arrives from a client
		 * @param	e
		 */
		private function onClientSocketData( e:ProgressEvent ):void
		{
			//e.target is the socket
			var s:Socket = Socket(e.target);
			var buffer:ByteArray = new ByteArray();
			
			s.readBytes( buffer, 0, s.bytesAvailable );
			var mess:String = buffer.toString();			
			if (mess == "vid") {
				
				//client received the video file
				for (var i:int = 0; i < clients.length; i++) {
					if (clients[i].socket == s) {
						clients[i].hasVideo = true;						
						break;
					}
				}
				checkVideoState();
			}			
		}
		
		
		/**
		 * Called from onClientSocketData whenever a "vid" message arrives
		 * Checks the hasVideo property of the client objects
		 * Attaches play listener once all videos have been pushed
		 */
		private function checkVideoState():void
		{
			var allVideos:Boolean = true;
			var i:int;
			for (i = 0; i < clients.length; i++) {
				if (!clients[i].hasVideo) {
					allVideos = false;
					break;
				}
			}
			if (allVideos) {
				theText.text = "All clients have video";
				
				btnInit.addEventListener(MouseEvent.MOUSE_DOWN, sendInit);
				btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, sendPlay);
				btnReplay.addEventListener(MouseEvent.MOUSE_DOWN, sendReplay);
			}
		}
		
		
		/**
		 * Pushes the init object to all clients
		 * object contains server command type, client id, actual width and height of video (vw,vh)
		 * and the cell width and height - which is scaled to full screen on the devices
		 * @param	e
		 */
		private function sendInit(e:MouseEvent):void
		{		
			for (var i:int = 0; i < clients.length; i++) {				
				clients[i].socket.writeObject({ type:1, id:i+1, vw:3840, vh:2160, cellw:1920, cellh:1080});
				clients[i].socket.flush();
				
			}
		}
		
		
		/**
		 * Sends the play command to all clients along with now in epoch time
		 * @param	e
		 */
		private function sendPlay(e:MouseEvent):void
		{
			for (var i:int = 0; i < clients.length; i++) {
				var now:Date = new Date();
				clients[i].socket.writeObject({ type:2, st:now.valueOf() });
				clients[i].socket.flush();
			}
		}
		
		private function sendReplay(e:MouseEvent):void
		{	
			for (var i:int = 0; i < clients.length; i++) {
				clients[i].socket.writeObject({ type:3 });
				clients[i].socket.flush();
			}
		}
		
		
		/**
		 * Pushes the video byteArray to connected clients
		 * only if the clients hasVideo property is false
		 * @param	e
		 */
		private function pushVideo(e:MouseEvent):void
		{			
			for (var i:int = 0; i < clients.length; i++) {
				if(!clients[i].hasVideo){
					clients[i].socket.writeBytes(videoBytes);
					clients[i].socket.flush();
				}
			}
		}		
		
		
		/**
		 * Called if a client disconnects
		 * Removes the client from the clients array
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
			numClients.text = "Clients: " + String(clients.length);
		}
		
	}
	
}