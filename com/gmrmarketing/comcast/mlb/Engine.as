package com.gmrmarketing.comcast.mlb
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;
	import flash.system.fscommand;
	import flash.ui.Mouse;
	
	
	public class Engine extends MovieClip
	{
		public static const GAME_WIDTH:int = 1280;
		public static const GAME_HEIGHT:int = 800;
		
		private var batter:Batter;
		private var theMeter:Meter;
		private var scoreBoard:Scoreboard;
		private var smash:Smash;
		private var gameOver:gameOverContainer; //lib clip
		
		private var currentLevel;
		
		private var balls:Array;
		private var icons:Array;
		
		private var ballTimer:Timer;
		private var levelTimer:Timer;
		private var iconTimer:Timer;
		
		private var hits:int;
		private var misses:int;
		
		private var okToSwing:Boolean = true; //set to false when space (swing) is pressed and then back to
		//true once space is released - prevents being able to hold down the swing button
		
		private var channel:SoundChannel; //for playing background sound
		private var ahit:ballhit = new ballhit(); //hit sound
		private var crowd:crowdNoise = new crowdNoise();
		
		//started in allowPlayAgain()
		private var timeoutTimer:Timer;
		private var timeoutSwingTimer:Timer;
		
		private var ballsPerLevel:Array = new Array(0, 7, 10, 14, 19); //total of 50 balls for the game
		private var timePerLevel:int = 15; //seconds per level
		//time per level (in seconds) divided by balls per level = time between balls
		private var ballsPitchedThisLevel:int;
	
		
		
		
		public function Engine() 
		{ 	
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			balls = new Array();
			icons = new Array();
			
			scoreBoard = new Scoreboard();
			addChild(scoreBoard);
			
			batter = new Batter(this);
			addChild(batter);
			
			theMeter = new Meter();			
			addChild(theMeter);
			
			smash = new Smash(this);
			
			gameOver = new gameOverContainer();
			gameOver.x = 640;
			gameOver.y = 400; //text is center registered so it animate scales properly			
			
			ballTimer = new Timer(5000);
			ballTimer.addEventListener(TimerEvent.TIMER, pitch, false, 0, true);	
			
			iconTimer = new Timer(500);
			iconTimer.addEventListener(TimerEvent.TIMER, releaseIcon, false, 0, true);
			
			levelTimer = new Timer(1500, 1);
			levelTimer.addEventListener(TimerEvent.TIMER, nextLevel, false, 0, true);
			
			//started in allowPlayAgain()
			timeoutTimer = new Timer(30000, 1);
			timeoutTimer.addEventListener(TimerEvent.TIMER, startTimeout, false, 0, true);
			timeoutSwingTimer = new Timer(5000);
			timeoutSwingTimer.addEventListener(TimerEvent.TIMER, timeoutSwing, false, 0, true);		
			
			gameDone();	
		}
		
		
		/**
		 * Called 15 seconds after game over if nothing happens
		 * @param	e
		 */
		private function startTimeout(e:TimerEvent):void
		{			
			currentLevel = 2;
			iconTimer.reset();
			iconTimer.delay = 1200;
			iconTimer.start();
			timeoutSwingTimer.start();
		}
		
		
		private function timeoutSwing(e:TimerEvent):void
		{
			if(Math.random() < .5){
				if(!batter.isSwinging()){
					batter.swing();
				}
			}
		}
		
		
		private function nextLevel(e:TimerEvent = null):void
		{
			currentLevel++; //set to 0 in playAgain()
			
			if (currentLevel == 1) {
				hits = 0; //reset score
				misses = 0;
				showScore();
			}
			
			if(currentLevel < 5){
				theMeter.setMeterLevel(currentLevel);
				scoreBoard.showLevelText(currentLevel);				
				
				ballTimer.delay = timePerLevel / ballsPerLevel[currentLevel] * 1000;
				ballTimer.reset();
				ballTimer.start();
				ballsPitchedThisLevel = 0;
				
				if (currentLevel > 1) {
					iconTimer.delay = 2200 - 450 * currentLevel;
					iconTimer.reset();
					iconTimer.start();
				}
				
			}else {
				gameDone();				
			}
		}
		
		
		/**
		 * Shows the Game Over / Press Start text
		 * Called from constructor and next level
		 */
		private function gameDone():void
		{			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);			
			
			ballTimer.stop();
			levelTimer.stop();
			iconTimer.stop();
			
			theMeter.setMeterLevel(0);
			scoreBoard.showLevelText(0); //shows the 'press swing button to begin' text
			
			addChild(gameOver);
			gameOver.theText.text = "GAME OVER";
			gameOver.alpha = 0;			
			gameOver.scaleX = gameOver.scaleY = .25;
			TweenLite.to(gameOver, 3, { scaleX:1, scaleY:1, alpha:1, ease:Elastic.easeOut, onComplete:fadeInThanks } );
		}
		
		
		private function fadeInThanks():void
		{
			gameOver.alpha = 0;	
			gameOver.theText.text = "THANKS FOR PLAYING";					
			gameOver.scaleX = gameOver.scaleY = .25;
			TweenLite.to(gameOver, 3, { scaleX:1, scaleY:1, alpha:1, ease:Elastic.easeOut, onComplete:fadeInPressSwing } );
		}
		
		private function fadeInPressSwing():void
		{
			gameOver.alpha = 0;
			gameOver.theText.text = "PRESS A KEY TO PLAY";	
			gameOver.scaleX = gameOver.scaleY = .25;
			TweenLite.to(gameOver, 3, {  scaleX:1, scaleY:1, alpha:1, ease:Elastic.easeOut, onComplete:allowPlayAgain } );
		}
		
		
		
		private function allowPlayAgain():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, playAgain, false, 0, true);			
			timeoutTimer.start(); //starts 15 second timer that calls startTimeout() when complete
		}
		
		
		
		private function playAgain(e:KeyboardEvent):void
		{
			timeoutTimer.reset(); //stop and reset the timeout timer
			timeoutSwingTimer.reset();			
			iconTimer.reset();
			currentLevel = 0;
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, playAgain);
			removeChild(gameOver);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyReleased, false, 0, true);
			
			//clear balls and icons if any remain on screen
			for (var i:int = 0; i < balls.length; i++) {
				removeChild(balls[i]);
				balls[i].kill();
				balls[i] = null;
			}
			for (var j:int = 0; j < icons.length; j++) {
				removeChild(icons[j]);
				icons[j].kill();
				icons[j] = null;
			}
			
			balls = new Array();
			icons = new Array();
			
			//crowd noise
			channel = crowd.play();
			
			nextLevel();			
		}
		
		
		
		public function getLevel():int
		{
			return currentLevel;
		}
		
		
		
		private function releaseIcon(e:TimerEvent):void
		{
			var ic:MovieClip;
			if (Math.random() < .5) {
				ic = new IconVideo(this);
			}else {
				ic = new IconMusic(this);
			}
			if(Math.random() < .5){
				addChildAt(ic, 1);
			}else {
				addChild(ic);
			}
			icons.push(ic);
		}
		
		
		
		public function removeIcon(icon:MovieClip):void
		{
			var itemIndex:int = icons.indexOf(icon);
			if (itemIndex != -1) {
				removeChild(icons[itemIndex]);
				icons.splice(itemIndex, 1);
			}			
		}
		
		/**
		 * Called by batter when batter is swinging
		 * returns the array of balls
		 * 
		 * @return
		 */
		public function getBalls():Array
		{
			return balls;
		}
		
		
		
		/**
		 * Called from batter when a ball is hit
		 * @param	index The array index, in balls, of the hit ball
		 */
		public function ballHit(index:int):void
		{
			hits++;
			showScore();
			var theBall:Baseball = Baseball(balls[index]);
			theBall.hit();
			
			//play hit sound
			ahit.play();
			
			//add effect
			addChild(smash);
			smash.x = theBall.x;
			smash.y = theBall.y;
			smash.show();
		}
	
		
		
		private function pitch(e:TimerEvent = null):void
		{
			var nb:Baseball = new Baseball(this);
			addChild(nb);
			balls.push(nb);
			ballsPitchedThisLevel++;
			if (ballsPitchedThisLevel == ballsPerLevel[currentLevel]) {
				//nextLevel();
				levelTimer.reset();
				levelTimer.start();
				ballTimer.stop();
			}
		}
		
		
		
		private function keyPressed(e:KeyboardEvent):void
		{
			var kc:int = e.keyCode;
			//per witmer - use a to swing now...
			if (kc == 65) {
				if(!batter.isSwinging() && okToSwing){
					batter.swing();
					okToSwing = false;
				}
			}
		}
		
		
		
		private function keyReleased(e:KeyboardEvent):void
		{
			var kc:int = e.keyCode;
			if (kc == 65) {
				okToSwing = true;
			}
		}
		
		
		
		public function incrementMisses():void
		{
			misses++;
			showScore();
		}
		
		
		
		/**
		 * Called from baseball when it goes off screen right
		 * @param	e
		 */
		public function removeBall(e:Baseball):void
		{			
			var itemIndex:int = balls.indexOf(e);
			if (itemIndex != -1) {
				removeChild(balls[itemIndex]);
				balls.splice(itemIndex, 1);
			}
		}
		
	
		
		private function showScore():void
		{			
			scoreBoard.showScore(hits);
			scoreBoard.showStrikes(misses);
		}
		
	
	}
	
}