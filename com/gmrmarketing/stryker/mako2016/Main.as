package com.gmrmarketing.stryker.mako2016
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.greensock.TweenMax;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
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
		private var logoContainer:Sprite;
		private var cornerContainer:Sprite;
		
		private var currentUser:Object;
		
		private var recommendedItems:RecommendedItems;
		
		private var configCorner:CornerQuit;
		private var quitCorner:CornerQuit;
		
		private var logo:MovieClip;//instance of mcLogo - located upper right
		private var logout:MovieClip;//instance of mcSignOut - appears on full map view
		
		private var tim:TimeoutHelper;
		
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			//Mouse.hide();

			mapContainer = new Sprite();
			mainContainer = new Sprite();
			detailContainer = new Sprite();
			logoContainer = new Sprite();
			cornerContainer = new Sprite();
			
			addChild(detailContainer);
			addChild(mapContainer);
			addChild(mainContainer);
			addChild(logoContainer);
			addChild(cornerContainer);
			
			orchestrate = new Orchestrate();
			
			config = new Config();
			config.container = cornerContainer;
			
			map = new Map();
			map.container = mapContainer;
			
			intro = new Intro();
			intro.container = mainContainer;
			
			welcome = new Welcome();
			welcome.container = mainContainer;
			
			detail = new Detail();
			detail.container = detailContainer;
			
			logo = new mcLogo();//1695,63
			logo.x = 1695;
			logo.y = 63;
			
			logout = new mcSignOut();
			logout.x = 1564;
			logout.y = 970;
			
			configCorner = new CornerQuit();
			configCorner.init(cornerContainer, "ul");
			configCorner.addEventListener(CornerQuit.CORNER_QUIT, showConfig);
			
			quitCorner = new CornerQuit();
			quitCorner.init(cornerContainer, "ll");
			quitCorner.addEventListener(CornerQuit.CORNER_QUIT, quitApp);
			
			recommendedItems = new RecommendedItems();//this is a sprite with the items in it - blue rects at lower left
			recommendedItems.x = 58;
			recommendedItems.y = 650;
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, logoutUser);
			tim.init(90000);
			
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
			logoutUser();
		}
		
		
		/**
		 * callback on Intro - called when a user scans their rfid
		 * @param	e
		 */
		private function rfidScanned(e:Event):void
		{
			intro.removeEventListener(Intro.GOT_RFID, rfidScanned);
			intro.scanning();
			
			orchestrate.addEventListener(Orchestrate.GOT_USER_DATA, gotUserData, false, 0, true);
			orchestrate.getUser(intro.RFID);
		}
		
		
		/**
		 * callback from retrieving the user data object from orchestrate
		 * @param	e
		 */
		private function gotUserData(e:Event):void
		{
			tim.startMonitoring();
			
			//submit the kiosk use for tracking
			orchestrate.submitKioskUse(config.kioskName, intro.RFID);
			
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
			
			if (!logoContainer.contains(logo)){
				logoContainer.addChild(logo);
				logo.alpha = 0;
				TweenMax.to(logo, 2, {alpha:1});
			}
			
			showFullMap();
		}
		
		
		/**
		 * Callback from clicking on map area - shows the detail for the area
		 * @param	e
		 */
		private function showMapDetail(e:Event):void
		{
			tim.buttonClicked();
			
			welcome.hide();
			
			while (detailContainer.numChildren){
				detailContainer.removeChildAt(0);
			}
			
			if (mainContainer.contains(recommendedItems)){
				mainContainer.removeChild(recommendedItems);
			}
			if (cornerContainer.contains(logout)){
				cornerContainer.removeChild(logout);				
			}
			
			//map.detail is the string gate name of what the user clicked on - matches the clip value in the orchestate gate array
			detail.show(map.detail, currentUser, map.recommendations, map.appointments);
			detail.addEventListener(Detail.CLOSE_DETAIL, showFullMap, false, 0, true);
		}
		
		
		/**
		 * callback for View Full Map button in Detail
		 * @param	e
		 */
		private function showFullMap(e:Event = null):void
		{
			tim.buttonClicked();
			
			detail.removeEventListener(Detail.CLOSE_DETAIL, showFullMap);
			detail.hide();
			
			map.removeDetail();
			welcome.show(currentUser);
		
			mainContainer.addChild(recommendedItems);
			recommendedItems.populate(map.recommendations, map.appointments);//this is the full list - can be more than two
			
			if (!cornerContainer.contains(logout)){
				cornerContainer.addChild(logout);				
			}
			
			logout.x = 1920;
			TweenMax.to(logout, .5, {x:1564});
			logout.addEventListener(MouseEvent.MOUSE_DOWN, logoutUser, false, 0, true);
		}
		
		
		/**
		 * closes the map
		 * shows the intro - get RFID screen
		 * @param	e
		 */
		private function logoutUser(e:Event = null):void
		{
			tim.stopMonitoring();
			
			if (cornerContainer.contains(logout)){
				cornerContainer.removeChild(logout);				
			}
			logout.removeEventListener(MouseEvent.MOUSE_DOWN, logoutUser);
			
			intro.addEventListener(Intro.GOT_RFID, rfidScanned, false, 0, true);
			intro.show();
			
			//remove logo on the intro/rfid page
			if (logoContainer.contains(logo)){
				logoContainer.removeChild(logo);
			}
			
			map.hide();
			
		}
		
		
		private function showConfig(e:Event):void
		{
			config.show();
		}
		
		
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}