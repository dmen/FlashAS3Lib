/**
 * Kleenex Achoo Game
 * 
 * Document Class
 * 
 * GMR Marketing
 */


package com.gmrmarketing.achooweb
{	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;		
	import com.gmrmarketing.kiosk.*;
	import flash.display.LoaderInfo;

	import flash.system.fscommand;
	
	
	
	public class Intro extends MovieClip
	{		
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
		 *
		 * adds intro
		 */
		public function Intro()
		{
			me = this.root;
		
			highScoreManager = HighScoreManager.getInstance(); //instantiate the score manager
			highScoreManager.init(me);
			
			intro = new IntroGraphic();
			
			addIntro();			
		}
		
	
		
		
		
		// --------------- PRIVATE -----------------
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
		 * Called by the gameEnded event from Engine when the high scores dialog has been removed
		 * Puts the intro back on stage and resumes attract loop checking
		 * @param	e Event
		 */
		private function resumeIntro(e:*):void
		{
			engine.removeEventListener("gameEnded", resumeIntro);			
			
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
			infoRoom.x = 23;// 34;
			infoRoom.y = 19;// 25; //34,25 for KIOSK
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
			}
			engine.setRoom(type);
			
			//the gameEnded event is dispatched from Engine when the high scores list is removed
			engine.addEventListener("gameEnded", resumeIntro);			
		}
	}	
}