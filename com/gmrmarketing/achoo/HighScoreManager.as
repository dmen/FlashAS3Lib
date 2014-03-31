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

package com.gmrmarketing.achoo
{ 	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.SharedObject;
	import flash.events.EventDispatcher;
	import flash.utils.Timer;
	import flash.media.SoundChannel;
	
	//TweenLite is used for displaying the high score list
	import com.greensock.TweenLite;
	import com.greensock.easing.*
	
	
	public class HighScoreManager extends EventDispatcher
	{
		public static var instance:HighScoreManager;
		
		//input dialog and score display objects
		private var tenScores:TenScores; //ref to the score display - library clip only
		private var highScoresDialog:HighScoreDialog;
		
		private var theScores:Array; //array of score objects, with name and score properties
		private var highScores:SharedObject;
		private var scoreInsert:int;	//position in the score list where to insert the new player score
		//determined in checkScore() - either a positive index or -1
		private var currentScore:uint;
		
		private var game:Sprite; //ref to the engine's game sprite
		
		private var removeTimer:Timer;
		
		private var channel:SoundChannel;
		
		//default scores
		private var defaultScores:Array = new Array( { name:"DWM", score:500 }, { name:"TIM", score:600 }, { name:"NIK", score:700 }, { name:"JAX", score:800 }, { name:"PPN", score:900 }, { name:"ARN", score:1000 }, { name:"LIZ", score:1100 }, { name:"JFK", score:1200 }, { name:"ABE", score:1300 }, { name:"ART", score:1400 } );
		
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
			
			highScores = SharedObject.getLocal("kleenexSneeze");
			
			//killSO(); //TESTING - clears the scores and uses defaults
			
			theScores = highScores.data.scores;			
			
			if (theScores == null) {
				trace("HS was null - using defaults");
				//no score data saved in SO - use default
				theScores = defaultScores;				
			}
			
			channel = new SoundChannel();
		}
		
		
		
		//clears the sharedObject data
		public function killSO():void
		{
			highScores.clear();
			highScores.flush();
		}
		
		
		
		/**
		 * Called from Engine.sneeze() when the game is over
		 * Checks if the submitted score is a high score
		 * 
		 * @param	playerScore
		 */
		public function checkScore(playerScore:uint):void
		{			
			var le:Number = theScores.length - 1;
			
			scoreInsert = -1;
			currentScore = playerScore;
			
			for (var i:Number = le; i >= 0; i--) {				
				if(playerScore > theScores[i].score){
					//player got on the board
					highScoresDialog = new HighScoreDialog();
					game.addChild(highScoresDialog);					
					highScoresDialog.addEventListener("highScoreSubmitted", saveScore);
					highScoresDialog.show();
					
					var congrats:VO_Congrats = new VO_Congrats();
					channel = congrats.play();
					
					scoreInsert = i; //used in saveScore
					break;				
				}
			}
			if (scoreInsert == -1) {
				//no high score
				showHighScores(Engine.GAME_WIDTH);	
			}
		}		
		
		
		/**
		 * Displays the list of high scores in the TenScores library clip
		 * 
		 * @param whichWidth The container width to center the dialog in changes if the
		 * dialog is showing in game - or in the attract loop
		 * 
		 */
		public function showHighScores(whichWidth:uint):void
		{
			//display scores
			tenScores = new TenScores(); //TenScores is a library clip only - it has no associated class
			tenScores.alpha = 0;
			game.addChild(tenScores);
			tenScores.x = (whichWidth / 2) - (tenScores.width / 2); //132;
			tenScores.y = 40;
			
			tenScores.addEventListener(MouseEvent.CLICK, removeScores);
			//set a timer to remove the scores after n seconds
			removeTimer = new Timer(20000, 1);
			removeTimer.addEventListener(TimerEvent.TIMER, removeScores);
			removeTimer.start();
			
			//bounce if the scores is in the attract loop portion - ie full screen
			if(whichWidth == Engine.FULL_WIDTH){
				tenScores.addEventListener(Event.ENTER_FRAME, bouncy);
				newRatio();
			}
			
			//ten scores
			for (var i:int = theScores.length - 1; i >= 0; i--) {				
				tenScores["s" + i].inits.text = theScores[i].name;
				tenScores["s" + i].score.text = theScores[i].score;					
			}
			
			TweenLite.to(tenScores, 2, { alpha:1 } );			
		}
	
		
		
		/**
		 * Removes the score list from the game
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
			
			//calls killGameFromEvent in Engine
			dispatchEvent(new Event("scoresRemoved"));
		}
		
		
		/**
		 * Removes the high score initials dialog
		 * Called from saveScore() and Engine.killGame()
		 */
		public function killInputDialog():void
		{
			if (highScoresDialog) {
				if (game.contains(highScoresDialog)) {
					highScoresDialog.removeEventListener("highScoreSubmitted", saveScore);
					game.removeChild(highScoresDialog);
				}
			}
			
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
			
			killInputDialog();
			
			var newScores:Array = new Array();
			
			var len = theScores.length;			
			
			//scoreInsert is set in checkScore
			//start at 1 - because we always drop the low score at index 0			
			for(var i = 1; i <= scoreInsert; i++){
				newScores.push(theScores[i]);
			}		
			
			newScores.push({name:highScoresDialog.getInitials(), score:currentScore});
			
			for(var j = scoreInsert + 1; j < len; j++){
				newScores.push(theScores[j]);
			}		
		
			theScores = newScores;			
			highScores.data.scores = theScores;
			highScores.flush();
			
			//Dialog is gone - show the new high scores
			
			showHighScores(Engine.GAME_WIDTH);
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