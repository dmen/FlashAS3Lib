package com.gmrmarketing.stryker.mako2016
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	
	public class Main extends MovieClip  
	{
		private var orchestrate:Orchestrate;
		private var config:Config;
		private var intro:Intro;
		private var welcome:Welcome;
		private var map:Map;
		
		private var screenText:ScreenText;
		private var mapContainer:Sprite;
		private var mainContainer:Sprite;
		private var currentUser:Object;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			//Mouse.hide();

			mapContainer = new Sprite();
			mainContainer = new Sprite();
			addChild(mapContainer);
			addChild(mainContainer);
			
			orchestrate = new Orchestrate();
			config = new Config();
			
			map = new Map();
			map.container = mapContainer;
			
			intro = new Intro();
			intro.container = mainContainer;
			
			welcome = new Welcome();
			welcome.container = mainContainer;
			
			screenText = new ScreenText();
			
			orchestrate.addEventListener(Orchestrate.GOT_BASE_URL, gotBaseURL, false, 0, true);
			orchestrate.getBaseURL();
		}
		
		
		/**
		 * callback from orchestrate.getBaseURL()
		 * @param	e
		 */
		private function gotBaseURL(e:Event):void
		{
			orchestrate.removeEventListener(Orchestrate.GOT_BASE_URL, gotBaseURL);
			orchestrate.addEventListener(Orchestrate.GOT_TOKEN, gotToken, false, 0, true);
			orchestrate.login(config.loginName + ":" + "Diego2017");
		}
		
		
		/**
		 * Orchestrate class has created the bearer token Authorization header
		 * get the gate list so we know the id's for everything
		 * @param	e
		 */
		private function gotToken(e:Event):void
		{			
			orchestrate.addEventListener(Orchestrate.GOT_GATES, showIntro, false, 0, true);
			orchestrate.getGates();
		}
		
		
		/**
		 * init complete - show the intro
		 * @param	e
		 */
		private function showIntro(e:Event):void
		{
			orchestrate.removeEventListener(Orchestrate.GOT_GATES, showIntro);
			
			intro.addEventListener(Intro.GOT_RFID, rfidScanned, false, 0, true);
			intro.show();
		}
		
		
		/**
		 * callback on Intro - called when a user scans their rfid
		 * @param	e
		 */
		private function rfidScanned(e:Event):void
		{
			intro.removeEventListener(Intro.GOT_RFID, rfidScanned);
			
			orchestrate.addEventListener(Orchestrate.GOT_USER_DATA, gotUserData, false, 0, true);
			orchestrate.getUser(intro.RFID);
		}
		
		
		
		private function gotUserData(e:Event):void
		{
			currentUser = orchestrate.user;
			intro.hide();
			
			var welcomeText:Object = screenText.getWelcome(currentUser.profileType);
			welcome.show(currentUser.firstName, welcomeText.greeting, welcomeText.message);	
			
			map.show(config.loginName);//sends Kiosk2, Kiosk3, etc. for the You Are Here
			map.setVisited(currentUser, orchestrate.gates);
		}
		
	}
	
}