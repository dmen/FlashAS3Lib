/**
 * Game Engine
 * 
 * GMR Marketing
 * 
 * Kleenex Achoo Game
 * 
 * Uses SWFKit to activate RS232 controlled relay for the sneezing functionality 
 */

 
package com.gmrmarketing.achooweb
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.*;
	import flash.filters.ConvolutionFilter;
	import flash.system.fscommand;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.media.SoundChannel;
	import com.greensock.TweenLite;
	import com.greensock.easing.*	
	import flash.external.ExternalInterface;
	
	
	public class Engine extends Sprite
	{
		
		//------------- VARIABLES ----------------
		public static const USE_VOICE:Boolean = true;
		
		//total size: 1360 x 768 - hud width = 278
		public static const GAME_WIDTH:uint =   763;// 1081; //static constants used by other classes for positioning
		public static const GAME_HEIGHT:uint = 600;// 768;
		public static const FULL_WIDTH:uint = 980;// 1360; //full width - used for centering the high scores dialog
		//within the attract loop
		
		//Height of each frame of the Did You Know dialog - 0 for matching index to frame number
		//Used for positioning of the dialog in the InfoRoom classes
		public static const DYK_HEIGHTS:Array = new Array(0, 400, 380, 400, 380, 390, 432, 380, 432, 510, 250, 250);
		//height of each frame in the final messaging dialog - used for positioning in the FinalMessages class
		public static const FINAL_HEIGHTS:Array = new Array(0, 400, 420, 340, 340, 420, 340);
		
		private const PUMP_ON_TIME:uint = 400; //milliseconds the pump is on per sneeze		
		private const BONUS_TIME:uint = 12000; //millseconds between addition of bonus boxes
		
		private const BUGS_PER_LEVEL:uint = 35; //how many bugs released before upping the level
		
		private var player:Kleenex; //reference to the player object
		private var theHUD:HUD; //reference to the heads up display object
		private var bonus:Bonus; //reference to the bonus object
		private var question:Question; //reference to the question object
		
		private var gameFrame:GameFrame;
		private var message:Message;
		private var backGround:MovieClip;
		
		private var highScoreManager:HighScoreManager; //reference to the high scores manager object
		//private var tenScores:TenScores; //ref to the score display
		//private var highScoresDialog:HighScoreDialog;
		
		private var theLevel:uint; //current game level
			
		private var bugList:Array = new Array(); //array of bugs in the game		
		private var bonusTimer:Timer;
		private var bonusActive:Boolean = false;//true when a bonus object is active
		
		private var bugChance:Number; //flotaing point number - chance bug has of being created
		//in each loop() a random number is created - if it's less than bugChance a bug is added
		
		private var bugCount:uint; //used for upping the level, once the number of bugs released equals
		//the BUGS_PER_LEVEL the level is increased
		
		private var gets:uint; //number of gets
		private var misses:uint; //total misses		
		private var maxMisses:uint = 40; //misses before sneeze occurs - change incMisses() if this is changed
		private var score:uint; //player score
		private var questionNum:uint; //current question number - corresponds to frame in the questions library clip
		
		private var myTimer:Timer; //sneeze timer - set in sneeze()
		
		private var game:Sprite; //main game container that game elements are added to
		
		private var myContainer:DisplayObjectContainer;
		
		private var channel:SoundChannel;
		private var catchSound:SoundCatch; //bug caught sound
		
		private var finalMessages:FinalMessages;
		private var myRoom:String;
		
		//directional helper arrows at start
		private var helperArrows:DirectionArrows;		
		
		
		/**
		 * CONSTRUCTOR
		 * 
		 * Instantiated by Intro - makeEngine()
		 * 
		 * Initializes game variables and starts the game playing
		 */
		public function Engine(stageRef:DisplayObjectContainer)
		{			
			myContainer = stageRef;
						
			game = new Sprite();			
			
			bonusTimer = new Timer(BONUS_TIME, 0);
			bonusTimer.addEventListener(TimerEvent.TIMER, addBonus, false, 0, true); //started in startGame()			
			
			highScoreManager = HighScoreManager.getInstance(); //instantiate the score manager
			//highScoreManager.init(game);			
						
			theHUD = new HUD();				
			
			player = new Kleenex(game, this);
			player.center();
			
			//directional arrows
			helperArrows = new DirectionArrows();
			helperArrows.x = player.x + 20;
			helperArrows.y = player.y;			
			
			gameFrame = new GameFrame();
			gameFrame.mouseEnabled = false; //need this to allow mouse clicks to get through the frame			
			
			message = new Message();	
			
			//startGame(); //now called in killArrows
			
			channel = new SoundChannel();
			catchSound = new SoundCatch();
		}
		
		public function setRoom(theRoom:String):void
		{
			bugCount = 0; //counter for level incrementing
			misses = 0;
			gets = 0;
			score = 0;
			theLevel = 1;
			
			setLevel(theLevel);
			
			myRoom = theRoom;
			switch(myRoom) {
				case "bathroom":
					backGround = new BathRoom();
					questionNum = 1; //questions 1,2,3 for bathroom
					break;
				case "bedroom":
					backGround = new BedRoom();
					questionNum = 4; //questions 4,5,6 for bedroom
					break;
				case "classroom":
					backGround = new ClassRoom();
					questionNum = 7; //questions 7,8,9 for classroom
					break;				
			}
			myContainer.addChildAt(backGround,0);
			backGround.x = 23;// 34;
			backGround.y = 19;// 25; //position bg under frame -  34,25 for kiosk game
			
			
			game.addChild(player);
			player.center();
			
			game.addChild(helperArrows); //auto pulse per timeline anim
			helperArrows.alpha = 1;
			TweenLite.to(helperArrows, 1, { alpha:0, delay:1.5, onComplete:killArrows } );
			
			myContainer.addChildAt(game, 1);
			myContainer.addChildAt(message, 2);
			myContainer.addChildAt(gameFrame, 3);
			myContainer.addChildAt(theHUD, 4);
			
			theHUD.reset();
			theHUD.showScore(score);
			theHUD.showLevel(theLevel);
			theHUD.updateMeter(0, maxMisses);
			
		}
		/**
		 * Sets bugChance, which is checked in loop() - if
		 * Math.random() is below bugChance a bug is added
		 * 
		 * Limits the level to 18, which makes bugChance = .54
		 * ie, greater than a 50/50 chance a bug will be spawned
		 * 	
		 * @param	newLev Integer game level
		 */
		public function setLevel(newLev:uint = 1):void
		{
			newLev = Math.min(newLev, 18);
			theLevel = newLev;			
			bugChance = (theLevel + 1) * .028; //add 1 to make initial level harder
			theHUD.showLevel(theLevel);
			showMessage("Level: " + theLevel);
		}
		
	
		/**
		 * Returns the list of current bugs in the game
		 * Used by the Kleenex object for hit testing
		 * 
		 * @return bugList array
		 */
		public function getBugs():Array
		{
			return bugList
		}
		
		
		/**
		 * Displays an in-game message - removes itself
		 * 
		 * @param	msg String message to display
		 */
		public function showMessage(msg:String)
		{			
			//game.addChild(new Message(game, msg));
			message.show(msg);
		}
		
		
		/**
		 * Increments the number of successful bug catches
		 * 
		 * Called by the Kleenex (player) object through
		 * the engine reference passed to it
		 * 
		 * Sets score in HUD
		 */
		public function incGets():void
		{
			gets++;
			score += 200 * theLevel;
			theHUD.showScore(score);			
			
			channel = catchSound.play();
		}
		
		
		/**
		 * Increments the number of bug misses
		 * Called by the bugs themselves, through the
		 * engine reference passed to them during creation
		 */
		public function incMisses():void
		{
			misses++;				
			theHUD.updateMeter(misses, maxMisses);
			if (misses >= maxMisses) {
				sneeze();
			}else {
				//max misses = 40
				if (misses % 10 == 0) {
					
					//ah ahhh ahhhh sound
					switch(misses) {
						case 10:
							var s:Sneeze1 = new Sneeze1();			
							channel = s.play();
							break;
						case 20:
							var s2:Sneeze2 = new Sneeze2();			
							channel = s2.play();
							break;
						case 30:
							var s3:Sneeze3 = new Sneeze3();			
							channel = s3.play();
							break;
					}
					
					question = new Question(questionNum, myRoom);					
					question.addEventListener("questionAnsweredCorrect", questionAnsweredCorrect);
					question.addEventListener("questionAnsweredWrong", questionAnsweredWrong);
					game.addChild(question);					
					questionNum++;
					pauseGame();					
				}
			}
		}
		
		
		/**
		 * called from the Kleenex (player) whenever a bonus box is caught
		 */
		public function incBonus():void
		{
			var bon = 1000 * theLevel;
			score += bon;
			theHUD.showScore(score);
			showMessage("BONUS: " + bon);
			
			var bonusSound:SoundBonus = new SoundBonus();
			channel = bonusSound.play();
		}
		
		/**
		 * Called from the player - returns true / false depending
		 * if the bonus is on screen or not
		 * 
		 * @return Boolean - true if bonus is on screen
		 */
		public function isBonusActive():Boolean
		{
			return bonusActive;
		}
		
		
		/**
		 * Called from the player - returns a ref to the bonus clip
		 * @return Reference to the bonus clip
		 */
		public function getBonus():Bonus
		{
			return bonus;
		}
		
		
		/**
		 * Called from sneeze() when the game is over
		 * or from Intro if the attract loop starts
		 * 
		 * Removes listeners from game elements and then removes
		 * elements from the game sprite
		 */
		public function clearGame():void
		{
			pauseGame(); //removes enterFrame listeners from all active objects
			
			TweenLite.killTweensOf(helperArrows);
			TweenLite.killTweensOf(question);
			if(game.contains(helperArrows)){game.removeChild(helperArrows)};
			
			player.removeSelf();
			
			//kill bugs and reset array
			while (bugList.length > 0) {
				var aBug = bugList.shift();
				aBug.removeEventListener(Event.REMOVED_FROM_STAGE, removeBug);
				aBug.removeSelf();
			}			
			
			bonusTimer.stop();
			bonusTimer.removeEventListener(TimerEvent.TIMER, addBonus);
			if (isBonusActive()) {
				bonus.removeSelf();				
			}
			
			if (finalMessages) {
				if (game.contains(finalMessages)) {
					finalMessages.removeSelf();
				}
			}
		}
		
		
		/**
		 * Completely removes game elements and game sprite
		 */
		public function killGame():void
		{			
			
			if (myContainer.contains(game)) {
				if (question) {
					if (game.contains(question)) {
						question.removeListeners();
						game.removeChild(question);
					}
				}
				clearGame();				
				myContainer.removeChild(backGround);
				myContainer.removeChild(game);
				myContainer.removeChild(gameFrame);
				theHUD.kill();//removes enterFrame loop from the hud that moves the bug's eyes
				myContainer.removeChild(theHUD);
				myContainer.removeChild(message);
			}
			highScoreManager.killInputDialog();
			highScoreManager.removeEventListener("scoresRemoved", killGame);			
		}
		
		
		/**
		 * Returns the game sprite
		 * 
		 * @return Sprite - game reference
		 */
		public function getGame():Sprite
		{
			return game;
		}
		
		
		
		
		// ------------- PRIVATE ---------------
		
		
		/**
		 * Event callback from answering a question
		 * @param	e Event - questionAnswered
		 */
		private function questionAnsweredCorrect(e:Event):void
		{
			showMessage("CORRECT!");
			
			var corr:VO_Correct = new VO_Correct();
			channel = corr.play();
			
			incBonus();
			question.removeEventListener("questionAnsweredCorrect", questionAnsweredCorrect);
			question.removeEventListener("questionAnsweredWrong", questionAnsweredWrong);
			
			TweenLite.to(question, 1, { alpha:0, onComplete:remQuestion } );
			
			resumeGame();
		}
		
		
		private function questionAnsweredWrong(e:Event):void
		{
			showMessage("INCORRECT!");
			
			var incorr:VO_Incorrect = new VO_Incorrect();
			channel = incorr.play();
			
			showMessage("SNEEZE METER +");
			incMisses();
			question.removeEventListener("questionAnsweredCorrect", questionAnsweredCorrect);
			question.removeEventListener("questionAnsweredWrong", questionAnsweredWrong);
			
			TweenLite.to(question, 1, { alpha:0, onComplete:remQuestion } );
			
			resumeGame();
		}
	
		private function remQuestion()
		{
			game.removeChild(question);
		}
		
		/**
		 * Adds the EnterFrame listener so loop method is called
		 */
		private function listen():void
		{
			addEventListener(Event.ENTER_FRAME, loop, false, 0, true); 
		}
		
		
		/**
		 * Removes EnterFrame listener
		 */
		private function quiet():void
		{
			removeEventListener(Event.ENTER_FRAME, loop); 
		}
		
		
		/**
		 * Starts the game
		 * Called from Constructor
		 */
		private function startGame():void
		{			
			showMessage("CATCH THE BUGS!"); //show at y 300 so it doesn't overlap "Level 1"
			
			var cat:VO_CatchTheBugs = new VO_CatchTheBugs();
			channel = cat.play();
			
			player.listen();
			bonusTimer.start();
			listen();
		}
		
		
		/**
		 * Stops bonusTimer and calls quiet() on all active objects
		 * quiet() removes listener
		 */
		private function pauseGame():void 
		{
			quiet(); //removes frame listener from engine and player
			player.quiet();
			var b:Array = getBugs();
			for (var i = 0; i < b.length; i++) {
				b[i].quiet();
			}
			if (isBonusActive()) {
				bonus.quiet();				
			}
			bonusTimer.stop();
		}
		
		
		/**
		 * Starts bonusTimer and calls listen() on all active objects
		 */
		private function resumeGame():void
		{
			listen();
			player.listen();
			var b:Array = getBugs();
			for (var i = 0; i < b.length; i++) {
				b[i].listen();
			}
			if (isBonusActive()) {
				bonus.listen();				
			}
			bonusTimer.start();
		}	
		
		
		/**
		 * Called when the timer times out - adds a new bonus object
		 * 
		 * @param	e Timer Event
		 */
		private function addBonus(e:TimerEvent):void
		{			
			bonus = new Bonus(game);
			//game.addChild(bonus);
			bonusActive = true;
			bonus.addEventListener(Event.REMOVED_FROM_STAGE, removeBonus);			
		}
		

		/**
		 * Main game loop callback listener, runs on ENTER_FRAME
		 * 
		 * @param	e Event
		 */
		private function loop(e:Event) : void
		{			
			if (Math.random() < bugChance)
			{	
				var bug:Bug;
				if(Math.random() < .5){
					bug = new Bug("A");
				}else {
					bug = new Bug("B");
				}
				
				bug.init(game, this);
				
				bugList.push(bug); //add to buglist so Kleenex class can hit check against				
				
				//var b = bug.getTheBug();//gets the sprite
				bug.addEventListener(Event.REMOVED_FROM_STAGE, removeBug, false, 0, true);
				
				bugCount++;
				if (bugCount == BUGS_PER_LEVEL) {
					bugCount = 0;
					theLevel++;
					setLevel(theLevel);					
				}
			}
		}
		
		
		/**
		 * REMOVED_FROM_STAGE Callback listener from a bug, removes the bug from the bugList
		 * 
		 * @param	e Event
		 */
		private function removeBug(e:Event):void
		{			
			e.currentTarget.removeEventListener(Event.REMOVED_FROM_STAGE, removeBug);			
			bugList.splice(bugList.indexOf(e.currentTarget), 1);			
		}
		
		
		/**
		 * Called on Removed from stage event - restarts the bonus timer
		 * 
		 * @param	e Event - REMOVED_FROM_STAGE
		 */
		private function removeBonus(e:Event):void
		{
			bonusActive = false;
			bonusTimer.start();
		}
		
		
		/**
		 * Game Over
		 * Called from incMisses()
		 * turns on the sneeze relay, then turns it off after the
		 * PUMP_ON_TIME setting
		 * 
		*/
		private function sneeze():void
		{	
			pauseGame();
			
			//play final sneeze sound
			var s:Sneeze4 = new Sneeze4();			
			var channel:SoundChannel = s.play();
			
			showMessage("GAME OVER");					
			
			
			//show final mesaging
			//myRoom will be bathroom, bedroom, classroom		
			finalMessages = new FinalMessages(game, myRoom);
			finalMessages.addEventListener("finalComplete", scoreCheck);
		}
		
		/**
		 * Callback from final messaging
		 * @param	e Event
		 */
		private function scoreCheck(e:Event)
		{			
			finalMessages.removeEventListener("finalComplete", scoreCheck);
			highScoreManager.checkScore(score);
			//listen for when the high score display is removed
			highScoreManager.addEventListener("scoresRemoved", killGameFromEvent);
		}
		
		/**
		 * Called from tweenlite onComplete when fading out the helper arrows
		 * 
		 * Removes helper arrows from the game sprite and then starts the game
		 */
		private function killArrows()
		{
			startGame();
			game.removeChild(helperArrows); 
		}
		
		private function killGameFromEvent(e:Event)
		{
			killGame();
			dispatchEvent(new Event("gameEnded"));
		}		
		
	}	
}