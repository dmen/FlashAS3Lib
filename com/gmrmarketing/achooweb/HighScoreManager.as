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

package com.gmrmarketing.achooweb
{ 	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;	
	import flash.net.URLVariables;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.media.SoundChannel;
	import com.greensock.TweenLite;		
	
	public class HighScoreManager extends EventDispatcher
	{
		public static var instance:HighScoreManager;
		
		//input dialog and score display objects
		private var tenScores:TenScores; //ref to the score display - library clip only
		private var highScoresDialog:HighScoreDialog;
		
		private var theScores:Array; //array of score objects, with name and score properties
	
		private var scoreInsert:int;	//position in the score list where to insert the new player score
		//determined in checkScore() - either an index or -1
		private var currentScore:uint;
		
		private var game:Sprite; //ref to the engine's game sprite
		
		private var removeTimer:Timer;
		
		private var channel:SoundChannel;
		
		private var loader:URLLoader;
		private var saver:URLLoader;
		private var req:URLRequest;
		
		private var globals:MyGlobals;
				
		//default scores used if no xml file is loaded
		private var defaultScores:XML = 
							<scores>
								<score name="GMR" points="50000"/>
								<score name="ARN" points="48900"/>
								<score name="TIM" points="40000"/>
								<score name="NCK" points="38900"/>
								<score name="PTE" points="30000"/>
								<score name="BRY" points="28900"/>
								<score name="JAX" points="20000"/>
								<score name="BET" points="18900"/>
								<score name="DWM" points="10000"/>
								<score name="GMR" points="5900"/>
							</scores>;
		
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
			globals = MyGlobals.getInstance();
		}
	
		/**
		* Init
		* 
		* @param	gameRef Container reference	
		*/
		public function init(gameRef:Sprite):void
		{
			game = gameRef;
			channel = new SoundChannel();
			
			var xmlURL = globals.getXMLURL();
			//if(xmlURL != undefined && xmlURL != null && xmlURL != ""){
				loader = new URLLoader();
				req = new URLRequest(xmlURL);
				loader.addEventListener(Event.COMPLETE, scoresLoaded);
				loader.addEventListener(IOErrorEvent.IO_ERROR, scoresLoadError);	
				loader.load(req);
			//}
		}
	
		
		/**
		 * Called from Engine.sneeze() when the game is over
		 * Checks if the submitted score is a high score
		 * 
		 * @param	playerScore
		 */
		public function checkScore(playerScore:uint):void
		{	
			scoreInsert = -1;
			currentScore = playerScore;
			
			for (var i:uint = 0; i < theScores.length; i++ ) {				
				if (playerScore > theScores[i].score) {
					scoreInsert = i; //used in saveScore
					
					//player got on the board
					highScoresDialog = new HighScoreDialog();
					game.addChild(highScoresDialog);					
					highScoresDialog.addEventListener("highScoreSubmitted", saveScore);
					highScoresDialog.show();
					
					var congrats:VO_Congrats = new VO_Congrats();
					channel = congrats.play();
					break;				
				}
			}
			if (scoreInsert == -1) {
				//no high score
				showHighScores();	
			}
		}		
		
		
		/**
		 * Displays the list of high scores in the TenScores library clip
		 * 
		 * @param whichWidth The container width to center the dialog in changes if the
		 * dialog is showing in game - or in the attract loop
		 * 
		 */
		public function showHighScores():void
		{
			//display scores
			tenScores = new TenScores(); //TenScores is a library clip only - it has no associated class
			tenScores.alpha = 0;
			game.addChild(tenScores);
			tenScores.x = (Engine.GAME_WIDTH / 2) - (tenScores.width / 2); //132;
			tenScores.y = 40;
			
			tenScores.addEventListener(MouseEvent.CLICK, removeScores);
			//set a timer to remove the scores after n seconds
			removeTimer = new Timer(20000, 1);
			removeTimer.addEventListener(TimerEvent.TIMER, removeScores);
			removeTimer.start();		
			
			//ten scores
			for (var i:int = 0; i < theScores.length; i++ ) {				
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
		
		
		//------------------ PRIVATE ------------------
			
		/**
		 * Callback from loading high scores from server
		 * 
		 * @param	e Event
		 */
		private function scoresLoaded(e:Event):void
		{
			loader.removeEventListener(IOErrorEvent.IO_ERROR, scoresLoadError);	
			loader.removeEventListener(Event.COMPLETE, scoresLoaded);
			
			parseScores(new XML(e.target.data));			
		}
		
		
		/**
		 * Callback from an error loading high scores from server
		 * @param	e IO error event
		 */
		private function scoresLoadError(e:IOErrorEvent):void
		{
			loader.removeEventListener(IOErrorEvent.IO_ERROR, scoresLoadError);	
			loader.removeEventListener(Event.COMPLETE, scoresLoaded);
			
			parseScores(defaultScores);			
		}
		
		
		/**
		 * Parses the xml into an array of obejcts: theScores
		 * @param	xmlScores
		 */
		private function parseScores(xmlScores:XML):void
		{
			theScores = new Array();
			var l = xmlScores.score.length();
			for (var i = 0; i < l; i++) {
				var oneScore = { name:xmlScores.score.@name[i], score:parseInt(xmlScores.score.@points[i]) };				
				theScores.push( oneScore );
			}
		}
		
		
		/**
		 * Adds a high score and saves to the server
		 * 
		 * Callback listener - called when submit is pressed in the dialog
		 * 
		 * scoreInsert is set in checkScore()
		 * 
		 * @param Event highScoreSubmitted
		 */
		private function saveScore(e:Event):void
		{			
			killInputDialog();
			
			var newScores:Array = new Array();
			
			var len = theScores.length;		
			
			//add scores before the new score
			for(var i = 0; i < scoreInsert; i++){
				newScores.push(theScores[i]);
			}		
			
			newScores.push( { name:highScoresDialog.getInitials(), score:currentScore } );			
			submitToServer(highScoresDialog.getInitials(), currentScore);
			
			for(var j = scoreInsert; j < len - 1; j++){
				newScores.push(theScores[j]);
			}		
		
			theScores = newScores;			
			
			//Dialog is gone - show the new high scores
			
			showHighScores();
		}
		
		/**
		 * Called from saveScore() to submit high score to server
		 * @param	inits
		 * @param	score
		 */
		private function submitToServer(inits:String, score:uint)
		{
			var variables:URLVariables = new URLVariables(); 
			variables.name = inits;
			variables.score = String(score);
			
			var request:URLRequest = new URLRequest("savescore.aspx"); 
			request.data = variables;  
			request.method = URLRequestMethod.POST;  
			
			saver = new URLLoader();  
			saver.dataFormat = URLLoaderDataFormat.VARIABLES;  
			
			saver.addEventListener(Event.COMPLETE, doNothing);  
			saver.addEventListener(IOErrorEvent.IO_ERROR, doNothing);  
			saver.load(request); 
		}
		
		/**
		 * do nothing callback from submitting high score to server
		 * @param	e Event
		 */
		private function doNothing(e:*)
		{
			saver.removeEventListener(Event.COMPLETE, doNothing);  
			saver.removeEventListener(IOErrorEvent.IO_ERROR, doNothing);  
			
		}
	} 
}
class SingletonBlocker {}