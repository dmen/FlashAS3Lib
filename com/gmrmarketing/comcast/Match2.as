package com.gmrmarketing.comcast
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import gs.TweenLite;
	import gs.plugins.*;
	import soulwire.display.PaperSprite;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.display.LoaderInfo; //for flashVars
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import com.gmrmarketing.comcast.SOAPY;
	import com.gmrmarketing.axegame.SimpleEncoder;
	//import com.pixelfumes.reflect.Reflect;
	import ascensionsystems.mirror.reflect;
	
	public class Match2 extends MovieClip
	{
		private var grid:screenGrid;		
		
		//12 logos - for 24 pairs - center screen stays the same - comcast logo
		private var logoNames:Array = new Array("espn", "versus", "mlb", "nfl", "golfchannel", "nhl2", "comcastsports", "nbatv", "flyers", "sixers", "redzone", "eagle");
		
		private var allLogos:Array = new Array();
		private var randomLogos:Array;
		
		private var curCards:Array; //stores the clicked on cards
		
		private var numMatches:int; //total number of matches found - 12 is max
		
		private var countdownTimer:Timer; //calls updateTimer or updateInitialTimer every second
		private var gameTime:int //decremented by the countdownTimer
		private var initialTime:int; //seconds to initially view cards - set in beginGame
		
		//used in unblockMouse() since it can be called by TweenLite after the game is over
		private var gameIsOver:Boolean;
		
		//holds the previous 'current' cards for flipping back when no match is made
		private var prevCards:Array;
		
		//timer used for resetting the cards when no match is made
		private var resetTimer:Timer;
		
		private var cardResetDelay:int = 750; //time (in ms) to show two non-matched cards before resetting
		
		private var channel:SoundChannel; //for playing sounds		
		private var beep:timeBeep; //beep sound for final five seconds of play
		private var rotSound:rotate; //
		private var allRot:allTurn;
		
		private var userID:String; //comes in via FlashVar from SWFObject
		
		//For SOAP service
		private var soapy:SOAPY;
		private var encoder:SimpleEncoder;			
		
		private var r1:reflect;
		private var r2:reflect;
		private var r3:reflect;
		private var r4:reflect;
		private var r5:reflect;
		
		private var eg:endGameDialog; //library clip
		
		
		/**
		 * CONSTRUCTOR
		 */
		public function Match2()
		{
			//FLASHVARS
			userID = loaderInfo.parameters.uid;			
			soapy = new SOAPY(loaderInfo.parameters.svcurl);
			encoder = new SimpleEncoder();
			
			//for color changing the start button and shadowing the end dialog
			TweenPlugin.activate([ColorTransformPlugin, DropShadowFilterPlugin, BlurFilterPlugin]); 
				
			beep = new timeBeep();
			rotSound = new rotate();
			allRot = new allTurn();
			
			grid = new screenGrid();			
			grid.x = 320;
			grid.y = 50;			
			
			var i:int;
			for(i = 1; i < 6; i++){
				grid["p"+i].rotationY = -25;
				grid["p"+i].z -= 70;
			}
			for(i = 6; i < 11; i++){
				grid["p"+i].rotationY = -15;
				grid["p"+i].z -= 15;
			}
			for(i = 16; i < 21; i++){
				grid["p"+i].rotationY = 25;
				grid["p"+i].z -= 5;
			}
			for(i = 21; i < 26; i++){
				grid["p"+i].rotationY = 40;
				grid["p"+i].z -= 60;
			}			

			addChild(grid); 
			
			r1 = new reflect();
			r2 = new reflect();
			r3 = new reflect();
			r4 = new reflect();
			r5 = new reflect();
			r1.constructReflection(grid.p5, .03, 0, 100, -16);
			r2.constructReflection(grid.p10, .03, 0, 100, 2);
			r3.constructReflection(grid.p15, .03, 0, 100, 10);
			r4.constructReflection(grid.p20, .03, 0, 100, -12);
			r5.constructReflection(grid.p25, .03, 0, 100, -40);
			//TweenLite.to(r1, 0, { blurFilter: { blurX:20, blurY:20 }} );
			//var r2 = new Reflect( { mc:grid.p10, alpha:28, ratio:150, distance: -5, updateTime:0, reflectionDropoff:1 } );
			//var r3 = new Reflect( { mc:grid.p15, alpha:28, ratio:150, distance: 3, updateTime:0, reflectionDropoff:1 } );
			//var r4 = new Reflect( { mc:grid.p20, alpha:28, ratio:150, distance: -20, updateTime:0, reflectionDropoff:1 } );
			//var r5 = new Reflect({mc:grid.p25, alpha:28, ratio:150, distance:-46, updateTime:0, reflectionDropoff:1});
			
			addEventListener(Event.ENTER_FRAME, rotateLights );
			//var rMask = new refMask();
			//addChild(rMask);
			//r1.cacheAsBitmap = true;
			//rMask.cacheAsBitmap = true;
			//rMask.x = 313; rMask.y = 435;
			//r1.mask = rMask;
			
			//build randomLogos array
			randomizeLogos();
			
			//put logos on screens
			createPaperSprites();
			addLogos();
			
			startButton.addEventListener(MouseEvent.MOUSE_OVER, tweenColor, false, 0, true);
			startButton.addEventListener(MouseEvent.MOUSE_OUT, unTweenColor, false, 0, true);
			startButton.addEventListener(MouseEvent.CLICK, beginGame, false, 0, true);
			startButton.addEventListener(MouseEvent.CLICK, unTweenColor, false, 0, true);
			startButton.buttonMode = true;
			
			resetTimer = new Timer(cardResetDelay, 1);
			resetTimer.addEventListener(TimerEvent.TIMER, resetCards, false, 0, true);
			
			countdownTimer = new Timer(1000);
			
			eg = new endGameDialog();
		}
		
		/**
		 * Called on EnterFrame
		 * @param	e
		 */
		private function rotateLights(e:Event)
		{			
			//refData.draw(reflection, null, null, null, new Rectangle(320, 380, 550, 100));
			r1.refresh();
			r2.refresh();
			r3.refresh();
			r4.refresh();
			r5.refresh();
		}
		
		
		/**
		 * Color tweens for the start button
		 * 
		 * @param	e MOUSE_OVER MouseEvent
		 */
		private function tweenColor(e:MouseEvent):void
		{
			TweenLite.to(e.currentTarget.bg, .5, {colorTransform:{tint:0xFFFF00, tintAmount:0.5}});
		}
		private function unTweenColor(e:MouseEvent = null):void
		{
			TweenLite.to(e.currentTarget.bg, .5, {colorTransform:{tint:0xFFFF00, tintAmount:0}});
		}
		
		
		
		/**
		 * Called once the start button is clicked on
		 * or from playAgain once the end game dialog has faded out
		 */
		private function beginGame(e:MouseEvent = null):void
		{		
			curCards = new Array();
			gameIsOver = false;
			prevCards = new Array();			
			gameTime = 30;
			initialTime = 10;
			numMatches = 0;
			
			theTimer.text = String(initialTime);
			theMatches.text = String(numMatches);
			
			if (contains(eg)) { removeChild(eg); }
			
			//disable start button		
			startButton.removeEventListener(MouseEvent.MOUSE_OVER, tweenColor);
			startButton.removeEventListener(MouseEvent.MOUSE_OUT, unTweenColor);
			startButton.removeEventListener(MouseEvent.CLICK, beginGame);
			startButton.buttonMode = false;
			startButton.alpha = .24;
			
			//show all logos
			showAllScreens();
				
			countdownTimer.addEventListener(TimerEvent.TIMER, updateInitialTimer);
			countdownTimer.start();			
		}
		
		
		
		/**
		 * Starts the game timer running to call updateTimer every 1 second
		 * Called from updateInitialTimer()
		 */
		private function startCountDown():void
		{			
			countdownTimer.addEventListener(TimerEvent.TIMER, updateTimer);
			countdownTimer.start();
			clickEnableCards();
		}
		
		
		
		/**
		 * Creates the randomLogos array
		 * an array of arrays where each sub array contains the logo name and an index value for matching
		 */
		private function randomizeLogos():void
		{
			//add logo names to allLogos - twice - to form the pairs
			for (var i = 0; i < logoNames.length; i++) {
				allLogos.push([logoNames[i], i]); //store index for matching
				allLogos.push([logoNames[i], i]);
			}
			
			randomLogos = new Array();			   
			while(allLogos.length > 0){   
				randomLogos.push(allLogos.splice(Math.floor(Math.random() * allLogos.length), 1)[0]);
			}
			
			//center square is always the comcast logo
			randomLogos.splice(12, 0, ["comcast", 0]);			
		}
		
		
		/**
		 * Creates a paperSprite object for each logo
		 * and attach it to the grid
		 * 
		 * Screens are named p1 - p25
		 * 
		 * Screen p13 is the center screen which does not rotate
		 */
		private function createPaperSprites():void
		{
			var myPaperSprite:PaperSprite;
			for (var i:int = 0; i < randomLogos.length; i++) {
				myPaperSprite = new PaperSprite();
				myPaperSprite.name = String(i); //name is the index in the randomLogos array
				if (i == 12) {
					//at screen 13 - use the special center logo
					myPaperSprite.front = new comcastCenter();
				}else{
					myPaperSprite.front = new comcast();
				}
				grid["p" + (i + 1)].holder.addChildAt(myPaperSprite,0);
			}
		}
		
		
		/**
		 * Adds logos to the paper sprite objects attached to each screen
		 */
		private function addLogos():void
		{			
			var myPaperSprite:PaperSprite;			
			var cRef:Class;
			for (var i:int = 0; i < randomLogos.length; i++) {				
				myPaperSprite = grid["p" + (i + 1)].holder.getChildAt(0);
				cRef = getDefinitionByName(randomLogos[i][0]) as Class;				
				myPaperSprite.back = new cRef();						
			}
		}
		
		
		
		/**
		 * Adds click listeners to all cards
		 */
		private function clickEnableCards():void
		{
			for (var i = 0; i < randomLogos.length; i++) {
				if (i != 12) {					
					grid["p" + (i + 1)].holder.getChildAt(0).addEventListener(MouseEvent.CLICK, rot);
					grid["p" + (i + 1)].holder.getChildAt(0).buttonMode = true;
				}
			}
		}
		
		
		
		/**
		 * Removes click listeners from all cards
		 */
		private function clickDisableCards():void
		{
			for (var i = 0; i < randomLogos.length; i++) {
				if(i != 12){
					grid["p" + (i + 1)].holder.getChildAt(0).removeEventListener(MouseEvent.CLICK, rot);
					grid["p" + (i + 1)].holder.getChildAt(0).buttonMode = false;
				}
			}
		}
		
		
		
		/**
		 * Show all screens in the grid, except center, 180 degrees
		 * 
		 * @param	e TIMER TimerEvent
		 */
		private function showAllScreens(e:TimerEvent = null):void
		{		
			channel = allRot.play();
			var i:int;
			for (i = 0; i < randomLogos.length; i++) {
				if(i != 12){
					TweenLite.to(grid["p" + (i + 1)].holder.getChildAt(0), 1, { rotationX:180 } );
				}
			}			
		}
		
		
		
		/**
		 * Hide all screens in the grid
		 * 
		 * @param	e TIMER TimerEvent
		 */
		private function hideAllScreens(e:TimerEvent = null):void
		{		
			channel = allRot.play();
			var i:int;
			for (i = 0; i < randomLogos.length; i++) {
				if(i != 12){
					TweenLite.to(grid["p" + (i + 1)].holder.getChildAt(0), 1, { rotationX:0 } );
				}
			}			
		}
		
		
		
		/**
		 * Called by MouseClick whenever a screen is clicked - rotates the screen 180
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function rot(e:MouseEvent):void
		{			
			//remove listener from selected card so it can't be clicked on again
			e.currentTarget.removeEventListener(MouseEvent.CLICK, rot);
			e.currentTarget.buttonMode = false;
			curCards.push(e.currentTarget);
			TweenLite.to(e.currentTarget, .3, { rotationX:180 } );
			channel = rotSound.play();
			if (curCards.length >= 2) {
				checkForMatch();
			}
		}
		
		
		
		/**
		 * Called from rot() whenever the curCards array length is >= 2
		 * 
		 * @param	theCard
		 */
		private function checkForMatch()
		{			
			if (randomLogos[parseInt(curCards[0].name)][1] == randomLogos[parseInt(curCards[1].name)][1]) {
				//match
				curCards.splice(0, 2);
				incMatches();
			}else {
				//no match
				if (curCards.length > 2) {
					//third card clicked while two already showing - reset timer and call resetCards
					resetTimer.reset();
					resetCards();
				}else{					
					resetTimer.start();
				}
			}							
		}
		
		
		
		/**
		 * Turns the cards to show comcast logo - called after one second or immediately if the player
		 * clicks a third card while the first two are still showing
		 * 
		 * @param	e TIMER TimerEvent
		 */
		private function resetCards(e:TimerEvent = null):void
		{
			prevCards = curCards.splice(0, 2);
			TweenLite.to(prevCards[0], .3, { overwrite:0, rotationX:0 } );
			TweenLite.to(prevCards[1], .3, { overwrite:0, rotationX:0, onComplete:enablePrevCards } );			
		}
		
		
		
		/**
		 * Renables the last two non matching cards once the tween is complete
		 * 
		 * @param	card1
		 * @param	card2
		 */
		private function enablePrevCards():void 
		{	
			if(!gameIsOver){
				prevCards[0].addEventListener(MouseEvent.CLICK, rot);
				prevCards[1].addEventListener(MouseEvent.CLICK, rot);
				prevCards[0].buttonMode = true;
				prevCards[1].buttonMode = true;
			}
		}
		
		
		
		/**
		 * Increments the number of matches and updates the text field
		 */
		private function incMatches():void
		{
			if(!gameIsOver){
				numMatches++;
				theMatches.text = String(numMatches);
				if (numMatches == 12) {
					gameOver();
				}
			}
		}
		
		
		
		/**
		 * Updates the game timer by timer event - called every 1000ms
		 * 
		 * @param	e
		 */
		private function updateTimer(e:Event)
		{
			gameTime--;
			theTimer.text = String(gameTime);
			if (gameTime == 0) {
				gameOver();
			}
			
			//beep for last 5 seconds
			if (gameTime < 6) {					
				channel = beep.play();
			}
		}
		
		
		
		/**
		 * Called once per second by countdownTimer
		 * Shows the 10-9-8...3-2-1 countdown for initial
		 * viewing of the cards
		 * 
		 * @param	e TIMER TimerEvent
		 */
		private function updateInitialTimer(e:Event)
		{
			initialTime--;
			theTimer.text = String(initialTime);
			
			if (initialTime == 0) {
				countdownTimer.reset();
				countdownTimer.removeEventListener(TimerEvent.TIMER, updateInitialTimer);
				theTimer.text = String(gameTime);
				hideAllScreens();
				startCountDown();				
			}
		}
		
		
		
		/**
		 * Called from incMatches() if all 12 matches were found, or from updateTimer() if the time expires
		 */
		private function gameOver():void
		{
			channel = new ping().play();
			countdownTimer.reset();
			clickDisableCards();
			countdownTimer.removeEventListener(TimerEvent.TIMER, updateTimer);
			
			//set flag in case there's a tween still running
			gameIsOver = true;
			
			//post to web service
			submitEntry();	
			showDialog();
		}
		
		
		/**
		 * Called from gameOver
		 * Displays the end game dialog and the play again button
		 */
		private function showDialog():void
		{			
			addChild(eg);
			eg.x = 422;
			eg.y = 125;
			eg.theBonus.text = String(numMatches);
			eg.alpha = 0;
			
			eg.btnContinue.addEventListener(MouseEvent.MOUSE_OVER, tweenColor, false, 0, true);
			eg.btnContinue.addEventListener(MouseEvent.MOUSE_OUT, unTweenColor, false, 0, true);
			//eg.btnContinue.addEventListener(MouseEvent.CLICK, thankYou, false, 0, true);
			eg.btnContinue.addEventListener(MouseEvent.CLICK, playAgain, false, 0, true);
			eg.btnContinue.buttonMode = true;
			
			TweenLite.to(eg, .75, { alpha:.98, dropShadowFilter: { color:0x000000, alpha:.7, blurX:12, blurY:12, distance:6 }} );			
		}
		
		
		
		/**
		 * Called by clicking the play again button in the end game dialog
		 * @param	e
		 */
		private function playAgain(e:MouseEvent):void
		{
			TweenLite.to(eg, 1.5, { alpha:0, onComplete:beginGame } );
			hideAllScreens();
			randomizeLogos();
			addLogos();			
		}
		
		/**
		 * Called by pressing the continue button in the end game dialog
		 */
		/*
		private function thankYou(e:MouseEvent):void
		{
			navigateToURL(new URLRequest("ThankYou.aspx?uid=" + userID), "_self");
		}
		*/
		
		
		/**
		 * Called from gameOver()
		 * Calls the webservice and sends the userID and number of sweeps entries they got by playing
		 */		
		private function submitEntry():void
		{
			var req:URLRequest = soapy.buildEnvelope(userID, encoder.encode(numMatches));			
			var loader:URLLoader = new URLLoader();
			loader.load(req);
			//loader.addEventListener(Event.COMPLETE, submitComplete, false, 0, true);
		}
		
		
		
		/**
		 * Called when the web service returns the envelope
		 * 
		 * @param	e COMPLETE Event
		 */
		/*
		private function submitComplete(e:Event):void
		{
			var loader:URLLoader = URLLoader(e.target);	
			var r:Object = soapy.parse(loader.data);			
			//r.success will either be SUCCESS or a Failure message
			if (r.success != "SUCCESS") {
				navigateToURL(new URLRequest("error.aspx?msg=" + r.success), "_self");
			}else {
				showDialog();
			}
		}
		*/
	}	
}