/**
 * 
 *       AXE 
 * The Beautiful Game
 * 
 *   GMR Marketing
 * 
 */

package com.gmrmarketing.axegame
{	
	import flash.display.Bitmap;
	import flash.display.LoaderInfo; //for flashVars
	import flash.display.Loader;
	import flash.display.MovieClip;	
	import flash.display.Sprite;
	
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
	
	import com.gmrmarketing.axegame.SOAPY;
	import com.gmrmarketing.axegame.SimpleEncoder;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;
	
	import flash.external.*;
	
	

	public class Engine extends MovieClip
	{		
		private const GAME:String = "Normal"; //Normal or FaceBook
		
		private const GAME_TIME:uint = 91; //total game time in seconds		
		private const FULL_BONUS:uint = 1000;	
		
		private var imageX:uint; //position of the difference image on stage
		private var imageY:uint;
		
		private const HALF_IMAGE:int = 336; //width of diffs is 672
		
		private var game:Sprite; //contains all game elements
		
		private var beginTime:Number;
		
		private var btnSpeaker:Speaker;
		
		private var bottleTimer:Bottle;
		private var bottleMaskRatio:Number;
		private var maskY:int; //y position of the bottle mask
		
		private var scoreText:CurScore;
		private var curScore:Number;
		
		private var bonusText:CurBonus;
		private var curBonus:Number; //calculated from elapsed time in updateBottle()		
		
		private var totalPoints:Number; //sum of curScore and total score retrieved from web service - set in getPointTotalComplete()
		
		private var curDiffs:CurrDiffs;
		
		private var diffLoader:Loader; //for loading the swf's
		private var swfLoader:Loader;
		private var gameSwfs:Array;
		private var previewImages:Array;
		
		private var theContent:MovieClip; //reference to the loaded swf
		
		private var alreadyClicked:Array; //keeps track of clicked differences
		
		private var allCircles:Array; //array of Circle objects used for highlights
		
		private var scrubPositions:Array; //x,y positions of the detailer when scrubbing the bubbles
		
		private var hintDialog:DialogHint;
		private var hintButtons:Array;		
		
		private var bigCounter:BigCounter;
		
		private var thePreloader:CircPreloader;//library item preloader clip
		
		private var detailer:Detailer; //axe detailer clip for clearing the bubbles
		
		private var multiLoader:MultiLoader;
		
		private var startCountdown:GameStartCountdown; //3-2-1 intro countdown in library
		
		private var redTopBar:RedTopBar;
		
		private var bottleFrames:Array;
		private var curBottle:uint = 0; //index in bottleFrames
		
		private var itemsToLoad:Array;
		
		private var instructions:Instructions; //library clip - instructions dialog
		private var challenge:Challenge; //library clip - challenge game dialog
		
		//FLASHVARS
		private var isDemoMode:Boolean; //Demo Mode string if yes then just one image will be shown
		private var registrantId:String; //registrantId - 0 if unregistered user
		private var playername:String;
		private var opponentname:String; //opponents name if playing head to head game
		private var headToHeadId:String; //head to head ID - 0 if not a h2h game
		private var opponentscore:String; //0 if challenger or points if challenged
		//NEW FLASHVAR FOR END OF GAME - 12/26
		private var promotionOver:Boolean; //currently only used in addInstructions()
		
		
		//For SOAP service
		private var soapy:SOAPY;
		private var gameId:String = "0"; //game id retrieved from calling web service - set in buildSWFArray()		
		private var svcurl:String; //url of web service, passed in flashvars
		
		private var imageFolder:String;		
		
		//for encoding score when sending to registration page from demo game
		private var simpleEncoder:SimpleEncoder = new SimpleEncoder(); 
		
		private var channel:SoundChannel; //for playing sounds
		//for controlling bg music volume
		private var musicVolume:SoundTransform = new SoundTransform(.15);
		private var music:Sound;
		private var musicChannel:SoundChannel = new SoundChannel();
		
		private var soundOn:Boolean = true; //toggled in soundToggle()
		
		private var language:String; //English or Spanish
		
		
		
		
		/**
		 * CONSTRUCTOR
		 */
		public function Engine()
		{		
			//FLASHVARS
			isDemoMode = loaderInfo.parameters.registrantId == "0" ? true : false;
			registrantId = loaderInfo.parameters.registrantId;
			playername = loaderInfo.parameters.playername;
			
			imageFolder = loaderInfo.parameters.impath;
			
			headToHeadId = loaderInfo.parameters.headToHeadId; //0 if not a head to head game
			opponentname = loaderInfo.parameters.opponentname; //only used if headToHeadId is not 0			
			opponentscore = loaderInfo.parameters.opponentscore; //0 if challenger - points if challenged
			
			language = loaderInfo.parameters.language; //english or spanish (en or sp)			
			
			svcurl = loaderInfo.parameters.svcurl;
			
			promotionOver = loaderInfo.parameters.promotionover == "True" ? true : false;
			//FLASHVARS			
			
			
			
			
			hintButtons = new Array();
			
			var key:String;
			if (GAME == "Normal") {
				if (language == "sp") {
					key = "7wb5x291qa53giy8m4fght5kb8iknznswses";
				}else{
					key = "7wb5x291qa53giy8m4fght5kb8iknznsws";
				}
			}else {
				key = "eonaqklar47c67484a7ng6z2qe1quinrfb";
			}
			
			soapy = new SOAPY(svcurl, key); //soap class uses url to build the web service location
			
			if (playername == null) { playername = ""; }
			if (registrantId == null) { registrantId = "1"; }
			if (headToHeadId == null) { headToHeadId = "0"; }
			if (language == null) { language = "en"; }
			
			if (imageFolder == null) { 
				imageFolder = ""; 
			}else {
				imageFolder += "/";
			}
			
			channel = new SoundChannel();
			musicChannel = new SoundChannel();
			
			curScore = 0;
			
			TweenPlugin.activate([BlurFilterPlugin]); 
			
			allCircles = new Array();

			game = new Sprite();
			
			scoreText = new CurScore();						
			game.addChild(scoreText);			
			
			bonusText = new CurBonus();					
			game.addChild(bonusText);
			
			curDiffs = new CurrDiffs();					
			game.addChild(curDiffs);
			
			//Bottle
			bottleTimer = new Bottle();	
			//bottle has four frames - one for each of the four different bottles
			//use three per game
			var bottFrames:Array = new Array(1, 2, 3, 4);
			bottleFrames = new Array();
			//pick three random frames
			for (var o:uint = 1; o < 4; o++) {
				var fr = Math.floor(Math.random() * bottFrames.length);
				bottleFrames.push(bottFrames.splice(fr, 1)[0]);
			}			
			bottleTimer.gotoAndStop(bottleFrames[curBottle]);
			bottleMaskRatio = bottleTimer.theMask.height / GAME_TIME; //pixels per second				
				
			
			btnSpeaker = new Speaker();
			
			thePreloader = new CircPreloader();			
			thePreloader.scaleX = thePreloader.scaleY = .4;
			
			hintDialog = new DialogHint();			
			game.addChild(hintDialog);			
			
			//start countdown
			startCountdown = new GameStartCountdown();			
			startCountdown.numberHolder.alpha = .25;
			
			var k:int;
			var aHintButton:HintMarker;
			
			if (GAME == "Normal") {				
				imageX = 220;
				imageY = 36;
				maskY = 27;
				scrubPositions = new Array([686, 57], [222, 132], [700, 187], [224, 320], [907, 381]);
				
				scoreText.x = 30;
				scoreText.y = 63;
				bonusText.x = 30;
				bonusText.y = 218;	
				curDiffs.x = 125;
				curDiffs.y = 218;
				bottleTimer.x = 60;
				bottleTimer.y = 262;
				thePreloader.x = 870;
				thePreloader.y = 415;
				hintDialog.x = 360;
				hintDialog.y = -300;
				startCountdown.x = 560;
				startCountdown.y = 223;
				
				//Big Counter behind the bottle
						
				bigCounter = new BigCounter();
				bigCounter.scaleX = 2;
				bigCounter.scaleY = 2;
				bigCounter.x = 6;
				bigCounter.y = 235;
				bigCounter.alpha = .3;
				
				game.addChild(bigCounter);
				bigCounter.mouseEnabled = false;
				bigCounter.theText.mouseEnabled = false;
				
				//Three Hint Buttons
				for (k = 0; k < 3; k++){
					aHintButton = new HintMarker(); //detailer icon in library
					aHintButton.x = 60 + (30 * k);
					aHintButton.y = 147;
					aHintButton.name = "hint" + k;
					game.addChild(aHintButton);
					hintButtons.push(aHintButton);
					//aHintButton.addEventListener(MouseEvent.CLICK, showHint);
				}
				
				//Red Top Bar
				redTopBar = new RedTopBar();
				redTopBar.x = 3;
				
				redTopBar.addChild(btnSpeaker);
				game.addChild(redTopBar);
				
				btnSpeaker.x = 865;
				btnSpeaker.y = 6;
				btnSpeaker.addEventListener(MouseEvent.CLICK, toggleSound, false, 0, true);
				redTopBar.playerName.text = playername;	//guest if demo					
				
			
			}else {				
				//facebook				
				imageX = 87;
				imageY = 1;
				maskY = 19;
				scrubPositions = new Array([585, 30], [85, 90], [585, 150], [85, 220], [720, 260]);
				
				scoreText.x = 530;
				scoreText.y = 402;
				bonusText.x = 2;
				bonusText.y = 144;
				curDiffs.x = 2;
				curDiffs.y = 198;
				bottleTimer.x = 8;
				bottleTimer.y = 266;
				thePreloader.x = 725;
				thePreloader.y = 368;
				hintDialog.x = 220;
				hintDialog.y = -300;
				startCountdown.x = 420;
				startCountdown.y = 190;
				
				//Three Hint Buttons
				for (k = 0; k < 3; k++){
					aHintButton = new HintMarker(); //detailer icon in library
					aHintButton.x = 27;
					aHintButton.y = 26 + (32 * k);
					aHintButton.name = "hint" + k;
					game.addChild(aHintButton);
					hintButtons.push(aHintButton);				
				}
				
				//sound toggle
				game.addChild(btnSpeaker);
				btnSpeaker.x = 407; //just left of score area
				btnSpeaker.y = 405;
				btnSpeaker.addEventListener(MouseEvent.CLICK, toggleSound, false, 0, true);	
			}
			
			game.addChild(bottleTimer); //add bottle after big number counter
			
			addChild(game);	
			
			//for loading the preview jpegs and swf's
			diffLoader = new Loader();
			swfLoader = new Loader();
			
			
			//instructions
			instructions = new Instructions();
			//challenge
			challenge = new Challenge();			
				
			
			if(!isDemoMode){
				if (headToHeadId != "0") {
					//calls buildSWFArray() when finished getting swf numbers
					beginHeadToHead();
					
					if(GAME == "Normal"){
						redTopBar.gameNumber.text = "Challenge: " + opponentname; //from flashVar
					}
				}else {
					//calls buildSWFArray() when finished getting swf numbers
					beginSolo();					
				}
			}else {
				//demo mode
				buildSWFArray();
			}			
			
			if (language == "sp") {
				
				if (GAME == "Normal") {
					ui.yourScore.text = "TU PUNTUACIÓN:";
				}else{
					ui.yourScore.text = "TU\nPUNTUACIÓN:";
				}
				ui.hintsRemaining.text = "PISTAS RESTANTES:";
				ui.bonus.text = "PUNTOS EXTRA:";
				ui.differences.text = "DIFERENCIAS:";
				
				if (GAME != "Normal") {
					//facebook
					ui.timer.text = "TEMPORIZADOR:";
				}
				
			}else {
				if (GAME == "Normal") {
					ui.yourScore.text = "YOUR SCORE:";
				}else{
					ui.yourScore.text = "YOUR\nSCORE:";
				}
				ui.hintsRemaining.text = "HINTS REMAINING:";
				ui.bonus.text = "BONUS:";
				ui.differences.text = "DIFFERENCES:";
				
				if (GAME != "Normal") {
					//facebook
					ui.timer.text = "TIMER:";
				}
			}
			
			//floodlight for landing page:
			//floodLight("landi429");
			
		} //CONSTRUCTOR
		
		
		
	
		
		
		// ------------------ PRIVATE --------------------
		
		/**
		 * Called from beginSoloComplete - when the service beginSolo service call
		 * has completed and a gameID and three game numbers are returned
		 * 
		 * ob contains gameId, game1, game2, game3 properties
		 * 
		 * @param	ob game Object
		 */
		private function buildSWFArray(ob:Object = null):void
		{
			gameSwfs = new Array(); //the three picked images from the service
			previewImages = new Array(); //three jpeg preview images for the three game swfs
			
			if(!isDemoMode){
			
				gameId = ob.gameId;
				
				gameSwfs.push(imageFolder + "diffs" + ob.game1 + ".swf");
				gameSwfs.push(imageFolder + "diffs" + ob.game2 + ".swf");
				gameSwfs.push(imageFolder + "diffs" + ob.game3 + ".swf");
				
				previewImages.push(imageFolder + "prev" + ob.game1 + ".jpg");
				previewImages.push(imageFolder + "prev" + ob.game2 + ".jpg");
				previewImages.push(imageFolder + "prev" + ob.game3 + ".jpg");		
				
			}else {
				//demo mode - using 1,2,3 only for now
				gameSwfs.push(imageFolder + "diffs1.swf");
				gameSwfs.push(imageFolder + "diffs1.swf");
				gameSwfs.push(imageFolder + "diffs1.swf");
				
				previewImages.push(imageFolder + "prev1.jpg");
				previewImages.push(imageFolder + "prev2.jpg");
				previewImages.push(imageFolder + "prev3.jpg");
			}
			
			itemsToLoad = previewImages.concat(gameSwfs);
			
			//Got the games, show the instructions
			if (isDemoMode) {				
				addInstructions(2); //frame 2 is demo mode instructions				
			}else {
				if (headToHeadId != "0") {
					addChallenge();
				}else{
					addInstructions(1); //regular instructions
				}
			}
		}
		
		
		/**
		 * Toggles the global sound volume to 0 or 1
		 * Called by clicking the speaker icon in the red top bar
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function toggleSound(e:MouseEvent = null):void
		{
			soundOn = !soundOn;
			if (soundOn) {
				SoundMixer.soundTransform = new SoundTransform(1);
				btnSpeaker.gotoAndStop(1);
			}else {
				SoundMixer.soundTransform = new SoundTransform(0);
				btnSpeaker.gotoAndStop(2);
			}
		}
		
		
		/**
		 * Init game variables
		 * 
		 * Called from diffLoaded() once the difference swf is loaded and ready
		 */
		private function begin():void		
		{
			//switch bottles
			bottleTimer.gotoAndStop(bottleFrames[curBottle]);
			curBottle++;
			if (curBottle >= bottleFrames.length) {
				curBottle = 0;
			}
			
			
			bonusText.theText.text = String(FULL_BONUS); //show 1000
			
			TweenLite.to(bottleTimer.theMask, .75, { y:maskY, onComplete:startBottleTimer } );
			
			curDiffs.theText.text = "0 of 5";	
			
			//contains the clicked differences
			alreadyClicked = new Array();
		}
		
		
		/**
		 * Called from addInstructions when frame = 3 - normal results
		 * 
		 * @param	e
		 */
		private function playAgain(e:MouseEvent = null):void
		{
			curScore = 0;
			curBonus = 0;
			updateScore();
			
			var i:int;
			
			hintButtons = new Array();			
			for (i = 0; i < 3; i++) {
				hintButtons.push(game.getChildByName("hint" + i));
			}
			
			for (i = 0; i < 3; i++) {
				hintButtons[i].alpha = 1;
			}
			
			headToHeadId = "0"; //reset for solo
			
			beginSolo();
		}
		
		
		/**
		 * Called from pressing the start button in the instructions.
		 * Starts the preloader
		 * 
		 * @param	e
		 */
		private function startPreloading(e:MouseEvent = null):void
		{
			//floodlight call for Play button pressed
			if (isDemoMode) {
				if (language == "sp") {
					floodLight("spani770");
				}else{
					floodLight("playb408");
				}
			}else {
				if (language == "sp") {
					floodLight("spani495");
				}else {
					floodLight("playb738");
				}				
			}
			
			instructions.btnStart.removeEventListener(MouseEvent.CLICK, startPreloading);
			
			TweenLite.to(instructions, 1, { alpha:0, onComplete:killInstructions } );
			
			//load items and call showCountdown when finished
			multiLoader = new MultiLoader(itemsToLoad);
			multiLoader.addEventListener("multiComplete", showCountdown, false, 0, true);
			
			//show rotating circle preloader while everything loads
			game.addChild(thePreloader);
			if (game.contains(swfLoader)) {
				game.removeChild(swfLoader);
			}
			
			thePreloader.addEventListener(Event.ENTER_FRAME, preloaderRotate, false, 0, true);
		}
		
		
		
		/**
		 * Adds the big instructions dialog to the game
		 * 
		 * Shows the specified frame: 1 - normal instructions, 2 - demo instructions
		 * 3 - normal results, 4 - demo results
		 * 
		 * 4 is called from removeDetailer
		 * 
		 * @param	whichFrame 1 - 4
		 */
		private function addInstructions(whichFrame:uint):void
		{	
			instructions.x = 0;
			instructions.y = 0;
			instructions.alpha = 0;
			
			game.addChild(instructions);
			instructions.gotoAndStop(whichFrame);					
			
			var cs = numberFormatter(curScore);
			var tp = numberFormatter(totalPoints);
			
			//normal instructions
			if (whichFrame == 1 || whichFrame == 2) {
				
				var inText:String;
				
				if (language == "sp") {
					instructions.title.text = "EL BELLO JUEGO INSTRUCCIONES";
					
					inText = "<font size='13'>ESTUDIA LAS FOTOS Y HAZ CLIC EN LAS DIFERENCIAS ENTRE AMBAS.<br/>HAY CINCO INSTRUCCIONES POR GRUPO DE FOTOS<br/><br/>";
					inText += "TU PUNTUACIÓN SERÁ BASADA<br/>EN TU VELOCIDAD Y PRECISIÓN<br/><br/>";
					inText += "SI NO SABES COMO AVANZAR, HAZ CLIC EN UNO DE<br/>LOS ÍCONOS DE PISTAS PARA VER LA DIFERENCIA</font><br/>";
					inText += "<font size='10'>(ten en cuenta que usar las pistas no incrementará tu puntuación)</font>";
					
					instructions.theImage.diffs.text = "Diferencias Encontradas";
					instructions.theImage.hints.text = "Pistas";
					instructions.theImage.points.text = "Puntos Para La Próxima Diferencia";
					instructions.theImage.timer.text = "Tempo Del Juego";
					
					instructions.btnStart.theText.htmlText = "<font size='19'>JUEGA</font>";					
					
				}else {					
					instructions.title.text = "THE BEAUTIFUL GAME INSTRUCTIONS";
					
					inText = "<font size='13'>STUDY THE SIDE BY SIDE PHOTOS AND CLICK ON THE DIFFERENCES<br/>BETWEEN THE TWO - THERE ARE FIVE DIFFERENCES PER PHOTO SET<br/><br/>";
					inText += "YOUR SCORE IS BASED<br/>ON SPEED AND ACCURACY<br/><br/>";
					inText += "IF YOU GET STUCK, CLICK ONE OF THE<br/>HINT ICONS TO REVEAL A DIFFERENCE</font><br/>";
					inText += "<font size='10'>(note that using the hints will not increase your score)</font>";
					
					instructions.theImage.diffs.text = "Differences Found";
					instructions.theImage.hints.text = "Hints";
					instructions.theImage.points.text = "Points for Next Difference";
					instructions.theImage.timer.text = "Game Timer";
					
					instructions.btnStart.theText.htmlText = "<font size='19'>PLAY</font>";				
				}
				
				instructions.btnStart.theText.y = 6;
				instructions.theText.htmlText = inText;
				
				instructions.btnStart.visible = true;
				instructions.btnStart.buttonMode = true;
				
				instructions.btnSignUp.visible = false;
				instructions.btnProfile.visible = false;				
				
				instructions.btnStart.addEventListener(MouseEvent.CLICK, startPreloading, false, 0, true);
				instructions.btnStart.addEventListener(MouseEvent.MOUSE_OVER, hideButtonBG, false, 0, true);
				instructions.btnStart.addEventListener(MouseEvent.MOUSE_OUT, showButtonBG, false, 0, true);				
			}			
			
			//3 regular recap, 4 demo recap
			if (whichFrame == 3 || whichFrame == 4) {
				instructions.btnStart.visible = false;
				instructions.btnSignUp.visible = true;				
				
				if (whichFrame == 3) {					
					//normal recap
					if(language == "sp"){
						instructions.btnSignUp.theText.htmlText = "<font size='15'>JUGAR DE NUEVO</font>";
						instructions.btnProfile.theText.htmlText = "<font size='15'>VER MI PERFIL</font>";						
					}else {
						instructions.btnSignUp.theText.htmlText = "<font size='15'>PLAY AGAIN</font>";
						instructions.btnProfile.theText.htmlText = "<font size='15'>VIEW MY PROFILE</font>";						
					}
					instructions.btnSignUp.theText.y = 8;
					instructions.btnProfile.theText.y = 8;
					
					instructions.btnSignUp.addEventListener(MouseEvent.CLICK, playAgain, false, 0, true);
					
					instructions.btnProfile.visible = true;
					instructions.btnProfile.buttonMode = true;
					instructions.btnProfile.addEventListener(MouseEvent.CLICK, goProfile, false, 0, true);
					instructions.btnProfile.addEventListener(MouseEvent.MOUSE_OVER, hideButtonBG, false, 0, true);
					instructions.btnProfile.addEventListener(MouseEvent.MOUSE_OUT, showButtonBG, false, 0, true);
					
				}else {
					//frame 4 - demo recap
					if(language == "sp"){
						instructions.btnSignUp.theText.htmlText = "<font size='15'>REGÍSTRATE AHORA</font>";					
					}else {						
						instructions.btnSignUp.theText.htmlText = "<font size='15'>SIGN UP NOW</font>";
					}
					instructions.btnSignUp.theText.y = 8;
					
					instructions.btnProfile.visible = false;
					instructions.btnSignUp.addEventListener(MouseEvent.CLICK, doSignup, false, 0, true);
				}
				
				instructions.btnSignUp.buttonMode = true;
				instructions.btnSignUp.theText.mouseEnabled = false;
				instructions.btnSignUp.addEventListener(MouseEvent.MOUSE_OVER, hideButtonBG, false, 0, true);
				instructions.btnSignUp.addEventListener(MouseEvent.MOUSE_OUT, showButtonBG, false, 0, true);
			}
			
			//regular recap	- title "Thanks for playing the beautiful game"
			if (whichFrame == 3) {
				
				if (language == "sp") {					
					instructions.title.text = "GRACIAS POR DISFRUTAR DE LA JUGADA HERMOSA";
				}else {
					instructions.title.text = "THANKS FOR PLAYING THE BEAUTIFUL GAME";
				}
				
				if (headToHeadId != "0") {
					//this was a challenge game
					//if opponent score is 0 then challenger, else challenged
					if (opponentscore == "0") {
						//challenger 
						if (language == "sp") {
							instructions.theText.htmlText = "<font size='13'>TU DESAFÍO HA SIDO ENVIADO: HAS RETADO A " + opponentname.toUpperCase() + " A SUPERAR TU PUNTUACIÓN DE " + cs + " PUNTOS.<br/><br/>PUEDES VERIFICAR EL ESTADO DE TODOS TUS DESAFÍOS DESDE LA PÁGINA DE TU PERFIL.<br/><br/>TUS PUNTOS TOTALES PARA TODOS LOS JUEGOS: " + tp + "</font>";
						}else{
							instructions.theText.htmlText = "<font size='13'>CHALLENGE SENT: YOU'VE CHALLENGED " + opponentname.toUpperCase() + " TO BEAT YOUR SCORE OF " + cs + " POINTS.<br/><br/>YOU CAN CHECK THE STATUS OF ALL YOUR CHALLENGE GAMES FROM YOUR PROFILE PAGE.<br/><br/>YOUR POINT TOTAL FOR ALL GAMES PLAYED: " + tp + "</font>";
						}
					}else {
						//challenged - show won or lost challenge message
						if (curScore > parseInt(opponentscore)) {
							//won
							if (language == "sp") {
								instructions.theText.htmlText = "<font size='13'>GANASTE EL DESAFÍO: FFELICITACIONES, HAS GANADO EL RETO.<br/><br/>TUS PUNTOS: " + cs + " PUNTOS.<br/>" + opponentname.toUpperCase() + ": " + numberFormatter(parseInt(opponentscore)) + " PUNTOS<br/><br/>HAS RECIBIDO 250 PUNTOS POR COMPLETAR EL DESAFÍO Y 100 PUNTOS POR GANAR.<br/><br/>TUS PUNTOS TOTALES PARA TODOS LOS JUEGOS: " + tp + "</font>";
							}else{
								instructions.theText.htmlText = "<font size='13'>CHALLENGE WON: CONGRATULATIONS YOU'VE WON THE CHALLENGE!<br/><br/>Your Points: " + cs + " POINTS<br/>" + opponentname.toUpperCase() + ": " + numberFormatter(parseInt(opponentscore)) + " POINTS<br/><br/>YOU'VE RECEIVED 250 POINTS FOR COMPLETING THE CHALLENGE AND 100 BONUS POINTS FOR THE WIN.<br/><br/>YOUR POINT TOTAL FOR ALL GAMES PLAYED: " + tp + "</font>"; 
							}
						}else {
							//lost
							if (language == "sp") {
								instructions.theText.htmlText = "<font size='13'>PERDISTE EL DESAFÍO: BUEN INTENTO, PERO HAS PERDIDO EL RETO.<br/><br/>TU PUNTUACIÓN: " + cs + "PUNTOS<br/>PUNTUACIÓN DE " + opponentname.toUpperCase() + ": " + numberFormatter(parseInt(opponentscore)) + " PUNTOS.<br/><br/>HAS RECIBIDO 250 PUNTOS POR COMPLETAR ESTE DESAFÍO.<br/><br/>TUS PUNTOS TOTALES PARA TODOS LOS JUEGOS: " + tp + "</font>";
							}else{
								instructions.theText.htmlText = "<font size='13'>CHALLENGE LOST: NICE EFFORT BUT YOU'VE LOST THE CHALLENGE!<br/><br/>Your Points: " + cs + " POINTS<br/>" + opponentname.toUpperCase() + ": " + numberFormatter(parseInt(opponentscore)) + " POINTS<br/><br/>YOU'VE RECEIVED 250 POINTS FOR COMPLETING THE CHALLENGE.<br/><br/>YOUR POINT TOTAL FOR ALL GAMES PLAYED: " + tp + "</font>"; 						
							}
						}
					}
					
				}else {					
					//regular game					
					if (language == "sp") {
						instructions.theText.htmlText = "<font size='13'>EN ESTA RONDA HAS GANADO " + cs + " PUNTOS<br/><br/>TUS PUNTOS TOTALES PARA TODOS LOS JUEGOS: " + tp + "</font>";
					}else{
						instructions.theText.htmlText = "<font size='13'>IN THIS ROUND YOU EARNED " + cs + " POINTS<br/><br/>YOUR POINT TOTAL FOR ALL GAMES PLAYED: " + tp + "</font>";
					}
				}
			}
			
			//demo recap	
			if (whichFrame == 4) {	
				if (promotionOver) {
					if(language == "sp"){
						instructions.title.text = "GRACIAS POR PROBAR LA JUGADA HERMOSA";
						instructions.theText.htmlText = "<font size='13'>ACABAS DE GANAR " + cs + " PUNTOS.<br/><br/>REGISTRATE AHORA PARA REVELER FOTOS ADICIONALES.<br/><br/>USAR TUS PUNTOS PARA CONTENIDO EXCLUSIVO DE AXE.</font>";
					}else {
						instructions.title.text = "THANKS FOR TRYING THE BEAUTIFUL GAME";
						instructions.theText.htmlText = "<font size='13'>YOU JUST EARNED " + cs + " POINTS.<br/><br/>SIGN-UP NOW TO UNLOCK ADDITIONAL PHOTOS.<br/><br/>REDEEM YOUR POINTS FOR EXCLUSIVE AXE CONTENT.</font>";
					}
				}else{
					if(language == "sp"){
						instructions.title.text = "GRACIAS POR PROBAR LA JUGADA HERMOSA";
						instructions.theText.htmlText = "<font size='13'>ACABAS DE GANAR " + cs + " PUNTOS.<br/><br/>REGÍSTRATE AHORA PARA REVELAR FOTOS ADICIONALES Y USAR TUS PUNTOS PARA UNA OPORTUNIDAD DE GANAR UNO DE MILES DE PREMIOS<br/><br/>TAMBIÉN PUEDES REGISTRARTE PARA GANAR UN VIAJE A SUDÁFRICA.</font>";
					}else {
						instructions.title.text = "THANKS FOR TRYING THE BEAUTIFUL GAME";
						instructions.theText.htmlText = "<font size='13'>YOU JUST EARNED " + cs + " POINTS.<br/><br/>SIGN-UP NOW TO UNLOCK ADDITIONAL PHOTOS AND USE YOUR POINTS FOR A CHANCE TO WIN ONE OF A THOUSAND PRIZES.<br/><br/>YOU CAN ALSO REGISTER TO WIN A TRIP TO SOUTH AFRICA.</font>";
					}		
				}
				
			}			
			
			TweenLite.to(instructions, 1, { alpha:1 } );			
		}
		
		
		/**
		 * Adds the challenge dialog to the game before the instructions are displayed
		 * Called from buildSWFArray() if headToHeadId is not 0
		 */
		private function addChallenge():void
		{
			challenge.alpha = 0;
			game.addChild(challenge);
			
			if (language == "sp") {
				challenge.title.text = "PARTIDO DE DESAFÍO";
				challenge.btnPlay.theText.text = "COMENZAR";
			}else {
				challenge.title.text = "CHALLENGE MATCH";
				challenge.btnPlay.theText.text = "START";
			}
			
			challenge.btnPlay.addEventListener(MouseEvent.CLICK, removeChallenge, false, 0, true);
			
			if (opponentscore == "0") {
				//challenger
				if (language == "sp") {
					challenge.theText.htmlText = "ESTÁS RETADO A " + opponentname.toUpperCase() + " AL BELLO JUEGO.<br/><br/>GANARÁS 250 PUNTOS EXTRA CUANDO TU AMIGO ACEPTE EL DESAFÍO.<br/><br/>EL GANADOR DEL RETO GANA 100 PUNTOS EXTRA.";
				}else{
					challenge.theText.htmlText = "YOU'RE CHALLENGING " + opponentname.toUpperCase() + " TO THE BEAUTIFUL GAME.<br/><br/>YOU WILL EARN AN EXTRA 250 POINTS WHEN YOUR FRIEND ACCEPTS THE CHALLENGE.<br/><br/>THE WINNER OF THE CHALLENGE GETS AN EXTRA 100 POINT BONUS.";
				}
			}else {
				//challenged
				if (language == "sp") {
					challenge.theText.htmlText = opponentname.toUpperCase() + " TE HA DESAFIADO A SUPERAR SU LOGRO DE " + numberFormatter(parseInt(opponentscore)) + " PUNTOS.<br/><br/>GANARÁS 250 PUNTOS EXTRA AL ACEPTAR EL RETO.<br/><br/>EL GANADOR DEL DESAFÍO GANA 100 PUNTOS EXTRA.";
				}else{
					challenge.theText.htmlText = opponentname.toUpperCase() + " HAS CHALLENGED YOU TO BEAT A SCORE OF " + numberFormatter(parseInt(opponentscore)) + " POINTS.<br/><br/>YOU'LL EARN AN EXTRA 250 POINTS FOR ACCEPTING THIS CHALLENGE.<br/><br/>THE WINNER OF THE CHALLENGE GETS AN EXTRA 100 POINT BONUS.";
				}
			}
			
			TweenLite.to(challenge, 1, { alpha:1 } );
		}
		
		
		/**
		 * Called from addChallenge()
		 * Fades out the challenge dialog then calls killChallenge to remove it
		 * @param	e
		 */
		private function removeChallenge(e:MouseEvent = null):void
		{
			TweenLite.to(challenge, 1, { alpha:0, onComplete:killChallenge } );
		}
		
		
		/**
		 * Removes challenge dialog once it's faded out
		 */
		private function killChallenge():void
		{
			if(game.contains(challenge)){
				game.removeChild(challenge);
			}
			
			//show instructions
			addInstructions(1);
		}
		
		
		
		private function hideButtonBG(e:MouseEvent):void
		{
			e.currentTarget.bg.visible = false;
		}
		
		
		private function showButtonBG(e:MouseEvent):void
		{
			e.currentTarget.bg.visible = true;
		}
		
		private function doSignup(e:MouseEvent):void
		{
			navigateToURL(new URLRequest("register.aspx?dgs=" + simpleEncoder.encode(curScore)), "_self");
		}
		
		private function goProfile(e:MouseEvent):void
		{
			var nav = "MyProfile.aspx?r=" + Math.random() * (500 * Math.random());
			navigateToURL(new URLRequest(nav), "_self");
		}
		
		
		/**
		 * Called by TweenLite, in startPreloading(), after the instructions fade out
		 */
		private function killInstructions():void
		{
			if(game.contains(instructions)){
				game.removeChild(instructions);
			}
		}
		
		
		
		/**
		 * Called by the multiLoader once all the game swf's and their preview images
		 * have loaded
		 * 
		 * @param	e custom "multiComplete" event dispatched from MultiLoader
		 */
		private function showCountdown(e:Event):void
		{
			multiLoader.removeEventListener("multiComplete", showCountdown);			
			
			//show the countdown and preview images
			game.addChild(startCountdown);
			
			diffLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, previewLoaded, false, 0, true);		
			
			loadPreview();
		}
		
		
		private function previewLoaded(e:Event):void
		{			
			var bit:Bitmap = e.target.content;			
			if(bit != null){
				bit.smoothing = true;
			}
			
			diffLoader.width = 400;
			diffLoader.height = 150;
			diffLoader.x = -200;
			if(GAME == "Normal"){
				diffLoader.y = -80;
			}else {
				diffLoader.y = -70;
			}
			diffLoader.alpha = 1;
			
			startCountdown.addChild(diffLoader);			
			
			if (previewImages.length > 0) {
				TweenLite.to(diffLoader, 1, { delay:.25, alpha:0, onComplete:loadPreview } );						
			}else {
				diffLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, previewLoaded);
				TweenLite.to(diffLoader, 1, { delay:.25, alpha:0, onComplete:finishPreviews } );								
			}
		}
		
		
		private function loadPreview():void
		{
			startCountdown.numberHolder.theText.text = previewImages.length;		
			startCountdown.numberHolder.scaleX = startCountdown.numberHolder.scaleY = 3.78;
			TweenLite.to(startCountdown.numberHolder, 1.5, { scaleX:5, scaleY:5 } );
			diffLoader.load(new URLRequest(previewImages.splice(0,1)[0]));
		}
		
		
		private function finishPreviews():void
		{
			startCountdown.removeChild(diffLoader);			
			game.removeChild(startCountdown);
			
			//remove rotating circle preloader
			game.removeChild(thePreloader);
			thePreloader.removeEventListener(Event.ENTER_FRAME, preloaderRotate);
			
			loadDifference();
		}
		
		
		/**
		 * Called from begin()
		 * Starts the bottle emptying timer and the bonus timer
		 */
		private function startBottleTimer():void
		{
			beginTime = getTimer();	
			
			updateBottle(); //call updateBottle to be sure curBonus is calculated before allowing any clicks
			
			bottleTimer.addEventListener(Event.ENTER_FRAME, updateBottle, false, 0, true);	
			
			theContent.addEventListener(MouseEvent.CLICK, contentClicked, false, 0, true);
			
			//add hint listeners
			var n:int = hintButtons.length;
			for (var k:int = 0; k < n; k++){
				hintButtons[k].addEventListener(MouseEvent.CLICK, showHint, false, 0, true);
			}
		}
		
		
		
		/**
		 * Removes the enter frame listener and stops the bottle emptying
		 */
		private function stopBottleTimer():void
		{
			bottleTimer.removeEventListener(Event.ENTER_FRAME, updateBottle);	
		}
		
		
		
		/**
		 * Called whenever a hint button/icon is clicked
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function showHint(e:MouseEvent):void
		{	
			var hintName:String = e.currentTarget.name;
			var hintIndex:int;		
			
			//find hint index in hintButtons from name
			for (var j = 0; j < hintButtons.length; j++) {
				if (hintButtons[j].name == hintName) {
					hintIndex = j;
					break;
				}
			}
			hintButtons[hintIndex].alpha = .2;
			hintButtons[hintIndex].removeEventListener(MouseEvent.CLICK, showHint);
			hintButtons.splice(hintIndex, 1); //remove hint from array
			
			//get a difference
			for (var i:int = 1; i < 6; i++){
				if (alreadyClicked.indexOf(String(i)) == -1) {
					addCircle(String(i), true);
					break;
				}
			}
		}
		
		
		
		/**
		 * Loads the first swf in the gameSwfs array
		 */
		private function loadDifference():void
		{	
			if (gameSwfs.length > 0) {
				
				if (game.contains(swfLoader)) {
					game.removeChild(swfLoader);
				}
			
				var theSwf = gameSwfs.splice(0, 1)[0];
				swfLoader.load(new URLRequest(theSwf));
				
				swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, diffLoaded, false, 0, true);				
				
			}else {		
				var aSound:cheer = new cheer();
				//play cheer at half volume
				var transform:SoundTransform = new SoundTransform(0.4);
				channel = aSound.play();
				channel.soundTransform = transform;
				
				gameOver();
			}
		}
		
		/**
		 * Stops the game and then calls the appropriate finish game method if not in demo mode
		 * 
		 * Called by updateBottle(), loadDifference() and removeDetailer()
		 * 
		 */
		private function gameOver():void
		{	
			stopGame();
			
			if(!isDemoMode){
				if (headToHeadId != "0") {
					finishHeadToHead();
				}else{
					finishSolo();
				}			
				
			}else {
				//demo
				addInstructions(4); //demo results at frame 4
			}
		}
		
		
		
		/**
		 * Called by ENTER_FRAME event - rotates the preloader
		 * called from loadDifference()
		 * 
		 * @param	e event ENTER_FRAME 
		 */
		private function preloaderRotate(e:Event):void
		{
			thePreloader.rotation += 3;
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
			//diffLoader.width = 671;
			//diffLoader.height = 397;
			
			swfLoader.alpha = 1;
			
			theContent = MovieClip(swfLoader.content);	
			
			//hide the click hotspots
			for (var i:uint = 1; i < 6; i++)
			{				
				theContent["diff" + i].alpha = 0;
				theContent["diff" + i + "2"].alpha = 0;					
			}			
			
			game.addChildAt(swfLoader, 0);	//add at index 0 so the image is below everything	
			
			//bring in the new image and call begin
			musicChannel.stop();					
			music = new Sound();
			//start background music			
			switch(gameSwfs.length) {
				case 2:
					music.load(new URLRequest(imageFolder + "level3.mp3"));
					break;
				case 1:
					music.load(new URLRequest(imageFolder + "level2.mp3"));
					break;
				case 0:
					music.load(new URLRequest(imageFolder + "level1.mp3"));
					break;
			}			
			musicChannel = music.play();
			musicChannel.soundTransform = musicVolume;
			
			TweenLite.to(swfLoader, .75, {y:imageY, onComplete:begin } );
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
				//same (not diff) spot clicked - remove 10 seconds from timer and 100 points from bonus
				badClick();
				
			}else {
				//difference clicked				
				
				//gets the diff number 1,2,3 etc. - diffs are named diff1, diff12, diff2, diff22, etc.
				var whichDiff:String = spot.substr(4, 1);
				
				if (alreadyClicked.indexOf(whichDiff) == -1) {
					
					addCircle(whichDiff, false);
					
				}else {
					//clicked the same diff twice
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
			
			/*
			if(!fromHint){
				//add circles based on mouse click position
				
				allCircles.push(new Circle(game, mouseX, mouseY));
				if (mouseX > imageX + HALF_IMAGE) {
					//clicked on right side image
					allCircles.push(new Circle(game, mouseX - HALF_IMAGE, mouseY));
				}else {
					//clicked on left side image
					allCircles.push(new Circle(game, mouseX + HALF_IMAGE, mouseY));
				}
			}else{
			*/
				//old method using reg point of diffs - now used to add circle from clicking hint
				allCircles.push(new Circle(game, imageX + theContent["diff" + clickedDiff].x, imageY + theContent["diff" + clickedDiff].y));
				allCircles.push(new Circle(game, imageX + theContent["diff" + clickedDiff + "2"].x, imageY + theContent["diff" + clickedDiff + "2"].y));
			//}
			
			var aSound:bell = new bell();
			channel = aSound.play();
			
			if(!fromHint){
				updateScore();
			}
		
			//update differences clicked text
			curDiffs.theText.text = String(alreadyClicked.length) + " of 5";
			
			//check for game over
			if (alreadyClicked.length == 5) {
				picComplete();						
			}
		}
		
		
		
		/**
		 * Called from contentClicked() when the alreadyClicked array length == 5 - all differences
		 * found - stops the timers and then calls scrubBubbles()
		 */
		private function picComplete():void
		{
			stopBottleTimer();
			
			quietHints(); //prevent clicks on hints
			
			//show complete message
			hintDialog.y = 90;
			hintDialog.alpha = 0;
			
			if (language == "sp") {
				hintDialog.theText.text = "Se Encontraron Todas Ellas!";
			}else{
				hintDialog.theText.text = "You Found Them All!";
			}
			
			TweenLite.to(hintDialog, 1, {delay:.5, alpha:1 } );
			TweenLite.to(hintDialog, .5, {overwrite:0, delay:2.5, y:-300, onComplete:scrubBubbles } );			
		}
		
		
		
		/**
		 * Called from picComplete
		 * Tweens the detailer across the screen, with a motion blur, to remove the bubbles
		 */
		private function scrubBubbles():void
		{			
			detailer = new Detailer();
			
			if(GAME == "Normal"){
				detailer.x = 214;
				detailer.y = 34;
			}else {
				//facebook
				detailer.x = 95;
				detailer.y = 5;
			}
			
			game.addChild(detailer);
			
			fadeCircles(false);

			TweenLite.to(detailer, .5, {x:scrubPositions[0][0],y:scrubPositions[0][1]});
			TweenLite.to(detailer, .25, {blurFilter:{blurX:50}, overwrite:0, ease:Linear.easeIn});
			TweenLite.to(detailer, .25, {blurFilter:{blurX:0}, delay:.25, overwrite:0});
			
			TweenLite.to(detailer, .5, {x:scrubPositions[1][0], y:scrubPositions[1][1], delay:.5, overwrite:0});
			TweenLite.to(detailer, .25, {blurFilter:{blurX:50}, delay:.5, overwrite:0, ease:Linear.easeIn});
			TweenLite.to(detailer, .25, {blurFilter:{blurX:0}, delay:.75, overwrite:0});
			
			TweenLite.to(detailer, .5, {x:scrubPositions[2][0] , y:scrubPositions[2][1] , delay:1, overwrite:0});
			TweenLite.to(detailer, .25, {blurFilter:{blurX:50}, delay:1, overwrite:0, ease:Linear.easeIn});
			TweenLite.to(detailer, .25, {blurFilter:{blurX:0}, delay:1.25, overwrite:0});
			
			TweenLite.to(detailer, .5, {x:scrubPositions[3][0] , y:scrubPositions[3][1] , delay:1.5, overwrite:0});
			TweenLite.to(detailer, .25, {blurFilter:{blurX:50}, delay:1.5, overwrite:0, ease:Linear.easeIn});
			TweenLite.to(detailer, .25, {blurFilter:{blurX:0}, delay:1.75, overwrite:0});
			
			TweenLite.to(detailer, .5, {x:scrubPositions[4][0] , y:scrubPositions[4][1] , delay:2, overwrite:0});
			TweenLite.to(detailer, .25, {blurFilter:{blurX:50}, delay:2, overwrite:0, ease:Linear.easeIn});
			TweenLite.to(detailer, .25, {blurFilter:{blurX:0}, delay:2.25, overwrite:0, onComplete:removeDetailer});
		}
		
		
		
		/**
		 * Called from scrubBubbles()
		 * when the detailer is done removing the bubbles - removes the detailer, hint dialog and
		 * loads a new difference image
		 */
		private function removeDetailer():void
		{
			game.removeChild(detailer);			
			killCircles();
			
			//check if demo mode
			if(!isDemoMode){
				loadDifference();
			}else {
				//game over if in demo mode
				gameOver();
			}
		}
		
		
		
		/**
		 * Fades the circles out
		 * 
		 * @param	callKillCircles Boolean - if true then kilLCircles is called once the last circle has faded
		 * 
		 */
		private function fadeCircles(callKillCircles:Boolean = false):void
		{
			for (var i:uint = 0; i < allCircles.length - 1; i++) {				
				TweenLite.to( allCircles[i].getCircle(), 2, { alpha:0, ease:Linear.easeNone } );				
			}
			
			if (callKillCircles) {
				TweenLite.to( allCircles[allCircles.length - 1].getCircle(), 2, { alpha:0, ease:Linear.easeNone, onComplete:killCircles } );			
			}else {
				TweenLite.to( allCircles[allCircles.length - 1].getCircle(), 2, { alpha:0, ease:Linear.easeNone } );
			}
		}
		
		
		
		/**
		 * Calls remove() on all Circle instances and resets the allCircles array
		 */
		private function killCircles():void
		{			
			for (var i:uint = 0; i < allCircles.length; i++) {
				allCircles[i].remove();
			}
			allCircles = new Array();
		}
		
		
		
		/**
		 * Called from contentClicked() whenever a non-difference area of the image is clicked
		 * or when the same difference area is clicked twice
		 */
		private function badClick():void
		{			
			var buzz:buzzer = new buzzer();
			channel = buzz.play();
			
			beginTime -= 10000;			
		}
		
		
		
		/**
		 * Called on EnterFrame - moves the bottle mask to 'empty' the bottle
		 * 
		 * @param	e ENTER_FRAME event
		 */
		private function updateBottle(e:Event = null):void
		{			
			var elapsedMilliseconds = getTimer() - beginTime;
			
			curBonus = Math.ceil(FULL_BONUS - ((elapsedMilliseconds / 200) * 2));			
			
			if (curBonus < 100) { 
				curBonus = 100;			
			}
			
			bonusText.theText.text = String(curBonus);		
			
			var elapsedSeconds = elapsedMilliseconds / 1000; //in seconds
			
			var remainingTime = GAME_TIME - elapsedSeconds;
			if(GAME == "Normal"){
				bigCounter.theText.text = String(Math.floor(remainingTime));
			}
			
			bottleTimer.theMask.y = maskY + (elapsedSeconds * bottleMaskRatio);
			
			if (elapsedSeconds >= GAME_TIME) {
				
				//ran out of time - game over
				if(GAME == "Normal"){
					bigCounter.theText.text = "0";
				}
				if(allCircles.length){
					fadeCircles(true); //fade and then call killCircles()
				}
				
				var aSound:timeExpired = new timeExpired();
				channel = aSound.play();
			
				gameOver();
			}
		}
		
		
		
		/**
		 * Stops the timers, removes event listeners
		 * called from gameOver()
		 */
		private function stopGame():void
		{
			musicChannel.stop();
			stopBottleTimer();			
			quietHints();
			theContent.removeEventListener(MouseEvent.CLICK, contentClicked);
		}
		
		
		
		/**
		 * Removes click listeners from all the hint icons
		 */
		private function quietHints():void
		{
			for (var i = 0; i < hintButtons.length; i++) {
				hintButtons[i].removeEventListener(MouseEvent.CLICK, showHint);
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
		
		
		
		//SOAPY
		private function beginSolo():void
		{
			if(GAME == "Normal"){
				redTopBar.gameNumber.text = "";
			}
			var req:URLRequest = soapy.buildEnvelope("BeginSoloGame", registrantId);
			var loader:URLLoader = new URLLoader();
			loader.load(req);
			loader.addEventListener(Event.COMPLETE, beginSoloComplete, false, 0, true);
		}
		
		private function beginSoloComplete(e:Event):void
		{
			var loader:URLLoader = URLLoader(e.target);	
			var r = soapy.parseGame(loader.data);
			
			buildSWFArray(r);
		}
		
		private function finishSolo():void 
		{
			var req:URLRequest = soapy.buildEnvelope("FinishSoloGame", null, gameId, null, String(curScore));
			var loader:URLLoader = new URLLoader();
			loader.load(req);
			loader.addEventListener(Event.COMPLETE, finishSoloComplete, false, 0, true);
		}		
		
		private function finishSoloComplete(e:Event):void
		{		
			//trace("Solo Game Recorded", gameId);
			getPointTotal();
		}
		
		private function beginHeadToHead():void
		{
			var req:URLRequest = soapy.buildEnvelope("BeginChallengeGame", registrantId, null, headToHeadId);
			var loader:URLLoader = new URLLoader();
			loader.load(req);
			loader.addEventListener(Event.COMPLETE, beginHeadToHeadComplete, false, 0, true);
		}
		
		private function beginHeadToHeadComplete(e:Event):void
		{
			var loader:URLLoader = URLLoader(e.target);	
			var r = soapy.parseGame(loader.data);
			
			buildSWFArray(r);
		}
		
		private function finishHeadToHead():void
		{
			var req:URLRequest = soapy.buildEnvelope("FinishChallengeGame", null, gameId, null, String(curScore));
			var loader:URLLoader = new URLLoader();
			loader.load(req);
			loader.addEventListener(Event.COMPLETE, finishHeadToHeadComplete, false, 0, true);
		}
		
		private function finishHeadToHeadComplete(e:Event):void
		{
			//trace("Challenge Game Recorded", gameId);
			getPointTotal();
		}
	
		/**
		 * Called from loadDifference() when the game is over in non-demo mode
		 */
		private function getPointTotal():void
		{
			var req:URLRequest = soapy.buildEnvelope("GetTotalPoints", registrantId);
			var loader:URLLoader = new URLLoader();
			loader.load(req);
			loader.addEventListener(Event.COMPLETE, getPointTotalComplete, false, 0, true);
		}
		
		private function getPointTotalComplete(e:Event):void
		{
			var loader:URLLoader = URLLoader(e.target);	
			var r:Number = parseInt(soapy.parseReply(loader.data));
			totalPoints = r; //don't add curScore - it's already added by the service
			
			
			addInstructions(3); //regular results
		}
		
		//SOAPY END
		
		
		
		
		/**
		 * Adds commas to a number for the score
		 * ie 11592 becomes 11,592
		 * 
		 * @param	theNumber
		 * @return  A string with commas separating the digits
		 */
		private function numberFormatter(theNumber:Number):String
		{
			var n:String = String(theNumber);			
			
			var ar:Array = new Array();			
			var l:uint = n.length;
			var commaMarker:uint = 0;

			for (var i:int = l - 1; i > 0; i--) {
				ar.unshift(n.charAt(i)); //unshift adds elements to the start of the array
				commaMarker++;
				if(commaMarker % 3 == 0){
					ar.unshift(",");
				}
			}
			ar.unshift(n.charAt(0));

			return ar.join("");
		}
		
		
		
		/**
		 * Doubleclick.net floodlight tracking code
		 */
		private function floodLight(theCat:String = null):void
		{					
			var rand:String = Math.floor(Math.random() * 100000000) + "?";
			
			var flood_url:String = "https://fls.doubleclick.net/activityi;src=1608225;type=axesk292;cat=" + theCat + ";ord=1";
			
			var tag_url:String = flood_url + rand;
			
			var dclk_flood = "f=function(){if(document.getElementById(\"DCLK_FLDiv\")){var flDiv=document.getElementById(\"DCLK_FLDiv\");}";
			dclk_flood += "else{var flDiv=document.body.appendChild(document.createElement(\"div\"));";
			dclk_flood += "void(flDiv.id=\"DCLK_FLDiv\");void(flDiv.style.display=\"none\");}";
			dclk_flood += "var DCLK_FLIframe=document.createElement(\"iframe\");void(DCLK_FLIframe.id=\"DCLK_FLIframe_" + Math.floor(Math.random()*10000) + "\");";
			dclk_flood += "void(DCLK_FLIframe.src=\"" + tag_url + "\");void(flDiv.appendChild(DCLK_FLIframe));}";
			
			if (ExternalInterface.available) {
				ExternalInterface.call(dclk_flood);
			} 

		}
		
	}	
	
}