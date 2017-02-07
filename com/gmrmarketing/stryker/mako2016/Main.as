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
		
		private var mainContainer:Sprite;
		private var currentUser:Object;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			//Mouse.hide();

			mainContainer = new Sprite();
			addChild(mainContainer);
			
			orchestrate = new Orchestrate();
			config = new Config();
			
			orchestrate.addEventListener(Orchestrate.GOT_BASE_URL, gotBaseURL, false, 0, true);
			orchestrate.getBaseURL();
			
			intro = new Intro();
			intro.container = mainContainer;
		}
		
		
		private function gotBaseURL(e:Event):void
		{
			orchestrate.removeEventListener(Orchestrate.GOT_BASE_URL, gotBaseURL);
			orchestrate.addEventListener(Orchestrate.GOT_TOKEN, gotToken, false, 0, true);
			orchestrate.login(config.loginName + ":" + "Diego2017");
		}
		
		
		/**
		 * Orchestrate class has created the bearer token Authorization header
		 * @param	e
		 */
		private function gotToken(e:Event):void
		{			
			orchestrate.addEventListener(Orchestrate.GOT_GATES, showIntro, false, 0, true);
			orchestrate.getGates();//wait for this???
		}
		
		
		private function showIntro(e:Event):void
		{
			orchestrate.removeEventListener(Orchestrate.GOT_GATES, showIntro);
			
			intro.addEventListener(Intro.GOT_RFID, rfidScanned, false, 0, true);
			intro.show();
		}
		
		
		private function rfidScanned(e:Event):void
		{
			trace("rfidScanned", intro.RFID);
			intro.removeEventListener(Intro.GOT_RFID, rfidScanned);
			
			orchestrate.addEventListener(Orchestrate.GOT_USER_DATA, gotUserData, false, 0, true);
			orchestrate.getUser(intro.RFID);
		}
		
		
		private function gotUserData(e:Event):void
		{
			currentUser = orchestrate.user;
			trace(currentUser.firstName, currentUser.lastName, currentUser.packageTypeName);
		}
		
	}
	
}