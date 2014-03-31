//PM Demo

package com.gmrmarketing.pm.matchgame
{	
	import flash.display.Bitmap;
	import flash.display.LoaderInfo; //for flashVars
	import flash.display.Loader;
	import flash.display.MovieClip;	
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.filters.DropShadowFilter;
	
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
	
 	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	import com.greensock.easing.*;
	
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
		private var curScore:Number;		
		
		private var curBonus:int = 500; //500 pts for every correct click
		private var badClickPoints:int = 200; //dec 200 for a bad click
		
		private var totalPoints:Number; //sum of curScore and total score retrieved from web service - set in getPointTotalComplete()
		
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
			
		private var itemsToLoad:Array;
		
		private var instructions:Instructions; //library clip - instructions dialog	
				
		private var imageFolder:String;	
		
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
		private var swfPath:String;
		
		//new for h2h
		private var startWaitingTitle:String;
		private var startWaitingText:String;
		private var endWaitingTitle:String;
		private var endWaitingText:String;
		private var waitingDialog:waitingForOpponentDialog;
		private var waitingTimer:Timer;
		private var waitCount:int;
		private var playingH2H:Boolean; //true if playing a head to head game
		
		private var delayGameOverTimer:Timer;
		
		
		
		/**
		 * CONSTRUCTOR
		 */
		public function Engine()
		{				
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);			
			
			//Mouse.hide();			
			
			configLoader = new URLLoader();
			configLoader.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			configLoader.addEventListener(IOErrorEvent.IO_ERROR, configNotFound, false, 0, true);
			configLoader.load(new URLRequest("C:\\PhilipMorris\\DCD\\config.xml"));			

			secondTimer = new Timer(1000);
			secondTimer.addEventListener(TimerEvent.TIMER, updateCountdown);
			
			if (imageFolder == null) { 
				imageFolder = ""; 
			}else {
				imageFolder += "/";
			}			
		
			musicArray = new Array(imageFolder + "level1.mp3", imageFolder + "level2.mp3", imageFolder + "level3.mp3");
			channel = new SoundChannel();
			musicChannel = new SoundChannel();
			
			curScore = 0;
			
			TweenPlugin.activate([BlurFilterPlugin]); 
			
			//allCircles = new Array();

			game = new Sprite();
			
			scoreText = new CurScore();						
			game.addChild(scoreText);	
			scoreText.x = 15;
			scoreText.y = 194;
			
			curDiffs = new CurrDiffs();					
			game.addChild(curDiffs);			
			curDiffs.x = 15;
			curDiffs.y = 270;
			
			gameTime = 46; 			
			
			hintDialog = new DialogHint();			
			game.addChild(hintDialog);			
			
			//start countdown - the big 3-2-1 counter
			introCounter = new GameStartCountdown();			
			//introCounter.numberHolder.alpha = .25;
			introCounter.x = 590;
			introCounter.y = 273;
			
			//position of the difference image
			imageX = 185;
			imageY = 25;
			
			hintDialog.x = 384;
			hintDialog.y = -1000;			
			
			smallDropShadow = new DropShadowFilter(3, 0, 0, .6, 5, 5, 1, 2, false, false);
			
			//Big countdown timer at lower left	
			bigCounter = new BigCounter();
			bigCounter.scaleX = 1.6;
			bigCounter.scaleY = 1.6;
			bigCounter.x = 3;
			bigCounter.y = 420;
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
			
			waitingDialog = new waitingForOpponentDialog();
			waitingTimer = new Timer(1000);
			waitingTimer.addEventListener(TimerEvent.TIMER, decrementWait, false, 0, true);
						
		} //CONSTRUCTOR
		
		
		
	
		
		
		// ------------------ PRIVATE --------------------
		/**
		 * Called once config.xml has been loaded
		 * @param	e COMPLETE event
		 */
		private function configLoaded(e:Event):void
		{
			var config:XML = new XML(e.target.data);
			configLoader.removeEventListener(Event.COMPLETE, configLoaded);
			configLoader.removeEventListener(IOErrorEvent.IO_ERROR, configNotFound);
			scoreToBeat = config.scoreToBeat;
			finalMessageNormal = config.didntWinMessage;
			finalMessageWin = config.winMessage;
			
			//H2H
			startWaitingTitle = config.waitForStartTitle;
			startWaitingText = config.waitForStartText;
			endWaitingTitle = config.waitForEndTitle;
			endWaitingText = config.waitForEndText;
			
			swfPath = config.swfPath;
			//swfPath = "";
			playAgain();
		}
		
		
		
		/**
		 * Provide an impossible to beat score if the config.xml file isn't available
		 * this makes the final dialog show finalMessageNormal instead of finalMessageWin
		 * @param	e
		 */ 
		private function configNotFound(e:IOErrorEvent):void
		{
			scoreToBeat = 1000000;
			swfPath = "";
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
			
			instructions.btnStart.removeEventListener(MouseEvent.CLICK, playAgain);
			//addInstructions(1); //normal instructions
			
			addStartWaitingDialog();
			
			if(ExternalInterface.available){
				ExternalInterface.addCallback("start", beginHeadToHeadPlay);
			}else {
				
			}
		}
		
		
		
		/**
		 * Called from playAgain()
		 * populates and randomizes the gameSwfs aray
		 */
		private function buildSWFArray():void		
		{		
			gameSwfs = new Array();
			
			var swfs:Array = new Array("diffs1.swf", "diffs2.swf", "diffs3.swf", "diffs4.swf", "diffs5.swf", "diffs6.swf", "diffs7.swf", "diffs8.swf", "diffs9.swf", "diffs10.swf", "diffs11.swf", "diffs12.swf", "diffs13.swf", "diffs14.swf", "diffs15.swf");			
				
			var temp:Array = new Array();			
			
			//randomize array
			var rInd:int;
			while (swfs.length) {
				rInd = Math.floor(swfs.length * Math.random());
				gameSwfs.push(swfs[rInd]);
				swfs.splice(rInd, 1);
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
		 * Called from playAgain()
		 */
		private function addStartWaitingDialog():void
		{
			waitingDialog.x = 0;
			waitingDialog.y = 0;
			waitingDialog.theTitle.text = startWaitingTitle;
			waitingDialog.theText.text = startWaitingText;
			
			waitCount = 10;
			waitingDialog.count.text = String(waitCount);
			
			game.addChild(waitingDialog);
			
			waitingTimer.start();
		}
		
		private function addEndWaitingDialog():void
		{
			waitingDialog.x = 0;
			waitingDialog.y = 0;
			waitingDialog.theTitle.text = endWaitingTitle;
			waitingDialog.theText.text = endWaitingText;
			waitingDialog.count.text = "";
			game.addChild(waitingDialog);
			
			//uses fscommand to send close and score to container
			delayCloseAndSend();
		}
		
		
		
		/**
		 * Called by timer when waiting for opponent to join
		 * @param	e
		 */
		private function decrementWait(e:TimerEvent):void
		{
			waitCount--;
			waitingDialog.count.text = String(waitCount);
			
			if (waitCount == 0) {
				//timer ran out before start command was received -
				//start a normal game
				//removeWaitingDialog();
				playingH2H = false;
				//addInstructions(1);
				waitingTimer.reset();
				showIntroCountdown(); //show the 3-2-1 counter
			}
			
			/*
			if (waitCount == 6) {
				beginHeadToHeadPlay("1,2,3,4,5,6,7,8,9,10,11,12,13,14,15");
			}
			*/
			
		}
		
		
		/**
		 * Called from stopIntroCountdown()
		 */
		private function removeWaitingDialog():void
		{			
			game.removeChild(waitingDialog);
		}
		
		
		
		/**
		 * Called by the ExternaInterface callback that listens for "start"
		 * @param swfList Comma separated list of numbers 1-15
		 */
		public function beginHeadToHeadPlay(swfList:String):void
		{
			waitingTimer.reset();
			//removeWaitingDialog();
			
			//build swf list
			var nums:Array = swfList.split(",");
			
			gameSwfs = new Array();
			
			for (var i:int = 0; i < nums.length; i++) {
				gameSwfs.push("diffs" + nums[i] + ".swf");
			}
			
			playingH2H = true;
			
			//show the 3-2-1 countdown
			showIntroCountdown();			
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
			instructions.x = 0;
			instructions.y = 0;
			instructions.alpha = 0;
			
			game.addChild(instructions);
			
			var cs = numberFormatter(curScore);
			var tp = numberFormatter(totalPoints);
			
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
					
					instructions.btnStart.addEventListener(MouseEvent.CLICK, removeInstructions, false, 0, true);
					
					break;				
				
				case 2:
					//results
					if (curScore > scoreToBeat) {
						instructions.title.text = finalMessageWin;
					}else{
						instructions.title.text = finalMessageNormal;
					}
					instructions.theText.htmlText = "<br/><br/>YOU SCORED " + cs + " POINTS";
					
					//instructions.btnStart.theText.htmlText = "<font size='19'>CLOSE</font>";					
					instructions.btnStart.visible = false;				
					//instructions.btnStart.buttonMode = true;
					//instructions.btnStart.theText.mouseEnabled = false;
					
					//instructions.btnStart.addEventListener(MouseEvent.CLICK, closeAndSend, false, 0, true);
					
					delayCloseAndSend();
					
					break;
			}
			
			
			instructions.btnStart.addEventListener(MouseEvent.MOUSE_OVER, hideButtonBG, false, 0, true);
			instructions.btnStart.addEventListener(MouseEvent.MOUSE_OUT, showButtonBG, false, 0, true);					
			
			TweenLite.to(instructions, 1, { alpha:1 } );			
		}
		
		
		private function delayCloseAndSend():void
		{
			delayGameOverTimer = new Timer(250, 1);
			delayGameOverTimer.addEventListener(TimerEvent.TIMER, closeAndSend, false, 0, true);
			delayGameOverTimer.start();
		}
		
		
		/**
		 * Called from close button at end of game - sends score to VB container
		 * @param	e
		 */
		private function closeAndSend(e:TimerEvent = null):void
		{
			delayGameOverTimer.removeEventListener(TimerEvent.TIMER, closeAndSend);
			fscommand("close", String(curScore));			
			//ExternalInterface.call("close", String(curScore));
		}
		
		
		/**
		 * Called from showInstructions when the play button is pressed
		 * @param	e
		 */
		private function removeInstructions(e:MouseEvent):void
		{
			TweenLite.to(instructions, 1, { alpha:0, onComplete:killInstructions } );
		}
		
		
		/**
		 * Called by TweenLite, from removeInstructions()
		 */
		private function killInstructions():void
		{
			if(game.contains(instructions)){
				game.removeChild(instructions);
			}
			showIntroCountdown(); //show the 3-2-1 counter
		}
		
		
		private function hideButtonBG(e:MouseEvent):void
		{
			e.currentTarget.bg.visible = false;
		}
		
		
		private function showButtonBG(e:MouseEvent):void
		{
			e.currentTarget.bg.visible = true;
		}
		
		
		
		/**
		 * Called from killInstructions()
		 * Begins the 3-2-1 counter before the game begins 
		 */
		private function showIntroCountdown():void
		{
			//New for H2H  - use the waiting dialog
			waitingDialog.theTitle.text = "GET READY";
			waitingDialog.theText.text = "YOUR GAME WILL START IN";
			
			countDownTimer = new Timer(1000);
			curCountdownNumber = 4;
			//game.addChild(introCounter);			
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
				//introCounter.numberHolder.theText.text = String(curCountdownNumber);		
				//introCounter.numberHolder.scaleX = introCounter.numberHolder.scaleY = 3.78;
				//TweenLite.to(introCounter.numberHolder, 1, { scaleX:5, scaleY:5 } );
				waitingDialog.count.text = String(curCountdownNumber);
			}
		}
		
		/**
		 * Stops the 3-2-1 counter and loads the first difference
		 */
		private function stopIntroCountdown():void
		{		
			countDownTimer.stop();
			countDownTimer.removeEventListener(TimerEvent.TIMER, advanceCountdown);	
			removeWaitingDialog();
			//game.removeChild(introCounter);
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
			theContent.addEventListener(MouseEvent.CLICK, contentClicked, false, 0, true);			
		}
		
		
		
		/**
		 * Removes the enter frame listener and stops the game timer
		 */
		private function stopCountdown():void
		{
			secondTimer.reset();
			//prevent clicks when circles are being removed
			theContent.removeEventListener(MouseEvent.CLICK, contentClicked);	
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
			
			if(!playingH2H){
				addInstructions(2);
			}else{
				addEndWaitingDialog();
			}
		}
		
		
		/**
		 * Loads the first swf in the gameSwfs array
		 * Called from removeDetailer() and stopCountdown()
		 */
		private function loadDifference():void
		{		
			if (game.contains(swfLoader)) {
				game.removeChild(swfLoader);
			}
			
			if(gameSwfs.length){
				var theSwf = gameSwfs.splice(0, 1)[0];
				
				swfLoader.load(new URLRequest(swfPath + theSwf));			
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
			
			addChildAt(swfLoader, 1);	//add at index 0 so the image is below everything	
			
			//bring in the new image and call begin
			TweenLite.to(swfLoader, .75, {y:imageY, onComplete:begin } );
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
		 * @param	e CLICK MouseEvent
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
					
			//old method using reg point of diffs - now used to add circle from clicking hint
			//allCircles.push(new Circle(game, imageX + theContent["diff" + clickedDiff].x, imageY + theContent["diff" + clickedDiff].y));
			//allCircles.push(new Circle(game, imageX + theContent["diff" + clickedDiff + "2"].x, imageY + theContent["diff" + clickedDiff + "2"].y));
			theContent["fill" + clickedDiff].alpha = 1;
			theContent["fill" + clickedDiff + "2"].alpha = 1;
			TweenLite.to(theContent["fill" + clickedDiff], .75, { alpha:0 } );
			TweenLite.to(theContent["fill" + clickedDiff + "2"], .75, { alpha:0 } );
			TweenLite.to(theContent["line" + clickedDiff], 1, { alpha:1} );
			TweenLite.to(theContent["line" + clickedDiff + "2"], 1, { alpha:1} );
			
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
			hintDialog.y = 90;
			hintDialog.alpha = 0;			
			
			hintDialog.theText.text = "You Found Them All!";			
			
			TweenLite.to(hintDialog, 1, { delay:.5, alpha:1 } );
			TweenLite.to(hintDialog, .5, {overwrite:0, delay:2.5, y:-300, onComplete:loadDifference } );
			//TweenLite.to(hintDialog, .5, {overwrite:0, delay:2.5, y:-300, onComplete:scrubBubbles } );			
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
				//gameOver();
				delayGameOverTimer = new Timer(250, 1);
				delayGameOverTimer.addEventListener(TimerEvent.TIMER, delayGameOver, false, 0, true);
				delayGameOverTimer.start();
			}
		}
		private function delayGameOver(e:TimerEvent):void
		{
			delayGameOverTimer.removeEventListener(TimerEvent.TIMER, delayGameOver);
			gameOver();
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
	
		
		/**
		 * Called by clicking the close button in the redTopBar
		 * @param	e
		 */
		private function closeProjector(e:MouseEvent):void
		{
			fscommand("quit");			
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