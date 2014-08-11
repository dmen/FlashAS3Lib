package com.gmrmarketing.sap.levisstadium.usmap
{
	import flash.display.*;
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
		private var quadrants:Array;//there are two quadrants to display tweets in
		
		public function TweetManager()
		{
			quadrants = new Array(0, 0); //all quadrants are empty
			refresh();
		}
	
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		public function stop():void
		{
			while (container.numChildren) {
				container.removeChildAt(0);
			}
		}
		
		private function refresh():void		
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/netbase/GameDayAnalytics?data=CaliMapTweets");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.load(r);
		}
		
		
		private function dataLoaded(e:Event = null):void
		{			
			var json:Object = JSON.parse(e.currentTarget.data);
			tweets = new Array();
			
			var p:Point;
			var m:String;
			var favorQuadrant1:Boolean;
			
			for (var i:int = 0; i < json.length; i++) {
				//if(json[i].latitude <= 42 && json[i].latitude > 32 && Math.abs(json[i].longitude) > 114 && Math.abs(json[i].longitude) < 125){
					p = latLonToXY(json[i].latitude, Math.abs(json[i].longitude));	
					m = Strings.removeLineBreaks(json[i].text);
					m = Strings.removeChunk(m, "http://");
					favorQuadrant1 = false;
					if (json[i].latitude < 37) {
						favorQuadrant1 = true;
					}
					tweets.push( { user:"@" + json[i].authorname, message:m, theY:p.y, theX:p.x, favor1:favorQuadrant1, pic:json[i].profilepicURL } );
				//}
			}
			
			//show tweets in both quadrants
			displayNext();
			TweenMax.delayedCall(2, displayNext);
		}
		
		
		private function displayNext():void
		{
			var a:Tweet = new Tweet();
			a.setContainer(container);
			
			var tw:Object = tweets.shift();				
			if (tweets.length == 0) {
				refresh();
				return;
			}
			if (tw.favor1 == true) {				
				if (quadrants[0] == 0) {
					quadrants[0] = 1; //mark as used
					a.show(tw.user, tw.message, tw.theX, tw.theY, 1);
					a.addEventListener(Tweet.COMPLETE, recycleQuadrant, false, 0, true);
				}else if (quadrants[1] == 0) {
					//favors q1 but it's not available
					//tweets.unshift(tw); //put the tweet back in tweets array for later use
					/*
					quadrants[1] = 1; //mark as used
					a.show(tw.user, tw.message, tw.theX, tw.theY, 2);
					a.addEventListener(Tweet.COMPLETE, recycleQuadrant, false, 0, true);
					*/
					displayNext();
				}
			}else{
				if (quadrants[0] == 0) {
					quadrants[0] = 1; //mark as used
					a.show(tw.user, tw.message, tw.theX, tw.theY, 1);
					a.addEventListener(Tweet.COMPLETE, recycleQuadrant, false, 0, true);
				}else if (quadrants[1] == 0) {
					quadrants[1] = 1; //mark as used
					a.show(tw.user, tw.message, tw.theX, tw.theY, 2);
					a.addEventListener(Tweet.COMPLETE, recycleQuadrant, false, 0, true);
				}
			}			
		}
		
		
		private function recycleQuadrant(e:Event):void
		{
			var q:int = Tweet(e.currentTarget).getQuadrant();//returns 1-2
			quadrants[q - 1] = 0; //mark as unused and available
			displayNext();
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