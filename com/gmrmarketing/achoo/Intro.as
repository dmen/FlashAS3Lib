/**
 * Kleenex Achoo Game
 * 
 * Document Class
 * 
 * GMR Marketing
 */


package com.gmrmarketing.achoo
{	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;		
	import com.gmrmarketing.kiosk.*;	

	import flash.system.fscommand;
	
	
	
	public class Intro extends MovieClip
	{
		private var helper:KioskHelper;
		private var me:*;
		
		private var intro:IntroGraphic; //reference to the intro graphic object - library clip
		private var vid:VideoPlayer; //reference to the VideoPlayer
		private var engine:Engine; //ref to the game
		
		private var frame:GameFrame;
		private var fakeHUD:HudFake;
		
		private var infoRoom:MovieClip;
		
		private var highScoreManager:HighScoreManager;
		
		
		
		/**
		 * CONSTRUCTOR
		 * Instantiates helper and sets logger
		 * adds intro
		 */
		public function Intro()
		{
			fscommand("fullscreen", "true");
            fscommand("allowscale", "false");

			me = this.root;
			
			highScoreManager =  HighScoreManager.getInstance(); //instantiate the score manager			
			
			helper = KioskHelper.getInstance();
			helper.setLogger(new TraceLogger());
			helper.attractInit(me, 30000);
			helper.addEventListener(KioskEvent.START_ATTRACT, attractPlay);
			
			vid = new VideoPlayer();
			vid.addEventListener(MouseEvent.CLICK, removeAttract);
			vid.addEventListener("videoPlaybackEnded", vidEnded);
			
			intro = new IntroGraphic();
			
			addIntro();
			
			//helperHolder = new Sprite();
			helper.fourCornerInit(me);
			helper.addEventListener(KioskEvent.FOUR_CLICKS, fourClick);
			helper.eightCornerInit(me);
			helper.addEventListener(KioskEvent.EIGHT_CLICKS, eightClick);
			helper.SneezeOffInit(me);
		}
		
		
		
		
		
		// --------------- PRIVATE -----------------
		
		private function fourClick(e:KioskEvent)
		{			
			if (engine) {
				engine.removeEventListener("gameEnded", resumeIntro);
				engine.killGame()
			};
			if(vid){vid.removeSelf()};
			removeInfo();
			resume();
		}
		private function eightClick(e:KioskEvent)
		{
			fscommand("ffish_run", "quit");
		}
		
		/**
		 * Adds the intro graphic and assigns button handlers
		 */
		private function addIntro():void
		{
			me.addChildAt(intro,0);			
			
			intro.btnA.addEventListener(MouseEvent.CLICK, btnAClick, false, 0, true);
			intro.btnB.addEventListener(MouseEvent.CLICK, btnBClick, false, 0, true);
			intro.btnC.addEventListener(MouseEvent.CLICK, btnCClick, false, 0, true);
		}
		
		private function removeIntro():void
		{
			if (me.contains(intro)) {
				me.removeChild(intro);
				intro.btnA.removeEventListener(MouseEvent.CLICK, btnAClick);
				intro.btnB.removeEventListener(MouseEvent.CLICK, btnBClick);
				intro.btnC.removeEventListener(MouseEvent.CLICK, btnCClick);
			}			
		}
		
		/**
		 * Event handler - 
		 * called by Helper when the attract loop timer times out
		 * Creates the video object
		 * Stops attract loop time checking
		 * 
		 * @param	e KioskEvent - type START_ATTRACT
		 */
		private function attractPlay(e:KioskEvent):void
		{			
			helper.log("Attract Loop Started!");
			
			//engine is null if it hasn't yet been instantiated
			if(engine){engine.killGame()};
			
			removeInfo();
			removeIntro();
			
			me.addChildAt(vid, 0);
			
			vid.x = (Engine.FULL_WIDTH - 1137) / 2; //center video	
			vid.doPlay();
			//stop checking once attract loop is started
			helper.attractStop();			
		}
		
		
		/**
		 * Called when the attract loop video ends by a player clicking on the video
		 * 
		 * @param	e Any Event
		 */
		private function removeAttract(e:*):void
		{
			helper.log("Video ended");
			
			//vid.removeEventListener(MouseEvent.CLICK, removeAttract);
			//vid.removeEventListener("videoPlaybackEnded", vidEnded);
			
			vid.removeSelf();
			me.removeChild(vid);		
			
			resume();
		}
		
		
		/**
		 * Called when the video finishes playing
		 * Shows the list of high scores
		 * 
		 * @param	e
		 */
		private function vidEnded(e:Event):void
		{
			//vid.removeEventListener(MouseEvent.CLICK, removeAttract);
			//vid.removeEventListener("videoPlaybackEnded", vidEnded);
			
			vid.removeSelf();
			me.removeChild(vid);
			
			//show the high scores
			highScoreManager.init(me);
			highScoreManager.showHighScores(Engine.FULL_WIDTH);
			highScoreManager.addEventListener("scoresRemoved", scoresGone);		
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
			//resume checking
			helper.attractStart();
			
			if (!me.contains(intro)) {
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
			helper.log("Attract loop canceled");
		
			//resume checking
			//helper.attractStart();
			
			if (!me.contains(intro)) {
				addIntro();
			}
		}
		
		
		private function addInfo():void
		{
			me.removeChild(intro); //remove intro graphic	
			
			frame = new GameFrame();
			frame.mouseEnabled = false;
			
			fakeHUD = new HudFake();
			
			me.addChildAt(infoRoom,0);
			me.addChildAt(frame,1);
			me.addChildAt(fakeHUD,2);
			
			fakeHUD.x = Engine.GAME_WIDTH;	
			infoRoom.x = 34;
			infoRoom.y = 25;
		}
		
		/**
		 * Called from make engine
		 */
		private function removeInfo():void
		{
			if (infoRoom) {
				infoRoom.killDialog();
				if(me.contains(infoRoom)){
					me.removeChild(frame);
					me.removeChild(infoRoom);
					me.removeChild(fakeHUD);
				}
			}
		}
		
		
		/**
		 * Room A CLICK callback
		 * Starts engine
		 * 
		 * @param	e MouseEvent
		 */
		private function btnAClick(e:MouseEvent):void
		{			
			infoRoom = new InfoRoom_Bath(me);
			addInfo();
			infoRoom.addEventListener("roomComplete", bathGame);
		}
		
		private function bathGame(e:Event):void
		{
			infoRoom.removeEventListener("roomComplete", bathGame);
			makeEngine("bathroom");
		}
		
		
		 /**
		 * Room B CLICK callback
		 * Starts engine
		 * 
		 * @param	e MouseEvent
		 */
		private function btnBClick(e:MouseEvent):void
		{			
			infoRoom = new InfoRoom_Bed(me);
			addInfo();
			infoRoom.addEventListener("roomComplete", bedGame);
		}
		
		private function bedGame(e:Event):void
		{
			infoRoom.removeEventListener("roomComplete", bedGame);
			makeEngine("bedroom");
		}
		
		
		/**
		 * Room C CLICK callback
		 * Starts engine
		 * 
		 * @param	e MouseEvent
		 */
		private function btnCClick(e:MouseEvent):void
		{			
			infoRoom = new InfoRoom_Class(me);
			addInfo();
			infoRoom.addEventListener("roomComplete", classGame);
		}
		
		private function classGame(e:Event):void
		{
			infoRoom.removeEventListener("roomComplete", classGame);
			makeEngine("classroom");
		}
		
		
		/**
		 * Called by clicking on a room selection
		 * Instantiates the game engine - removes intro graphic
		 * 
		 * @param	type
		 */
		private function makeEngine(type:String = "bathroom"):void
		{	
			
			removeIntro();					
			removeInfo();
					
			if(!engine){
				engine = new Engine(me);
				helper.log("New Engine instance created");
			}
			engine.setRoom(type);
			
			//the gameEnded event is dispatched from Engine when the high scores list is removed
			engine.addEventListener("gameEnded", resumeIntro);
			
			helper.log("Game Started - " + type);
		}
	}	
}