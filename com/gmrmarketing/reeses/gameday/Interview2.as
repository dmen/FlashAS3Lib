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
	import flash.filesystem.File;
	
	public class Interview2 extends EventDispatcher
	{
		private var basePath:String;
		
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
			//folder where rece videos are located
			 basePath = File.applicationDirectory.resolvePath("receVideo").nativePath + "\\";
			 
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
			randQuestions();
			
			if (!myContainer.contains(vid)) {
				myContainer.addChild(vid);
				vid.x = 20;
				vid.y = 20;
			}
		}
		
		
		public function randQuestions():void
		{
			var questions:Array = [[basePath + "conferenceChampionship",5], [basePath + "preGameTailgate",5], [basePath + "beatingTheNumberOne",5], [basePath + "afternoonGames",5], [basePath + "underdogsOrFavorites",5], [basePath + "modernJerseys",5], [basePath + "studentSection",5], [basePath + "pocketPassers",5], [basePath + "speedOrPower",5], [basePath + "unstoppableOffense",5], [basePath + "piecesOrCups",5]];
			
			//this is for flash player - .mp4 for these
			playList = [];
			fileList = [];
			while (playList.length < 5) {
				var a:Array = questions.splice(Math.floor(Math.random() * questions.length), 1)[0];
				var b:Array = a.concat();
				a[0] += ".mp4";
				b[0] += ".mov";
				playList.push(a);
				fileList.push(b[0]);
			}		
		
			fileList.unshift(basePath + "intro.mov");
			fileList.push(basePath + "outro.mov");
		}
		
		
		public function playIntro():void
		{
			ns.addEventListener(NetStatusEvent.NET_STATUS, introStatus);
			ns.play(basePath + "intro.mp4");
		}
		
		
		public function stop():void
		{
			ns.play(null);
		}
		
		
		private function introStatus(e:NetStatusEvent):void 
		{			
			if(e.info.code == "NetStream.Play.Stop"){
				ns.removeEventListener(NetStatusEvent.NET_STATUS, introStatus);
				dispatchEvent(new Event(INTRO_COMPLETE));
			}
		}		
		
		private function questionStatus(e:NetStatusEvent):void 
		{
			if(e.info.code == "NetStream.Play.Stop"){
				ns.removeEventListener(NetStatusEvent.NET_STATUS, questionStatus);
				dispatchEvent(new Event(QUESTION_COMPLETE));			
			}
		}		
		
		private function outroStatus(e:NetStatusEvent):void 
		{
			if(e.info.code == "NetStream.Play.Stop"){
				ns.removeEventListener(NetStatusEvent.NET_STATUS, questionStatus);
				dispatchEvent(new Event(OUTRO_COMPLETE));
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
				ns.play(basePath + "outro.mp4");
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