/**
 * Creates a Video object in a given container and plays
 * the randomized interview
 */

package com.gmrmarketing.reeses.gameday
{
	import flash.display.DisplayObjectContainer;
	import flash.events.*;
	import flash.media.Video;
	import flash.net.*;
	import flash.utils.ByteArray;
	
	public class Interview extends EventDispatcher
	{
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/recevideo/intro.flv", mimeType="application/octet-stream")]
		private var introVideo:Class;
		
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/recevideo/conferenceChampionship.flv", mimeType="application/octet-stream")]
		private var q1:Class;
		
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/recevideo/preGameTailgate.flv", mimeType="application/octet-stream")]
		private var q2:Class;
		
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/recevideo/beatingTheNumberOne.flv", mimeType="application/octet-stream")]
		private var q3:Class;
		
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/recevideo/afternoonGames.flv", mimeType="application/octet-stream")]
		private var q4:Class;
		
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/recevideo/underdogsOrFavorites.flv", mimeType="application/octet-stream")]
		private var q5:Class;
		
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/recevideo/modernJerseys.flv", mimeType="application/octet-stream")]
		private var q6:Class;
		
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/recevideo/studentSection.flv", mimeType="application/octet-stream")]
		private var q7:Class;
		
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/recevideo/pocketPassers.flv", mimeType="application/octet-stream")]
		private var q8:Class;
		
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/recevideo/speedOrPower.flv", mimeType="application/octet-stream")]
		private var q9:Class;
		
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/recevideo/unstoppableOffense.flv", mimeType="application/octet-stream")]
		private var q10:Class;
		
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/recevideo/piecesOrCups.flv", mimeType="application/octet-stream")]
		private var q11:Class;
		
		[Embed(source="C:/Users/dmennenoh/Desktop/reeses/recevideo/outro.flv", mimeType="application/octet-stream")]
		private var outroVideo:Class;
		
		public static const PLAY_COMPLETE:String = "videoFinishedPlaying";
		
		private var vid:Video;
		private var myContainer:DisplayObjectContainer;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var playList:Array;
		
		
		public function Interview()
		{
			vid = new Video();
			vid.width = 696;
			vid.height = 392;
			
			nc = new NetConnection();
			nc.connect(null);
			
			ns = new NetStream(nc);
			ns.client = { };
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			ns.play(null);
			
			vid.attachNetStream(ns);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			var questions:Array = [new q1(), new q2(), new q3(), new q4(), new q5(), new q6(), new q7(), new q8(), new q9(), new q10(), new q11()];
			playList = [];
			
			while (playList.length < 5) {
				var q:ByteArray = questions.splice(Math.floor(Math.random() * questions.length), 1)[0] as ByteArray;
				playList.push(q);
			}
			
			//add intro and outro
			playList.unshift(new introVideo());
			playList.push(new outroVideo());
			
			if (!myContainer.contains(vid)) {
				myContainer.addChild(vid);
			}
		}
		
		
		public function startPlay():void
		{
			ns.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
			ns.appendBytes(playList.shift() as ByteArray);
		}
		
		
		private function netStatus(e:NetStatusEvent):void 
		{
			var code:String = e.info.code;
			switch(code) {
				case "NetStream.Buffer.Empty":
					ns.seek(0);
					break;
				case "NetStream.Seek.Notify":
					if (e.info.seekPoint == 0) 
					{
						dispatchEvent(new Event(PLAY_COMPLETE));
					}
					break;
			}
		}
		
		

		public function playNext():void 
		{		
			if(playList.length){
				var b:ByteArray = playList.shift();			
				ns.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
				ns.appendBytes(b);
			}
		}
		
	}
	
}