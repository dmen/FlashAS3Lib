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
		private var detail:Detail;
		
		private var mapContainer:Sprite;
		private var mainContainer:Sprite;
		private var detailContainer:Sprite;
		
		private var currentUser:Object;
		
		private var recommendedItems:RecommendedItems;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			//Mouse.hide();

			mapContainer = new Sprite();
			mainContainer = new Sprite();
			detailContainer = new Sprite();			
			
			
			addChild(detailContainer);
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
			
			detail = new Detail();
			detail.container = detailContainer;
			
			recommendedItems = new RecommendedItems();//this is a sprite with the items in it - blue rects at lower left
			
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
		
		
		/**
		 * callback from retrieving the user data object from orchestrate
		 * @param	e
		 */
		private function gotUserData(e:Event):void
		{
			//submit the kiosk use for tracking
			//orchestrate.submitKioskUser(config.kioskName, intro.RFID);
			
			currentUser = orchestrate.user;
			intro.hide();			
			
			welcome.show(currentUser);	
			
			map.show(config.loginName);//sends Kiosk2, Kiosk3, etc. for the You Are Here
			map.setVisited(currentUser, orchestrate.gates);
			map.setDemoReminders(currentUser, orchestrate.gates);
			map.showRecommendedGates(currentUser, orchestrate.gates, config.loginName);
			
			map.addListeners();
			map.addEventListener(Map.DETAIL, showMapDetail, false, 0, true);
			//can call map.appointments and map.recommendations to get those lists and display them
			
			recommendedItems.populate(map.recommendations);//this is the full list - can be more than two
			mainContainer.addChild(recommendedItems);
			recommendedItems.x = 58;
			recommendedItems.y = 680;			
		}
		
		
		/**
		 * Callback from clicking on map area - shows the detail for the area
		 * @param	e
		 */
		private function showMapDetail(e:Event):void
		{
			welcome.hide();
			
			while (detailContainer.numChildren){
				detailContainer.removeChildAt(0);
			}
			
			recommendedItems.hide();
			
			detail.show(map.detail, currentUser);
			detail.addEventListener(Detail.CLOSE_DETAIL, showFullMap, false, 0, true);
		}
		
		
		/**
		 * callback for View Full Map button in Detail
		 * @param	e
		 */
		private function showFullMap(e:Event):void
		{
			detail.removeEventListener(Detail.CLOSE_DETAIL, showFullMap);
			detail.hide();
			
			map.removeDetail();
			welcome.show(currentUser);
		
			recommendedItems.populate(map.recommendations);//this is the full list - can be more than two
		}
		
	}
	
}