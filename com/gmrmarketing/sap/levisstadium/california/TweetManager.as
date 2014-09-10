package com.gmrmarketing.sap.levisstadium.california
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
		private var killed:Boolean;
		private var localCache:Array;
		
		public function TweetManager()
		{
			quadrants = new Array(0, 0); //all quadrants are empty
		}
	
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			killed = false;
			container = $container;
		}
		
		
		//removes tweets from the container
		public function kill():void
		{
			killed = true;
			
			while (container.numChildren) {
				var t:MovieClip = MovieClip(container.removeChildAt(0));
				t.removeEventListener(Tweet.COMPLETE, recycleQuadrant);
			}
		}
		
		public function refresh():void		
		{
			killed = false;
			//quadrants = new Array(0, 0); //all quadrants are empty
			
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
			var favorQuadrant1:Boolean;
			
			for (var i:int = 0; i < json.length; i++) {
				if(json[i].latitude <= 42 && json[i].latitude > 32 && Math.abs(json[i].longitude) > 114 && Math.abs(json[i].longitude) < 125){
					p = latLonToXY(json[i].latitude, Math.abs(json[i].longitude));	
					m = Strings.removeLineBreaks(json[i].text);
					m = Strings.removeChunk(m, "http://");
					favorQuadrant1 = false;
					if (json[i].latitude < 37) {
						favorQuadrant1 = true;
					}
					tweets.push( { user:"@" + json[i].authorname, message:m, theY:p.y, theX:p.x, favor1:favorQuadrant1, pic:json[i].profilepicURL } );
				}
			}
			
			localCache = tweets.concat();//duplicates array
			
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
			if(!killed){
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
		}
		
		
		private function recycleQuadrant(e:Event):void
		{
			if(!killed){
				var q:int = Tweet(e.currentTarget).getQuadrant();//returns 1-2
				quadrants[q - 1] = 0; //mark as unused and available
				displayNext();
			}
		}
		
		
		private function latLonToXY(lat:Number, lon:Number):Point
		{
			//latitude: northern extent of cali is 42.0º - 123 pixels - southern is 32.5 - 477 pixels
			//longitude: western extent is 124.5 - 279 pixels - eastern is 114.25 - 609 pixels
			
			var latDelta:Number = 42.0 - lat;
			var lonDelta:Number = 124.5 - lon;
			
			var latMultiplier:Number = 37.263157; //pixel extents / degree extents (477 - 123)/(42 - 32.5) = 354 / 9.5
			var lonMultiplier:Number = 32.195121; // (609-279) / (124.5 - 114.25) = 330 / 10.25
			
			var tx:Number = 279 + (lonDelta * lonMultiplier); //left edge of cali at 279 on stage
			var ty:Number = 123 + (latDelta * latMultiplier); //top of cali at 123 on stage
			
			return new Point(tx,ty);
		}
		
	}
	
}