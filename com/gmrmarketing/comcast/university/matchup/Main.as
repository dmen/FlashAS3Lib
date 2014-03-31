/**
 * Comcast University
 * Matchup
 */
package com.gmrmarketing.comcast.university.matchup
{
	import away3d.core.stats.Logo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.display.MovieClip;	
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import flash.utils.Timer;	
	import soulwire.display.PaperSprite; //for two sided screens
	import com.gmrmarketing.utilities.Utility;
	import flash.filters.DropShadowFilter;
	import flash.utils.getTimer;
	import com.gmrmarketing.comcast.university.matchup.Dialog;
	import com.gmrmarketing.comcast.university.matchup.Bonus;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.external.ExternalInterface;
	import flash.display.LoaderInfo;
	
	
	public class Main extends MovieClip
	{
		private var screenGrid:Array;
		private var bgContainer:Sprite;
		private var gridContainer:Sprite;
		private var configData:XML;
		
		private var screenImage:Bitmap; //bezel 
		
		private var images:XMLList;
		private var imageLoaderIndex:int;
		private var imageBitmaps:Array;//the on screen flip images - original array
		private var gridBitmaps:Array; //game array created from imageBitmaps original		
		
		private var screenBack:Bitmap;//logo image on flip side of screen
		private var backBitmaps:Array; //array of screenBack - needed for paperSprite to have separate bitmaps for all sprites
		
		private var introContainer:Sprite; //container for introImage and introMask
		private var introImage:Bitmap;
		private var introMask:Bitmap; //lib asset
		
		private var clicked:Array; //all the clicked screens		
		private var matchCount:int; //number of confirmed matches - updated in checkForMatch()
		
		private var startClip:MovieClip; //lib clip - clipStart
		private var bottomText:MovieClip; //two lines of text at bottom of screen - set in the data.xml
		private var btnPlayAgain:MovieClip;//lib clip
		private var shadowFilter:DropShadowFilter;
		private var timerClip:MovieClip; //lib clip
		private var gameTimer:Timer; //for conting while the game is being played
		private var introTimer:Timer; //for counting down from 10sec during the intro period
		private var introPeriod:int; //10 second intro period - set in startGame()
		private var startTime:int;
		
		private var flipTime:Number; //sreen rotation time
		
		private var dialog:Dialog;
		
		private var elap:Number; //used in updateGameTimer()
		private var elapMs:String;//for converting to displayed time
		private var points:int;//players points - set to 6000 in beginGame()
		
		private var flipSound:Sound; //library sounds
		private var flipBackSound:Sound;
		private var warningSound:Sound;
		private var allRotateSound:Sound;
		private var completeSound:Sound;
		private var bonusSound:Sound;
		private var completeVolume:SoundTransform; //for lowering the volume
		private var chan:SoundChannel;
		
		private var matchChain:int; //counts number of successive matches - for awarding a bonus
		private var bonusClip:Bonus;
		
		private var configXML:String = loaderInfo.parameters.config;
		
		
		
		public function Main()
		{
			//x,y,rotationY,zAdjust
			//screenGrid = new Array([84, 48, -30, -30], [84, 152, -30, -30], [84, 256, -30, -30], [84, 360, -30, -30],[241, 54, -8, 0], [241, 155, -8, 0], [241, 255, -8, 0], [241, 355, -8, 0],[403, 54, 8, 0], [403, 155, 8, 0], [403, 255, 8, 0], [403, 355, 8, 0],[560, 48, 30, -30], [560, 152, 30, -30], [560, 256, 30, -30], [560, 360, 30, -30]);									
			screenGrid = new Array([84, 48, -30, -30], [84, 152, -30, -30], [241, 54, -8, 0],[84, 256, -30, -30],[241, 155, -8, 0],[403, 54, 8, 0],[84, 360, -30, -30],[241, 255, -8, 0],[403, 155, 8, 0],[560, 48, 30, -30],[241, 355, -8, 0],[403, 255, 8, 0],[560, 152, 30, -30], [403, 355, 8, 0],[560, 256, 30, -30],[560, 360, 30, -30]);
			
			dialog = new Dialog();
			bgContainer = new Sprite();
			gridContainer = new Sprite();
			gridContainer.x = 65;
			gridContainer.y = 30;
			
			introContainer = new Sprite();
			introContainer.x = 391;
			introContainer.y = 267; //screen center so introImage can rotate about center
			
			shadowFilter = new DropShadowFilter(0, 0, 0, 1, 6, 6, 1, 2);
			
			startClip = new clipStart();//instructions with start button				
			bottomText = new clipBottomText();
			
			btnPlayAgain = new buttonPlayAgain();
			btnPlayAgain.x = 293;
			btnPlayAgain.y = 200;			
			btnPlayAgain.filters = [shadowFilter];
			
			timerClip = new clipTimer(); //lib clip
			timerClip.x = 170;//was 150 - set to 170 for HBO Girls
			timerClip.y = 600;
			timerClip.filters = [shadowFilter];
			
			gameTimer = new Timer(100);			
			gameTimer.addEventListener(TimerEvent.TIMER, updateGameTimer, false, 0, true);
			
			introTimer = new Timer(1000);
			introTimer.addEventListener(TimerEvent.TIMER, updateIntroTimer, false, 0, true);
			
			introMask = new Bitmap(new theMask());
			
			flipTime = .5;
			
			flipSound = new soundRotate(); //lib sounds
			flipBackSound = new soundRotateBack();
			warningSound = new soundWarning();
			allRotateSound = new soundAllRotate();
			completeSound = new soundComplete();
			bonusSound = new soundBonus();
			completeVolume = new SoundTransform(.4);
			
			bonusClip = new Bonus();
			
			if(ExternalInterface.available){
				ExternalInterface.addCallback("FBPostSucceeded", FBPostGood);
				ExternalInterface.addCallback("FBPostFailed", FBPostFail);
				ExternalInterface.addCallback("leaderPosted", leaderPost);
			}
			
			loadXML();
		}
		
		
		private function loadXML():void
		{
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			dialog.show(this, "loading xml");
			try {				
				//urlLoader.load(new URLRequest("../../flash/" + configXML)); //for facebook
				urlLoader.load(new URLRequest("data_girls.xml")); //for testing
			}catch (e:Error) {
				
			}
		}
		
		
		private function xmlLoaded(e:Event):void
		{
			configData = new XML(e.target.data);			
			loadBackground();
		}
		
		
		private function loadBackground():void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bgImageLoaded, false, 0, true);
			dialog.show(this, "loading background");
			try{
				loader.load(new URLRequest(configData.background));
			}catch (e:Error) {
				
			}
		}
		
		
		private function bgImageLoaded(e:Event):void
		{
			var b:Bitmap = Bitmap(e.target.content);
			b.smoothing = true;
			bgContainer.addChild(b);
			loadIntroImage();			
		}
		
		
		private function loadIntroImage():void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, introImageLoaded, false, 0, true);
			dialog.show(this, "loading intro");
			try{
				loader.load(new URLRequest(configData.introImage));
			}catch (e:Error) {
				
			}
		}
		
		
		private function introImageLoaded(e:Event):void
		{
			introImage = Bitmap(e.target.content);
			introImage.smoothing = true;
			//trace("introImageLoaded", introImage);
			loadScreenImage();
		}
		
		
		/**
		 * Load the background grid tv screen image - aka the bezel image
		 */
		private function loadScreenImage():void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, screenImageLoaded, false, 0, true);
			dialog.show(this, "loading screen");
			try{
				loader.load(new URLRequest(configData.screen));
			}catch (e:Error) {
				
			}
		}
		
		
		private function screenImageLoaded(e:Event):void
		{
			screenImage = Bitmap(e.target.content);
			screenImage.smoothing = true;						
			loadScreenBack();
		}
		
		
		/**
		 * loads the logo image that appears on the back side of all the tv flip images
		 */
		private function loadScreenBack():void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, screenBackImageLoaded, false, 0, true);
			dialog.show(this, "loading tile");
			try{
				loader.load(new URLRequest(configData.screenBack));
			}catch (e:Error) {
				
			}
		}
		
		
		private function screenBackImageLoaded(e:Event):void
		{		
			screenBack = Bitmap(e.target.content);
			screenBack.smoothing = true;
			backBitmaps = new Array();
			for (var i:int = 0; i < screenGrid.length; i++){
				var dup:Bitmap = new Bitmap(screenBack.bitmapData);
				backBitmaps.push(dup);
			}
			loadFlipImages();
		}
		
		
		/**
		 * Creates the original imageBitmaps array by loading the images from the xml
		 */
		private function loadFlipImages():void
		{			
			images = configData.images.image;
			imageLoaderIndex = 0;
			imageBitmaps = new Array();
			
			loadNextFlipImage();
		}
		
		
		private function loadNextFlipImage():void
		{
			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, flipImageLoaded, false, 0, true);
			l.load(new URLRequest(images[imageLoaderIndex]));
			dialog.show(this, "loading game image " + String(imageLoaderIndex));
		}
		
		
		private function flipImageLoaded(e:Event):void
		{
			var image:Bitmap = Bitmap(e.target.content);
			var b:BitmapData = new BitmapData(image.width, image.height, false, 0);
			
			//flip image on x and y
			var m:Matrix = new Matrix( -1, 0, 0, -1, image.width, image.height);
			
			b.draw(image, m);
			var i:Bitmap = new Bitmap(b);			
			i.smoothing = true;
			
			imageBitmaps.push(i);
			
			imageLoaderIndex++;
			if (imageLoaderIndex < images.length()) {
				loadNextFlipImage();
			}else {
				dialog.hide();
				createGrid();
				beginGame();
			}
		}
		
		
		/**
		 * Resets the grid and shows the start game button
		 * Called from flipImageLoaded the fist time and
		 * then by timer from playAgain()
		 */
		private function beginGame(e:TimerEvent = null):void
		{
			randomizeFlipImages();
			fillGrid();
			clicked = new Array();			
			matchCount = 0;
			matchChain = 0;
			points = 6000;
			
			//only show intro if showIntro is true and this is the first time playing
			if(configData.showIntro == "true" && e == null){
				showIntro();
				TweenLite.to(startClip, 1, { alpha:1, delay:2 } );
			}else {
				TweenLite.to(startClip, 1, { alpha:1 } );
			}
			
			startClip.instructionsTitle.htmlText = configData.instructions.title;
			startClip.instructionsOne.htmlText = configData.instructions.lineOne;
			startClip.instructionsTwo.htmlText = configData.instructions.lineTwo;
			startClip.instructionsThree.htmlText = configData.instructions.lineThree;
			
			bottomText.lineOne.htmlText = configData.bottomText.lineOne;
			bottomText.lineTwo.htmlText = configData.bottomText.lineTwo;
			
			startClip.alpha = 0;
			addChild(bottomText);
			addChild(startClip);
			startClip.btnStart.addEventListener(MouseEvent.CLICK, startGame, false, 0, true);
		}
		
		
		/**
		 * Called by pressing start button
		 * removes start - adds timerClip - starts introTimer
		 * @param	e CLICK
		 */
		private function startGame(e:MouseEvent):void
		{
			killIntro();//kills the multi screen image intro if it's still playing
			
			TweenLite.to(startClip, .3, { alpha:0, onComplete:killStart } );			
			startClip.btnStart.removeEventListener(MouseEvent.CLICK, startGame);
			
			timerClip.numMatches.text = "0";
			timerClip.theTime.text = "10.00";
			timerClip.thePoints.text = String(points);
			
			
			addChild(timerClip);
			introPeriod = 10;
			introTimer.start();
			showAllScreens();
			
			TweenLite.to(timerClip, .75, { y:465, ease:Back.easeOut, delay:.75 } );
			
			//google analytics
			if(ExternalInterface.available){
				ExternalInterface.call("evalFromFlash", "_gaq.push(['_trackEvent', 'Engagement', 'MatchGame', 'GameStarted']);");
			}
		}
		
		private function killStart():void
		{
			removeChild(startClip);
		}
		
		/**
		 * Called once per second during the initial 10 sec preview
		 * introPeriod set to 10 in startGame()
		 * @param	e
		 */
		private function updateIntroTimer(e:TimerEvent):void
		{
			introPeriod--;
			if (introPeriod == 0) {
				introTimer.stop();
				startTime = getTimer();//begin time in ms
				hideAllScreens();
				gameTimer.start();//calls updateGameTimer()
				addGridListeners();
			}else {
				timerClip.theTime.text = String(introPeriod) + ".00";
				if (introPeriod < 4) {
					warningSound.play();
				}
			}
		}
		
		
		/**
		 * Called by timer every 100ms
		 * @param	e
		 */
		private function updateGameTimer(e:TimerEvent):void
		{
			elap = (getTimer() - startTime) * .001;		
			
			elapMs = String(elap);
			
			var i:int = elapMs.indexOf(".");
			if(i == -1){
				elapMs = elapMs + ".00";
			}else {
				elapMs = elapMs.substring(0, i + 3);
			}
			while (elapMs.length < 4) {
				elapMs += "0";
			}
			timerClip.theTime.text = elapMs;
			
			points -= Math.max(3 * (Math.round(elap * .2)), 3);
			points = points < 0 ? 0 : points;
			
			timerClip.thePoints.text = String(points);
		}
		
		
		private function showIntro():void
		{
			//introContainer at 391,267 - screen center
			//introImage.width = 680;
			//introImage.height = 450;
			introImage.x = 0 - Math.round(introImage.width * .5);
			introImage.y = 0 - Math.round(introImage.height * .5);
			
			introContainer.addChild(introImage);
			addChild(introMask);
			introMask.y = -1;			
			addChild(introContainer);
			
			introImage.cacheAsBitmap = true;
			introMask.cacheAsBitmap = true;			
			introImage.mask = introMask;
			
			TweenLite.to(introContainer, 2, { scaleX:4, scaleY:4,  x:"-50", rotation:360, ease:Linear.easeNone } );
			TweenLite.to(introContainer, 2.5, { overwrite:0, alpha:0, delay:2, onComplete:killIntro } );
		}
		
		
		/**
		 * Called from tween complete in showIntro() and startGame()
		 */
		private function killIntro():void
		{
			TweenLite.killTweensOf(introContainer);
			if(introImage){
				introImage.mask = null; 
				if(introContainer.contains(introImage)){
					introContainer.removeChild(introImage);
					removeChild(introMask);
				}
				//introImage = null;
				//introMask = null;
			}
		}
		
		
		/**
		 * Called from flipImageLoaded() once all flip images are loaded
		 * Creates the gridBitmaps array by doubling imageBitmaps 
		 */
		private function randomizeFlipImages():void
		{
			//double array
			var a:Array = new Array();
			for (var i:int = 0; i < imageBitmaps.length; i++) {
				a.push([new Bitmap(Bitmap(imageBitmaps[i]).bitmapData), i], [new Bitmap(Bitmap(imageBitmaps[i]).bitmapData),i]);				
			}
			
			gridBitmaps = Utility.randomizeArray(a);			
		}
		
		
		/**
		 * called from flipImageLoaded() once all images are loaded
		 */
		private function createGrid():void
		{			
			for (var i:int = 0; i < screenGrid.length; i++) {
				
				//make a bitmap from the loaded screen image
				var b:Bitmap = new Bitmap(screenImage.bitmapData);
				b.x = 0 - Math.round(b.width * .5);
				b.y = 0 - Math.round(b.height * .5);
			
				//put screen bitmap into a new MovieClip
				//use mc because it's dynamic and can have the image index inserted into it
				var s:MovieClip = new MovieClip();				
				s.addChild(b);
				
				/*
				//create paperSprite
				var p:PaperSprite = new PaperSprite(backBitmaps[i], gridBitmaps[i][0]);
				s.imageIndex = gridBitmaps[i][1];
				s.addChild(p);
				p.name = "screen";
				p.x -= 1;
				p.y -= 1;						
					*/
				s.x = screenGrid[i][0];
				s.y = screenGrid[i][1];
				s.rotationY = screenGrid[i][2];
				s.z += screenGrid[i][3];
			
				
				gridContainer.addChild(s);//the movieClip container				
			}
			
			addChild(bgContainer);
			//gridContainer.alpha = 0;
			
			addChild(gridContainer);			
			
			//TweenLite.to(gridContainer, .5, { alpha:1 } );
			
			//causes paperSprites to refresh and show the proper side
			//TweenLite.to(p, .01, { rotationX:.01 } );
		}
		
		
		
		/**
		 * Puts the paper sprites into the clips created by createGrid()
		 */
		private function fillGrid():void
		{
			for (var i:int = 0; i < screenGrid.length; i++) {
				
				var m:MovieClip = MovieClip(gridContainer.getChildAt(i));//clip containing the screen bitmap
				
				//trace(m.numChildren);
				//child index 0 is the screen/bezel image
				if (m.numChildren > 1) {
					m.removeChildAt(1); //remove the old paperSprite clip
				}
				//trace(m.numChildren);
				
				//create paperSprite
				var p:PaperSprite = new PaperSprite(backBitmaps[i], gridBitmaps[i][0]);
				m.imageIndex = gridBitmaps[i][1];
				m.addChild(p);
				p.name = "screen";
				p.x -= 1;
				p.y -= 1;		
				
				//causes paperSprites to refresh and show the proper side
				TweenLite.to(p, .01, { rotationX:.01 } );
			}
		}
		
		
		/**
		 * adds mouse click listeners for all screens in the grid
		 */
		private function addGridListeners():void
		{			
			var n:int = gridContainer.numChildren;
			for (var i:int = 0; i < n; i++) {
				MovieClip(gridContainer.getChildAt(i)).addEventListener(MouseEvent.CLICK, flipClicked, false, 0, true);
			}
		}
		
		
		private function removeGridListeners():void
		{			
			var n:int = gridContainer.numChildren;
			for (var i:int = 0; i < n; i++) {
				MovieClip(gridContainer.getChildAt(i)).removeEventListener(MouseEvent.CLICK, flipClicked);
			}
		}	
		
		
		/**
		 * Called whenever a screen is clicked
		 * pushes the clicked screen onto the clicked array
		 * @param	e CLICK
		 */
		private function flipClicked(e:MouseEvent):void
		{
			var m:MovieClip = MovieClip(e.currentTarget);
			//if the same tile isn't clicked twice
			if (clicked.indexOf(m) == -1) {
				flipSound.play();
				clicked.push(m);
				if(clicked.length % 2 == 0){
					TweenLite.to(m.getChildByName("screen"), flipTime, { rotationX:180, onComplete:checkForMatch } );
				}else {
					TweenLite.to(m.getChildByName("screen"), flipTime, { rotationX:180 } );
				}
			}
		}
		
		
		/**
		 * Shows all the screens for the 10 second intro period
		 */
		private function showAllScreens():void
		{			
			var m:MovieClip;
			var n:int = gridContainer.numChildren;
			for (var i:int = 0; i < n; i++) {
				m = MovieClip(gridContainer.getChildAt(i));
				TweenLite.to(m.getChildByName("screen"), flipTime, { rotationX:180, delay:.025 * i } );
			}
			allRotateSound.play();
		}
		
		private function hideAllScreens():void
		{			
			var m:MovieClip;
			var n:int = gridContainer.numChildren;
			for (var i:int = 0; i < n; i++) {
				m = MovieClip(gridContainer.getChildAt(i));
				TweenLite.to(m.getChildByName("screen"), flipTime, { rotationX:0, delay:.025 * i } );
			}
			allRotateSound.play();
		}
		
		
		/**
		 * Called from flipClicked() by TweenLite whenever the second screen is clicked
		 * 
		 */
		private function checkForMatch():void
		{			
			if(clicked.length >= 2){
				if (clicked[0].imageIndex == clicked[1].imageIndex) {
					clicked[0].removeEventListener(MouseEvent.CLICK, flipClicked);
					clicked[1].removeEventListener(MouseEvent.CLICK, flipClicked);
					matchCount++;
					timerClip.numMatches.text = String(matchCount);
					matchChain++;
					var bonus:int = 0;
					if(matchChain > 1){
						bonus = matchChain * 100;
						points += bonus;
						bonusClip.show(this, String(matchChain) + "X - BONUS " + String(bonus));
						bonusSound.play();
					}
					if (matchCount == 8) {
						gameOver();
					}
				}else {
					//no match - flip em back
					matchChain = 0;
					TweenLite.to(MovieClip(clicked[0]).getChildByName("screen"), flipTime, { rotationX:0, delay:.25, onStart:playFlipBackSound } );
					TweenLite.to(MovieClip(clicked[1]).getChildByName("screen"), flipTime, { rotationX:0, delay:.25 } );				
				}
				clicked.splice(0, 2);//delete the two screens fromc clicked
			}			
		}
		
		
		/**
		 * Called from tweenLite when the flip back tween starts
		 */
		private function playFlipBackSound():void
		{
			flipBackSound.play();
		}
		
		
		/**
		 * Called from checkForMatch() once all 8 matches have been found
		 */
		private function gameOver():void
		{		
			//google analytics
			if(ExternalInterface.available){
				ExternalInterface.call("evalFromFlash", "_gaq.push(['_trackEvent', 'Engagement', 'MatchGame', 'GameCompleted']);");
			}
			
			chan = completeSound.play();
			chan.soundTransform = completeVolume;
			
			dialog.showWin(this, timerClip.theTime.text, points);
			dialog.addEventListener(Dialog.NO_THANKS, showPlayAgain, false, 0, true);
			dialog.addEventListener(Dialog.YES_PLEASE, postToFB, false, 0, true);
			dialog.addEventListener(Dialog.LEADER, addLeader, false, 0, true);
			
			removeGridListeners();
			gameTimer.stop();
			//make sure any last match bonus points display in the point field
			timerClip.thePoints.text = String(points);
		}
		
		
		/**
		 * Called by pressing the share on FB button in the win dialog
		 * @param	e
		 */
		private function postToFB(e:Event):void
		{
			if(ExternalInterface.available){
				ExternalInterface.call("pubFeed", timerClip.theTime.text, String(points));
				dialog.show(this, "POSTING TO FACEBOOK");
				showPlayAgain();
			}else {
				//dialog.show(this, "FACEBOOK NOT AVAILABLE");
				showPlayAgain();
			}
		}
		
		
		private function addLeader(e:Event):void
		{
			if(ExternalInterface.available){
				ExternalInterface.call("leaderboard", String(points));
				//dialog.show(this, "ADDING TO LEADERBOARD");
			}
		}
		
		
		/**
		 * Callbacks on ExternalInterface
		 */
		private function FBPostGood():void
		{
			dialog.show(this, "THANK YOU FOR SHARING!");
			showPlayAgain();
		}
		
		private function FBPostFail():void
		{
			dialog.show(this, "SORRY, AN ERROR OCCURED. PLEASE TRY AGAIN");
		}
		
		private function leaderPost():void
		{
			dialog.show(this, "YOU'VE BEEN ADDED TO THE LEADER BOARD!");
			//disable button?
			dialog.disableLeader();
		}
		
		
		
		
		/**
		 * Called by pressing the 'No, tell them later' button
		 * @param	e
		 */
		private function showPlayAgain(e:Event = null):void
		{
			dialog.removeEventListener(Dialog.NO_THANKS, showPlayAgain);
			dialog.removeEventListener(Dialog.YES_PLEASE, postToFB);
			dialog.removeEventListener(Dialog.LEADER, addLeader);
			dialog.hideWin();
			dialog.hide();
			btnPlayAgain.alpha = 0;
			addChild(btnPlayAgain);
			TweenLite.to(btnPlayAgain, 1, { alpha:1 } );
			btnPlayAgain.addEventListener(MouseEvent.MOUSE_DOWN, playAgain, false, 0, true);
		}
		
		
		private function playAgain(e:MouseEvent):void
		{
			btnPlayAgain.removeEventListener(MouseEvent.MOUSE_DOWN, playAgain);
			removeChild(btnPlayAgain);			
			hideAllScreens();
			
			var a:Timer = new Timer(1000, 1);
			a.addEventListener(TimerEvent.TIMER, beginGame, false, 0, true);
			a.start();
		}
	}
	
}