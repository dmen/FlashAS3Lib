/**
 * Engine
 */

package com.gmrmarketing.morris
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.*;
	import flash.filters.ConvolutionFilter;
	import flash.system.fscommand;
	import flash.ui.ContextMenuBuiltInItems;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.media.SoundChannel;
	import gs.TweenLite;
	import gs.easing.*
	import com.gmrmarketing.kiosk.KioskHelper;
	import flash.external.ExternalInterface;
	import flash.utils.getTimer;
	
	
	public class Engine extends Sprite
	{
		public static const USE_VOICE:Boolean = true;
		
		//total size: 1280 x 800 - hud width = 270
		public static const GAME_WIDTH:uint = 1010; //static constants used by other classes for positioning
		public static const GAME_HEIGHT:uint = 700;	
		
		public static const FULL_WIDTH:uint = 1280;
		
		private const BONUS_TIME:uint = 5000; //millseconds between addition of bonus boxes
		
		private var LEVEL_LENGTH:uint = 30000; //millisecond level length - 30 seconds
		
		private var theGame:Sprite; //main game container that game elements are added to - sent by intro
		
		private var highScoreManager:HighScoreManager; //reference to the high scores manager object
		
		private var message:Message;		
		private var theHUD:HUD;
		
		private var frame:gameFrame; //library item
		
		public static var theLevel:uint; //current game level
		
		private var question:Question;
		
		private var bonus:Bonus; //reference to the bonus object
		private var bonusTimer:Timer;
		private var bonusActive:Boolean = false;//true when a bonus object is active
		
		private var channel:SoundChannel;		
		private var catchSound:goodCatch; //good item caught sound
		
		private var myScreen:String;
		private var backGround:MovieClip;
		
		//number of good,neutral,bad items per level
		private const ITEM_COUNTS:Array = new Array([100, 20, 25], [75, 20, 50], [50, 20, 75], [25, 20, 100]);
		
		//release time arrays
		private var goodItems:Array;
		private var neutralItems:Array;
		private var badItems:Array;		
		
		//arrays of falling items
		private var goodItemList:Array;
		private var neutralItemList:Array;
		private var badItemList:Array;
		
		private var currTime:int;
		
		private var goodStart:int;
		private var neutralStart:int;
		private var badStart:int;
		
		private var bonusCount:int = 3; //3 bonus packs per level
		private var curBonusCount:int = 0;
		
		private var player:Morris;
		
		private var congrats:Congrats;
		private var stuPack:studentPackage;
		
		private var foreground:MovieClip;
		
		private var strikes:int;
		private var points:int;
		
		//145 x positions for releasing items so they don't overlap
		private const POSITIONS:Array = new Array(52,450,870,225,650,150,530,325,850,90,500,780,190,390,260,600,720,52,450,870,225,650,150,530,325,850,90,500,780,190,390,260,600,720,52,450,870,225,650,150,530,325,850,90,500,780,190,390,260,600,720,52,450,870,225,650,150,530,325,850,90,500,780,190,390,260,600,720,52,450,870,225,650,150,530,325,850,90,500,780,190,390,260,600,720,52,450,870,225,650,150,530,325,850,90,500,780,190,390,260,600,720,52,450,870,225,650,150,530,325,850,90,500,780,190,390,260,600,720,52,450,870,225,650,150,530,325,850,90,500,780,190,390,260,600,720,420,200,660,340,105,770,109,280,77,515);
		private var curPositions:Array; //dup of POSITIONS - used per level
		
		
		
		/**
		 * CONSTRUCTOR
		 * 
		 * Instantiated by Intro - makeEngine()
		 * 
		 * Initializes game variables and starts the game playing
		 */
		public function Engine(container:Sprite)
		{			
			theGame = container;
			
			message = new Message();			
			
			player = new Morris(theGame, this);			
			
			theHUD = new HUD();
			
			bonusTimer = new Timer(BONUS_TIME, 1);
			bonusTimer.addEventListener(TimerEvent.TIMER, addBonus);
			
			frame = new gameFrame();
			frame.mouseEnabled = false; //need this to allow mouse clicks to get through the frame
			
			congrats = new Congrats(); //congratulations library clip
			
			channel = new SoundChannel();
			catchSound = new goodCatch();
			
			highScoreManager = HighScoreManager.getInstance();		
			
			question = new Question(theGame);
		}
		
		
		
		public function setRoom(whichScreen:String = "mall"):void 
		{
			myScreen = whichScreen;
	
			switch(myScreen) {
				case "mall":
					backGround = new Mall();
					foreground = new foreground_mall();
					foreground.x = 190;
					foreground.y = 675;
					break;
				case "campus":
					backGround = new Campus();
					foreground = new foreground_campus();
					foreground.x = 130;
					foreground.y = 665;
					break;							
			}
			
			theGame.addChildAt(backGround, 0);
			backGround.x = 46;
			backGround.y = 133;// 25; //position bg under frame -  34,25 for kiosk game
			
			theGame.addChildAt(player, 1);
			player.center();
			
			trace("Engine set room - adding children");
			
			theGame.addChildAt(message, 2);
			theGame.addChildAt(foreground, 3);
			theGame.addChildAt(frame, 4);			
			theGame.addChildAt(theHUD, 5);
			
			strikes = 0;
			points = 0;
			
			setLevel(1);
			
			theHUD.resetHud();			
			startGame();
		}
		
		
		
		/**
		 * Sets the game level - limits to 18
		 * Called from setRoom()
		 * 
		 * @param	newLev - uint level
		 */
		public function setLevel(newLev:uint = 1):void
		{			
			theLevel = newLev;
			
			//create release time arrays
			goodItems = randomArraySum(LEVEL_LENGTH, ITEM_COUNTS[theLevel - 1][0]);
			goodStart = getTimer();
			
			neutralItems = randomArraySum(LEVEL_LENGTH, ITEM_COUNTS[theLevel - 1][1]);
			neutralStart = getTimer();
			
			badItems = randomArraySum(LEVEL_LENGTH, ITEM_COUNTS[theLevel - 1][2]);
			badStart = getTimer();
			
			curBonusCount = 0;
			
			showMessage("LEVEL " + theLevel);
			
			theHUD.showLevel(theLevel);
			
			curPositions = POSITIONS.slice(); //duplicate POSITIONS
		}
		
		public static function setAttractLevel()
		{
			theLevel = 1;
		}
		/**
		 * Used by item class for setting speed of objects
		 */
		public static function getLevel() 
		{
			return theLevel;
		}
		
		
		//These are called by Morris
		public function getGoodItems():Array
		{
			return goodItemList;
		}
		public function getNeutralItems():Array
		{
			return neutralItemList;
		}
		public function getBadItems():Array
		{
			return badItemList;
		}
		
		
		
		/**
		 * Starts the game
		 * Called from setRoom()
		 */
		private function startGame():void
		{			
			showMessage("READY?");
			
			goodItemList = new Array();
			neutralItemList = new Array();
			badItemList = new Array();
			
			//var cat:VO_CatchTheBugs = new VO_CatchTheBugs();
			//channel = cat.play();
			
			player.listen();
			bonusTimer.start();
			listen();
		}
		
		
		
		/**
		 * Displays an in-game message, at screen center, using the message queue
		 * 
		 * @param	msg String message to display
		 * @param 	clear set to True to clear the mesage queue when displaying this message - as game over message does
		 * @param	doDispatch - if true a messageComplete event will be dispatched when the message is done showing - this is
		 * currently used for the gameOver so the congrats screen fades in after the game over message is displayed
		 */
		public function showMessage(msg:String, clear:Boolean = false, doDispatch:Boolean = false ):void
		{			
			message.show(msg, clear, doDispatch);
		}
		
		
		/**
		 * Displays a quick, fading message at the players current position
		 * 
		 * @param	msg String to show - max about 15 characters		
		 */
		public function showQuickMessage(msg:String):void
		{
			var quickMessage = new QuickMessage(theGame, msg);
			quickMessage.x =  player.x - 10;
			quickMessage.y = player.y - 20;
			theGame.addChild(quickMessage);
		}
		
		
		/**
		 * Called from Morris whenever he catches a good item
		 */
		public function incGets():void
		{
			var addPoints:Number = 50 * theLevel;
			points += addPoints;
			var qm:String = "+" + String(addPoints);
			showQuickMessage(qm);
			theHUD.showScore(points);
			
			channel = catchSound.play();
		}
		
		
		/**
		 * Called by Morris whenever he catches a bad item
		 */
		public function incStrikes():void 
		{
			strikes++;
			theHUD.showStrikes(strikes);
			showMessage("STRIKE "+String(strikes));
			showQuickMessage("X");
			
			var aSound:SoundStrike = new SoundStrike();
			channel = aSound.play();
			
			if (strikes == 3) {
				//game over	 - show message, don't erase queue, dispatch when complete			
				showMessage("GAME OVER", false, true);
				message.addEventListener("messageComplete", showCongrats, false, 0, true);
				clearGame();				
			}
		}
		
		
		//called when the game over message is done fading out
		private function showCongrats(e:Event):void
		{			
			message.removeEventListener("messageComplete", showCongrats);
			
			theGame.addChild(congrats);
			congrats.alpha = 0;
			
			congrats.penny.alpha = 0;
			congrats.nickel.alpha = 0;
			congrats.dime.alpha = 0;
			congrats.quarter.alpha = 0;
			
			TweenLite.to(congrats, 1, { alpha:1 } );
			if (theLevel > 4) { theLevel = 4;}
			switch(theLevel) {
				case 1:
					congrats.penny.alpha = 1;
					congrats.theLevel.text = "PENNY";
					break;
				case 2:
					congrats.nickel.alpha = 1;
					congrats.theLevel.text = "NICKEL";
					break;
				case 3:
					congrats.dime.alpha = 1;
					congrats.theLevel.text = "DIME";
					break;
				case 4:
					congrats.quarter.alpha = 1;
					congrats.theLevel.text = "QUARTER";
					break;
			}
			
			congrats.theScore.text = String(points);
			congrats.btnKeyboard.addEventListener(MouseEvent.CLICK, fadeInKeyboard);
			congrats.btnSkip.addEventListener(MouseEvent.CLICK, clearCongrats);
		}
		
		private function fadeInKeyboard(e:MouseEvent):void
		{
			highScoreManager.showKeyboard(points, congrats.theLevel.text);
			highScoreManager.addEventListener("scoresRemoved", clearCongrats);			
		}
		
		/**
		 * called by high score manager scoresRemoved event
		 * once the high scores have been removed from the screen
		 * 
		 * @param	e scoresRemove Event
		 */
		private function clearCongrats(e:Event):void
		{
			highScoreManager.removeEventListener("scoresRemoved", clearCongrats);
			congrats.btnKeyboard.removeEventListener(MouseEvent.CLICK, fadeInKeyboard);			
			
			stuPack = new studentPackage(); //libray clip			
			theGame.addChild(stuPack);			
			
			removeCongrats();			
			stuPack.addEventListener(MouseEvent.CLICK, removeStuPack);
		}
		
		/**
		 * Called by tweenLite once the student package screen has faded in
		 * removes the high screen behind - so stu package fades in over the high scores
		 */
		private function removeCongrats()
		{
			congrats.penny.alpha = 0;
			congrats.nickel.alpha = 0;
			congrats.dime.alpha = 0;
			congrats.quarter.alpha = 0;
			if(theGame.contains(congrats)){
				theGame.removeChild(congrats);
			}
		}
		
		private function removeStuPack(e:MouseEvent):void
		{
			stuPack.removeEventListener(MouseEvent.CLICK, removeStuPack);
			theGame.removeChild(stuPack);
			stuPack = null;
			killGame();
		}
			
		 
		/**
		 * Adds the EnterFrame listener so loop method is called
		 * Called from startGame()
		 */
		private function listen():void
		{
			this.addEventListener(Event.ENTER_FRAME, loop); 
		}
		
		
		
		/**
		 * Removes EnterFrame listener
		 */
		private function quiet():void
		{			
			this.removeEventListener(Event.ENTER_FRAME, loop); 
		}
		
		
		/**
		 * Completely removes game elements and game sprite
		 * called from removeStuPack when the student package screen is gone
		 */
		public function killGame():void
		{			
			clearGame();
			if(theGame.contains(backGround)){
				theGame.removeChild(backGround);			
				theGame.removeChild(frame);			
				theGame.removeChild(theHUD);
				theGame.removeChild(message);
				theGame.removeChild(foreground);
			}
			if (theGame.contains(question)) {
				theGame.removeChild(question);
			}
			if (theGame.contains(congrats))	{
				theGame.removeChild(congrats);
			}
			
			highScoreManager.killKeyboard();
			
			dispatchEvent(new Event("gameEnded")); //listened for by intro
		}		
		
		/**
		 * Stops bonusTimer and calls quiet() on all active objects
		 * quiet() removes listener
		 */
		private function pauseGame():void 
		{			
			quiet(); //removes frame listener from engine and player
			player.quiet();
			bonusTimer.reset();
			
			var b:Array;
			var i:int;
			
			b = getGoodItems();
			for (i = 0; i < b.length; i++) {
				b[i].quiet();
			}
			b = getNeutralItems();
			for (i = 0; i < b.length; i++) {
				b[i].quiet();
			}
			b = getBadItems();
			for (i = 0; i < b.length; i++) {
				b[i].quiet();
			}
			if (isBonusActive()) {
				bonus.quiet();				
			}			
		}
			
		/**
		 * Starts bonusTimer and calls listen() on all active objects
		 */
		private function resumeGame():void
		{
			listen();
			player.listen();
			
			var b:Array;
			var i:int;
			
			b = getGoodItems();
			for (i = 0; i < b.length; i++) {
				b[i].listen();
			}
			b = getNeutralItems();
			for (i = 0; i < b.length; i++) {
				b[i].listen();
			}
			b = getBadItems();
			for (i = 0; i < b.length; i++) {
				b[i].listen();
			}
			if (isBonusActive()) {
				bonus.listen();				
			}
			bonusTimer.start();
		}
		
		
		public function clearGame():void
		{			
			pauseGame();
			player.removeSelf();			
			
			//bonusTimer.removeEventListener(TimerEvent.TIMER, addBonus);
			if (isBonusActive()) {
				bonus.removeSelf();		
				bonus.removeEventListener(Event.REMOVED_FROM_STAGE, removeBonus);
						
			}
			bonusTimer.reset();
			bonusActive = false;
			
			var p:Timer = new Timer(100,1);
			p.addEventListener(TimerEvent.TIMER, removeItems, false, 0, true);
			p.start();
		}
		
		/**
		 * Called from clearGame above, after 100ms - prevents a conflict...
		 * @param	e
		 */
		private function removeItems(e:TimerEvent) {
			var anItem:Item;
			while(goodItemList.length) {
				anItem = goodItemList.shift();
				anItem.removeEventListener(Event.REMOVED_FROM_STAGE, removeGoodItem);
				anItem.removeSelf();
			}			
			
			while(neutralItemList.length) {
				anItem = neutralItemList.shift();
				anItem.removeEventListener(Event.REMOVED_FROM_STAGE, removeNeutralItem);
				anItem.removeSelf();
			}
			
			while(badItemList.length) {
				anItem = badItemList.shift();
				anItem.removeEventListener(Event.REMOVED_FROM_STAGE, removeBadItem);
				anItem.removeSelf();
			}
			
			TweenLite.killTweensOf(question);
			question.removeEventListener("questionAnsweredCorrect", bonusAnsweredCorrectly);
			question.removeEventListener("questionAnsweredWrong", bonusAnsweredWrong);
			question.removeSelf();
		}
		
		
		/**
		 * Main game loop callback listener, runs on ENTER_FRAME
		 * 
		 * @param	e Event
		 */
		private function loop(e:Event) : void
		{	
			
			currTime = getTimer();
			var theX:int;
			
			if ((currTime - goodStart) >= goodItems[0] && goodItems.length) {
				//time to release
				goodItems.shift();
				goodStart = currTime;
				
				theX = curPositions.shift();
				
				var gi:Item = new GoodItem(theGame, theX);			
				goodItemList.push(gi);				
				gi.addEventListener(Event.REMOVED_FROM_STAGE, removeGoodItem, false, 0, true);
			}
			
			
			if ((currTime - neutralStart) >= neutralItems[0] && neutralItems.length) {
				neutralItems.shift();
				neutralStart = currTime;
				
				theX = curPositions.shift();
				
				var ni:Item = new NeutralItem(theGame, theX);				
				neutralItemList.push(ni);				
				ni.addEventListener(Event.REMOVED_FROM_STAGE, removeNeutralItem, false, 0, true);
			}
			
			
			if ((currTime - badStart) >= badItems[0] && badItems.length) {
				badItems.shift();
				badStart = currTime;
				
				theX = curPositions.shift();
				
				var bi:Item = new BadItem(theGame, theX);				
				badItemList.push(bi);				
				bi.addEventListener(Event.REMOVED_FROM_STAGE, removeBadItem, false, 0, true);
			}			
		}
		
		
		/**
		 * Called from removeItem listeners below - if all three lists are zero length then the
		 * last item has ben removed from the stage - so this should only be called once per level
		 */
		private function checkForLevelEnd():void
		{
			var tim:Timer;
			if ((badItemList.length == 0) && (neutralItemList.length == 0) && (goodItemList.length == 0)) {
				//all items released - go to next level
				theLevel++;
				if(theLevel < 5){
					strikes = 0;
					
					theHUD.showStrikes(strikes);
					showMessage("NEXT LEVEL");
					tim = new Timer(2000, 1);
					tim.addEventListener(TimerEvent.TIMER, levelUp, false, 0, true);
					tim.start();
					
					bonusTimer.reset();
				}else {
					//got past level 4 - game over...
					showMessage("WINNER", false, true);
					message.addEventListener("messageComplete", showCongrats, false, 0, true);
					clearGame();					
				}
			}		
			
		}
	
		/**
		 * Called from checkForLevelEnd() when the timer runs out - gives a pause
		 * between levels
		 * @param	e TimerEvent
		 */
		private function levelUp(e:TimerEvent):void
		{			
			setLevel(theLevel);			
			bonusTimer.start();
		}
		
		
		/**
		 * REMOVED_FROM_STAGE Callback listeners from an item, removes item from appropriate list
		 * 
		 * @param	e Event
		 */
		private function removeGoodItem(e:Event):void
		{	
			e.currentTarget.removeEventListener(Event.REMOVED_FROM_STAGE, removeGoodItem);			
			goodItemList.splice(goodItemList.indexOf(e.currentTarget), 1);
			checkForLevelEnd();
		}
		private function removeNeutralItem(e:Event):void
		{	
			e.currentTarget.removeEventListener(Event.REMOVED_FROM_STAGE, removeNeutralItem);			
			neutralItemList.splice(neutralItemList.indexOf(e.currentTarget), 1);
			checkForLevelEnd();
		}
		private function removeBadItem(e:Event):void
		{	
			e.currentTarget.removeEventListener(Event.REMOVED_FROM_STAGE, removeBadItem);			
			badItemList.splice(badItemList.indexOf(e.currentTarget), 1);
			checkForLevelEnd();
		}
		
		
		
		/**
		 * Called when the timer times out - adds a new bonus object
		 * 
		 * @param	e Timer Event
		 */
		private function addBonus(e:TimerEvent):void
		{		
			
			if (curBonusCount < bonusCount) {
				curBonusCount++;		
				trace("bonus added");
				bonus = new Bonus(theGame);
				//game.addChild(bonus);
				bonusActive = true;
				bonus.addEventListener(Event.REMOVED_FROM_STAGE, removeBonus, false, 0, true);	
			}
		}
		public function isBonusActive():Boolean
		{
			return bonusActive;
		}
		public function getBonus():*
		{
			return bonus;
		}
		public function incBonus():void
		{			
			trace("engine inc bonus");
			var bonusSound:SoundBonus = new SoundBonus();
			channel = bonusSound.play();
			
			//PAUSE GAME _ QUESTION POPUP
			bonus.removeSelf();
			pauseGame();
			
			question.askQuestion(player.x, player.y);
			question.addEventListener("questionAnsweredCorrect", bonusAnsweredCorrectly, false, 0, true);
			question.addEventListener("questionAnsweredWrong", bonusAnsweredWrong, false, 0, true);
		}	
		
		private function bonusAnsweredCorrectly(e:Event):void
		{
			var aSound:soundRight = new soundRight();
			channel = aSound.play();
			points += 1000;
			showQuickMessage("+1000");
			showMessage("BONUS");			
			theHUD.showScore(points);
			//bonus.removeSelf();
			question.removeSelf();
			resumeGame();
			player.invincibleOn();
		}
		private function bonusAnsweredWrong(e:Event):void
		{
			var aSound:soundWrong = new soundWrong();
			channel = aSound.play();
			showMessage("INCORRECT");
			//bonus.removeSelf();
			question.removeSelf();
			resumeGame();
			player.invincibleOn();
		}
		
		/**
		 * Called on Removed from stage event - restarts the bonus timer
		 * 
		 * @param	e Event - REMOVED_FROM_STAGE
		 */
		private function removeBonus(e:Event):void
		{			
			bonus.removeEventListener(Event.REMOVED_FROM_STAGE, removeBonus);	
			bonusActive = false;
			bonusTimer.start();
		}
		
		
		
		
		/**
		 * Creates an array of count random numbers that total up to sum
		 * @param	sum Sum of the items in the array
		 * @param	count Number of items in the array
		 * @return	Array of count random numbers that add up to sum
		 */
		private function randomArraySum(sum:Number, count:int):Array 
		{
			var i:int;
			var list:Array = new Array();   
			var total:Number = 0;
			var curr:Number;
		   
			// create count random numbers
			i = count;
			while(i--){
				curr = Math.random();
				total += curr;
				list.push(curr);
			}
			// normalize random numbers to fit the sum
			var ratio:Number = sum / total;
			i = count;
			while(i--){
				list[i] = Math.round(list[i] * ratio);		
			}
		   
			return list;
		}
	}	
}