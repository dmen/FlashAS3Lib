package com.gmrmarketing.sap.superbowl.gda.teamvteam
{
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.TextFieldAutoSize;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.loading.*;
	import com.greensock.loading.display.*;
	import com.greensock.*;
	import com.greensock.events.LoaderEvent;
	import com.gmrmarketing.utilities.Utility;
	import flash.text.TextFormat;
	
	
	public class Main extends MovieClip implements IModuleMethods
	{
		public static const FINISHED:String = "finished";
		private var localCache:Object;
		private var video:VideoLoader;
		private var tvtCircle:Sprite;//gray circle in the title		
		private var animValue:Object;//for animating sentiment
		private var animChars:Array;
		private var allVids:Array;		
		private var setIndex:int; //1 or 2 - set in init() - for showing the first four milestones, or the second four
		private var curStat:int//
		private var animValues:Array//for animating stats
		private var TESTING:Boolean = false;
		
		
		public function Main()
		{
			tvtCircle = new Sprite();
			
			//milestone videos - nfc,afc,nfc,afc - first four are for set 1, second four are for set 2
			allVids = ["SeahawksWeek1.mp4","PatriotsWeek5.mp4","SeahawksWeek10.mp4","PatriotsWeek8.mp4","SeahawksWeek13.mp4","PatriotsWeek9.mp4","SeahawksWeek17.mp4","PatriotsWeek15.mp4"];					
			
			if(TESTING){
				init();
			}
		}
		
		
		/**
		 * Only called once
		 * @param	initValue String 1 or 2 for the video set - first set of 4 or second set of 4
		 */
		public function init(initValue:String = "1"):void
		{			
			setIndex = parseInt(initValue);
			
			if(!contains(tvtCircle)){
				addChild(tvtCircle);
			}
			tvtCircle.x = 320;
			tvtCircle.y = 166;
			
			hideThings();
			
			//setStats();
			
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
			
			//vidBar.alpha = 0;
			week15.y = 236;	
		}
		
		
		//sets the stats per week
		private function setStats():void
		{
			var o:Object;
			
			if (curStat % 2 == 0) {
				//nfc current
				t1s1.wing.theLabel.text = "WINS";
				t1s1.theStat.text = localCache.stats[curStat].MilestoneWins;
				t1s2.wing.theLabel.text = "LOSSES";
				t1s2.theStat.text = localCache.stats[curStat].MilestoneLosses;
				t1s3.wing.theLabel.text = "RUSHING YARDS";
				t1s3.theStat.text = localCache.stats[curStat].MilestoneRushingYds;
				t1s4.wing.theLabel.text = "PASSING YARDS";
				t1s4.theStat.text = localCache.stats[curStat].MilestonePassingYds;
				t1s5.wing.theLabel.text = "TOUCHDOWNS";
				t1s5.theStat.text = localCache.stats[curStat].MilestoneTDs;
				
				t2s1.wing.theLabel.text = "WINS";
				t2s1.theStat.text = localCache.stats[curStat].AltTeamWins;
				t2s2.wing.theLabel.text = "LOSSES";
				t2s2.theStat.text = localCache.stats[curStat].AltTeamLosses;
				t2s3.wing.theLabel.text = "RUSHING YARDS";
				t2s3.theStat.text = localCache.stats[curStat].AltTeamRushingYds;
				t2s4.wing.theLabel.text = "PASSING YARDS";
				t2s4.theStat.text = localCache.stats[curStat].AltTeamPassingYds;
				t2s5.wing.theLabel.text = "TOUCHDOWNS";
				t2s5.theStat.text = localCache.stats[curStat].AltTeamTDs;
				
				o = localCache.stats[curStat];
				animValues = [o.MilestoneWins, o.MilestoneLosses, o.MilestoneRushingYds, o.MilestonePassingYds, o.MilestoneTDs, o.AltTeamWins, o.AltTeamLosses, o.AltTeamRushingYds, o.AltTeamPassingYds, o.AltTeamTDs];
				
			}else {
				//afc current
				t1s1.wing.theLabel.text = "WINS";
				t1s1.theStat.text = localCache.stats[curStat].AltTeamWins;
				t1s2.wing.theLabel.text = "LOSSES";
				t1s2.theStat.text = localCache.stats[curStat].AltTeamLosses;
				t1s3.wing.theLabel.text = "RUSHING YARDS";
				t1s3.theStat.text = localCache.stats[curStat].AltTeamRushingYds;
				t1s4.wing.theLabel.text = "PASSING YARDS";
				t1s4.theStat.text = localCache.stats[curStat].AltTeamPassingYds;
				t1s5.wing.theLabel.text = "TOUCHDOWNS";
				t1s5.theStat.text = localCache.stats[curStat].AltTeamTDs;
				
				t2s1.wing.theLabel.text = "WINS";
				t2s1.theStat.text = localCache.stats[curStat].MilestoneWins;
				t2s2.wing.theLabel.text = "LOSSES";
				t2s2.theStat.text = localCache.stats[curStat].MilestoneLosses;
				t2s3.wing.theLabel.text = "RUSHING YARDS";
				t2s3.theStat.text = localCache.stats[curStat].MilestoneRushingYds;
				t2s4.wing.theLabel.text = "PASSING YARDS";
				t2s4.theStat.text = localCache.stats[curStat].MilestonePassingYds;
				t2s5.wing.theLabel.text = "TOUCHDOWNS";
				t2s5.theStat.text = localCache.stats[curStat].MilestoneTDs;
				
				o = localCache.stats[curStat];
				animValues = [o.AltTeamWins, o.AltTeamLosses, o.AltTeamRushingYds, o.AltTeamPassingYds, o.AltTeamTDs, o.MilestoneWins, o.MilestoneLosses, o.MilestoneRushingYds, o.MilestonePassingYds, o.MilestoneTDs];
				
			}
		}
		
		
		private function refreshData():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetCachedFeed?feed=TeamSentimentNFC");
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
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetCachedFeed?feed=TeamSentimentAFC");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, afcLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		
		private function afcLoaded(e:Event):void
		{
			var o:Object = JSON.parse(e.currentTarget.data);
			localCache.afc = o[0].NetSentiment;
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetMilestones");
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
			var o:Object = JSON.parse(e.currentTarget.data);//array of 8 objects - four NFC, then four AFC			
			localCache.stats = [o[0], o[4], o[1], o[5], o[2], o[6], o[3], o[7]]; 
			//localCache.stats2 = []; //for set 2
			
			animText();//sets up animChars array
			if (TESTING) {				
				show();
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void	
		{
			
			if(localCache == null || localCache.afc == null){
				localCache = { afc:"+50", nfc:"+50" };
			}
			animText();//sets up animChars array
			if(TESTING){
				show();	
			}
		}
		
		
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		public function show():void
		{
			//set the start position within localCache stats
			if (setIndex == 1) {
				curStat = 0; //play 0,1,2,3 - nfc1,afc1,nfc2,afc2
			}else {
				curStat = 4; //play 4,5,6,7 - nfc3,afc3,nfc4,afc4
			}			
			
			//hideThings() called prior by init() or by cleanup()
			setStats();
			
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
			
			week15.theText.text = localCache.stats[curStat].MilestoneWeek;
			
			
			if (curStat % 2 == 0) {
				//nfc stat
				TweenMax.to(week15.bg, .25, { colorTransform: { tint:0x69a639, tintAmount:1 }} );
			}else {
				TweenMax.to(week15.bg, .25, { colorTransform: { tint:0x0d254c, tintAmount:1 }} );
			}
			
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
			if(curStat == 0 || curStat == 4){
				animValue.dummy = 0;
				TweenMax.to(animValue, 3, { dummy:3, onUpdate:animateText, onComplete:showActualText } );
			}
			animValue.dummy2 = 5;
			TweenMax.to(animValue, 1, { dummy2:3, onUpdate:animateStats, onComplete:showActualStats } );
			
		}
		
		//milestone text
		private function showFact():void
		{
			theFact.theText.autoSize = TextFieldAutoSize.CENTER;
			theFact.theText.text = localCache.stats[curStat].MilestoneDescription;
			
			var tf:TextFormat = theFact.theText.getTextFormat();

			while(theFact.theText.textHeight > 110){	
				 tf.size = int(tf.size) - 1;
				theFact.theText.setTextFormat(tf);
			}
			
			theFact.theText.y = (125 - theFact.theText.textHeight) * .5;
			
			if (curStat % 2 == 0) {
				//nfc stat
				TweenMax.to(theFact.bg, .5, { colorTransform: { tint:0x69a639, tintAmount:1 }} );
			}else {
				TweenMax.to(theFact.bg, .5, { colorTransform: { tint:0x0d254c, tintAmount:1 }} );
			}
			TweenMax.to(theFact, .5, { alpha:1 } );
			TweenMax.to(theFact, 1, { alpha:0, delay:5, onComplete:playVid } );
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
		
		private function animateStats():void
		{
			var thisVal:String;
			var newStrings:Array = [];
			var newString:String;
			var n:int;
			
			for (var i:int = 0; i < 10; i++) {
				thisVal = animValues[i];
				newString = "";
				for (var j:int = 0; j < thisVal.length; j++) {
					n = 47 + Math.ceil(Math.random() * 10); //48 to 57
					newString += String.fromCharCode(n);
				}
				newStrings.push(newString);
			}
			t1s1.theStat.text = newStrings[0];
			t1s2.theStat.text = newStrings[1];
			t1s3.theStat.text = newStrings[2];
			t1s4.theStat.text = newStrings[3];
			t1s5.theStat.text = newStrings[4];
			
			t2s1.theStat.text = newStrings[5];
			t2s2.theStat.text = newStrings[6];
			t2s3.theStat.text = newStrings[7];
			t2s4.theStat.text = newStrings[8];
			t2s5.theStat.text = newStrings[9];
		}
		
		
		private function showActualStats():void
		{
			t1s1.theStat.text = animValues[0];
			t1s2.theStat.text = animValues[1];
			t1s3.theStat.text = animValues[2];
			t1s4.theStat.text = animValues[3];
			t1s5.theStat.text = animValues[4];
			
			t2s1.theStat.text = animValues[5];
			t2s2.theStat.text = animValues[6];
			t2s3.theStat.text = animValues[7];
			t2s4.theStat.text = animValues[8];
			t2s5.theStat.text = animValues[9];
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
			video = new VideoLoader(allVids[curStat], { width:432, height:244, x:104, y:507, autoPlay:false, container:this } );
			video.load();
			video.content.alpha = 0;			
			
			video.playVideo();
			video.addEventListener(VideoLoader.VIDEO_COMPLETE, nextVideo);

			TweenMax.to(video.content, .5, { alpha:1 } );
			//TweenMax.to(vidBar, .5, { alpha:1 } );			
		}
		
		
		private function nextVideo(e:Event):void
		{
			video.removeEventListener(VideoLoader.VIDEO_COMPLETE, nextVideo);
			video.dispose(true);
			
			curStat++;
			if ((setIndex == 1 && curStat < 4) || (setIndex == 2 && curStat < 8)) {
				//tween out current week indicator and stats
				TweenMax.to(week15, .5, { y:236, onComplete:swapWeek } );
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
				//TweenMax.to(vidBar, .5, { alpha:0 } );
				
				TweenMax.to(week15, .5, { y:275, delay:1.5, onStart:setStats, onComplete:animStats, ease:Back.easeOut } );
			}else {
				dispatchEvent(new Event(FINISHED));
			}
		}
		private function swapWeek():void
		{
			week15.theText.text = localCache.stats[curStat].MilestoneWeek;
				
				if (curStat % 2 == 0) {
					//nfc stat
					TweenMax.to(week15.bg, .25, { colorTransform: { tint:0x69a639, tintAmount:1 }} );
				}else {
					TweenMax.to(week15.bg, .25, { colorTransform: { tint:0x0d254c, tintAmount:1 }} );
				}
		}
		
		
		public function cleanup():void
		{			
			//video.dispose(true);
			hideThings();
			tvtCircle.graphics.clear();
			refreshData();
		}
		
	}
	
}