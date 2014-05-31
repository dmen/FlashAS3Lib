/**
 * Twitter feed to MOV creator for SAP
 * Creates video.flv and outputName.mov
 * in the User/Documents folder
 */
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
	import flash.ui.Mouse;
	import flash.utils.*;
	
	
	public class Main extends MovieClip
	{
		private var twitter:TwitterFeed;
		private var encoder:Encoder;
		private var ffmpeg:FFMPEG;
		private var soccerFacts:SoccerFacts;
		
		private var frameGrab:BitmapData;
		private var speed:int = 4;
		private var toX:int;		
		private var currTweet:int;
		
		private const WIDTH:int = 1280;//Final video size
		private const HEIGHT:int = 1024;
		private const STARTX:int = 850; //where text starts animating from
		
		private var startTime:Number;
		private var charCount:int; //total characters animated
		
		private var speedRatios:Array;//characters per second speed for each speed 1-6
		private var maxChars:int; //determined by dividing the video length (in sec) by the speedRatio for that speed
		
		private const grabRect:Rectangle = new Rectangle(0, 0, 1280, 18)
		private const grabPoint:Point = new Point(0, 0);
		
		private var moveContainer:Sprite; //holds all text chunks - instances of lib item 'mover'
		private var gap:int = 250; //pixels between text chunks
		
		
		public function Main()
		{
			twitter = new TwitterFeed();
			encoder = new Encoder(WIDTH, HEIGHT);
			ffmpeg = new FFMPEG();
			soccerFacts = new SoccerFacts();
			
			//divide into the number of seconds in the video length to get the number of chars in the video - speeds are 3 - 7
			speedRatios = new Array(.1433962264150943, .1036349574632637, .072957623416339, .0678708264915161, .0581180811808118);
			
			col1.selectedColor = 0x008FCC;//bright blue twitter text
			col1t.selectedColor = 0x9C277B;//bright purple title
			
			col2.selectedColor = 0xB4CA48;//bright green soccer facts
			col2t.selectedColor = 0xDE8A2E;//bright orange title
			
			moveContainer = new Sprite();
			moveContainer.x = STARTX;
			moveContainer.y = -6;
			
			//scroll speed buttons
			btnD.addEventListener(MouseEvent.CLICK, lessSpeed, false, 0, true);
			btnU.addEventListener(MouseEvent.CLICK, moreSpeed, false, 0, true);
			
			frameGrab = new BitmapData(WIDTH, HEIGHT, false, 0xff000000);
			
			getTweets();
		}
		
		/**
		 * called from constructor and start button press to recycle
		 * @param	e
		 */
		private function getTweets(e:MouseEvent = null):void
		{
			btnStart.removeEventListener(MouseEvent.CLICK, getTweets);
			
			logText.text = "Refreshing Tweets...\n";
			
			soccerFacts.rand(); //randomize the facts
			twitter.addEventListener(TwitterFeed.GOT_FEED, tweetsLoaded, false, 0, true);
			twitter.addEventListener(TwitterFeed.FEED_END, tweetsComplete, false, 0, true);			
			twitter.getFeeds();
		}
		
		
		private function lessSpeed(e:MouseEvent):void
		{
			speed--;
			if (speed < 3) {
				speed = 3;
			}
			scSpeed.text = String(speed);
		}
		
		
		private function moreSpeed(e:MouseEvent):void
		{
			speed++;
			if (speed > 7) {
				speed = 7;
			}
			scSpeed.text = String(speed);
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
			
			maxChars = parseFloat(vidTime.text) / speedRatios[speed - 3];
			
			var currTweet:int = 0;
			var curX:int = 0;

			charCount = 0;

			//NEW METHOD - Tweets then Facts
			var halfMax:int = Math.round(maxChars * .5);
			
			//Tweets first - TITLE
			var mes:MovieClip = new mover2(); //lib clip
			mes.theText.autoSize = TextFieldAutoSize.LEFT;
			mes.theText.htmlText = "<b>** Soccer Social Feed **</b>";
			mes.theText.textColor = col1t.selectedColor;
			moveContainer.addChild(mes);
			mes.x = curX;
			curX += mes.theText.textWidth + 20;			
			
			while (charCount < halfMax) {
				mes = new mover2(); //lib clip
				mes.theText.autoSize = TextFieldAutoSize.LEFT;
				
				mes.theText.htmlText = twitter.getNextFeed();
				//mes.theText.text = twitter.getNextFeed();
				mes.theText.textColor = col1.selectedColor;
				
				charCount += mes.theText.length;
				
				logMessage("Adding tweet - length: " + mes.theText.length);		
				
				moveContainer.addChild(mes);
				mes.x = curX;
				curX += mes.theText.textWidth + gap;
			}
			
			var temp:int = charCount; //total chars in tweets
			
			//Soccer Facts
			charCount = 0;
			
			
			mes = new mover2(); //lib clip
			mes.theText.autoSize = TextFieldAutoSize.LEFT;
			mes.theText.htmlText = "<b>** Soccer Insights **</b>";
			mes.theText.textColor = col2t.selectedColor;
			moveContainer.addChild(mes);		
			mes.x = curX;
			curX += mes.theText.textWidth + 20;
			
			while (charCount < halfMax) {
				mes = new mover2(); //lib clip
				mes.theText.autoSize = TextFieldAutoSize.LEFT;
				
				mes.theText.htmlText = soccerFacts.getFact();
				mes.theText.textColor = col2.selectedColor;
				
				charCount += mes.theText.length;
				
				logMessage("Adding insight - length: " + mes.theText.length);
				
				moveContainer.addChild(mes);
				mes.x = curX;
				curX += mes.theText.textWidth + gap;
			}			
			
			//OLD METHOD - Mixed Tweets and Facts
			/*
			while (charCount < maxChars) {
				
				var mes:MovieClip = new mover(); //lib clip
				mes.theText.autoSize = TextFieldAutoSize.LEFT;
				
				//Color / Fact Cycle
				if (currTweet % 2 == 0) {
					mes.icon.gotoAndStop(1);//twitter icon
					mes.theText.text = twitter.getNextFeed();
					mes.theText.textColor = col1.selectedColor;
				}else {
					mes.icon.gotoAndStop(2);//soccer ball icon
					mes.theText.text = soccerFacts.getFact();
					mes.theText.textColor = col2.selectedColor;
				}
				
				currTweet++;
				charCount += mes.theText.length;
				moveContainer.addChild(mes);
				mes.x = curX;
				curX += mes.theText.textWidth + mes.theText.x + gap;
			}
			*/
			
			charCount += temp; //add tweets to soccer total
			
			addChild(moveContainer);				
			
			toX = 0 - moveContainer.width;
			
			encoder.record();//start encoding
			
			addEventListener(Event.ENTER_FRAME, nextMove, false, 0, true);
		}
		
		
		/**
		 * Animation step
		 * Moves the text chunk to the left by speed pixels
		 */
		private function nextMove(e:Event):void
		{
			moveContainer.x -= speed;
			
			var stagePic:BitmapData = new BitmapData(900, 250, false, 0xff000000);//stage width, height
			stagePic.draw(stage);
			
			frameGrab.copyPixels(stagePic, grabRect, grabPoint);			
			encoder.addFrame(frameGrab);
			
			if (moveContainer.x <= toX) {
				removeEventListener(Event.ENTER_FRAME, nextMove);
				animComplete();
			}			
		}		
		
		
		/**
		 * Called from animateNextTweet() or by pressing stop button
		 * @param	e
		 */
		private function animComplete(e:MouseEvent = null):void
		{
			removeEventListener(Event.ENTER_FRAME, nextMove);
			btnStop.removeEventListener(MouseEvent.CLICK, animComplete);
			encoder.stop();
			var delta:Number = getTimer() - startTime;
			logMessage("Recording complete: " + new Date().toString());
			logMessage("Time: " + delta / 1000 + " seconds");
			logMessage("Total characters animated: " + charCount);
			logMessage("Creating MOV - FFMPEG is working...");			
			
			ffmpeg.addEventListener(FFMPEG.COMPLETE, movComplete, false, 0, true);
			ffmpeg.addEventListener(FFMPEG.DELETED, movDeleted, false, 0, true);
			ffmpeg.convert(encoder.getFLVName(), outFname.text);
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
			ffmpeg.removeEventListener(FFMPEG.DELETED, movDeleted);
			logMessage("Conversion to MOV Complete");			
			btnStart.addEventListener(MouseEvent.CLICK, getTweets, false, 0, true);
		}
		
		private function movDeleted(e:Event):void
		{
			logMessage("Old MOV file deleted");
		}	
		
		
		private function logMessage(mess:String):void
		{
			logText.appendText(mess + "\n");
			logText.scrollV++;
		}
		
	}
	
}