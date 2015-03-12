package com.gmrmarketing.sap.nhl2015.gda.cali
{
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.geom.Point;
	import com.gmrmarketing.sap.levisstadium.california.Tweet;
	import com.gmrmarketing.utilities.Strings;
	import com.gmrmarketing.utilities.SwearFilter;
	import com.greensock.TweenMax;

	
	public class TweetManager
	{
		private var container:DisplayObjectContainer;
		private var tweets:Array; //all tweets from the service
		private var quadrants:Array;//there are two quadrants to display tweets in
		private var killed:Boolean;		
		private var data:Data;
		
		
		public function TweetManager()
		{
			tweets = [];
			data = new Data();
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
			quadrants = new Array(0, 0); //all quadrants are empty
			while (container.numChildren) {
				var t:MovieClip = MovieClip(container.removeChildAt(0));
				t.removeEventListener(Tweet.COMPLETE, recycleQuadrant);
			}
		}
		
		
		public function refresh():void		
		{
			if (tweets.length < 10) {	
				//quadrants = new Array(0, 0); //all quadrants are empty
				
				var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
				var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/NHL/GetCachedFeed?feed=NHLCaliMapTweets");
				r.requestHeaders.push(hdr);
				var l:URLLoader = new URLLoader();
				l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
				l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
				l.load(r);
			}else {
				//trace("not refreshing - tweets.length =",tweets.length);
			}
		}
		
		
		private function dataLoaded(e:Event = null):void
		{			
			var json:Object = JSON.parse(e.currentTarget.data);
			
			var p:Array;
			var m:String;
			var favorQuadrant1:Boolean;
			
			for (var i:int = 0; i < json.length; i++) {
				p = data.getClosest(Math.abs(json[i].latitude), Math.abs(json[i].longitude));
				m = Strings.removeLineBreaks(json[i].text);
				
				while (m.indexOf("http://") != -1){
					m = Strings.removeChunk(m, "http://");
				}
				while (m.indexOf("https://") != -1){
					m = Strings.removeChunk(m, "https://");
				}
				m = SwearFilter.cleanString(m); //remove any major swears
				
				m = m.replace(/&lt;/g, "<");
				m = m.replace(/&gt;/g, "<");
				m = m.replace(/&amp;/g, "&");		
				
				//if latitude < 38 try and put the tweet at upper right
				favorQuadrant1 = false;
				if (json[i].latitude < 38) {
					favorQuadrant1 = true;//try for upper right
				}
				tweets.push( { user:"@" + json[i].authorname, message:m, theX:p[0], theY:p[1], favor1:favorQuadrant1, pic:json[i].profilepicURL } );
			}
		}
		
		
		public function show():void
		{
			//show tweets in both quadrants
			killed = false;
			displayNext();
			TweenMax.delayedCall(2, displayNext);
		}
		
		
		private function dataError(e:IOErrorEvent):void	{}
		
		
		private function displayNext():void
		{
			
			if (!killed && tweets.length > 0) {
				var a:Tweet = new Tweet();
				a.setContainer(container);
				
				var tw:Object = tweets.shift();				
				
				if (tw.favor1 == true) {
					//tweet's latitude is < 38 degrees
					if (quadrants[0] == 0) {
						quadrants[0] = 1; //mark as used
						a.show(tw.user, tw.message, tw.pic, tw.theX, tw.theY, 1);
						a.addEventListener(Tweet.COMPLETE, recycleQuadrant, false, 0, true);
					}else if (quadrants[1] == 0) {
						//favors q1 but it's not available
						//tweets.unshift(tw); //put the tweet back in tweets array for later use
						
						quadrants[1] = 1; //mark as used
						a.show(tw.user, tw.message, tw.pic, tw.theX, tw.theY, 2);
						a.addEventListener(Tweet.COMPLETE, recycleQuadrant, false, 0, true);
						
						//displayNext();
					}
				}else{
					if (quadrants[0] == 0) {
						quadrants[0] = 1; //mark as used
						a.show(tw.user, tw.message, tw.pic, tw.theX, tw.theY, 1);
						a.addEventListener(Tweet.COMPLETE, recycleQuadrant, false, 0, true);
					}else if (quadrants[1] == 0) {
						quadrants[1] = 1; //mark as used
						a.show(tw.user, tw.message, tw.pic, tw.theX, tw.theY, 2);
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
		
	}
	
}