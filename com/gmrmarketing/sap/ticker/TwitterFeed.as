package com.gmrmarketing.sap.ticker
{
	import flash.display.GraphicsGradientFill;
	import flash.events.*;
	import flash.net.*;
	
	
	public class TwitterFeed extends EventDispatcher
	{
		public static const GOT_FEED:String = "gotFeed";
		public static const FEED_END:String = "noMoreTweets";
		
		private var json:Object;
		private var feedIndex:int;
		private var totalTweets:int;
		
		public function TwitterFeed()
		{			
		}
		
		
		public function getFeeds():void
		{
			var req:URLRequest = new URLRequest("http://wall.thesocialtab.net/SocialPosts/GetPosts?ProgramID=14");
			
			var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
			var hdr2:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			
			req.method = URLRequestMethod.POST;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, gotFeed, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, ioError, false, 0, true);
			lo.load(req);
		}
		
		
		private function gotFeed(e:Event):void
		{
			json = JSON.parse(e.currentTarget.data);
			totalTweets = json.SocialPosts.length;
			feedIndex = -1;
			dispatchEvent(new Event(GOT_FEED));
		}
		
		
		public function getTotalTweets():int
		{
			return totalTweets;
		}
		
		
		public function getNextFeed():String
		{			
			feedIndex++;
			if (feedIndex >= json.SocialPosts.length) {
				dispatchEvent(new Event(FEED_END));
				feedIndex = 0;
			}
			return json.SocialPosts[feedIndex].Text
		}
		
		
		private function ioError(e:IOErrorEvent):void
		{
			trace("IO Error getting tweets");
		}
		
		
	}
	
}