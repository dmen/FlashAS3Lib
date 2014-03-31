package com.gmrmarketing.wrigley.gumergency
{
	import flash.events.*;
	import flash.net.*;	
	import flash.utils.Timer;
	
	public class FeedReader extends EventDispatcher
	{
		public static const COMPLETE:String = "feedMessagesRetrieved";
		public static const ERROR:String = "feedError";
		
		//private const FEED_URL2:String = "http://wall.thesocialtab.net/SocialPosts/GetPosts?ProgramId=17";//rosie
		private const FEED_URL:String = "http://wall.thesocialtab.net/SocialPosts/GetPosts?ProgramId=27&SwearRating=8";//gumergency
		private var req:URLRequest;
		private var posts:Array;//All the posts - array of arrays - subarrays contain [id,message]
		private var newPosts:Array; //Just the new posts since last time the service was called
		private var loadTimer:Timer;
		private var newPostNum:int = 0;
		
		private var delayTime:Number;
		private var testMode:Boolean = false;
		
		
		public function FeedReader()
		{
			posts = new Array();
			newPosts = new Array();
			
			delayTime = 180000;
			
			loadTimer = new Timer(180000, 1);//3 minutes between checks
			loadTimer.addEventListener(TimerEvent.TIMER, load, false, 0, true);
			
			load();
		}
		
		
		/**
		 * Returns all posts retrieved thus far
		 * @return
		 */
		public function getMessages():String
		{
			var m:String = "";
			
			for (var i:int = 0; i < posts.length; i++) {
				m += posts[i][1];
				m += "              ";
			}
			return m;
		}
		
		
		/**
		 * Returns the new posts only
		 * @return
		 */
		public function getNewMessages():String
		{
			var m:String = "";
			
			for (var i:int = 0; i < newPosts.length; i++) {
				if(testMode){
					m += String(i) + ": " + posts[i][1];
				}else{
					m += posts[i][1];
				}
				m += "              ";
			}
			return m;
		}
		
		
		public function refreshQueue(n:int):void
		{
			loadTimer.reset();			
			delayTime = n;
			loadTimer.delay = delayTime;
			loadTimer.start();
		}
		
		
		public function getNumNewMessages():int
		{
			return newPostNum;
		}
	
		
		public function setTestMode(t:Boolean):void
		{
			testMode = t;			
		}
		
		/**
		 * Called from LEDSign.doReset()
		 * clears all posts
		 */
		public function resetTimer():void
		{
			loadTimer.reset();
			//loadTimer.start();
			posts = new Array();
			newPostNum = 0;
		}
		
		
		public function load(e:TimerEvent = null):void
		{
			loadTimer.reset();//restarted in retrieved feed
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");			
			
			req = new URLRequest(FEED_URL);			
			
			req.requestHeaders.push(hdr);
			
			req.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, feedError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, retrievedFeed, false, 0, true);
			
			lo.load(req);
		}
		
		
		private function retrievedFeed(e:Event):void
		{
			//trace("======================= RETRIEVED FEED =======================");
			var json:Object = JSON.parse(e.currentTarget.data);
			
			var num:int = json.SocialPosts.length;
			//num = Math.min(5, num);//TESTING ONLY
			
			var thisID:int;
			var foundID:Boolean;
			var p1:String;
			var p2:String;
			
			newPostNum = 0;
			newPosts = new Array();
			
			for (var i:int = 0; i < num; i++) {
				thisID = json.SocialPosts[i].ID;
				
				//check to see if this ID is already in the retrieved posts
				foundID = false;
				for (var j:int = 0; j < posts.length; j++) {
					if (posts[j][0] == thisID) {
						foundID = true;
						break;
					}
				}
				
				if (!foundID) {
					var message:String = json.SocialPosts[i].Text;
					
					//remove URL's from message
					var ind:int;
					ind = message.indexOf("http:");
					while (ind != -1) {						
						var ind2:int = message.indexOf(" ", ind);
						if (ind2 == -1) {							
							ind2 = message.length;
						}
						p1 = message.substr(0, ind);
						p2 = message.substr(ind2);
						
						message = p1 + p2;
						ind = message.indexOf("http:");
					}
					ind = message.indexOf("https:");
					while (ind != -1) {						
						ind2 = message.indexOf(" ", ind);						
						if (ind2 == -1) {							
							ind2 = message.length;
						}
						p1 = message.substr(0, ind);
						p2 = message.substr(ind2);
						
						message = p1 + p2;	
						ind = message.indexOf("https:");		
					}
					
					if (testMode) {
						//in test mode only give back 1/10th the actual messages
						if(Math.random() < .1){
							posts.unshift([thisID, message]);//unshift inserts at the beginning of the array
							newPosts.push([thisID, message]);
							
							//trace(thisID, message);
							newPostNum++;
						}
					}else {
						posts.unshift([thisID, message]);//unshift inserts at the beginning of the array
						newPosts.push([thisID, message]);
						
						//trace(thisID, message);
						newPostNum++;
					}
				}				
			}
			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		/**
		 * resets main load timer and calls load again in 30 seconds
		 * @param	e
		 */
		private function feedError(e:IOErrorEvent):void
		{
			dispatchEvent(new Event(ERROR));			
			refreshQueue(30000);
		}
		
	}
	
}