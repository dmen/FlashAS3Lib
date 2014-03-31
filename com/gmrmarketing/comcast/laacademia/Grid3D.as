package com.gmrmarketing.comcast.laacademia
{	
	import away3d.cameras.*;
	import away3d.containers.View3D;	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.BitmapData;	
	import flash.display.Bitmap;	
	import away3d.primitives.Cube;
	import away3d.primitives.data.CubeMaterialsData;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.events.MouseEvent3D;	
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	import com.gmrmarketing.utilities.Utility;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	
	
	public class Grid3D extends MovieClip
	{
		private var viewport:View3D;
		private var cube:Cube;
		private var frontMaterial:BitmapMaterial;
		private var backMaterial:BitmapMaterial;
		private var sideMaterial:BitmapMaterial;
		
		private const CARD_WIDTH:int = 160;
		private const CARD_HEIGHT:int = 100;
		private const CARD_RESET_DELAY:int = 750; //time (in ms) to show two non-matched cards before resetting
		
		private var util:Utility;		
		
		//12 logos - for 24 pairs - center screen stays the same - comcast logo
		private var logoNames:Array = new Array("tbs", "foxSports", "iconNet", "nflNetwork", "guillermo", "hanley", "jorge", "tony", "iconPhone", "academia", "futbol", "iconTv");
		private var allLogos:Array = new Array();
		private var randomLogos:Array;
		
		private var allCards:Array; //all cards in the grid
		private var curCards:Array; //stores the two current clicked on cards		
		private var prevCards:Array; //stores cards when more than two have been clicked
		private var resetArray:Array; //holds the two 'current' cards when they are being reset
		
		private var gameIsOver:Boolean;
		
		private var numMatches:int; //total number of matches found - 12 is max
		
		private var countdownTimer:Timer; //calls updateTimer or updateInitialTimer every second		
		private var resetTimer:Timer; //timer used for resetting the cards when no match is made
		private var prevTimer:Timer;
		private var gameTime:int //decremented by the countdownTimer
		private var initialTime:int; //seconds to initially view cards - set in beginGame
		
		//sound
		private var channel:SoundChannel; //for playing sounds		
		private var beep:timeBeep; //beep sound for final five seconds of play
		private var rotSound:rotate; //
		private var allRot:allTurn;
		
		//private var eg:endGameDialog; //library clip
		private var dialog:theDialog;
		
		private var language:String; //set in setLanguage() by main
		private var xfinSpots:Vector.<int>;
		
		public function Grid3D()
		{
			xfinSpots = new Vector.<int>();
			xfinSpots.push(1,3,5,8,10,12,13,15,17,20,22,24);
			
			beep = new timeBeep();
			rotSound = new rotate();
			allRot = new allTurn();
			
			dialog = new theDialog(); //lib clip
			dialog.x = 238;
			dialog.y = 156;
			
			allCards = new Array();
			util = new Utility();//contains gridLoc function
			
			randomizeLogos();			
			
			viewport = new View3D({x:683, y:384});
			addChild(viewport);
			
			//build grid
			var loc:Array = new Array();
			var i:int;
			for (i = 1; i < 25; i++) {
				loc = util.gridLoc(i, 6);				
				var aCard:Cube = card(randomLogos[i - 1][0], i);
				aCard.name = String(randomLogos[i - 1][1]);
				viewport.scene.addChild(aCard);
				aCard.x = loc[0] * CARD_WIDTH + ((loc[0] - 1) * 5);
				aCard.y = loc[1] * CARD_HEIGHT + ((loc[1] - 1) * 8);
				
				allCards.push(aCard);
			}
			
			//column 1
			var col:Array = new Array(1, 7, 13, 19);
			for (i = 0; i < col.length; i++) {
				allCards[col[i]].rotationY = -20;
				allCards[col[i]].z -= 20;
				allCards[col[i]].x += 3;
			}
			allCards[1].y -= 1;
			allCards[19].y += 1;
			//column 4
			col = new Array(4, 10, 16, 22);
			for (i = 0; i < col.length; i++) {
				allCards[col[i]].rotationY = 20;
				allCards[col[i]].z -= 20;
				allCards[col[i]].x -= 3;
			}
			allCards[4].y -= 1;
			allCards[22].y += 1;
			
			//column 0
			col = new Array(0, 6, 12, 18);
			for (i = 0; i < col.length; i++) {
				allCards[col[i]].rotationY = -36;
				allCards[col[i]].z -= 100;
				allCards[col[i]].x += 25;
			}
			//column 5
			col = new Array(5, 11, 17, 23);
			for (i = 0; i < col.length; i++) {
				allCards[col[i]].rotationY = 36;
				allCards[col[i]].z -= 100;
				allCards[col[i]].x -= 25;
			}
			
			//eg = new endGameDialog();
			
			viewport.camera.moveTo(580,250,0);
			viewport.camera.moveBackward(1100);			
			
			countdownTimer = new Timer(1000);
			prevTimer = new Timer(200);
			prevTimer.addEventListener(TimerEvent.TIMER, checkPrev, false, 0, true);
			resetTimer = new Timer(CARD_RESET_DELAY, 1);
			resetTimer.addEventListener(TimerEvent.TIMER, resetCards, false, 0, true);
			
					
			addEventListener(Event.ENTER_FRAME, renderScene);
		}
		
		
		/**
		 * Called from Main.as
		 * @param	l language string "en" or "sp"
		 */
		public function setLanguage(l:String):void
		{
			language = l;
			
			if (!contains(dialog)) {
				addChild(dialog);
				dialog.alpha = 0;
				TweenLite.to(dialog, 1, { alpha:1 } );
			}
			
			//set instructions
			if (language == "en") {
				dialog.theTitle.text = "How to Play:";
				dialog.theText.text = "After selecting 'start game', you will have 10 seconds to memorize the La Academia de Comcast matchup screens. Each image, will have a match. Once the screens flip, you will have 30 seconds to make matches by touching the corresponding screens.";
				dialog.startButton.theText.text = "START GAME";
				matchText.text = "MATCHES:";
				timerText.text = "TIMER:";
			}else {
				dialog.theTitle.text = "Cómo jugar:";
				dialog.theText.text = "Después de seleccionar 'Iniciar juego' tendrás 10 segundos para memorizar las pantallas de La Academia de Comcast. Cada imagen tiene un par. Una vez que las pantallas se volteen, tendrás 30 segundos para formar pares tocando las pantallas correspondientes.";			
				dialog.startButton.theText.text = "INICIAR JUEGO";
				matchText.text = "PARES:";
				timerText.text = "RELOJ:";
			}
			
			dialog.startButton.addEventListener(MouseEvent.CLICK, beginGame, false, 0, true);	
		}
		
		
		
		/**
		 * Creates an Away3D cube
		 * 
		 * Called from constructor
		 * 
		 * @param	backMatName String name of the material to use on the back of the card
		 * all cards get the comcast logo on front
		 * @return new cube object
		 */
		private function card(backMatName:String, cardIndex:int):Cube
		{	
			if (xfinSpots.indexOf(cardIndex) != -1) {				
				frontMaterial = new BitmapMaterial(new xfinity(CARD_WIDTH, CARD_HEIGHT));							
			}else {				
				frontMaterial = new BitmapMaterial(new comcast(CARD_WIDTH, CARD_HEIGHT));
			}
			frontMaterial.smooth = true;
			
			var ClassReference:Class = getDefinitionByName(backMatName) as Class;
            var instance:BitmapData = new ClassReference(CARD_WIDTH, CARD_HEIGHT);

			backMaterial = new BitmapMaterial(instance);
			backMaterial.smooth = true;
			
			sideMaterial = new BitmapMaterial(new blackMap(20,20));
			
			var cubedata:CubeMaterialsData = new CubeMaterialsData(
			{top:sideMaterial,
			bottom:sideMaterial,
			front:frontMaterial,
			back:backMaterial,
			left:sideMaterial,
			right:sideMaterial } );				
			
			cube = new Cube( { width:CARD_WIDTH, height:CARD_HEIGHT, depth:2, faces:cubedata } );			
			return cube;
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
		 * Adds Away3D click listeners to all cards
		 */
		private function clickEnableCards():void
		{
			for (var i = 0; i < allCards.length; i++) {									
				allCards[i].addOnMouseDown(cubeClicked);
			}
		}
		
		
		
		/**
		 * Removes Away3D click listeners from all cards
		 */
		private function clickDisableCards():void
		{
			for (var i = 0; i < allCards.length; i++) {									
				allCards[i].removeOnMouseDown(cubeClicked);			
			}
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
		}
		
		
		
		/**
		 * Called once the start button is clicked on
		 * or from playAgain once the end game dialog has faded out
		 */
		private function beginGame(e:MouseEvent = null):void
		{		
			if (contains(dialog)) { removeChild(dialog); }
			
			curCards = new Array();
			gameIsOver = false;
			prevCards = new Array();			
			gameTime = 30;
			initialTime = 10;
			numMatches = 0;
			
			theTimer.text = String(initialTime);
			theMatches.text = String(numMatches);
			
			//if (contains(eg)) { removeChild(eg); }
			
			//disable start button		
			dialog.startButton.removeEventListener(MouseEvent.CLICK, beginGame);			
			//startButton.alpha = .24;
			
			//show all logos
			showAllScreens();
				
			countdownTimer.addEventListener(TimerEvent.TIMER, updateInitialTimer);
			countdownTimer.start();
			
			prevTimer.start(); //call checkPrev() every 200ms
		}
		
		
		
		/**
		 * Called when a card is clicked
		 * @param	e
		 */
		private function cubeClicked(e:MouseEvent3D):void
		{			
			//remove listener from selected card so it can't be clicked on again
			e.object.removeOnMouseDown(cubeClicked);			
			curCards.push(e.object);
			TweenLite.to(e.object, .5, { rotationX:180 } );
			channel = rotSound.play();
			if (curCards.length >= 2) {
				checkForMatch();
			}						
		}
		
		
		/**
		 * Called from cubeClicked() whenever the curCards array length is >= 2
		 * 
		 * @param	theCard
		 */
		private function checkForMatch()
		{			
			if (curCards[0].name == curCards[1].name) {
				//match - remove cards from curCards
				curCards.splice(0, 2);
				incMatches();
			}else {
				//no match
				if (curCards.length > 2) {
					//third card clicked while two already showing, push first two (oldest) cards onto prevCards
					//so they are turned back by prevTimer
					prevCards.push(curCards.splice(0, 1)[0]);
					prevCards.push(curCards.splice(0, 1)[0]);
					resetTimer.reset();					
				}else {
					//just two cards - no match - start resetTimer which calls resetCards()					
					resetTimer.reset();
					resetTimer.start();
				}
			}							
		}
		
		/**
		 * Called by prevTimer every 200 ms - turns cards in the prevCards array back
		 * @param	e
		 */
		private function checkPrev(e:TimerEvent):void
		{
			if(prevCards.length > 0){
				var card:Cube = prevCards.splice(0, 1)[0];
				TweenLite.to(card, .5, { rotationX:0, onComplete:enablePrev, onCompleteParams:[card] } );
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
		 * Turns the cards to show comcast logo - called after one second by resetTimer
		 * 
		 * @param	e TIMER TimerEvent
		 */
		private function resetCards(e:TimerEvent = null):void
		{
			resetArray = new Array();
			resetArray.push(curCards.splice(0, 1)[0], curCards.splice(0, 1)[0]);
			
			TweenLite.to(resetArray[0], .5, {rotationX:0 } );			
			TweenLite.to(resetArray[1], .5, { rotationX:0, onComplete:enableResetCards } );
		}			
		
		private function enableResetCards():void
		{
			if (!gameIsOver) {				
				resetArray[0].addOnMouseDown(cubeClicked);
				resetArray[1].addOnMouseDown(cubeClicked);
			}
		}
		
		/**
		 * Renables the last two non matching cards once the tween is complete		 
		 */
		private function enablePrev(card:Cube):void 
		{	
			if (!gameIsOver) {				
				card.addOnMouseDown(cubeClicked);
			}
		}
		
		
		private function renderScene(e:Event):void 
		{			
			viewport.render();
		}
		
		
		/**
		 * Show all screens in the grid
		 * 
		 * @param	e TIMER TimerEvent
		 */
		private function showAllScreens(e:TimerEvent = null):void
		{		
			//channel = allRot.play();			
			for (var i:int = 0; i < allCards.length; i++) {				
				TweenLite.to(allCards[i], 1, { rotationX:180 } );				
			}			
		}
		
		
		/**
		 * Hide all screens in the grid
		 * 
		 * @param	e TIMER TimerEvent
		 */
		private function hideAllScreens(e:TimerEvent = null):void
		{		
			//channel = allRot.play();			
			for (var i:int = 0; i < allCards.length; i++) {				
				TweenLite.to(allCards[i], 1, { rotationX:0 } );				
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
		 * Called from gameOver
		 * Displays the end game dialog and the play again button
		 */
		private function showDialog():void
		{			
			if (!contains(dialog)) { addChild(dialog); }
			dialog.alpha = 0;
			
			//addChild(eg);
			//eg.x = 452;
			//eg.y = 250;
			
			//eg.theBonus.text = String(numMatches);
			//eg.alpha = 0;
			
			/*
			if (language == "en") {
				eg.theTitle.text = "GAME OVER";
				eg.theText.htmlText = "Thanks for playing the La Academia de Comcast matchup.<br/>You got:";
				eg.theText2.text = "correct matches!";
				eg.btnContinue.theText.text = "CONTINUE";
			}else {
				eg.theTitle.text = "FIN DEL JUEGO";
				eg.theText.htmlText = "Gracias por jugar el juego de búsqueda de pares de La Academia de Comcast.<br/>Tienes:";
				eg.theText2.text = "pares correctos";
				eg.btnContinue.theText.text = "CONTINUAR";
			}
			
			eg.btnContinue.addEventListener(MouseEvent.CLICK, continueClicked, false, 0, true);			
			
			TweenLite.to(eg, .75, { alpha:.98, dropShadowFilter: { color:0x000000, alpha:.7, blurX:12, blurY:12, distance:6 }} );			
			*/
			
			if (language == "en") {
				dialog.theTitle.text = "GAME OVER";
				dialog.theText.htmlText = "Thanks for playing the La Academia de Comcast matchup.<br/><br/>You got: " + String(numMatches) + " correct matches";
				//eg.theText2.text = "correct matches!";
				dialog.startButton.theText.text = "CONTINUE";
			}else {
				dialog.theTitle.text = "FIN DEL JUEGO";
				dialog.theText.htmlText = "Gracias por jugar el juego de búsqueda de pares de La Academia de Comcast.<br/><br/>Tienes: " + String(numMatches) + " pares correctos";
				//eg.theText2.text = "pares correctos";
				dialog.startButton.theText.text = "CONTINUAR";
			}
			
			TweenLite.to(dialog, 1, { alpha:1, onComplete:enableButton } );
		}
		private function enableButton():void
		{
			dialog.startButton.addEventListener(MouseEvent.CLICK, continueClicked, false, 0, true);
		}
		
		private function continueClicked(e:MouseEvent):void
		{
			dialog.startButton.removeEventListener(MouseEvent.CLICK, continueClicked);
			dispatchEvent(new Event("continueButtonClicked"));
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
						
			showDialog();
		}
		
		
		public function stopGame():void
		{
			gameIsOver = true;
			countdownTimer.reset();
			countdownTimer.removeEventListener(TimerEvent.TIMER, updateTimer);
			resetTimer.reset();
		}
		
	}	
}