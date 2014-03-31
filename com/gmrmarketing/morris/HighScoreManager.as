/**
 * High Score Manager
 * GMR Marketing
 * 
 * Manages the shared object and the input dialog and the ten score display
 * 
 * Kleenex Achoo Game
 * 
 * Singleton
 */

package com.gmrmarketing.morris
{ 	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.SharedObject;
	import flash.events.EventDispatcher;
	import flash.utils.Timer;
	import flash.media.SoundChannel;
	
	//TweenLite is used for displaying the high score list
	import gs.TweenLite;
	import gs.easing.*
	
	
	public class HighScoreManager extends EventDispatcher
	{
		public static var instance:HighScoreManager;
		
		//input dialog and score display objects
		private var tenScores:TenScores; //ref to the score display - library clip 
		private var highScoresDialog:HighScoreDialog;
		
		private var theScores:Array; //array of score objects, with name and score properties
		private var highScores:SharedObject;
		
		//determined in checkScore() - either a positive index or -1
		private var currentScore:uint;
		private var theLevel:String;
		
		private var game:Sprite; //ref to the engine's game sprite
		
		private var removeTimer:Timer;
		
		private var channel:SoundChannel;
		
		//default scores
		private var defaultScores:Array = new Array( { name:"DWM", score:500, phone:"xxx", level:"penny" }, { name:"TIM", score:600, phone:"xxx", level:"penny" }, { name:"NIK", score:700, phone:"xxx", level:"penny" }, { name:"JAX", score:800, phone:"xxx", level:"penny" }, { name:"PPN", score:900, phone:"xxx", level:"penny" }, { name:"ARN", score:1000, phone:"xxx", level:"penny" }, { name:"LIZ", score:1100, phone:"xxx", level:"penny" }, { name:"JFK", score:1200, phone:"xxx", level:"penny" }, { name:"ABE", score:1300, phone:"xxx", level:"penny" }, { name:"ART", score:1400, phone:"xxx", level:"penny" } );
		
		//for bouncing
		private var xRatio:Number;
		private var yRatio:Number;
		
		
		public static function getInstance():HighScoreManager
		{
			if (instance == null) {
				instance = new HighScoreManager(new SingletonBlocker());
			}
			return instance;
		}

		
		
		/**
		 * "PRIVATE" CONSTRUCTOR
		 * 
		 * @param	aLogger An object of type ILogger
		 */
		public function HighScoreManager(key:SingletonBlocker) 
		{
			if (key == null) {
				throw new Error("Error: Singleton - use getInstance()");
			}
		}
		
		
		
		/**
		* Init
		* 
		* @param	gameRef Container reference
		*/
		public function init(gameRef:Sprite):void
		{
			game = gameRef;
			
			highScores = SharedObject.getLocal("usbankMorris", "/");
			
			channel = new SoundChannel();
			
			highScoresDialog = new HighScoreDialog(); //keyboard
			
			
			theScores = highScores.data.scores;			
			
			if (theScores == null) {
				trace("HS MANAGER INIT: HS was null - using defaults");
				//no score data saved in SO - use default
				theScores = defaultScores;				
			}
		}
		
		
		
		//clears the sharedObject data
		public function killSO():void
		{
			highScores.clear();
			highScores.flush();
		}
		
		
		
		public function showKeyboard(playerScore:int, playerLevel:String):void
		{
			game.addChild(highScoresDialog);
			highScoresDialog.x = 65;
			highScoresDialog.y = 280;
			highScoresDialog.initials.text = "";
			highScoresDialog.phone.text = "";
			currentScore = playerScore;
			theLevel = playerLevel;
			highScoresDialog.addEventListener("highScoreSubmitted", saveScore);
			highScoresDialog.enableScoreKeyboard();
		}
		
		
		
		/**
		 * Displays the list of high scores in the TenScores library clip
		 * 
		 * @param whichWidth The container width to center the dialog in changes if the
		 * dialog is showing in game - or in the attract loop
		 * 
		 */
		public function showHighScores(checkMouse:Boolean = true):void
		{
			//display scores
			tenScores = new TenScores(); //TenScores is a library clip only - it has no associated class
			tenScores.alpha = 0;			
			game.addChild(tenScores);
			
			if(checkMouse){
				tenScores.addEventListener(MouseEvent.CLICK, removeScores);
			}
			//set a timer to remove the scores after n seconds
			removeTimer = new Timer(30000, 1);
			removeTimer.addEventListener(TimerEvent.TIMER, removeScores);
			removeTimer.start();
			
			//ten scores
			var l = theScores.length;
			var ind = 9;
			for (var i:int = l - 1; i >= l - 10; i--) {				
				tenScores["s" + ind].inits.text = theScores[i].name;
				tenScores["s" + ind].score.text = theScores[i].score;	
				ind--;
			}			
			TweenLite.to(tenScores, 2, { alpha:1 } );			
		}
	
		
		
		/**
		 * Removes the TenScore clip score list from the game
		 * Called by clicking on the dialog
		 * 
		 * @param	e MouseEvent
		 */
		public function removeScores(e:*):void
		{
			removeTimer.stop();
			removeTimer.removeEventListener(TimerEvent.TIMER, removeScores);
			
			tenScores.removeEventListener(Event.ENTER_FRAME, bouncy);
			
			tenScores.removeEventListener(MouseEvent.CLICK, removeScores);
			if (game.contains(tenScores)) {
				game.removeChild(tenScores);
			}			
			dispatchEvent(new Event("scoresRemoved"));
		}
		
		
		/**
		 * Removes the high score keyboard
		 * Called from saveScore() and Engine.killGame()
		 */
		public function killKeyboard():void
		{
			if (highScoresDialog) {
				if (game.contains(highScoresDialog)) {
					highScoresDialog.removeEventListener("highScoreSubmitted", saveScore);
					game.removeChild(highScoresDialog);
				}
			}			
		}
		
		
		public function checkScore(playerScore:uint):int
		{			
			var le:Number = theScores.length - 1;
			
			var scoreInsert:int = 0;
			currentScore = playerScore;
			
			for (var i:Number = le; i >= 0; i--) {				
				if(playerScore > theScores[i].score){
					scoreInsert = i; //used in saveScore
					break;				
				}
			}
			if (scoreInsert == le) {
				var aSound:newHigh = new newHigh();
				channel = aSound.play();
			}
			return scoreInsert;
		}		
		
		/**
		 * Adds a high score and saves into the SO
		 * 
		 * Callback listener - called when submit is pressed in the dialog
		 * 
		 * @param Event highScoreSubmitted
		 */
		private function saveScore(e:Event):void
		{			
			killKeyboard();			
			var newScores:Array = new Array();
			
			theScores = highScores.data.scores;			
			
			if (theScores == null) {
				trace("HS was null - using defaults");
				//no score data saved in SO - use default
				theScores = defaultScores;				
			}
			var len = theScores.length;		
			
			var ins:int = checkScore(currentScore);
			
			//scoreInsert is set in checkScore				
			for(var i = 0; i <= ins; i++){
				newScores.push(theScores[i]);
			}		
			
			newScores.push({name:highScoresDialog.getInitials(), score:currentScore, phone:highScoresDialog.getPhone(), level:theLevel});
			
			for(var j = ins + 1; j < len; j++){
				newScores.push(theScores[j]);
			}		
		
			theScores = newScores;			
			highScores.data.scores = theScores;
			highScores.flush();
			
			//Dialog is gone - show the new high scores			
			showHighScores();
		}
		
		
		/**
		 * Calculates new x,y ratios for moving the dialog in bouncy()
		 */
		private function newRatio():void
		{
			xRatio = 1.5 + (Math.random() * 2);
			yRatio = 1.5 + (Math.random() * 1.5);
			if (Math.random() < .5) { xRatio *= -1; }
			if (Math.random() < .5) { yRatio *= -1; }
		}
		
		
		/**
		 * Called on EnterFrame loop to "bounce" the ten scores dialog
		 * @param	e
		 */
		private function bouncy(e:Event):void
		{
			tenScores.x += xRatio;
			tenScores.y += yRatio;
			if (tenScores.x < 0 || ((tenScores.x + tenScores.width) > Engine.FULL_WIDTH)) {
				xRatio *= -1;
			}
			if (tenScores.y < 0 || ((tenScores.y + tenScores.height) > Engine.GAME_HEIGHT + 40)) {
				yRatio *= -1;
			}
		}
		
	} 
}

class SingletonBlocker {}