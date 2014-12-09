package com.gmrmarketing.sap.metlife.twitterTicker
{
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.text.*;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.Strings;
	import com.gmrmarketing.utilities.SwearFilter;
	import flash.utils.Timer;
	
	public class Main extends MovieClip
	{		
		private var localCache:Object; //copy of last good json get from the web service
		private var tweetIndex:int; //current index in json array		
		private var tweets:Array; //references to tweets on screen
		private var refreshing:Boolean;
		
		public function Main()
		{			
			tweets = new Array();
			init();
		}
		
		
		/**
		 * Loads the tweets from the web service
		 */
		public function init(e:TimerEvent = null):void
		{
			refreshing = true;
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapmetlifeapi.thesocialtab.net/Api/GameDay/GetCachedFeed?feed=SAPJetsTweets" + "&abc=" + String(new Date().valueOf()));
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
			refreshing = false;
			localCache = JSON.parse(e.currentTarget.data);//array of objects with authorname and text properties
			if(localCache.length > 0){
				show();
			}else {
				checkAgain();
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			if (localCache) {
				refreshing = false;
				show();
			}else {
				checkAgain();
			}
		}
		
		
		private function checkAgain():void
		{
			var t:Timer = new Timer(30000, 1);
			t.addEventListener(TimerEvent.TIMER, init, false, 0, true);
			t.start();
		}
		
		
		public function show():void
		{
			tweetIndex = 0;			
			addTweet();
			addEventListener(Event.ENTER_FRAME, move);
		}
		
		
		private function addTweet():void
		{	
			var tw:MovieClip = new tickerText(); //lib clip
			tw.theText.autoSize = TextFieldAutoSize.LEFT;
			var message:String = localCache[tweetIndex].text;
			
			//Clean up the message
			message = Strings.removeLineBreaks(message);
			message = message.replace(/&lt;/g, "<");
			message = message.replace(/&gt;/g, "<");
			message = message.replace(/&amp;/g, "&");
			message = Strings.removeChunk(message, "http://");
			message = SwearFilter.cleanString(message); //remove any major swears
			
			tw.theText.text = "@" + localCache[tweetIndex].authorname + " " + message;
			tw.theText.cacheAsBitmap = true;
			tw.slash.x = tw.theText.textWidth + 18;
			tw.x = 1018;//1008 - but add 10 to space out the slash
			tw.y = -3;
			addChild(tw);
			tweets.push(tw);
		}
		
		
		/**
		 * Moves the background city graphic
		 * and tweetContainer
		 * @param	e
		 */
		private function move(e:Event):void
		{		
			//scroll city background
			
			bg.x += .12;
			if (bg.x >= 0) {
				bg.x = -1008;//reset to starting position
			}
			
			//move all tweets
			for (var i:int = 0; i < tweets.length; i++){
				tweets[i].x -= 1;				
			}
			
			//see if last tweet has moved left of the screens right edge - if so add another tweet
			var m:MovieClip = MovieClip(tweets[tweets.length - 1]);
			if (m.x <= 1008 - m.width  && !refreshing) {
				tweetIndex++;
				if (tweetIndex >= localCache.length) {
					refreshing = true;
					init();
				}else{
					addTweet();
				}
			}
			
			//see if the first tweet is off screen left and remove it if so
			m = MovieClip(tweets[0]);
			if (m.x <= - m.width ){
				removeChild(tweets[0]);
				tweets.shift();
			}
		}
	}
	
}