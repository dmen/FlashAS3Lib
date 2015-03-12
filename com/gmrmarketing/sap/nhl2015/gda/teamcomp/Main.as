package com.gmrmarketing.sap.nhl2015.gda.teamcomp
{
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.Strings;
	

	public class Main extends MovieClip implements IModuleMethods
	{
		public static const FINISHED:String = "finished";
		private const DISPLAY_TIME:int = 15;
		
		private var degToRad:Number = 0.0174532925; //PI / 180
		
		private var homeRing:MovieClip;
		private var homeTwitter:MovieClip;
		private var homeStats:MovieClip;
		private var homeSent:Sprite; //container for animated arc
		
		private var visRing:MovieClip;
		private var visTwitter:MovieClip;
		private var visStats:MovieClip;
		private var visSent:Sprite; //container for animated arc
		
		private var tweenObject:Object;
		private var localCache:Object;
		private var animValues:Array//for animating stats
		private var TESTING:Boolean = false;
		
		
		public function Main()
		{
			homeRing = new ringSharks();			
			homeTwitter = new whiteTop();
			TweenMax.to(homeTwitter.bg, 0, { tint:0x007789 } );
			homeStats = new stats();			
			
			visRing = new ringLA();
			visTwitter = new whiteTop();
			TweenMax.to(visTwitter.bg, 0, { tint:0x000000 } );
			visStats = new stats();			
			
			homeSent = new Sprite();///home sentiment
			visSent = new Sprite();//visitor sentiment		
			
			if (TESTING) {
				init();
			}
		}
		
		
		
		/**
		 * initValue is a date like 08/17/14
		 */
		public function init(initValue:String = ""):void
		{
			homeRing.x = -231;
			homeRing.y = 20;
			
			homeTwitter.x = -234;
			homeTwitter.y = 188;
			
			homeStats.x = -234;
			homeStats.y = 240;
			homeStats.scaleY = 0;
			
			visRing.x = 778;
			visRing.y = 20;
			
			visTwitter.x = 775;
			visTwitter.y = 188;
			
			visStats.x = 775;
			visStats.y = 240;			
			visStats.scaleY = 0;			
			
			if(!homeStats.contains(homeSent)){
				homeStats.addChild(homeSent);
			}
			if (!visStats.contains(visSent)) {
				visStats.addChild(visSent);
			}	
			
			teams.y = -275;
			
			tweenObject = { htSent:0, vtSent:0 };
			
			refreshData();
		}
		
		
		private function refreshData():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/NHL/GetTeamComparison?gamedate=02/21/15");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		
		//assumes sharks then kings		
		private function dataLoaded(e:Event):void
		{
			localCache = JSON.parse(e.currentTarget.data);
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/NHL/GetCachedFeed?feed=NHLTeamSentiment");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, sentLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}			
		}
		
		
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		private function dataError(e:IOErrorEvent):void { }
		
		
		//assumes sharks then kings
		private function sentLoaded(e:Event):void
		{
			var sent:Object = JSON.parse(e.currentTarget.data);
			
			//these are strings like "+88" or "-70"
			localCache.Game[0].Teams[0].Stats[0].Sentiment = sent[0].NetSentiment;//sharks
			localCache.Game[0].Teams[1].Stats[0].Sentiment = sent[1].NetSentiment;
			//integer values
			localCache.Game[0].Teams[0].Stats[0].SentimentInt = parseInt(String(sent[0].NetSentiment).substr(1));
			localCache.Game[0].Teams[1].Stats[0].SentimentInt = parseInt(String(sent[1].NetSentiment).substr(1));
			
			if (TESTING) {
				show();
			}
		}
		
		
		public function show():void
		{
			//text in the middle that slides down
			teams.teamHome.text = localCache.Game[0].HomeTeam;
			teams.teamVisiting.text = localCache.Game[0].VisitingTeam;	
			
			var ht:Object = localCache.Game[0].Teams[0];//Home
			var vt:Object = localCache.Game[0].Teams[1];//Visiting
			
			homeTwitter.teamName.text = ht.TeamShortName;
			homeTwitter.twitterHandle.text = ht.TeamTwitterHandle;			
			
			animValues = [String(ht.Stats[0].Wins), String(ht.Stats[0].Losses), String(ht.Stats[0].OTL), String(vt.Stats[0].Wins), String(vt.Stats[0].Losses), String(vt.Stats[0].OTL)];
			
			homeStats.wins.theText.text = "0";
			homeStats.losses.theText.text = "0";
			homeStats.otl.theText.text = "0";
			
			homeStats.wins.scaleX = homeStats.wins.scaleY = 0;
			homeStats.losses.scaleX = homeStats.losses.scaleY = 0;
			homeStats.otl.scaleX = homeStats.otl.scaleY = 0;
			
			visTwitter.teamName.text = vt.TeamShortName;
			visTwitter.twitterHandle.text = vt.TeamTwitterHandle;
			
			visStats.wins.theText.text = "0";
			visStats.losses.theText.text = "0";
			visStats.otl.theText.text = "0";
			
			visStats.wins.scaleX = visStats.wins.scaleY = 0;
			visStats.losses.scaleX = visStats.losses.scaleY = 0;
			visStats.otl.scaleX = visStats.otl.scaleY = 0;
			
			addChild(homeRing);
			addChild(homeTwitter);
			addChild(homeStats);
			
			addChild(visRing);
			addChild(visTwitter);
			addChild(visStats);
			
			TweenMax.to(homeRing, 1, { x:41, ease:Back.easeOut } );
			TweenMax.to(homeTwitter, 1, { x:36, ease:Back.easeOut, delay:.25 } );
			TweenMax.to(homeStats, 1, { x:36, scaleY:1, ease:Back.easeOut, delay:.5 } );
			
			TweenMax.to(homeStats.wins, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.25 } );
			TweenMax.to(homeStats.losses, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.3 } );
			TweenMax.to(homeStats.otl, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.35 } );
			
			TweenMax.to(visRing, 1, { x:514, ease:Back.easeOut, delay:.25 } );
			TweenMax.to(visTwitter, 1, { x:509, ease:Back.easeOut, delay:.5 } );
			TweenMax.to(visStats, 1, { x:509, scaleY:1, ease:Back.easeOut, delay:.75 } );
			
			TweenMax.to(visStats.wins, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.65 } );
			TweenMax.to(visStats.losses, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.55 } );
			TweenMax.to(visStats.otl, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.5 } );
			
			TweenMax.to(teams, 1, { y:50, ease:Back.easeOut, delay:1 } );
			
			//draw filled in white background circles first
			Utility.drawArc(homeStats.graphics, 65, 128, 26, 0, 360, 6, 0x000000);
			Utility.drawArc(visStats.graphics, 65, 128, 26, 0, 360, 6, 0xb0b7bb);
			
			tweenObject.htSent = 0;
			tweenObject.vtSent = 0;
			
			homeStats.theSentiment.theText.text = 0;
			visStats.theSentiment.theText.text = 0;
			
			if (ht.Stats[0].SentimentInt < 0) {
				homeSent.scaleX = -1;
				homeSent.x = 130;
				tweenObject.htNegSent = true;
			}else {
				homeSent.scaleX = 1;
				homeSent.x = 0;
				tweenObject.htNegSent = false;
			}
				
			if (vt.Stats[0].SentimentInt < 0) {
				visSent.scaleX = -1;		
				visSent.x = 130;
				tweenObject.vtNegSent = true;
			}else {
				visSent.scaleX = 1;
				visSent.x = 0;
				tweenObject.vtNegSent = false;
			}
			
			var hts:Number = Math.abs(ht.Stats[0].SentimentInt * 3.6);
			var vts:Number = Math.abs(vt.Stats[0].SentimentInt * 3.6);
			
			TweenMax.to(tweenObject, 5, { htSent:hts, delay:1, onUpdate:drawHSent } );
			TweenMax.to(tweenObject, 5, { vtSent:vts, delay:1, onUpdate:drawVSent } );
			
			tweenObject.dummy = 0;
			TweenMax.to(tweenObject, 2, { dummy:3, delay:1, onUpdate:animateStats, onComplete:showActualStats } );
			
			TweenMax.delayedCall(DISPLAY_TIME, done);
		}
		
		
		private function done():void
		{
			dispatchEvent(new Event(FINISHED));//will call cleanup
		}
		
		
		public function cleanup():void
		{
			teams.y = -275;
			homeRing.x = -231;
			homeRing.y = 20;
			
			homeTwitter.x = -234;
			homeTwitter.y = 188;
			
			homeStats.x = -234;
			homeStats.y = 240;
			homeStats.scaleY = 0;
			
			visRing.x = 778;
			visRing.y = 20;
			
			visTwitter.x = 775;
			visTwitter.y = 188;
			
			visStats.x = 775;
			visStats.y = 240;			
			visStats.scaleY = 0;
			
			tweenObject = { htSent:0, vtSent:0 };
			
			removeChild(homeRing);
			removeChild(homeTwitter);
			removeChild(homeStats);
			
			removeChild(visRing);
			removeChild(visTwitter);
			removeChild(visStats);
			
			homeStats.graphics.clear();
			visStats.graphics.clear();
			
			homeSent.graphics.clear();
			visSent.graphics.clear();
			
			refreshData();
		}
		

		private function animateStats():void
		{
			var thisVal:String;
			var newStrings:Array = [];
			var newString:String;
			var n:int;
			
			for (var i:int = 0; i < 6; i++) {
				thisVal = animValues[i];
				newString = "";
				for (var j:int = 0; j < thisVal.length; j++) {
					n = 47 + Math.ceil(Math.random() * 10); //48 to 57
					newString += String.fromCharCode(n);
				}
				newStrings.push(newString);
			}
			homeStats.wins.theText.text = newStrings[0];
			homeStats.losses.theText.text = newStrings[1];
			homeStats.otl.theText.text = newStrings[2];
			
			visStats.wins.theText.text = newStrings[3];
			visStats.losses.theText.text = newStrings[4];
			visStats.otl.theText.text = newStrings[5];
		}
		
		
		private function showActualStats():void
		{
			homeStats.wins.theText.text = animValues[0];
			homeStats.losses.theText.text = animValues[1];
			homeStats.otl.theText.text = animValues[2];
			
			visStats.wins.theText.text = animValues[3];
			visStats.losses.theText.text = animValues[4];
			visStats.otl.theText.text = animValues[5];
		}
		
		
		private function drawHSent():void
		{
			Utility.drawArc(homeSent.graphics, 65, 128, 26, 0, tweenObject.htSent, 6, 0xffffff);
			if(tweenObject.htNegSent){
				homeStats.theSentiment.theText.text = "-" + Math.round(-tweenObject.htSent / 3.6);
			}else {
				homeStats.theSentiment.theText.text = "+" + Math.round(tweenObject.htSent / 3.6);				
			}			
		}
		
		
		private function drawVSent():void
		{
			Utility.drawArc(visSent.graphics, 65, 128, 26, 0, tweenObject.vtSent, 6, 0xffffff);
			if (tweenObject.vtNegSent) {
				visStats.theSentiment.theText.text = "-" + Math.round(-tweenObject.vtSent / 3.6);
			}else{
				visStats.theSentiment.theText.text = "+" + Math.round(tweenObject.vtSent / 3.6);
			}
			
		}

	}
	
}