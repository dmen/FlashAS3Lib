//PM Demo for iPad

package com.gmrmarketing.pm.matchgame
{	
	import fl.data.DataProvider;
	import flash.display.Bitmap;
	import flash.display.LoaderInfo; //for flashVars
	import flash.display.Loader;
	import flash.display.MovieClip;	
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	import flash.net.navigateToURL;
	
 	import com.greensock.TweenMax;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;
	
	import flash.system.fscommand;
	
	import flash.external.ExternalInterface;
	import flash.display.StageScaleMode;
	
	
	
	
	

	public class Engine extends MovieClip
	{	
		private var gameTime:int;			
		
		private var imageX:int; //position of the difference image on stage
		private var imageY:int;
		
		private var game:Sprite; //contains all game elements
		
		private var beginTime:Number;		
		
		private var scoreText:CurScore;
		private var curScore:int;		
		
		private var curBonus:int = 500; //500 pts for every correct click
		private var badClickPoints:int = 200; //dec 200 for a bad click
		
		private var curDiffs:CurrDiffs;
		
		private var diffLoader:Loader; //for loading the swf's
		private var swfLoader:Loader;
		private var gameSwfs:Array;		
		
		private var theContent:MovieClip; //reference to the loaded swf
		
		private var alreadyClicked:Array; //keeps track of clicked differences
		
		//private var allCircles:Array; //array of Circle objects used for highlights
		
		private var hintDialog:DialogHint;			
		
		private var bigCounter:BigCounter; //countdown timer
		
		private var introCounter:GameStartCountdown; //3-2-1 intro countdown in library contains numberHolder.theText
		private var curCountdownNumber:int; //the 3-2-1 text
		private var countDownTimer:Timer;
		
		private var instructions:Instructions; //library clip - instructions dialog	
		
		private var channel:SoundChannel; //for playing sounds
		//for controlling bg music volume
		private var musicVolume:SoundTransform = new SoundTransform(.15);
		private var music:Sound;
		private var musicChannel:SoundChannel = new SoundChannel();
		
		private var soundOn:Boolean = true; //toggled in soundToggle()
		
		private var secondTimer:Timer;
		
		private var musicArray:Array;
		private var theSong:String;
		
		private var smallDropShadow:DropShadowFilter;
		
		private var configLoader:URLLoader;
		private var scoreToBeat:int;
		private var finalMessageNormal:String;
		private var finalMessageWin:String;
		//private var swfPath:String;		
		
		private var config:XML;
		
		private var venDialog:VenueDialog;
		
		private var initTimer:Timer;
		
		
		public function Engine()
		{				
			initTimer = new Timer(350, 1);
			initTimer.addEventListener(TimerEvent.TIMER, init, false, 0, true);
			initTimer.start();
		}
		
		
		private function init(e:TimerEvent):void
		{			
			initTimer.removeEventListener(TimerEvent.TIMER, init);
			
			if(contains(cover)){
				removeChild(cover);
			}
			
			venDialog = new VenueDialog();
			venDialog.addEventListener("closeVenueDialog", closeVenueDialog, false, 0, true);
			
			//Mouse.hide();			
			
			configLoader = new URLLoader();
			configLoader.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			configLoader.addEventListener(IOErrorEvent.IO_ERROR, configNotFound, false, 0, true);
			configLoader.load(new URLRequest("config.xml"));			

			secondTimer = new Timer(1000);
			secondTimer.addEventListener(TimerEvent.TIMER, updateCountdown);
			
			channel = new SoundChannel();
			musicChannel = new SoundChannel();
			
			curScore = 0;

			game = new Sprite();
			
			scoreText = new CurScore();						
			game.addChild(scoreText);	
			scoreText.x = 497;
			scoreText.y = 31;
			
			curDiffs = new CurrDiffs();					
			game.addChild(curDiffs);			
			curDiffs.x = 506;
			curDiffs.y = 82;
			
			gameTime = 46; 			
			
			hintDialog = new DialogHint();			
			game.addChild(hintDialog);			
			
			//start countdown - the big 3-2-1 counter
			introCounter = new GameStartCountdown();
			introCounter.cacheAsBitmap = true;
			introCounter.cacheAsBitmapMatrix = new Matrix();
			introCounter.x = 508;
			introCounter.y = 430;
			
			//position of the difference image
			imageX = 102;
			imageY = 158;
			
			hintDialog.x = 298;
			hintDialog.y = -1000;			
			
			smallDropShadow = new DropShadowFilter(3, 0, 0, .6, 5, 5, 1, 2, false, false);
			
			//Big countdown timer at upper right
			bigCounter = new BigCounter();		
			bigCounter.cacheAsBitmap = true;
			bigCounter.x = 821;
			bigCounter.y = 19;
			bigCounter.alpha = 1;
			//bigCounter.filters = [smallDropShadow];
			
			game.addChild(bigCounter);
			bigCounter.mouseEnabled = false;
			bigCounter.theText.mouseEnabled = false;
			
			addChild(game);	
			
			//for loading the preview jpegs and swf's
			diffLoader = new Loader();
			swfLoader = new Loader();			
			
			//instructions
			instructions = new Instructions();
			
			ui.cacheAsBitmap = true;
			ui.cacheAsBitmapMatrix = new Matrix();
		}
	
		
		
		// ------------------ PRIVATE --------------------
		/**
		 * Called once config.xml has been loaded
		 * @param	e COMPLETE event
		 */
		private function configLoaded(e:Event):void
		{			
			config = new XML(e.target.data);
			configLoader.removeEventListener(Event.COMPLETE, configLoaded);
			configLoader.removeEventListener(IOErrorEvent.IO_ERROR, configNotFound);
			scoreToBeat = config.scoreToBeat;
			finalMessageNormal = config.didntWinMessage;
			finalMessageWin = config.winMessage;
			//swfPath = config.swfPath;
			
			musicArray = new Array();
			var songList:String = config.soundList;
			var songArray:Array = songList.split(",");
			for (var i:int = 0; i < songArray.length; i++) {
				musicArray.push(songArray[i] + ".mp3");
			}
			
			//playAgain();
			openVenueDialog();
		}
		
		
		
		/**
		 * Provide an impossible to beat score if the config.xml file isn't available
		 * this makes the final dialog show finalMessageNormal instead of finalMessageWin
		 * @param	e
		 */ 
		private function configNotFound(e:IOErrorEvent):void
		{
			scoreToBeat = 1000000;
			//swfPath = "diffs/";
			finalMessageNormal = "THANKS FOR PLAYING";
			playAgain();
		}
		
		
		
		/**
		 * Called initially from configLoaded 
		 * Called from addInstructions when frame = 3 - normal results
		 * 
		 * @param	e
		 */
		private function playAgain(e:MouseEvent = null):void
		{
			if (contains(swfLoader)) {
				removeChild(swfLoader);
			}
			curScore = 0;
			scoreText.theText.text = numberFormatter(curScore);
			gameTime = 45;
			bigCounter.theText.text = "45";	
			curDiffs.theText.text = "0 of 3";
			
			buildSWFArray();
			
			addInstructions(1);
		}
		
		
		
		/**
		 * Called from playAgain()
		 * populates and randomizes the gameSwfs aray
		 */
		private function buildSWFArray():void		
		{		
			gameSwfs = new Array();
			
			var swfList:String = config.swfList;
			var swfs:Array = swfList.split(",");
			
			var temp:Array = new Array();			
			
			//randomize array
			var rInd:int;
			while (swfs.length) {
				rInd = Math.floor(swfs.length * Math.random());
				gameSwfs.push(swfs.splice(rInd, 1)[0] + ".swf");				
			}			
		}
		
		
		
		/**
		 * Init game variables
		 * 
		 * Called from diffLoaded() once the difference swf is loaded and ready
		 */
		private function begin():void		
		{			
			curDiffs.theText.text = "0 of 3";	
			
			//contains the clicked differences
			alreadyClicked = new Array();
			
			startCountdown(); //start 45 sec countdown	
		}
		
		
		
		
		/**
		 * Adds the big instructions dialog to the game
		 * 
		 * Shows the specified frame: 1 - normal instructions, 2 - results
		 * 
		 * @param	whichFrame 1: normal instructions, 5: head to head wait
		 */
		private function addInstructions(whichFrame:int = 1):void
		{	
			instructions.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, playAgain);
			instructions.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, removeInstructions);
			
			instructions.x = 0;
			instructions.y = 0;
			instructions.alpha = 0;
			
			game.addChild(instructions);
			
			var cs = numberFormatter(curScore);			
			
			//instructions
			switch(whichFrame)
			{
				case 1:
					var inText:String;				
					
					instructions.title.text = "PHOTO HUNT GAME INSTRUCTIONS";
					
					inText = "STUDY THE SIDE BY SIDE PHOTOS AND CLICK ON THE DIFFERENCES<br/>BETWEEN THE TWO<br/><br/>THERE ARE THREE DIFFERENCES PER PHOTO SET<br/><br/>";
					inText += "YOUR SCORE IS BASED ON SPEED AND ACCURACY";	
					instructions.theText.htmlText = inText;				
					instructions.btnStart.theText.htmlText = "<font size='19'>PLAY</font>";				
					
					instructions.btnStart.visible = true;
					instructions.btnStart.buttonMode = true;		
					instructions.btnStart.theText.mouseEnabled = false;
					
					instructions.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, removeInstructions, false, 0, true);
					
					break;				
				
				case 2:
					//results
					if (curScore > scoreToBeat) {
						instructions.title.text = finalMessageWin;
					}else{
						instructions.title.text = finalMessageNormal;
					}
					instructions.theText.htmlText = "<br/><br/>YOU SCORED " + cs + " POINTS";
					
					instructions.btnStart.theText.htmlText = "<font size='19'>CLOSE</font>";					
					instructions.btnStart.visible = true;					
					instructions.btnStart.theText.mouseEnabled = false;
					
					instructions.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, playAgain, false, 0, true);
					
					venDialog.addGame(curScore);
					
					break;
			}		
			
			TweenMax.to(instructions, 1, { alpha:1 } );			
		}
		
		
		
		/**
		 * Called from showInstructions when the play button is pressed
		 * @param	e
		 */
		private function removeInstructions(e:MouseEvent):void
		{
			TweenMax.to(instructions, 1, { alpha:0, onComplete:killInstructions } );
		}
		
		
		/**
		 * Called by TweenMax, from removeInstructions()
		 */
		private function killInstructions():void
		{
			if(game.contains(instructions)){
				game.removeChild(instructions);
			}
			showIntroCountdown(); //show the 3-2-1 counter
		}
		
		
		
		/**
		 * Called from killInstructions()
		 * Begins the 3-2-1 counter before the game begins 
		 */
		private function showIntroCountdown():void
		{			
			countDownTimer = new Timer(1000);
			curCountdownNumber = 4;
			game.addChild(introCounter);			
			countDownTimer.addEventListener(TimerEvent.TIMER, advanceCountdown, false, 0, true);			
			countDownTimer.start();
			advanceCountdown();
		}
		
		
		
		private function advanceCountdown(e:TimerEvent = null):void
		{
			curCountdownNumber--;
			if (curCountdownNumber == 0) {
				stopIntroCountdown();
			}else{
				introCounter.numberHolder.theText.text = String(curCountdownNumber);		
				introCounter.numberHolder.scaleX = introCounter.numberHolder.scaleY = 5;
				TweenMax.to(introCounter.numberHolder, 1, { scaleX:4, scaleY:4} );				
			}
		}
		
		
		/**
		 * Called from advanceCountdown once the curCountdownNumber is zero
		 * Stops the 3-2-1 counter and loads the first difference
		 */
		private function stopIntroCountdown():void
		{		
			countDownTimer.stop();
			countDownTimer.removeEventListener(TimerEvent.TIMER, advanceCountdown);	
			game.removeChild(introCounter);
			//startSound();
			loadDifference();
		}
		
		
		/**
		 * Called from begin()
		 * Starts the 45 second timer
		 */
		private function startCountdown():void
		{
			secondTimer.start();
			MovieClip(ui).mouseEnabled = false; //interface already on stage			
			theContent.addEventListener(MouseEvent.MOUSE_DOWN, contentClicked, false, 0, true);			
		}
		
		
		
		/**
		 * Removes the enter frame listener and stops the game timer
		 */
		private function stopCountdown():void
		{
			secondTimer.reset();
			//prevent clicks when circles are being removed
			theContent.removeEventListener(MouseEvent.MOUSE_DOWN, contentClicked);	
		}
		
		
		
		/**
		 * Stops the game and then calls the appropriate finish game method if not in demo mode
		 * 
		 * Called by updateCountdown(), loadDifference() and removeDetailer()
		 * 
		 */
		private function gameOver():void
		{	
			stopCountdown();
			addInstructions(2);
		}
		
		
		/**
		 * Loads the first swf in the gameSwfs array
		 * Called from stopIntroCountdown()
		 */
		private function loadDifference():void
		{		
			if (game.contains(swfLoader)) {
				game.removeChild(swfLoader);
			}
			
			if(gameSwfs.length){
				var theSwf = gameSwfs.splice(0, 1)[0];				
				swfLoader.load(new URLRequest(theSwf));	//swfPath set in configLoaded		
				swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, diffLoaded, false, 0, true);
			}else {
				gameOver();
			}
		}
		
		
		
		/**
		 * Called by loader event complete once the difference swf is loaded
		 * 
		 * @param	e Load complete event
		 */
		private function diffLoaded(e:Event):void
		{			
			swfLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, diffLoaded);
			
			swfLoader.x = imageX;
			swfLoader.y = -420;
			
			swfLoader.alpha = 1;
			
			theContent = MovieClip(swfLoader.content);
			theContent.cacheAsBitmap = true;
			theContent.cacheAsBitmapMatrix = new Matrix();
			
			//hide the click hotspots
			for (var i:int = 1; i < 4; i++)
			{				
				theContent["diff" + i].alpha = 0;
				theContent["diff" + i + "2"].alpha = 0;
				
				//hide fills and outlines
				theContent["line" + i].alpha = 0;
				theContent["line" + i + "2"].alpha = 0;
				//theContent["line" + i].scaleX = theContent["line" + i].scaleY = .5;
				theContent["line" + i + "2"].alpha = 0;
				//theContent["line" + i + "2"].scaleX = theContent["line" + i + "2"].scaleY = .5;
				theContent["fill" + i].alpha = 0;
				theContent["fill" + i + "2"].alpha = 0;
				theContent["line" + i].mouseEnabled = false;
				theContent["line" + i + "2"].mouseEnabled = false;
				theContent["fill" + i].mouseEnabled = false;
				theContent["fill" + i + "2"].mouseEnabled = false;
			}			
			
			addChildAt(swfLoader, 0);	//add at index 0 so the image is below everything	
			
			//bring in the new image and call begin
			TweenMax.to(swfLoader, .75, {y:imageY, onComplete:begin } );
		}
		
		
		/**
		 * Called from stopIntroCountdown()
		 */
		private function startSound():void
		{
			musicChannel.stop();
			music = new Sound();
			music.load(new URLRequest(theSong));
			musicChannel = music.play();
			musicChannel.soundTransform = musicVolume;
			musicChannel.addEventListener(Event.SOUND_COMPLETE, getNewSong, false, 0, true);
		}
		private function getNewSong(e:Event):void
		{			
			theSong = musicArray[Math.floor(Math.random() * 3)];
			startSound();
		}

		
		
		/**
		 * Called whenever the loaded difference swf is clicked
		 * 
		 * adds the clicked difference 1-5 as a string ("1") to alreadyClicked
		 * 
		 * @param	e MOUSE_DOWN MouseEvent
		 */
		private function contentClicked(e:MouseEvent):void
		{				
			var spot:String = e.target.name;
			
			if (spot.substr(0, 4) != "diff") {
				//not a diff 
				badClick();
				
			}else {
				//difference clicked
				//gets the diff number 1,2,3 etc. - diffs are named diff1, diff12, diff2, diff22, etc.
				var whichDiff:String = spot.substr(4, 1);
				
				if (alreadyClicked.indexOf(whichDiff) == -1) {
					
					addCircle(whichDiff, false);
					
				}else {
					//already clicked
					badClick();
				}
			}
		}
		
		
		
		/**
		 * Called from showHint or contentClicked
		 * adds a circle to the image to show the difference
		 * 
		 * @param	clickedDiff String number "1","2" etc of the clicked difference
		 * @param	fromHint Boolean - true if a hint was clicked - no score is added if true
		 */
		private function addCircle(clickedDiff:String, fromHint:Boolean = false):void
		{
			alreadyClicked.push(clickedDiff);					
			theContent["fill" + clickedDiff].alpha = 1;
			theContent["fill" + clickedDiff + "2"].alpha = 1;
			TweenMax.to(theContent["fill" + clickedDiff], .75, { alpha:0 } );
			TweenMax.to(theContent["fill" + clickedDiff + "2"], .75, { alpha:0 } );
			TweenMax.to(theContent["line" + clickedDiff], 1, { alpha:1} );
			TweenMax.to(theContent["line" + clickedDiff + "2"], 1, { alpha:1} );
			
			//var aSound:bell = new bell();
			//channel = aSound.play();
			
			if(!fromHint){
				updateScore();
			}
		
			//update differences clicked text
			curDiffs.theText.text = String(alreadyClicked.length) + " of 3";
			
			//check for game over
			if (alreadyClicked.length == 3) {
				picComplete();						
			}
		}
		
		
		
		/**
		 * Called from contentClicked() when the alreadyClicked array length == 3 - all differences
		 * found - stops the timers and then calls scrubBubbles()
		 */
		private function picComplete():void
		{
			stopCountdown();
			
			//show complete message
			hintDialog.y = 280;
			hintDialog.alpha = 0;			
			
			hintDialog.theText.text = "You Found Them All!";			
			
			TweenMax.to(hintDialog, 1, { delay:.5, alpha:1 } );
			TweenMax.to(hintDialog, .5, {overwrite:0, delay:2.5, y:-300, onComplete:loadDifference } );					
		}
		
		
		
		/**
		 * Called from contentClicked() whenever a non-difference area of the image is clicked
		 * or when the same difference area is clicked twice
		 */
		private function badClick():void
		{			
			//var buzz:buzzer = new buzzer();
			//channel = buzz.play();
			
			curScore -= badClickPoints;
			scoreText.theText.text = numberFormatter(curScore);
		}
		
		
		
		/**
		 * Called on TimerEvent
		 * one second intervals
		 * 
		 * @param	e TimerEvent
		 */
		private function updateCountdown(e:TimerEvent):void
		{				
			gameTime--;			
			bigCounter.theText.text = String(gameTime);			
			
			if (gameTime <= 0) {				
				bigCounter.theText.text = "0";
				gameOver();
				
			}
		}
		
		
		/**
		 * Called from contentClicked() whenever a difference spot is clicked
		 * adds the remaining bonus to the score
		 */
		private function updateScore():void
		{			
			curScore += curBonus;
			scoreText.theText.text = numberFormatter(curScore);			
		}
	
		
		private function openVenueDialog():void
		{
			if (!contains(venDialog)) {
				addChild(venDialog);
			}
			venDialog.show();
		}
		private function closeVenueDialog(e:Event = null):void
		{
			if (contains(venDialog)) {
				removeChild(venDialog);
			}
			playAgain();
		}
		
		
		/**
		 * Adds commas to a number for the score
		 * ie 11592 becomes 11,592
		 * 
		 * @param	theNumber
		 * @return  A string with commas separating the digits
		 */
		private function numberFormatter(theNumber:Number):String
		{
			var isNeg:Boolean = false;
			if (theNumber < 0) {
				isNeg = true;
				theNumber = Math.abs(theNumber);
			}
			
			var n:String = String(theNumber);			
			
			var ar:Array = new Array();			
			var l:int = n.length;
			var commaMarker:int = 0;

			for (var i:int = l - 1; i > 0; i--) {
				ar.unshift(n.charAt(i)); //unshift adds elements to the start of the array
				commaMarker++;
				if(commaMarker % 3 == 0){
					ar.unshift(",");
				}
			}
			ar.unshift(n.charAt(0));
			var s:String = ar.join("");
			if (isNeg) {
				return "-" + s
			}else{
				return s;
			}
		}		
	}	
}