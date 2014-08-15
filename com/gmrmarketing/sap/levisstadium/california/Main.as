package com.gmrmarketing.sap.levisstadium.california
{
	import flash.display.*;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.net.*;
	import flash.events.*;
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Utility;
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const READY:String = "ready"; //scheduler requires the READY event to be the string "ready"
		
		private var dots:Sprite;//container for all the dot clips
		private var textContainer:Sprite;//container for twitter text messages
		private var tweets:Array; //array of lat/lon/weights from the service
		private var tweetManager:TweetManager; //manages getting and displaying the text tweets
		
		public function Main()
		{
			dots = new Sprite();
			textContainer = new Sprite();
			tweets = new Array();
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/netbase/GameDayAnalytics?data=CaliMapSentiment");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.load(r);
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function setConfig(config:String):void
		{
			
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function show():void
		{			
			addChild(dots);//container for dot clips
			addChild(textContainer);
			
			//add the tweet dots to the map
			var del:Number = 0;
			for (var j:int = 0; j < tweets.length; j++) {
				addLoc(tweets[j].lat, Math.abs(tweets[j].lon), tweets[j].normalized, del);
				del += .25;
			}
			
			tweetManager = new TweetManager();//gets text tweets and starts to display them
			tweetManager.setContainer(textContainer);
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function hide():void
		{
			
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function doStop():void
		{			
			
			
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function kill():void
		{
			if (contains(dots)) {
				removeChild(dots);
			}
			if (contains(textContainer)) {
				removeChild(textContainer);
			}
			tweetManager.kill();
			tweetManager = null;
		}
		

		
		/**
		 * Callback for refreshData()
		 * @param	e
		 */
		private function dataLoaded(e:Event):void
		{			
			var json:Object = JSON.parse(e.currentTarget.data);			
					
			for (var i:int = 0; i < json.length; i++) {
				tweets.push( { lat:json[i].latitude, lon:Math.abs(json[i].longitude), weight:json[i].weight } );				
			}
			
			normalize();
			//tweets.reverse();//draw smaller first
			tweets = Utility.randomizeArray(tweets);
			
			//show();//TESTING
			dispatchEvent(new Event(READY));			
		}
		
		
		/**
		 * Normalizes weights with Math.log() and then does a linear normalization:
		 * newvalue = (newRangeMax - newRangeMin) / (max - min) * (value - max) + newRangeMax
		 * into the range .1 - .6
		 */		
		private function normalize():void
		{
			var newRangeMin:Number = .1;
			var newRangeMax:Number = .6;
			
			var min:int = 500;
			var max:int = 0;
			
			for (var i:int = 0; i < tweets.length; i++) {				
				//normalize value using a logarithm
				tweets[i].normalized = Math.max(Math.log(tweets[i].weight), .2);
				if (tweets[i].normalized < min) {
					min = tweets[i].normalized;
				}
				if (tweets[i].normalized > max) {
					max = tweets[i].normalized;
				}
			}
			
			for (i = 0; i < tweets.length; i++) {
				tweets[i].normalized = (newRangeMax - newRangeMin) / (max - min) * (tweets[i].normalized - max) + newRangeMax;
			}
		}
		
		
		/**
		 * Adds a dot to the map at the specified lat/lon position
		 * @param	lat latitude
		 * @param	lon ABS of longitude
		 * @param	weight Number .1 - .6
		 * @param	del seconds to delay drawing
		 */
		private function addLoc(lat:Number, lon:Number, weight:Number, del:Number = 0):void
		{
			var w:Number;//weight
			var a:Number; //alpha
			var dot:MovieClip; //lib clip
			
			if(weight < .2){
				dot = new dotGray();
				w = 7 * weight;
				a = .2 + Math.random() * .6; //.7 - .9
			}else if (weight < .35) {
				dot = new dotOrange();
				w = weight;
				a = .5 + Math.random() * .2; //.5 - .7
			}else {
				dot = new dotBlue();
				w = weight;
				a = .5 + Math.random() * .2; //.4 - .6
			}
			a = .3 + Math.random() * .6; //.7 - .9
			dot.filters = [new DropShadowFilter(0, 0, 0x000000, .5, 5, 5)];
			var p:Point = latLonToXY(lat, lon);
			dot.x = p.x;
			dot.y = p.y;
			dot.scaleX = dot.scaleY = .01;
			dot.alpha = 0;
			dots.addChild(dot);
			
			TweenMax.to(dot, 1, { alpha:a, scaleX:w, scaleY:w, delay:del, ease:Elastic.easeOut } );
		}
		
		
		/**
		 * latitude is east/west - extents are 124.5º - 114.25º - pixel extents are 279 - 609
		 * longitude is north/south extents are 32.5º - 42º - pixel extents are 123 - 477
		 * 
		 * @param	lat
		 * @param	lon
		 * @return
		 */
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