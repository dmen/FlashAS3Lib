/**
 * Document Class
 */

package com.gmrmarketing.morris
{	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;		
	import com.gmrmarketing.kiosk.*;	
	import flash.ui.Mouse;
	
	import gs.TweenLite;

	import flash.system.fscommand;
	
	import com.gmrmarketing.kiosk.KioskHelper;
	import com.gmrmarketing.kiosk.KioskEvent;

	
	public class Intro extends MovieClip
	{		
		private var introContainer:Sprite;
		
		private var gameContainer:Sprite;
		
		private var intro:IntroGraphic; //reference to the intro graphic object - library clip		
		private var instructions:Instructions; //instructions clip in the library
		
		private var engine:Engine; //ref to the game engine		
		
		private var gameChoice:String; //mall or campus - picked on intro screen
		
		//private var frame:GameFrame;	
		private var highScoreManager:HighScoreManager;		
		
		private var helper:KioskHelper;
		
		private var introCounter:int = 0;//simple counter used to mod against for the intro screen bottom text rotation
		
		private var fallingAttract:FallingItems;
		private var fallingContainer:Sprite;
		private var mouseTrap:MovieClip;
		
		/**
		 * CONSTRUCTOR
		 */
		public function Intro()
		{
			introContainer = new Sprite();
			addChild(introContainer);
			
			gameContainer = new Sprite();
			addChild(gameContainer);
			
			highScoreManager =  HighScoreManager.getInstance(); //instantiate the score manager	
			highScoreManager.init(gameContainer);
			
			intro = new IntroGraphic(); //library clips
			instructions = new Instructions();
			
			helper = KioskHelper.getInstance();
			helper.fourCornerInit(stage); //upper left by default
			helper.addEventListener(KioskEvent.FOUR_CLICKS, fourClicked);
			helper.attractInit(stage, 60000);
			helper.addEventListener(KioskEvent.START_ATTRACT, startAttract);
			
			fallingContainer = new Sprite();			
			fallingAttract = new FallingItems(fallingContainer);
			
			addIntro();
		}
		
		
		
		// --------------- PRIVATE -----------------
		
		private function fourClicked(e:KioskEvent)
		{
			fscommand("ffish_run", "quit");			
		}
		
		
		/**
		 * Called by helper if the attract loop times out
		 * @param	e
		 */
		private function startAttract(e:KioskEvent)
		{
			//intro.theText.appendText("timeout received\n");
			
			Engine.setAttractLevel(); //sets theLevel to 1
			addChild(fallingContainer);
			fallingAttract.listen();
			
			helper.attractStop(); //stop mouse testing while in attract loop		
			
			if (engine) {
				engine.removeEventListener("gameEnded", resumeIntro);
				engine.killGame();
			}
		
			highScoreManager.showHighScores(false); //don't check for mouse click			
			highScoreManager.addEventListener("scoresRemoved", backToIntro);
			
			mouseTrap = new MouseTrap();
			mouseTrap.alpha = 0;
			fallingContainer.addChild(mouseTrap);
			fallingContainer.addEventListener(MouseEvent.CLICK, clearAttract, false, 0, true);
		}
		
		
		/**
		 * Part of attract loop - called when the high scores have been removed by timer
		 * @param	e TIMER event
		 */
		private function backToIntro(e:Event)
		{			
			trace("Intro:back to intro");
			removeInstructions();
			removeIntro();
			addIntro();
			helper.attractStart();		
			highScoreManager.removeEventListener("scoresRemoved", backToIntro);
		}
		
		
		//called by clicking on fallingContainer
		private function clearAttract(e:MouseEvent)
		{	
			trace("Intro:clear attract");
			fallingContainer.removeChild(mouseTrap);
			removeChild(fallingContainer);
			fallingAttract.quiet();
			fallingAttract.removeItems();
			highScoreManager.removeScores(1);
			
			fallingContainer.removeEventListener(MouseEvent.CLICK, clearAttract);
			
			removeInstructions();
			removeIntro();
			addIntro();
			
			//helper.attractInit(gameContainer, 120000); //set back to 2 minutes	
		}
		
		/**
		 * Adds the intro graphic and assigns button listeners
		 * This container is 'under' game container - so game container
		 * must be empty
		 */
		private function addIntro():void
		{
			introContainer.addChild(intro);			
			intro.btnA.addEventListener(MouseEvent.CLICK, btnAClick);
			intro.btnB.addEventListener(MouseEvent.CLICK, btnBClick);
			introCounter = 0;
			intro.addEventListener(Event.ENTER_FRAME, flashText);
		}
		
		
		private function removeIntro():void
		{
			if (introContainer.contains(intro)) {
				introContainer.removeChild(intro);
				intro.btnA.removeEventListener(MouseEvent.CLICK, btnAClick);
				intro.btnB.removeEventListener(MouseEvent.CLICK, btnBClick);				
			}
			TweenLite.killTweensOf(intro.t1);
			TweenLite.killTweensOf(intro.t2);
			intro.t1.alpha = 1;
			intro.t2.alpha = 0;
			intro.removeEventListener(Event.ENTER_FRAME, flashText);
		}
		
		/**
		 * rotating text at bottom of intro page
		 * @param	e
		 */
		private function flashText(e:Event):void
		{
			introCounter++;
			if (introCounter % 90 == 0) {
				if (intro.t1.alpha > 0) {
					TweenLite.to(intro.t1, .5, { alpha:0 } );
					TweenLite.to(intro.t2, .5, { alpha:1 } );
				}else {
					TweenLite.to(intro.t1, .5, { alpha:1 } );
					TweenLite.to(intro.t2, .5, { alpha:0 } );	
				}
			}
		}
		
		/**
		 * Add instructions screen and start button listener
		 */
		private function addInstructions():void 
		{
			introContainer.addChild(instructions);
			instructions.btnStart.addEventListener(MouseEvent.CLICK, btnStartClick);
			instructions.btnRules.addEventListener(MouseEvent.CLICK, showRules);
			instructions.legal.mouseEnabled = false;
		}
		
		
		private function removeInstructions():void
		{
			if (introContainer.contains(instructions)) {
				introContainer.removeChild(instructions);
				instructions.legal.alpha = 0;
				instructions.btnStart.removeEventListener(MouseEvent.CLICK, btnStartClick);
				instructions.btnRules.removeEventListener(MouseEvent.CLICK, showRules);
			}
		}
		
		/**
		 * Call back from high score display being removed
		 * 
		 * @param	e  Event
		 */
		private function scoresGone(e:Event)
		{
			highScoreManager.removeEventListener("scoresRemoved", scoresGone);		
			resume();			
		}
		
		
		/**
		 * Shows the intro - select graphic and resumes attract loop checking
		 */
		private function resume():void
		{			
			if (!introContainer.contains(intro)) {
				addIntro();
			}
		}
		
		
		/**
		 * Called by the gameEnded event from Engine when the high scores dialog has been removed
		 * Puts the intro back on stage and resumes attract loop checking
		 * @param	e Event
		 */
		private function resumeIntro(e:*):void
		{			
			engine.removeEventListener("gameEnded", resumeIntro);
			//helper.log("Attract loop canceled");
		
			//resume checking
			//helper.attractStart();
			
			if (!introContainer.contains(intro)) {
				addIntro();
			}
		}
		
		
		/**
		 * Called from clicking Start button on instructions page
		 * @param	e CLICK event
		 */
		private function btnStartClick(e:MouseEvent):void
		{
			removeInstructions();
			makeEngine(gameChoice);
		}
		
		
		private function btnAClick(e:MouseEvent):void
		{		
			gameChoice = "mall";
			removeIntro();
			addInstructions();
		}
		
		
		private function btnBClick(e:MouseEvent):void
		{	
			gameChoice = "campus";
			removeIntro();
			addInstructions();
		}
		
		private function showRules(e:MouseEvent)
		{
			TweenLite.to(instructions.legal, 1, { alpha:1 } );
			instructions.legal.mouseEnabled = true;
			instructions.legal.addEventListener(MouseEvent.CLICK, hideRules);
		}
		
		
		private function hideRules(e:MouseEvent)
		{
			instructions.legal.removeEventListener(MouseEvent.CLICK, hideRules);
			instructions.legal.mouseEnabled = false;
			TweenLite.to(instructions.legal, 1, { alpha:0 } );
		}
		
		/**
		 * Called from gameStart()
		 * Instantiates the game engine
		 * 
		 * @param	type String - mall or campus
		 */
		private function makeEngine(type:String = "mall"):void
		{			
			if(!engine){
				engine = new Engine(gameContainer);				
			}
			
			engine.setRoom(type);
			
			//the gameEnded event is dispatched from Engine when the student package info is removed
			engine.addEventListener("gameEnded", resumeIntro);
		}
	}	
}