package com.gmrmarketing.sap.superbowl.gda.usmap
{
	import flash.display.*;
	import flash.errors.IOError;
	import flash.net.*;
	import flash.events.*;
	import flash.geom.Point;
	import com.gmrmarketing.sap.superbowl.gda.usmap.Tweet;
	import com.gmrmarketing.sap.superbowl.gda.usmap.Data;
	import com.gmrmarketing.utilities.Strings;
	import com.greensock.TweenMax;
	
	
	public class TweetManager extends EventDispatcher
	{		
		public static const FINISHED:String = "tweetsDisplayed";
		public static const READY:String = "dataReady";
		private var container:DisplayObjectContainer;
		private var localCache:Array;//all tweets from the service
		private var cacheIndex:int; //current index in localCache
		private var isRunning:Boolean;
		private var needsRefreshing:Boolean;//set to true in displayTweets() once the list of tweets has been displayed
		private var tweetX:int; //starts at 660
		private var tweetCount:int; //used to know when all tweets have been displayed
		private var data:Data;
		
		public function TweetManager()
		{
			data = new Data();
			needsRefreshing = true;			
		}
	
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		//called from Main.show() or Main.startTweets() once ready is received
		//ie data is loaded
		public function start():void
		{
			tweetX = 660; //starting x pos for tweets - off screen right
			isRunning = true;			
			displayTweets();
		}
		
		
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		public function stop():void
		{			
			isRunning = false;
			while (container.numChildren) {
				container.removeChildAt(0);				
			}
		}
		
		
		/**
		 * Gets new tweet data from the server
		 * initially called from Main.dataLoaded() and then 
		 * from Main.cleanup()
		 */
		public function refresh():void		
		{
			if(needsRefreshing){
				var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
				var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetUSMapTweets");
				r.requestHeaders.push(hdr);
				var l:URLLoader = new URLLoader();
				l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
				l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
				l.load(r);
			}
		}
		
		
		/**
		 * Callback from service call
		 * Populates localCache
		 * @param	e
		 */
		private function dataLoaded(e:Event = null):void
		{			
			var json:Object = JSON.parse(e.currentTarget.data);
			localCache = new Array();
			needsRefreshing = false;
			cacheIndex = 0;
			//var p:Point;
			var p:Array;
			var m:String;
			
			//limit the number of tweets displayed before refreshing
			//always use the 20 latest
			var maxTweets:int = Math.min(20, json.length);
			
			for (var i:int = 0; i < maxTweets; i++) {
				//p = latLonToXY(json[i].latitude, Math.abs(json[i].longitude));
				p = data.getClosest(Math.abs(json[i].latitude), Math.abs(json[i].longitude));
				m = Strings.removeLineBreaks(json[i].text);
				m = Strings.removeChunk(m, "http://");
				m = Strings.removeChunk(m, "https://");
				localCache.push( { user:"@" + json[i].authorname, message:m, theY:p[1], theX:p[0], pic:json[i].profilepicURL } );				
			}			
			dispatchEvent(new Event(READY));
		}
		
		
		private function dataError(e:IOErrorEvent):void	{}
		
		
		/**
		 * called from start()
		 */
		private function displayTweets():void
		{
			var a:Tweet;
			if (localCache && localCache.length) {
				
				tweetCount = 5;
				for (var i:int = 0; i < 5; i++) {
					
					var tw:Object = localCache[cacheIndex];
					cacheIndex++;
					if (cacheIndex >= localCache.length) {
						cacheIndex = 0;
						needsRefreshing = true;//will load data in refresh
					}
					
					a = new Tweet();
					a.setContainer(container);
					a.addEventListener(Tweet.COMPLETE, tweetComplete);
					a.show(tw.user, tw.message, tw.theX, tw.theY, tweetX);
					
					tweetX += a.getWidth() + 60;
				}
			}
		}		
		
		
		private function tweetComplete(e:Event):void
		{
			var a:Tweet = Tweet(e.target);
			a.removeEventListener(Tweet.COMPLETE, tweetComplete);
			a.dispose();
			
			tweetCount--;
			if (tweetCount == 0) {
				dispatchEvent(new Event(FINISHED));
			}
		}
		
		
		/**
		 * Latitude is North/South
		 * Longitude is East/West
		 * 
		 * @param	lat
		 * @param	lon
		 * @return
		 */
		private function latLonToXY(lat:Number, lon:Number):Point
		{
			//latitude: northern extent of wash is 48.0º - 164 pixels - southern is 25º - 494 pixels
			//longitude: western extent is 124.5º - 40 pixels - eastern is 66º - 595 pixels
			
			//lat = lat < 25 ? 25 : lat;
			//lat = lat > 48 ? 48 : lat;
			//lon = lon > 124.5 ? 124.5 : lon;
			//lon = lon < 66 ? 66 : lon;
			
			var latDelta:Number = 48.0 - lat;
			var lonDelta:Number = 124.5 - lon;
			
			var latMultiplier:Number = 14.3478; //pixel extents / degree extents (494 - 164)/(48 - 25) = 330 / 23   - NORTH
			var lonMultiplier:Number = 9.4871; // (595 - 40) / (124.5 - 66) = 555 / 58.5     - WEST
			
			var lonAdd:int;
			if (lon > 80) {
				//west of 80 lat
				lonAdd = 40;
			}else {
				//east of 80 lat
				lonAdd = 75;
			}
			
			var tx:Number = 40 + lonDelta * lonMultiplier;
			var ty:Number = 164 + latDelta * latMultiplier;
			
			//trace(lat,"N",lon,"W",latDelta,lonDelta
			
			return new Point(tx,ty);
		}		
		
		
	}
	
}