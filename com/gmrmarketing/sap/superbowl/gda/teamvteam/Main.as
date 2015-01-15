package com.gmrmarketing.sap.superbowl.gda.teamvteam
{
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.loading.*;
	import com.greensock.loading.display.*;
	import com.greensock.*;
	import com.greensock.events.LoaderEvent;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Main extends MovieClip implements IModuleMethods
	{
		public static const FINISHED:String = "finished";
		private var localCache:Object;
		private var video:VideoLoader;
		private var tvtCircle:Sprite;//gray circle in the title
		private var TESTING:Boolean = false;
		private var animValue:Object;
		private var animChars:Array;
		private var allVideos:Array;//the two sets of videos
		private var allStats:Array;
		private var videos:Array;//the picked set of video
		private var vidIndex:int;//index in the current set of videos
		private var setIndex:int; //1 or 2 - set in init()
		
		public function Main()
		{
			tvtCircle = new Sprite();
			
			//two sets of videos
			allVideos = [[["test.mp4", "WEEK 4", "Packers generally kicking ass"],["test.mp4", "WEEK 4", "Patriots doing patriotic things"],["test.mp4", "WEEK 8", "Continued Packers domination"],["test.mp4", "WEEK 8", "Patriots sneak out a win"]], [["test.mp4", "WEEK 4", "Packers generally kicking ass"],["test.mp4", "WEEK 4", "Patriots doing patriotic things"],["test.mp4", "WEEK 8", "Continued Packers domination"],["test.mp4", "WEEK 8", "Patriots sneak out a win"]]];
			//each stats array contains 5 nfc stats then 5 afc stats
			allStats = [[[["12","4","48.34%","119.28","58.21%"],["11","5","40.2%","120","52%"]],[["12","4","48.34%","119.28","58.21%"],["11","5","40.2%","120","52%"]],[["12","4","48.34%","119.28","58.21%"],["11","5","40.2%","120","52%"]],[["12","4","48.34%","119.28","58.21%"],["11","5","40.2%","120","52%"]]],[[[["12","4","48.34%","119.28","58.21%"],["11","5","40.2%","120","52%"]],[["12","4","48.34%","119.28","58.21%"],["11","5","40.2%","120","52%"]],[["12","4","48.34%","119.28","58.21%"],["11","5","40.2%","120","52%"]],[["12","4","48.34%","119.28","58.21%"],["11","5","40.2%","120","52%"]]]]];
			
			if(TESTING){
				init();
			}
		}
		
		
		/**
		 * Only called once
		 * @param	initValue String 1 or 2 for the video set - first set of 4 or second set of 4
		 */
		public function init(initValue:String = "0"):void
		{
			setIndex = parseInt(initValue);
			
			videos = allVideos[setIndex];//the set of videos - set 1 or 2
			vidIndex = 0;//index within the selected set
			
			if(!contains(tvtCircle)){
				addChild(tvtCircle);
			}
			tvtCircle.x = 320;
			tvtCircle.y = 166;
			
			hideThings();
			
			setStats();
			
			refreshData();
		}
		
		private function hideThings():void
		{
			//team vs team text inside circle
			tvt.alpha = 0;
			
			//hide wings in masks
			lWing.x = 265;
			rWing.x = 175;
			
			//logos
			team1.alpha = 0;
			team2.alpha = 0;
			team1.scaleX = team1.scaleY = 2;
			team2.scaleX = team2.scaleY = 2;
			
			//stats
			t1s1.alpha = 0;
			t1s2.alpha = 0;
			t1s3.alpha = 0;
			t1s4.alpha = 0;
			t1s5.alpha = 0;
			t1s1.wing.x = 182;
			t1s2.wing.x = 182;
			t1s3.wing.x = 182;
			t1s4.wing.x = 182;
			t1s5.wing.x = 182;
			
			t2s1.alpha = 0;
			t2s2.alpha = 0;
			t2s3.alpha = 0;
			t2s4.alpha = 0;
			t2s5.alpha = 0;
			t2s1.wing.x = -111;
			t2s2.wing.x = -111;
			t2s3.wing.x = -111;
			t2s4.wing.x = -111;
			t2s5.wing.x = -111;
			
			//sentiment
			sent.y = 734;
			sent.lWing.x = 8;
			sent.rWing.x = 110;
			
			theFact.alpha = 0;
			
			vidBar.alpha = 0;
			week15.y = 236;	
		}
		
		//sets the stats per week
		private function setStats():void
		{
			var nfcStats:Array = allStats[setIndex][vidIndex][0]; //array of 5 items
			var afcStats:Array = allStats[setIndex][vidIndex][1]; //array of 5 items
			
			t1s1.wing.theLabel.text = "WINS";
			t1s1.theStat.text = nfcStats[0];
			t1s2.wing.theLabel.text = "LOSSES";
			t1s2.theStat.text = nfcStats[1];
			t1s3.wing.theLabel.text = "3RD DN CONVERSIONS";
			t1s3.theStat.text = nfcStats[2];
			t1s4.wing.theLabel.text = "RUSHING YDS/GAME";
			t1s4.theStat.text = nfcStats[3];
			t1s5.wing.theLabel.text = "RED ZONE SCORING";
			t1s5.theStat.text = nfcStats[4];
			
			t2s1.wing.theLabel.text = "WINS";
			t2s1.theStat.text = afcStats[0];
			t2s2.wing.theLabel.text = "LOSSES";
			t2s2.theStat.text = afcStats[1];
			t2s3.wing.theLabel.text = "3RD DN CONVERSIONS";
			t2s3.theStat.text = afcStats[2];
			t2s4.wing.theLabel.text = "RUSHING YDS/GAME";
			t2s4.theStat.text = afcStats[3];
			t2s5.wing.theLabel.text = "RED ZONE SCORING";
			t2s5.theStat.text = afcStats[4];
		}
		
		private function refreshData():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/getteamsentiment?team=nfc");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, nfcLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		//callback from refreshData()
		private function nfcLoaded(e:Event):void
		{
			var o:Object = JSON.parse(e.currentTarget.data);
			localCache = { nfc:o[0].NetSentiment };
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/getteamsentiment?team=afc");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		
		private function dataLoaded(e:Event):void
		{
			var o:Object = JSON.parse(e.currentTarget.data);
			localCache.afc = o[0].NetSentiment;
			
			animText();
			//incVideo();
			if (TESTING) {				
				show();
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void	
		{
			
			if(localCache == null){
				localCache = { afc:"+50", nfc:"+50" };
			}
			animText();
			//incVideo();
			if(TESTING){
				show();	
			}
		}
		
		
		private function incVideo():void
		{
			video = new VideoLoader(videos[vidIndex][0], { width:432, height:244, x:104, y:550, autoPlay:false, container:this } );
			video.load();
			video.content.alpha = 0;
			//vidIndex++;
			if (vidIndex >= videos.length) {
				vidIndex = 0;
			}
		}
		
		
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		public function show():void
		{
			tvt.alpha = 0;//team vs team text inside circle
			
			lWing.x = 265;//hide wings in masks
			rWing.x = 175;
			
			team1.alpha = 0;//logos
			team2.alpha = 0;
			team1.scaleX = team1.scaleY = 2;
			team2.scaleX = team2.scaleY = 2;
			
			t1s1.alpha = 0;
			t1s2.alpha = 0;
			t1s3.alpha = 0;
			t1s4.alpha = 0;
			t1s5.alpha = 0;
			t1s1.wing.x = 182;
			t1s2.wing.x = 182;
			t1s3.wing.x = 182;
			t1s4.wing.x = 182;
			t1s5.wing.x = 182;
			
			t2s1.alpha = 0;
			t2s2.alpha = 0;
			t2s3.alpha = 0;
			t2s4.alpha = 0;
			t2s5.alpha = 0;
			t2s1.wing.x = -111;
			t2s2.wing.x = -111;
			t2s3.wing.x = -111;
			t2s4.wing.x = -111;
			t2s5.wing.x = -111;
			
			sent.y = 734;
			sent.lWing.x = 8;
			sent.rWing.x = 110;
			
			theFact.alpha = 0;
			
			vidBar.alpha = 0;
			week15.y = 236;
			
			animValue = { angle:0 };			
			
			TweenMax.to(tvt, .75, { alpha:1, delay:.5 } );			
			TweenMax.to(animValue, .5, { angle:360, onUpdate:fillArc, onComplete:showWings, ease:Linear.easeNone } );			
		}
		
		
		private function fillArc():void
		{
			Utility.drawArc(tvtCircle.graphics, 0, 0, 60, 0, animValue.angle, 18, 0xcccccc, 1);
		}
		
		
		private function showWings():void
		{
			TweenMax.to(lWing, .75, { x:59 } );
			TweenMax.to(rWing, .75, { x:379 } );
			
			TweenMax.to(team1, 1, { scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut, delay:.5 } );
			TweenMax.to(team2, 1, { scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut, delay:.5 } );
			
			week15.theText.text = videos[vidIndex][1];
			TweenMax.to(week15, .5, { y:275, delay:1, onComplete:animStats, ease:Back.easeOut } );
		}
			
		private function animStats():void
		{
			TweenMax.to(t1s1, .25, { alpha:1 } );			
			TweenMax.to(t1s2, .25, { alpha:1, delay:.1 } );
			TweenMax.to(t1s3, .25, { alpha:1, delay:.2 } );
			TweenMax.to(t1s4, .25, { alpha:1, delay:.3 } );
			TweenMax.to(t1s5, .25, { alpha:1, delay:.4 } );
			TweenMax.to(t1s1.wing, .5, { x:0 } );
			TweenMax.to(t1s2.wing, .5, { x:0, delay:.1 } );
			TweenMax.to(t1s3.wing, .5, { x:0, delay:.2 } );
			TweenMax.to(t1s4.wing, .5, { x:0, delay:.3 } );
			TweenMax.to(t1s5.wing, .5, { x:0, delay:.4 } );
			
			TweenMax.to(t2s1, .25, { alpha:1 } );			
			TweenMax.to(t2s2, .25, { alpha:1, delay:.1 } );
			TweenMax.to(t2s3, .25, { alpha:1, delay:.2 } );
			TweenMax.to(t2s4, .25, { alpha:1, delay:.3 } );
			TweenMax.to(t2s5, .25, { alpha:1, delay:.4 } );
			TweenMax.to(t2s1.wing, .5, { x:72 } );
			TweenMax.to(t2s2.wing, .5, { x:72, delay:.1 } );
			TweenMax.to(t2s3.wing, .5, { x:72, delay:.2 } );
			TweenMax.to(t2s4.wing, .5, { x:72, delay:.3 } );
			TweenMax.to(t2s5.wing, .5, { x:72, delay:.4, onComplete:showFact} );
			
			TweenMax.to(sent, .5, { y:772, delay:1.5, ease:Back.easeOut } );
			TweenMax.to(sent.lWing, .5, { x:-72, delay:1.75 } );
			TweenMax.to(sent.rWing, .5, { x:200, delay:1.75 } );
			
			//only animate sentiment text first time through
			if(vidIndex == 0){
				animValue.dummy = 0;
				TweenMax.to(animValue, 3, { dummy:3, onUpdate:animateText, onComplete:showActualText } );
			}
		}
		
		
		private function showFact():void
		{
			theFact.theText.text = videos[vidIndex][2];
			theFact.theText.y = (130 - theFact.theText.textHeight) * .5;
			
			TweenMax.to(theFact, .5, { alpha:1 } );
			TweenMax.to(theFact, 1, { alpha:0, delay:3, onComplete:playVid } );
		}
		
		
		/**
		 * sets up animChars for animating in animateText()
		 */
		private function animText():void
		{			
			animChars = new Array([], []);
			
			var i:int;
			var n:int;
			for (i = 0; i < localCache.nfc.length; i++) {
				n = localCache.nfc.charCodeAt(i);
				if (n >= 48 && n <= 57) {
					//number
					animChars[0][i] = 1;//mark this character for animation
				}else {
					animChars[0][i] = 0;//don't animate this char - it's not a number
				}
			}
			for (i = 0; i < localCache.afc.length; i++) {
				n = localCache.afc.charCodeAt(i);
				if (n >= 48 && n <= 57) {
					//number
					animChars[1][i] = 1;//mark this character for animation
				}else {
					animChars[1][i] = 0;//don't animate this char - it's not a number
				}
			}
		}
		
		
		/**
		 * Called by TweenMax onUpdate
		 */
		private function animateText():void
		{
			var newString:String = "";
			var i:int;
			var n:int;
			for (i = 0; i < localCache.nfc.length; i++) {
				n = 47 + Math.ceil(Math.random() * 10); //48 to 57
				if (animChars[0][i] == 1) {
					newString += String.fromCharCode(n);
				}else {
					newString += localCache.nfc.charAt(i);
				}
			}
			
			sent.lWing.theText.text = newString;
			//theStat.theValue.setTextFormat(tf);
			
			newString = "";
			for (i = 0; i < localCache.afc.length; i++) {
				n = 47 + Math.ceil(Math.random() * 10); //48 to 57
				if (animChars[1][i] == 1) {
					newString += String.fromCharCode(n);
				}else {
					newString += localCache.afc.charAt(i);
				}
			}
			sent.rWing.theText.text = newString;			
		}
		
		
		private function showActualText():void
		{
			sent.lWing.theText.text = localCache.nfc;
			sent.rWing.theText.text = localCache.afc;
		}
		
		
		/**
		 * callback from TweenMax in showFact()
		 */
		private function playVid():void
		{
			video = new VideoLoader(videos[vidIndex][0], { width:432, height:244, x:104, y:495, autoPlay:false, container:this } );
			video.load();
			video.content.alpha = 0;
			//vidIndex++;
			if (vidIndex >= videos.length) {
				vidIndex = 0;
			}
			
			video.playVideo();
			video.addEventListener(VideoLoader.VIDEO_COMPLETE, nextVideo);

			TweenMax.to(video.content, .5, { alpha:1 } );
			TweenMax.to(vidBar, .5, { alpha:1 } );			
		}
		
		private function nextVideo(e:Event):void
		{
			video.removeEventListener(VideoLoader.VIDEO_COMPLETE, nextVideo);
			video.dispose(true);
			vidIndex++;
			if (vidIndex < videos.length) {
				//tween out current week indicator and stats
				TweenMax.to(week15, .5, { y:236 } );
				//stats
				TweenMax.to(t1s5.wing, .5, { x:182 } );
				TweenMax.to(t1s4.wing, .5, { x:182, delay:.1 } );
				TweenMax.to(t1s3.wing, .5, { x:182, delay:.2 } );
				TweenMax.to(t1s2.wing, .5, { x:182, delay:.3 } );
				TweenMax.to(t1s1.wing, .5, { x:182, delay:.4 } );
				
				TweenMax.to(t1s5, .25, { alpha:0, delay:.5 } );			
				TweenMax.to(t1s4, .25, { alpha:0, delay:.6 } );
				TweenMax.to(t1s3, .25, { alpha:0, delay:.7 } );
				TweenMax.to(t1s2, .25, { alpha:0, delay:.8 } );
				TweenMax.to(t1s1, .25, { alpha:0, delay:.9 } );
				
				TweenMax.to(t2s5.wing, .5, { x:-111 } );
				TweenMax.to(t2s4.wing, .5, { x:-111, delay:.1 } );
				TweenMax.to(t2s3.wing, .5, { x:-111, delay:.2 } );
				TweenMax.to(t2s2.wing, .5, { x:-111, delay:.3 } );
				TweenMax.to(t2s1.wing, .5, { x: -111, delay:.4 } );
				
				TweenMax.to(t2s5, .25, { alpha:0, delay:.5 } );			
				TweenMax.to(t2s4, .25, { alpha:0, delay:.6 } );
				TweenMax.to(t2s3, .25, { alpha:0, delay:.7 } );
				TweenMax.to(t2s2, .25, { alpha:0, delay:.8 } );
				TweenMax.to(t2s1, .25, { alpha:0, delay:.9 } );
				
				//TweenMax.to(video.content, .5, { alpha:0 } );
				TweenMax.to(vidBar, .5, { alpha:0 } );
			
				TweenMax.delayedCall(.9, setStats);
				week15.theText.text = videos[vidIndex][1];
				TweenMax.to(week15, .5, { y:275, delay:1, onComplete:animStats, ease:Back.easeOut } );
			}else {
				dispatchEvent(new Event(FINISHED));
			}
		}
		
		
		public function cleanup():void
		{
			vidIndex = 0;
			//video.dispose(true);
			hideThings();
			tvtCircle.graphics.clear();
			refreshData();
		}
		
	}
	
}