package com.gmrmarketing.pm
{
	import flash.display.Loader;
	import flash.display.MovieClip;	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.fscommand;


	public class Main extends MovieClip
	{
		
		private var setup:Setup;
		private var sideMenu:TheMenu;
		private var myLoader:Loader;
		
		private var barScene:Components; //lib clip
		public function Main()
		{		
			fscommand("fullscreen", "true");
			fscommand("allowscale", "false");

			myLoader = new Loader();
			barScene = new Components();
			setup = new Setup();
			addSetup();
		}
		
		private function addSetup():void
		{
			setup.x = 81; setup.y = 0;			
			setup.addEventListener("beginPresentation", beginPresentation, false, 0, true);
			addChild(setup);
		}
		
		/**
		 * Called when the Begin Presentation button is clicked on the setup screen
		 * 
		 * @param	e
		 */
		private function beginPresentation(e:Event):void
		{
			removeChild(setup);
			setup.removeEventListener("beginPresentation", beginPresentation);
			
			sideMenu = new TheMenu();
			sideMenu.x = 0; sideMenu.y = 0;
			sideMenu.addEventListener(MenuEvent.MENU_EVENT, menuClicked, false, 0, true);
			addChild(sideMenu);			
		}
		
		
		private function menuClicked(e:MenuEvent):void
		{
			
			var whichBtn:String = e.params.btn; //menu button - overview, components, benefits, requirements
			var fileToLoad:String;
			
			if (whichBtn == "overview") {
				checkForBarScene();
				//use naming convention - (brand_menuButtonName.swf) - ie. marlboro_overview.swf 
				//fileToLoad = setup.getBrand().toLowerCase() + "_" + whichBtn + ".swf";
				myLoader.load(new URLRequest("overview.swf"));
				myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, contentLoaded, false, 0, true);
			}
			
			if (whichBtn == "components") {
				barScene.x = 220;
				barScene.y = 10;
				addChild(barScene);
				barScene.loadBar(setup.getVenue(), setup.getVenueFile(), setup.getFacilityType(), setup.getBrand());
			}
			
			if (whichBtn == "requirements") {
				checkForBarScene();
				fileToLoad = "programRequirements.swf";
				myLoader.load(new URLRequest(fileToLoad));
				myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, contentLoaded, false, 0, true);
			}

			if (whichBtn == "benefits") {
				checkForBarScene();
				fileToLoad = "programBenefits.swf";
				myLoader.load(new URLRequest(fileToLoad));
				myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, contentLoaded, false, 0, true);
			}
			
			if (whichBtn == "setup") {
				if (contains(myLoader)) { removeChild(myLoader); }
				removeChild(sideMenu);
				checkForBarScene();
				addSetup();
			}
			
		}
		
		private function checkForBarScene():void 
		{
			if (contains(barScene)) {
				barScene.removeBar();
				removeChild(barScene);
			}
		}
		
		
		private function contentLoaded(e:Event):void
		{
			myLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, contentLoaded);
			addChild(myLoader);
			MovieClip(myLoader.content).init(setup.getBrand(), setup.getFacilityType());
			myLoader.x = 220;
			myLoader.y = 10;
		}
		
	}
	
}