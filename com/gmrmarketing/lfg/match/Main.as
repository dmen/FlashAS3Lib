/**
 * MatchGame
 * LFG
 */
package com.gmrmarketing.lfg.match
{
	//import away3d.core.stats.Logo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.display.MovieClip;	
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;	
	import soulwire.display.PaperSprite; //for two sided screens
	import com.gmrmarketing.utilities.Utility;
	import flash.filters.DropShadowFilter;
	import flash.utils.getTimer;
	import com.gmrmarketing.lfg.match.Dialog;	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;	
	import flash.utils.getDefinitionByName;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication; //for quitting
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.gmrmarketing.utilities.CSVWriter; //for reporting
	

	
	public class Main extends MovieClip
	{		
		private var gridContainer:Sprite;
		private var configData:XML;
		
		private var screenImage:Bitmap; //bezel 
		
		private var images:XMLList;
		private var imageLoaderIndex:int;
		
		private var gridBitmaps:Array; //game array created from imageBitmaps original		
		
		private var screenBack:Bitmap;//logo image on flip side of screen
		private var backBitmaps:Array; //array of screenBack - needed for paperSprite to have separate bitmaps for all sprites		
		
		private var introImage:Bitmap;
		private var introMask:Bitmap; //lib asset
		
		private var clicked:Array; //all the clicked screens		
		private var matchCount:int; //number of confirmed matches - updated in checkForMatch()
		
		private var startClip:MovieClip; //lib clip - clipStart		
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
		
		private var flipSound:Sound; //library sounds
		private var flipBackSound:Sound;
		private var warningSound:Sound;
		private var allRotateSound:Sound;
		private var completeSound:Sound;
		private var bonusSound:Sound;
		private var completeVolume:SoundTransform; //for lowering the volume
		private var chan:SoundChannel;
		
		private var totalGameTime:int; //total allowed time to complete the game - set in beginGame()
		
		private var cq:CornerQuit;
		
		private var ssImage1:MovieClip; //ad images for screen saver
		private var ssImage2:MovieClip;
		private var timeoutHelper:TimeoutHelper;
		
		private var csvWriter:CSVWriter; //for reporting
		
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();

			dialog = new Dialog();
			
			ssImage1 = new ad1();
			ssImage2 = new ad2();
			
			csvWriter = new CSVWriter();
			csvWriter.setFileName("LFG_matchData.csv"); //file will be on the desktop
			
			cq = new CornerQuit();
			cq.init(this, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			timeoutHelper = TimeoutHelper.getInstance();
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, doReset, false, 0, true);
			timeoutHelper.init(90000);	
			
			gridContainer = new Sprite();
			
			shadowFilter = new DropShadowFilter(0, 0, 0, 1, 6, 6, 1, 2);
			
			startClip = new clipStart();//instructions with start button	
			
			timerClip = new clipTimer(); //lib clip
			timerClip.x = 783;
			timerClip.y = 1100;
			timerClip.filters = [shadowFilter];
			
			gameTimer = new Timer(100);			
			gameTimer.addEventListener(TimerEvent.TIMER, updateGameTimer, false, 0, true);
			
			introTimer = new Timer(1000);
			introTimer.addEventListener(TimerEvent.TIMER, updateIntroTimer, false, 0, true);
			
			flipTime = .5;
			
			/*
			flipSound = new soundRotate(); //lib sounds
			flipBackSound = new soundRotateBack();
			warningSound = new soundWarning();
			allRotateSound = new soundAllRotate();
			completeSound = new soundComplete();
			bonusSound = new soundBonus();
			completeVolume = new SoundTransform(.4);
			*/
			
			reporting("APPLICATION STARTED");
			
			createImageBitmapArray();
			dialog.hide();
			createGrid();
			beginGame();
		}
		
		
		/**
		 * Populates the imageBitmaps array with the game images from the library
		 */
		private function createImageBitmapArray():void
		{
			var a:Array = new Array();
			
			for( var i:int = 1; i < 7; i++ ){
				var classRef:Class = getDefinitionByName( "c" + i ) as Class;
				var clip:Bitmap = new Bitmap(BitmapData(new classRef()));
				var clip2:Bitmap = new Bitmap(BitmapData(new classRef()));
				
				//flip image on x and y
				var b:BitmapData = new BitmapData(300, 250, true, 0x00000000);
				var c:BitmapData = new BitmapData(300, 250, true, 0x00000000);
				
				var m:Matrix = new Matrix( -1, 0, 0, -1, 300, 250);
				
				b.draw(clip, m);
				c.draw(clip2, m);
				
				var d:Bitmap = new Bitmap(b);			
				d.smoothing = true;
				
				var e:Bitmap = new Bitmap(b);			
				e.smoothing = true;
				
				a.push([d, i - 1],[e, i - 1]);
			}
			
			gridBitmaps = Utility.randomizeArray(a);			
			
			//create backBitmaps
			backBitmaps = new Array();
			for (var j:int = 0; j < 12; j++) {
				backBitmaps.push(new Bitmap(new back()));
			}
		}
		
			
		
		/**
		 * Creates the container clips to hold the images
		 * adds clips to gridContainer
		 */
		private function createGrid():void
		{			
			for (var i:int = 0; i < 12; i++) {
							
				var s:MovieClip = new MovieClip();								
				var loc:Array = Utility.gridLoc(i + 1, 4);
				
				s.x = 450 + (340 * ( loc[0] - 1));
				s.y = 240 + (285 * ( loc[1] - 1));
				
				gridContainer.addChild(s);//the movieClip container				
			}			
					
			addChild(gridContainer);
		}
		
		
		/**
		 * Resets the grid and shows the start game button
		 * Called from flipImageLoaded the first time and
		 * then by timer from playAgain()
		 */
		private function beginGame(e:TimerEvent = null):void
		{			
			gridBitmaps = Utility.randomizeArray(gridBitmaps);
			
			fillGrid();
			clicked = new Array();			
			matchCount = 0;			
			totalGameTime = 20;
			
			timeoutHelper.startMonitoring();
			
			TweenMax.to(timerClip, .5, { y:1100 } );//make sure timer is off screen
			
			TweenMax.to(startClip, 1, { alpha:1 } );
			
			startClip.alpha = 0;			
			addChild(startClip);
			cq.moveToTop();
			startClip.btnStart.addEventListener(MouseEvent.CLICK, startGame, false, 0, true);
		}
		
		
		/**
		 * Puts the paper sprites into the clips created by createGrid()
		 * called from beginGame()
		 */
		private function fillGrid():void
		{
			for (var i:int = 0; i < 12; i++) {
				
				var m:MovieClip = MovieClip(gridContainer.getChildAt(i));//clip containing the screen bitmap				
				
				//remove the old paperSprite clip
				while (m.numChildren > 0) {
					m.removeChildAt(0); 
				}
				
				//create paperSprite
				var p:PaperSprite = new PaperSprite(backBitmaps[i], gridBitmaps[i][0]);
				m.imageIndex = gridBitmaps[i][1];
				m.addChild(p);
				p.name = "screen";
				p.x -= 1;
				p.y -= 1;	
				p.filters = [shadowFilter];
				
				//causes paperSprites to refresh and show the proper side
				TweenMax.to(p, .01, { rotationX:.01 } );
			}
		}
		
		/**
		 * Called by pressing start button
		 * removes start - adds timerClip - starts introTimer
		 * @param	e CLICK
		 */
		private function startGame(e:MouseEvent):void
		{			
			timeoutHelper.buttonClicked();
			reporting("GAME STARTED");
			
			TweenMax.to(startClip, .3, { alpha:0, onComplete:killStart } );			
			startClip.btnStart.removeEventListener(MouseEvent.CLICK, startGame);			
			
			timerClip.theTime.text = "5.00";						
			
			addChild(timerClip);
			introPeriod = 5;
			introTimer.start();
			showAllScreens();
			
			TweenMax.to(timerClip, .75, { y:975, ease:Back.easeOut, delay:.75 } );
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
					//warningSound.play();
				}
			}
		}
		
		
		/**
		 * Called by timer every 100ms
		 * @param	e
		 */
		private function updateGameTimer(e:TimerEvent):void
		{
			elap = totalGameTime - ((getTimer() - startTime) * .001);
			
			elapMs = String(elap);
			
			var i:int = elapMs.indexOf(".");
			if(i == -1){
				elapMs = elapMs + ".00";
			}else {
				elapMs = elapMs.substring(0, i + 3);
			}
			
			//make sure there's always two numerals after the decimal 
			if(elap < 10){
				while (elapMs.length < 4) {
					elapMs += "0";
				}
			}else {
				while (elapMs.length < 5) {
					elapMs += "0";
				}
			}
			
			timerClip.theTime.text = elapMs;
			
			if (elap <= 0) {
				timerClip.theTime.text = "0.00";
				gameOver(false);
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
			timeoutHelper.buttonClicked();
			
			var m:MovieClip = MovieClip(e.currentTarget);
			//if the same tile isn't clicked twice
			if (clicked.indexOf(m) == -1) {
				//flipSound.play();
				clicked.push(m);
				if(clicked.length % 2 == 0){
					TweenMax.to(m.getChildByName("screen"), flipTime, { rotationX:180, onComplete:checkForMatch } );
				}else {
					TweenMax.to(m.getChildByName("screen"), flipTime, { rotationX:180 } );
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
				TweenMax.to(m.getChildByName("screen"), flipTime, { rotationX:180, delay:.025 * i } );
			}
			//allRotateSound.play();
		}
		
		private function hideAllScreens():void
		{			
			var m:MovieClip;
			var n:int = gridContainer.numChildren;
			for (var i:int = 0; i < n; i++) {
				m = MovieClip(gridContainer.getChildAt(i));
				TweenMax.to(m.getChildByName("screen"), flipTime, { rotationX:0, delay:.025 * i } );
			}
			//allRotateSound.play();
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
					if (matchCount == 6) {
						gameOver(true);
					}
				}else {
					//no match - flip em back					
					TweenMax.to(MovieClip(clicked[0]).getChildByName("screen"), flipTime, { rotationX:0, delay:.25, onStart:playFlipBackSound } );
					TweenMax.to(MovieClip(clicked[1]).getChildByName("screen"), flipTime, { rotationX:0, delay:.25 } );				
				}
				clicked.splice(0, 2);//delete the two screens from clicked
			}			
		}
		
		
		/**
		 * Called from tweenLite when the flip back tween starts
		 */
		private function playFlipBackSound():void
		{
			//flipBackSound.play();
		}
		
		
		/**
		 * Called from checkForMatch() once all 8 matches have been found
		 * Called from updateGameTimer() if time runs out
		 */
		private function gameOver(didWin:Boolean):void
		{			
			//chan = completeSound.play();
			//chan.soundTransform = completeVolume;
			
			if (didWin) {
				reporting("GAME WON");
			}else {
				reporting("GAME LOST");
			}
			
			removeGridListeners();
			gameTimer.stop();	
			
			dialog.showWin(this, timerClip.theTime.text, didWin);
			dialog.addEventListener(Dialog.PLAY_AGAIN, playAgain, false, 0, true);
			
			cq.moveToTop();
		}
		
		
		
		private function playAgain(e:Event = null):void
		{				
			dialog.hideWin();
			hideAllScreens();
			
			var a:Timer = new Timer(1000, 1);
			a.addEventListener(TimerEvent.TIMER, beginGame, false, 0, true);
			a.start();
		}
		
		
		/**
		 * Called by timeoutHelper if the timeout period expires
		 * shows screen saver
		 * @param	e
		 */
		private function doReset(e:Event):void
		{			
			reporting("GAME TIMED OUT");
			
			gameTimer.stop(); //game seconds timer
			introTimer.stop();//10sec countdown timer
			timeoutHelper.stopMonitoring();	//stop screensaver monitoring	
			showAd1();
			stage.addEventListener(MouseEvent.MOUSE_DOWN, killScreenSaver, false, 0, true);
		}		
		
		private function showAd1():void
		{
			ssImage1.alpha = 0;
			addChild(ssImage1);
			TweenMax.to(ssImage1, 2, { alpha:1, onComplete:killAd2 } );
			TweenMax.delayedCall(15, showAd2 );
		}
		
		private function showAd2():void
		{
			ssImage2.alpha = 0;
			addChild(ssImage2);
			TweenMax.to(ssImage2, 2, { alpha:1, onComplete:killAd1 } );
			TweenMax.delayedCall(15, showAd1);
		}
		
		private function killAd1():void
		{
			if (contains(ssImage1)) {
				removeChild(ssImage1);
			}
		}
		
		private function killAd2():void
		{
			if (contains(ssImage2)) {
				removeChild(ssImage2);
			}
		}
		
		private function killScreenSaver(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, killScreenSaver);
			TweenMax.killAll();
			killAd1();
			killAd2();
			
			playAgain();
		}
		
		
		private function reporting(repString:String):void
		{
			var d:Date = new Date();
			
			var dateString:String = String(d.getMonth() + 1) + "/" + String(d.getDate()) + "/" + String(d.getFullYear());
			var hours:Number = d.getHours();
			var amPm:String = "am";
			
			if (hours == 12) {
				amPm = "pm";
			}else if (hours > 12) {
				amPm = "pm";
				hours -= 12;
			}
			
			var timeString:String = String(hours) + ":" + String(d.getMinutes()) + "." + String(d.getSeconds()) + " " + amPm;
			
			csvWriter.writeLine([dateString, timeString, repString]);
		}
		
		
		/**
		 * Called by CornerQuit by tapping four times at upper left
		 * @param	e
		 */
		private function quitApplication(e:Event = null):void
		{
			reporting("APPLICATION TERMINATED");
			NativeApplication.nativeApplication.exit();
		}
	}
	
}