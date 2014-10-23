package com.gmrmarketing.sap.metlife.giants.usmap
{
	import flash.display.*;
	import flash.errors.IOError;
	import flash.net.*;
	import flash.events.*;
	import flash.geom.Point;
	import com.gmrmarketing.sap.metlife.usmap.Tweet;
	import com.gmrmarketing.utilities.Strings;
	import com.greensock.TweenMax;
	
	
	public class TweetManager extends EventDispatcher
	{
		public static const READY:String = "dataReady";
		private var container:DisplayObjectContainer;
		private var q0:Boolean;//true if the quadrant is available
		private var q1:Boolean;
		private var localCache:Array;//all tweets from the service
		private var cacheIndex:int; //current loc in localCache
		private var isRunning:Boolean;
		private var needsRefreshing:Boolean;
		
		
		public function TweetManager()
		{
			needsRefreshing = true;
		}
	
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		//called from Main.dataReady()
		public function start():void
		{
			isRunning = true;
			needsRefreshing = true;
			q0 = true;//both quadrants available
			q1 = true;
			cacheIndex = 0;
			displayNext();
			TweenMax.delayedCall(1, displayNext);
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
				var r:URLRequest = new URLRequest("http://sapmetlifeapi.thesocialtab.net/api/GameDay/GetCachedFeed?feed=NYGiantsUSMapTweets"+"&abc="+String(new Date().valueOf()));
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
			var p:Point;
			var m:String;
			
			for (var i:int = 0; i < json.length; i++) {
				p = latLonToXY(json[i].latitude, Math.abs(json[i].longitude));	
				m = Strings.removeLineBreaks(json[i].text);
				m = Strings.removeChunk(m, "http://");
				localCache.push( { user:"@" + json[i].authorname, message:m, theY:p.y, theX:p.x, pic:json[i].profilepicURL } );
			}			
			dispatchEvent(new Event(READY));
		}
		
		
		private function dataError(e:IOErrorEvent):void	{}
		
		
		private function displayNext():void
		{
			var a:Tweet;
			
			var tw:Object = localCache[cacheIndex];
			cacheIndex++;
			if (cacheIndex >= localCache.length) {
				cacheIndex = 0;
				needsRefreshing = true;
			}
			
			a = new Tweet();
			a.setContainer(container);
			a.addEventListener(Tweet.COMPLETE, recycleQuadrant);
			
			if (q0) {				
				q0 = false; //mark as used
				a.show(tw.user, tw.message, tw.theX, tw.theY, 0);				
			}else if (q1) {				
				q1 = false; //mark as used
				a.show(tw.user, tw.message, tw.theX, tw.theY, 1);
			}			
		}
		
		
		/**
		 * Callback from Tweet object - tweet has removed itself
		 * @param	e
		 */
		private function recycleQuadrant(e:Event):void
		{			
			var a:Tweet = Tweet(e.currentTarget);
			a.removeEventListener(Tweet.COMPLETE, recycleQuadrant);
			var q:int = a.getQuadrant();//returns 0-1
			a.dispose();
			if (q == 0) {
				q0 = true;
			}else {
				q1 = true;
			}
			if(isRunning){
				displayNext();
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
			//latitude: northern extent of wash is 48.0º - 180 pixels - southern is 25º - 493 pixels
			//longitude: western extent is 124.5º - 227 pixels - eastern is 66º - 776 pixels
			
			lat = lat < 25 ? 25 : lat;
			lat = lat > 48 ? 48 : lat;
			lon = lon > 124.5 ? 124.5 : lon;
			lon = lon < 66 ? 66 : lon;
			
			var latDelta:Number = 48.0 - lat;
			var lonDelta:Number = 124.5 - lon;
			
			var latMultiplier:Number = 14.5; //pixel extents / degree extents (493 - 180)/(48 - 25) = 313 / 23   - NORTH
			var lonMultiplier:Number = 9.9; // (776 - 227) / (124.5 - 66) = 549 / 58.5     - WEST
			
			//east of 
			if (lon < 80) {
				lonMultiplier = 10.2;
				latMultiplier = 11;
			}
			//southern state
			if (lat < 37) {
				latMultiplier = 11.9;
				lonMultiplier = 10.6;
			}
			
			var tx:Number = 227 + lonDelta * lonMultiplier;
			var ty:Number = 180 + latDelta * latMultiplier;
			
			return new Point(tx,ty);
		}
		
	}
	
}