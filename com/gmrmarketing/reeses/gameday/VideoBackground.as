/**
 * Plays and loops a FLV video in a container
 */

package com.gmrmarketing.reeses.gameday
{		
	import flash.display.DisplayObjectContainer;
	import flash.media.Video;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.ByteArray;

	public class VideoBackground
	{
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/stadium_overlay.flv", mimeType="application/octet-stream")]
        private var FieldVideo:Class;
		
		private var vid:Video;
		private var stream:NetStream;
		private var connection:NetConnection;
		private var ba:ByteArray;
		private var myContainer:DisplayObjectContainer;
		
		
		public function VideoBackground(c:DisplayObjectContainer)
		{
			myContainer = c;
			
			vid = new Video();
			vid.width = 1920;
			vid.height = 950;
			vid.x = 0;
			vid.y = 0;
			myContainer.addChild(vid);
			
			ba = new FieldVideo();
			
			connection = new NetConnection();
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			connection.connect(null);
			
			stream = new NetStream(connection);
			stream.client = this;
			stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			vid.attachNetStream(stream);
			stream.play(null);
			streamLoop();
		}
		
		private function netStatusHandler(e:NetStatusEvent):void
		{
			trace("netStatusHandler: " + e.info.code);
		}
		
		private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			trace("securityError: " + e);
		}
		
		private function asyncErrorHandler(e:AsyncErrorEvent):void
		{
			trace("asyncError: " + e);
		}
		
		public function onXMPData(xmp:Object):void { }
		
		public function onPlayStatus(status:Object):void { }
		
		private function streamLoop():void 
		{
            stream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
            stream.appendBytes(ba);
        }
		
		public function onMetaData(metaData:Object):void
		{
			streamLoop();
		}
	}
	
}