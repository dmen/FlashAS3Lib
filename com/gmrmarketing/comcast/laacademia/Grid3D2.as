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
		
		private var util:Utility;		
		
		//12 logos - for 24 pairs - center screen stays the same - comcast logo
		private var logoNames:Array = new Array("steelers", "versus", "mlb", "nfl", "golfChannel", "nhl", "comcastsports", "nbatv", "flyers", "sixers", "redzone", "eagle");
		private var allLogos:Array = new Array();
		private var randomLogos:Array;
		
		private var allCards:Array; //all cards in the grid
		private var curCards:Array; //stores the clicked on cards
		//holds the previous 'current' cards for flipping back when no match is made
		private var prevCards:Array;
		
		private var gameIsOver:Boolean;
		
		private var numMatches:int; //total number of matches found - 12 is max
		
		private var countdownTimer:Timer; //calls updateTimer or updateInitialTimer every second
		private var gameTime:int //decremented by the countdownTimer
		private var initialTime:int; //seconds to initially view cards - set in beginGame
		
		//sound
		private var channel:SoundChannel; //for playing sounds		
		private var beep:timeBeep; //beep sound for final five seconds of play
		private var rotSound:rotate; //
		private var allRot:allTurn;
		
		private var eg:endGameDialog; //library clip
		
		
		
		public function Grid3D()
		{
			beep = new timeBeep();
			rotSound = new rotate();
			allRot = new allTurn();
			
			allCards = new Array();
			util = new Utility();//contains gridLoc function
			
			randomizeLogos();			
			
			viewport = new View3D({x:640, y:400});
			addChild(viewport);
			
			//build grid
			var loc:Array = new Array();
			var i:int;
			for (i = 1; i < 25; i++) {
				loc = util.gridLoc(i, 6);				
				var aCard:Cube = card(randomLogos[i - 1][0]);
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
		
			viewport.camera.moveTo(580,250,0);
			viewport.camera.moveBackward(1100);
			
			addEventListener(Event.ENTER_FRAME, renderScene);
		}
		
		
		/**
		 * Creates an Away3D cube
		 * 
		 * @param	backMatName String name of the material to use on the back of the card
		 * all cards get the comcast logo on front
		 * @return new cube object
		 */
		private function card(backMatName:String):Cube
		{
			frontMaterial = new BitmapMaterial(new comcast(CARD_WIDTH, CARD_HEIGHT));
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
			
			//var cubecol:ColorMaterial = new ColorMaterial(0x999999);
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
		 * Adds click listeners to all cards
		 */
		private function clickEnableCards():void
		{
			for (var i = 0; i < allCards.length; i++) {									
				this["p" + (i + 1)].holder.getChildAt(0).addEventListener(MouseEvent.CLICK, rot);
				this["p" + (i + 1)].holder.getChildAt(0).buttonMode = true;				
			}
		}
		
		
		
		/**
		 * Removes click listeners from all cards
		 */
		private function clickDisableCards():void
		{
			for (var i = 0; i < randomLogos.length; i++) {				
				this["p" + (i + 1)].holder.getChildAt(0).removeEventListener(MouseEvent.CLICK, rot);
				this["p" + (i + 1)].holder.getChildAt(0).buttonMode = false;				
			}
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
		 * Called when a card is clicked
		 * @param	e
		 */
		private function cubeClicked(e:MouseEvent3D):void
		{
			//trace(e.object.name);//traces index 1 - 24
			TweenLite.to(e.object, .5, { rotationX:"180" } );			
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
		
	}	
}