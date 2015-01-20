package com.gmrmarketing.sap.superbowl.ticker
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
		private var tweetIndex:int; //current index in localCache.tweets array
		private var tweetCount:int;
		private var ctaIndex:int;//current index in localCache.cta array
		private var eventsIndex:int; //current index in localCache.events array
		private var lastWasCTA:Boolean;
		private var tweets:Array; //references to scrolling clips(tweets) on screen
		private var refreshing:Boolean;
		private var raySprite:Sprite;
		private var raySprite2:Sprite;
		
		
		public function Main()
		{		
			raySprite = new Sprite();
			raySprite2 = new Sprite();
			addChildAt(raySprite, 0);
			addChildAt(raySprite2, 0);
			raySprite.x = 1040;
			raySprite2.x = 1040;
			raySprite.y = 1200;
			raySprite2.y = 1200;
			
			var g:Graphics = raySprite.graphics;
			var g2:Graphics = raySprite2.graphics;
			g.lineStyle(1, 0x53468d, .6);
			g2.lineStyle(1, 0x53468d, .6);
			
			var x:Number;
			var y:Number;
			for (var i:int = 0; i < 360; i++) {
				if(Math.random() < .35){
					x = Math.cos(i / 57.29577) * 3000;
					y = Math.sin(i / 57.29577) * 3000;
					g.moveTo(0,0);
					g.lineTo(x, y);
				}
				if(Math.random() < .35){
					x = Math.cos(i / 57.29577) * 3000;
					y = Math.sin(i / 57.29577) * 3000;
					g2.moveTo(0,0);
					g2.lineTo(x, y);
				}
			}
			
			tweetCount = 0;
			eventsIndex = 0;
			ctaIndex = 0;
			lastWasCTA = false;
			localCache = new Object();
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
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetCallToAction");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, ctaLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		
		private function ctaLoaded(e:Event):void
		{
			localCache.cta = JSON.parse(e.currentTarget.data);
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetCachedFeed?feed=Events");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, eventsLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		
		private function eventsLoaded(e:Event):void
		{
			localCache.events = JSON.parse(e.currentTarget.data);//array of objects with text property
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetCachedFeed?feed=TickerTweets");
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
			localCache.tweets = JSON.parse(e.currentTarget.data);//array of objects with authorname and text properties
			if(localCache.tweets.length > 0){
				show();
			}else {
				checkAgain();
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			if (localCache.tweets.length > 0) {
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
			tweetCount++;
			
			var tw:MovieClip;
			
			//every 5th tweet add a cta or an event
			if (tweetCount % 3 == 0) {
				if (lastWasCTA) {
					//add an event
					tw = new eventText();//lib clip
					tw.theText.autoSize = TextFieldAutoSize.LEFT;
					
					tw.theText.text = localCache.events[eventsIndex].text;
					
					tw.theText.cacheAsBitmap = true;
					tw.x = 2300;//2080 wide - add a little gap
					tw.y = 60;
					
					eventsIndex++;
					if (eventsIndex >= localCache.events.length) {
						eventsIndex = 0;
					}
					
					lastWasCTA = false;
					
				}else {
					//add a call to action
					tw = new ctaText();//lib clip
					tw.headline1.autoSize = TextFieldAutoSize.LEFT;
					tw.headline2.autoSize = TextFieldAutoSize.LEFT;
					tw.disclaimer.autoSize = TextFieldAutoSize.LEFT;
					
					tw.headline1.text = localCache.cta[ctaIndex].Headline1;
					tw.headline2.text = localCache.cta[ctaIndex].Headline2;
					tw.disclaimer.text = localCache.cta[ctaIndex].Disclaimer;
					
					tw.headline1.cacheAsBitmap = true;
					tw.headline2.cacheAsBitmap = true;				
					tw.disclaimer.cacheAsBitmap = true;
					
					tw.x = 2300;//2080 wide - add a little gap
					tw.y = 50;
					
					ctaIndex++;
					if (ctaIndex >= localCache.cta.length) {
						ctaIndex = 0;
					}
					
					lastWasCTA = true;
				}
			}else {
				tw = new tickerText(); //lib clip
				tw.theText.autoSize = TextFieldAutoSize.LEFT;
				
				//Clean up the tweet
				var message:String = localCache.tweets[tweetIndex].text;
				message = Strings.removeLineBreaks(message);
				message = message.replace(/&lt;/g, "<");
				message = message.replace(/&gt;/g, "<");
				message = message.replace(/&amp;/g, "&");
				message = Strings.removeChunk(message, "http://");
				message = Strings.removeChunk(message, "https://");
				message = SwearFilter.cleanString(message); //remove any major swears
				
				tw.theText.text = message;
				tw.theAuthor.text = "@" + localCache.tweets[tweetIndex].authorname
				tw.theText.cacheAsBitmap = true;
				tw.theAuthor.cacheAsBitmap = true;				
				tw.x = 2300;//2080 wide - add a little gap
				tw.y = 60;
			}
			
			addChildAt(tw, 2);//add behind stats zone logo and in front of raySprites
			tweets.push(tw);
		}
		
		
		/**
		 * Moves the background city graphic
		 * and tweetContainer
		 * @param	e
		 */
		private function move(e:Event):void
		{		
			raySprite.rotation += .06;
			raySprite2.rotation -= .001;
			
			//move all tweets
			for (var i:int = 0; i < tweets.length; i++){
				tweets[i].x -= 1;				
			}
			
			//see if last tweet has moved left of the screens right edge - if so add another tweet
			var m:MovieClip = MovieClip(tweets[tweets.length - 1]);
			if (m.x <= 2080 - m.width  && !refreshing) {
				tweetIndex++;
				if (tweetIndex >= localCache.tweets.length) {
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