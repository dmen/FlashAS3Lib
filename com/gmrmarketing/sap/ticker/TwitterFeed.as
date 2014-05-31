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
		
		private var tweets:Array;
		
		
		public function TwitterFeed()
		{			
		}
		
		
		public function getFeeds():void
		{
			var req:URLRequest = new URLRequest("http://wall.thesocialtab.net/SocialPosts/GetPosts?ProgramID=46&ShowImages=False");
			
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
			
			tweets = new Array();			
			
			var cleaned:String;
			for (var i:int = 0; i < totalTweets; i++) {
				
				cleaned = json.SocialPosts[i].Text;			
				//cleaned = cleaned.replace(/\&lt;/g, "<");
				//cleaned = cleaned.replace(/\&gt;/g, ">");
				//cleaned = cleaned.replace(/\&amp;/g, "&");
				cleaned = cleaned.replace(/[\r\n]+/g, "");				
				cleaned = cleaned.replace('⚽', "☺");//soccer ball
				
				tweets.push("<b>"+cleaned+"</b>");
				//tweets.push(cleaned);
			}	
			
			
			dispatchEvent(new Event(GOT_FEED));
		}
		
		
		public function getTotalTweets():int
		{
			return totalTweets;
		}
		
		
		public function getNextFeed():String
		{			
			feedIndex++;
			if (feedIndex >= tweets.length) {
				dispatchEvent(new Event(FEED_END));
				feedIndex = 0;
			}
			return tweets[feedIndex];
		}
		
		
		private function ioError(e:IOErrorEvent):void
		{
			trace("IO Error getting tweets");
		}
		
		
	}
	
}