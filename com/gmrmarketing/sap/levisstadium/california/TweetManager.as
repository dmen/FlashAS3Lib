package com.gmrmarketing.sap.levisstadium.california
{
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.geom.Point;
	import com.gmrmarketing.sap.levisstadium.california.Tweet;
	import com.gmrmarketing.utilities.Strings;
	
	public class TweetManager
	{
		private var container:DisplayObjectContainer;
		private var tweets:Array; //all tweets from the service
		private var quadrants:Array;//there are four quadrants to display tweets in
		private var curIndex:int; //current index in tweets array
		
		public function TweetManager()
		{
			quadrants = new Array(0, 0, 0, 0); //all four quadrants are empty
			curIndex = 0;
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/netbase/calimaptweets");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.load(r);
		}
	
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		private function dataLoaded(e:Event = null):void
		{			
			var json:Object = JSON.parse(e.currentTarget.data);
			tweets = new Array();
			
			var p:Point;
			var m:String;
			for (var i:int = 0; i < json.length; i++) {
				if(json[i].latitude <= 42 && json[i].latitude > 32 && Math.abs(json[i].longitude) > 114 && Math.abs(json[i].longitude) < 125){
					p = latLonToXY(json[i].latitude, Math.abs(json[i].longitude));	
					m = Strings.removeLineBreaks(json[i].text);
					m = Strings.removeChunk(m, "http://");					
					tweets.push( { user:"@" + json[i].authorname, message:m, theY:p.y, theX:p.x, pic:json[i].profilepicURL } );
				}
			}
			
			//show tweets in all four quadrants
			displayNext();
			displayNext();
			displayNext();
			displayNext();
		}
		
		
		private function displayNext():void
		{
			var a:Tweet = new Tweet();
			a.setContainer(container);
			
			var tw:Object = tweets[curIndex];
			curIndex++;
			if (curIndex >= tweets.length) {
				curIndex = 0;
			}
			var ind:int;
			for (var i:int = 0; i < 4; i++) {
				if (quadrants[i] == 0) {
					ind = i + 1;//quadrant in Tweet is 1-4
					break;
				}
			}
			quadrants[ind - 1] = 1; //mark as used
			a.show(tw.user, tw.message, tw.theX, tw.theY, ind);
			a.addEventListener(Tweet.COMPLETE, recycleQuadrant, false, 0, true);
		}
		
		
		private function recycleQuadrant(e:Event):void
		{
			var q:int = Tweet(e.currentTarget).getQuadrant();//returns 1-4
			quadrants[q - 1] = 0; //mark as unused and available
			displayNext();
		}
		
		
		private function latLonToXY(lat:Number, lon:Number):Point
		{
			//latitude: northern extent of cali is 42.0º
			//longitude: western extent is 124.41º
			
			var latDelta:Number = 42.0 - lat;
			var lonDelta:Number = 124.41 - lon;
			
			//trace("latlontoxy-- lat:", lat, "lon:", lon, "latDelta:", latDelta, "lonDelta:", lonDelta);
			
			var latMultiplier:Number = 50.1054; //pixel extents / degree extents
			var lonMultiplier:Number = 43.0232;
			
			var tx:Number = 164 + (lonDelta * lonMultiplier); //left edge of cali at 164 on stage
			var ty:Number = 16 + (latDelta * latMultiplier); //top of cali at 16 on stage
			
			return new Point(tx, ty);
		}
		
	}
	
}