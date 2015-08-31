/**
 * Creates a Video object in a given container and plays
 * the randomized interview
 */

package com.gmrmarketing.reeses.gameday
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.media.Video;
	import flash.net.*;
	import flash.utils.ByteArray;
	import com.greensock.TweenMax;
	
	
	public class Interview2 extends EventDispatcher
	{
		//private const BASE_PATH:String = "recevideo/";
		private const BASE_PATH:String = "c:/Users/dmennenoh/Desktop/reeses/receVideo/";
		
		public static const INTRO_COMPLETE:String = "introFinishedPlaying";
		public static const QUESTION_COMPLETE:String = "questionFinishedPlaying";
		public static const OUTRO_COMPLETE:String = "outroFinishedPlaying";
		
		private var vid:Video;
		private var myContainer:DisplayObjectContainer;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var playList:Array;
		private var fileList:Array;
		private var whiteFader:Sprite;
		
		
		public function Interview2()
		{
			vid = new Video();
			vid.width = 640;
			vid.height = 360;
			
			whiteFader = new Sprite();
			whiteFader.graphics.beginFill(0xFFFFFF, 1);
			whiteFader.graphics.drawRect(0, 0, 640, 360);
			whiteFader.graphics.endFill();
			
			nc = new NetConnection();
			nc.connect(null);
			
			ns = new NetStream(nc);
			ns.client = { };			
			ns.play(null);
			
			vid.attachNetStream(ns);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function get questions():Array
		{
			return fileList;
		}
		
		
		public function show():void
		{
			var questions:Array = [[BASE_PATH + "conferenceChampionship.flv",5], [BASE_PATH + "preGameTailgate.flv",5], [BASE_PATH + "beatingTheNumberOne.flv",5], [BASE_PATH + "afternoonGames.flv",5], [BASE_PATH + "underdogsOrFavorites.flv",5], [BASE_PATH + "modernJerseys.flv",5], [BASE_PATH + "studentSection.flv",5], [BASE_PATH + "pocketPassers.flv",5], [BASE_PATH + "speedOrPower.flv",5], [BASE_PATH + "unstoppableOffense.flv",5], [BASE_PATH + "piecesOrCups.flv",5]];
			
			playList = [];
			
			while (playList.length < 5) {
				playList.push(questions.splice(Math.floor(Math.random() * questions.length), 1)[0]);
			}			
			
			fileList = [];
			for (var i:int = 0; i < playList.length; i++) {
				fileList.push(playList[i][0]);
			}
			fileList.unshift(BASE_PATH + "intro.flv");
			fileList.push(BASE_PATH + "outro.flv");
			
			if (!myContainer.contains(vid)) {
				myContainer.addChild(vid);
				vid.x = 20;
				vid.y = 20;
			}
		}
		
		
		public function playIntro():void
		{
			ns.addEventListener(NetStatusEvent.NET_STATUS, introStatus);
			ns.play(BASE_PATH + "intro.flv");
		}
		
		private function introStatus(e:NetStatusEvent):void 
		{
			var code:String = e.info.code;
			//trace("introStatus",code);
			switch(code) {				
				case "NetStream.Play.Stop":
					ns.removeEventListener(NetStatusEvent.NET_STATUS, introStatus);
					dispatchEvent(new Event(INTRO_COMPLETE));
					break;
			}
		}		
		
		private function questionStatus(e:NetStatusEvent):void 
		{
			var code:String = e.info.code;
			//trace("questionStatus",code);
			switch(code) {				
				case "NetStream.Play.Stop":
					ns.removeEventListener(NetStatusEvent.NET_STATUS, questionStatus);
					dispatchEvent(new Event(QUESTION_COMPLETE));
					break;
			}
		}		
		
		private function outroStatus(e:NetStatusEvent):void 
		{
			var code:String = e.info.code;
			//trace("outroStatus",code);
			switch(code) {				
				case "NetStream.Play.Stop":
					ns.removeEventListener(NetStatusEvent.NET_STATUS, questionStatus);
					dispatchEvent(new Event(OUTRO_COMPLETE));
					break;
			}
		}	

		public function nextQuestion():Number 
		{			
			if (playList.length) {
				myContainer.addChild(whiteFader);
				whiteFader.x = 20;
				whiteFader.y = 20;
				whiteFader.alpha = 1;
				TweenMax.to(whiteFader, .5, { alpha:0, onComplete:removeWhiteFader } );
				ns.addEventListener(NetStatusEvent.NET_STATUS, questionStatus);
				var ques:Array = playList.shift();
				ns.play(ques[0]);
				return ques[1];//time allowed for response
			}else {
				myContainer.addChild(whiteFader);
				whiteFader.alpha = 1;
				TweenMax.to(whiteFader, .5, { alpha:0, onComplete:removeWhiteFader } );
				ns.addEventListener(NetStatusEvent.NET_STATUS, outroStatus);
				ns.play(BASE_PATH + "outro.flv");
				return -1;
			}
		}
		
		
		private function removeWhiteFader():void
		{
			if (myContainer.contains(whiteFader)) {
				myContainer.removeChild(whiteFader);
			}
		}
		
	}
	
}