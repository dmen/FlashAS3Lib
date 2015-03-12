package com.gmrmarketing.sap.nhl2015.gda.cali
{
	import flash.display.*;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.net.*;
	import flash.events.*;
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Utility;
	
	public class Main extends MovieClip implements IModuleMethods
	{
		public static const FINISHED:String = "finished";
		private var DISPLAY_TIME:int = 30;
		private var dots:Sprite;//container for all the dot clips
		private var textContainer:Sprite;//container for twitter text messages
		private var tweetManager:TweetManager; //manages getting and displaying the text tweets
		private var localCache:Array; //array of lat/lon/weights from the service
		private var data:Data;
		private var TESTING:Boolean = false;
		
		
		public function Main()
		{
			data = new Data();
			dots = new Sprite();
			textContainer = new Sprite();
			
			tweetManager = new TweetManager();//gets text tweets and starts to display them
			tweetManager.setContainer(textContainer);
			
			if (TESTING) {
				init();
			}
		}
		
		
		public function init(initValue:String = ""):void
		{
			refreshData();			
		}
		
		
		private function refreshData():void
		{
			tweetManager.refresh();
			
			//gets the sentiment values which is for the dots
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/NHL/GetCachedFeed?feed=NHLCaliMapVolume");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			l.load(r);
		}
		
		
		/**
		 * Callback for refreshData()
		 * @param	e
		 */
		private function dataLoaded(e:Event):void
		{			
			var json:Object = JSON.parse(e.currentTarget.data);			
			localCache = [];
			
			for (var i:int = 0; i < json.length; i++) {
				localCache.push( { lat:json[i].latitude, lon:Math.abs(json[i].longitude), weight:json[i].weight, name:json[i].name } );				
			}
			//trace(localCache.length);
			normalize();
			//tweets.reverse();//draw smaller first
			localCache = Utility.randomizeArray(localCache);			
			
			//limit to 100 points
			//localCache = localCache.slice(0, 100);			
			
			if (TESTING) {
				show();
			}
		}
		
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		private function dataError(e:IOErrorEvent):void	{}
		
		
		public function show():void
		{			
			addChild(dots);//container for dot clips
			addChild(textContainer);
			
			tweetManager.show();
			
			//add the tweet dots to the map
			var del:Number = 0;
			for (var j:int = 0; j < localCache.length; j++) {
				addLoc(localCache[j].lat, localCache[j].lon, localCache[j].normalized, del, localCache[j].name);
				del += .075;
			}
			//trace(del);
			TweenMax.delayedCall(DISPLAY_TIME, done);
		}
		
		
		private function done():void
		{			
			dispatchEvent(new Event(FINISHED));//will call cleanup
		}
		
		
		public function cleanup():void
		{			
			while (dots.numChildren) {
				dots.removeChildAt(0);
			}
			
			if (contains(dots)) {
				removeChild(dots);
			}
			
			if (contains(textContainer)) {
				removeChild(textContainer);
			}
			
			tweetManager.kill();//removes tweets from textContainer
			refreshData();
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
			
			var min:Number = 500;
			var max:Number = 0;
			
			for (var i:int = 0; i < localCache.length; i++) {				
				//normalize value using a logarithm
				localCache[i].normalized = Math.max(Math.log(localCache[i].weight), .2);
				if (localCache[i].normalized < min) {
					min = localCache[i].normalized;
				}
				if (localCache[i].normalized > max) {
					max = localCache[i].normalized;
				}
			}
			
			for (i = 0; i < localCache.length; i++) {
				//localCache[i].normalized = (localCache[i].normalized - min) / (max - min);
				localCache[i].normalized = (newRangeMax - newRangeMin) / (max - min) * (localCache[i].normalized - max) + newRangeMax;
			}
		}
		
		
		/**
		 * Adds a dot to the map at the specified lat/lon position
		 * @param	lat latitude
		 * @param	lon ABS of longitude
		 * @param	weight Number .1 - .6
		 * @param	del seconds to delay drawing
		 */
		private function addLoc(lat:Number, lon:Number, weight:Number, del:Number = 0, n:String=""):void
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
			
			var p:Array = data.getClosest(lat, lon);
			dot.x = p[0];
			dot.y = p[1];
			dot.scaleX = dot.scaleY = .01;
			dot.alpha = 0;
			dots.addChild(dot);
			dot.cacheAsBitmap = true;
			dot.theName.text = n;
			
			TweenMax.to(dot, 1, { alpha:a, scaleX:w, scaleY:w, delay:del, ease:Elastic.easeOut } );
		}
				
	}
	
}