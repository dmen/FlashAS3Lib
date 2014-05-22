package com.gmrmarketing.sap.ticker
{
	import flash.display.*;
	import com.gmrmarketing.sap.ticker.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.*;
	
	
	public class Main extends MovieClip
	{
		private var twitter:TwitterFeed;
		private var encoder:Encoder;
		private var ffmpeg:FFMPEG;
		
		private var frameGrab:BitmapData;
		private var speed:int;
		private var toX:int;
		private var maxTweets:int; //max number of tweets added to the video
		private var currTweet:int;
		
		private const WIDTH:int = 512;
		private const HEIGHT:int = 16;
		
		private var startTime:Number;
		
		
		public function Main()
		{
			twitter = new TwitterFeed();
			encoder = new Encoder(WIDTH, HEIGHT);
			ffmpeg = new FFMPEG();
			
			logText.text = "Getting tweets from feed...\n";
			
			col1.selectedColor = 0xFFCC00;
			col2.selectedColor = 0xFFCC00;
			
			twitter.addEventListener(TwitterFeed.GOT_FEED, tweetsLoaded, false, 0, true);
			twitter.addEventListener(TwitterFeed.FEED_END, tweetsComplete, false, 0, true);			
			twitter.getFeeds();
		}		
		
		
		private function tweetsLoaded(e:Event):void
		{
			logMessage("Retrieved " + String(twitter.getTotalTweets()) + " tweets.");
			btnStart.addEventListener(MouseEvent.CLICK, startEncoding, false, 0, true);
		}
		
		private function startEncoding(e:MouseEvent):void
		{			
			btnStart.removeEventListener(MouseEvent.CLICK, startEncoding);
			btnStop.addEventListener(MouseEvent.CLICK, animComplete, false, 0, true);
			logMessage("Recording begin: " + new Date().toString());
			startTime = getTimer();
			currTweet = 0;
			maxTweets = parseInt(maxT.text);
			if (maxTweets == 0) {
				maxTweets = twitter.getTotalTweets(); //all tweets if param is 0
			}
			logMessage("Encoding " + maxTweets + " tweets");
			speed = parseInt(scSpeed.text);
			encoder.record(fName.text);
			animateNextTweet();
		}
		
		
		private function animateNextTweet():void
		{		
			if(currTweet < maxTweets){
				theText.autoSize = TextFieldAutoSize.LEFT;
				theText.x = WIDTH; //text field on stage
				theText.text = twitter.getNextFeed();
				if (currTweet % 2 == 0) {
					theText.textColor = col1.selectedColor;
				}else {
					theText.textColor = col2.selectedColor;
				}
				toX = 0 - theText.textWidth;
				currTweet++;				
				nextMove();
			}else {				
				animComplete();
			}
		}
		
		
		private function nextMove():void
		{
			theText.x -= speed;
			addFrame();
			var t:Timer = new Timer(10, 1);//wait for encoding
			t.addEventListener(TimerEvent.TIMER, checkPosition, false, 0, true);
			t.start();
			//checkPosition();
		}
		
		
		private function checkPosition(e:TimerEvent = null):void
		{
			if (theText.x > toX) {
				nextMove();
			}else {
				logMessage("done with: " + currTweet);
				animateNextTweet();
			}
		}
		
		
		private function addFrame():void
		{
			var bmd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0xff000000);
			bmd.draw(stage);
			
			frameGrab = new BitmapData(WIDTH, HEIGHT, false, 0xff000000);
			frameGrab.copyPixels(bmd, new Rectangle(0, 0, WIDTH, HEIGHT), new Point(0, 0));
			
			encoder.addFrame(frameGrab);
		}
		
		
		private function animComplete(e:MouseEvent = null):void
		{
			btnStop.removeEventListener(MouseEvent.CLICK, animComplete);
			encoder.stop();
			var delta:Number = getTimer() - startTime;
			logMessage("Recording complete: " + new Date().toString());
			logMessage("Time: " + delta / 1000 + " seconds");
			logMessage("Creating MOV");			
			
			ffmpeg.addEventListener(FFMPEG.COMPLETE, movComplete, false, 0, true);
			ffmpeg.convert(fName.text, outFname.text);
		}
		
		
		/**
		 * called when the call to twitter.getNextFeed() returns the
		 * first tweet again
		 * @param	e
		 */
		private function tweetsComplete(e:Event):void
		{
			animComplete();//stop recording
		}		
		
		
		private function movComplete(e:Event):void
		{
			ffmpeg.removeEventListener(FFMPEG.COMPLETE, movComplete);
			logMessage("MOV Complete");
		}
		
		
		private function logMessage(mess:String):void
		{
			logText.appendText(mess + "\n");
			logText.scrollV++;
		}
		
	}
	
}