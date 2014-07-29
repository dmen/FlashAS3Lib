package com.gmrmarketing.sap.levisstadium.california
{
	import flash.display.*;
	import flash.geom.Point;
	import flash.net.*;
	import flash.events.*;
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		private var dots:Sprite;//container for all the dot clips
		private var textContainer:Sprite;
		private var tweets:Array; //array of lat/lon/weights from the service
		private var tweetManager:TweetManager; //manages getting and displaying the text tweets
		
		public function Main()
		{
			dots = new Sprite();
			textContainer = new Sprite();
			tweets = new Array();			
			
			addChild(dots);
			addChild(textContainer);
			
			tweetManager = new TweetManager();//gets text tweets and starts to display them
			tweetManager.setContainer(textContainer);
			
			refreshData();			
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
		
		
		public function refreshData():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/netbase/calimap");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.load(r);
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
			tweets.reverse();//draw smaller first
			
			var del:Number = 0;
			for (var j:int = 0; j < tweets.length; j++) {
				addLoc(tweets[j].lat, Math.abs(tweets[j].lon), tweets[j].normalized, del);
				del += .1;
			}
			/*
			//now add a tweet text...TESTING
			var a:Tweet = new Tweet();
			a.setContainer(this);
			var p:Point = latLonToXY(tweets[0].lat, tweets[0].lon);
			a.show("#49ersSAP Kaepernick! You rule bra!", p.x, p.y, 3);
			*/
			
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
		
		
		private function addLoc(lat:Number, lon:Number, weight:Number, del:Number = 0):void
		{
			var w:Number;//weight
			var a:Number; //alpha
			var dot:MovieClip; //lib clip
			
			if(weight < .2){
				dot = new dotGray();
				w = 7 * weight;
				a = .6 + Math.random() * .2; //.6 - .8
			}else if (weight < .35) {
				dot = new dotOrange();
				w = weight;
				a = .4 + Math.random() * .2; //.4 - .6
			}else {
				dot = new dotBlue();
				w = weight;
				a = .25 + Math.random() * .3; //.25 - .55
			}
			
			var p:Point = latLonToXY(lat, lon);
			dot.x = p.x;
			dot.y = p.y;
			dot.scaleX = dot.scaleY = .01;
			dot.alpha = 0;
			dots.addChild(dot);
			
			TweenMax.to(dot, 1, { alpha:a, scaleX:w, scaleY:w, delay:del, ease:Elastic.easeOut } );
		}		
		
		
		private function latLonToXY(lat:Number, lon:Number):Point
		{
			//latitude: northern extent of cali is 42.0º
			//longitude: western extent is 124.
			
			var latDelta:Number = 42.0 - lat;
			var lonDelta:Number = 124.41 - lon;
			
			var latMultiplier:Number = 50.1054; //pixel extents / degree extents
			var lonMultiplier:Number = 43.0232;
			
			var tx:Number = 164 + (lonDelta * lonMultiplier); //left edge of cali at 164 on stage
			var ty:Number = 16 + (latDelta * latMultiplier); //top of cali at 16 on stage
			
			return new Point(tx, ty);
		}
				
	}
	
}