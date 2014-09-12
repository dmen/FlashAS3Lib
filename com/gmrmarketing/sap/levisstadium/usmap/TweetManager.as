package com.gmrmarketing.sap.levisstadium.usmap
{
	import flash.display.*;
	import flash.errors.IOError;
	import flash.net.*;
	import flash.events.*;
	import flash.geom.Point;
	import com.gmrmarketing.sap.levisstadium.california.Tweet;
	import com.gmrmarketing.utilities.Strings;
	import com.greensock.TweenMax;
	
	
	public class TweetManager
	{
		private var container:DisplayObjectContainer;
		private var tweets:Array; //all tweets from the service
		private var q0:Boolean;//true if the quadrant is available
		private var q1:Boolean;
		private var killed:Boolean;
		private var localCache:Array;
		
		
		
		public function TweetManager()
		{
			q0 = true;//both quadrants available
			q1 = true;
		}
	
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			killed = false;
			container = $container;
		}
		
		
		public function kill():void
		{
			killed = true;
			q0 = true;//both quadrants available
			q1 = true;
			while (container.numChildren) {
				var t:MovieClip = MovieClip(container.removeChildAt(0));
				t.removeEventListener(Tweet.COMPLETE, recycleQuadrant);
			}
		}
		
		
		public function refresh():void		
		{			
			killed = false;
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/netbase/GameDayAnalytics?data=CaliMapTweets"+"&abc="+String(new Date().valueOf()));
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			l.load(r);
		}
		
		
		private function dataLoaded(e:Event = null):void
		{			
			var json:Object = JSON.parse(e.currentTarget.data);
			tweets = new Array();
			
			var p:Point;
			var m:String;
			//var favorQuadrant1:Boolean;
			
			for (var i:int = 0; i < json.length; i++) {
					p = latLonToXY(json[i].latitude, Math.abs(json[i].longitude));	
					m = Strings.removeLineBreaks(json[i].text);
					m = Strings.removeChunk(m, "http://");
					//favorQuadrant1 = false;
					//if (json[i].latitude < 37) {
						//favorQuadrant1 = true;
					//}
					tweets.push( { user:"@" + json[i].authorname, message:m, theY:p.y, theX:p.x, pic:json[i].profilepicURL } );//favor1:favorQuadrant1,
			}
			
			localCache = tweets.concat();
			
			//show tweets in both quadrants
			displayNext();
			TweenMax.delayedCall(2, displayNext);
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			if (localCache) {
				tweets = localCache.concat();
				displayNext();
				TweenMax.delayedCall(2, displayNext);
			}else {
				
			}
		}
		
		
		private function displayNext():void
		{
			if (!killed) {
				
				var a:Tweet;
				
				var tw:Object = tweets.shift();				
				if (tweets.length == 0) {
					refresh();
					return;
				}
				
				if (q0) {
					
					a = new Tweet();
					a.setContainer(container);
					q0 = false; //mark as used
					a.show(tw.user, tw.message, tw.theX, tw.theY, 0);
					a.addEventListener(Tweet.COMPLETE, recycleQuadrant);
					
				}else if (q1) {
					
					a = new Tweet();
					a.setContainer(container);
					q1 = false; //mark as used
					a.show(tw.user, tw.message, tw.theX, tw.theY, 1);
					a.addEventListener(Tweet.COMPLETE, recycleQuadrant);
					
				}
			}
		}
		
		
		private function recycleQuadrant(e:Event):void
		{
			if (!killed) {
				var a:Tweet = Tweet(e.currentTarget);
				a.removeEventListener(Tweet.COMPLETE, recycleQuadrant);
				var q:int = a.getQuadrant();//returns 0-1
				a.dispose();
				if (q == 0) {
					q0 = true;
				}else {
					q1 = true;
				}
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
			//latitude: northern extent of wash is 48.0º - 192 pixels - southern is 25º - 467 pixels
			//longitude: western extent is 124.5º - 80 pixels - eastern is 66º - 638 pixels
			
			var latDelta:Number = 48.0 - lat;
			var lonDelta:Number = 124.5 - lon;
			
			var latMultiplier:Number = 11.956521; //pixel extents / degree extents (467 - 192)/(48 - 25) = 275 / 23
			var lonMultiplier:Number = 9.5384615; // (638 - 80) / (124.5 - 66) = 558 / 58.5
			
			var tx:Number = 80 + (lonDelta * lonMultiplier); //left edge of cali at 279 on stage
			var ty:Number = 192 + (latDelta * latMultiplier); //top of cali at 123 on stage
			
			return new Point(tx,ty);
		}
		
	}
	
}