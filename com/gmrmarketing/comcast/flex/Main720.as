//VOD Server - 1280x720 - desktop version

package com.gmrmarketing.comcast.flex
{
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import com.gmrmarketing.utilities.Utility;
	import flash.events.*;	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import com.gmrmarketing.comcast.flex.MenuButton;	
	import com.gmrmarketing.website.VPlayer;
	import flash.system.fscommand;
	import flash.ui.Mouse;	
	import com.greensock.TweenMax;
	import com.gmrmarketing.comcast.flex.Drops;
	

	public class Main720 extends MovieClip
	{
		private var introText:MovieClip;		
		private var menuLoader:URLLoader;
		private var menuXML:XML;
		private var upperLeft:MovieClip; //contains comcast logo and time (0,0)
		private var bottomBar:MovieClip; //blue bar at bottom of screen when menus are present
		
		private var curMenu:String = ""; //name of the current menu in the xml
		private var curMenuPosition:int; //index to start at - only 10 buttons go on screen at a time
		private var selectedButton:int; //index of the currently highlighted button
				
		private var lastMenu:Array = new Array(); //bread crumb for when last/back button on remote is pressed - set in buildMenu()
		
		private var curMenuEndIndex:int; //index of the last button in the currently displayed menu
		private var nextMenuStartIndex:int; //index of the first button when "more" is showing
		private var totalMenuButtons:int; //total number of buttons in the currently picked menu
		
		private var menuContainer:MovieClip;
		
		private var clockTimer:Timer;
		
		private var barker:VPlayer; //player for the barker at upper right
		private var player:VPlayer; //player for the main video
		
		private var barkerContainer:MovieClip;
		
		private var more:moreChoices; //lib clip
		
		private var theList:listing; //lib clip
		private var curList:String;
		private var curListPosition:int; //set to 0 in displayList
		private var selectedListButton:int;
		private var totalListItems:int; //number of total items in the current list
		
		private var mainInfo:infoScreen;
		private var theRatingIcon:MovieClip; //rating icon used within the info screen
		private var currentIcon:int = 0; //index in infoIcons of the currently highlighted icon
		private var infoIcons:Array; //the icons at lower left
		private var currentMainVideo:String; //name of the main video to play - set in showListingInfo()
		
		private var progress:progressBar; //lib clip
		private var progressBarUpdater:Timer; //used for polling the player every n seconds to get the playhead time
		private var progressBarTimer:Timer; //used for auto hiding the progress bar
		private var pixelsPerSecond:Number; //ratio for the progress bar - set in updateEndTime
		
		private var speedTimer:Timer; //used for fastForward / rewind
		
		private var timeoutHelper:TimeoutHelper;
		private var attractClip:screenSaver; //library clip
		private var hd:Drops;
		
		private var blacker:blackBack; //lib clip
		
		private var keysOK:Boolean = true;
		private var keyOKTimer:Timer;
		
		
		public function Main720()
		{	
			fscommand("allowscale", "true");
			fscommand("fullscreen", "true");
			
			Mouse.hide();
			
			blacker = new blackBack();
			
			timeoutHelper = TimeoutHelper.getInstance();
			
			mainInfo = new infoScreen();
			infoIcons = new Array(mainInfo.iconBack, mainInfo.iconBuy, mainInfo.iconLock, mainInfo.iconPreview);
			
			barkerContainer = new MovieClip();
			barkerContainer.x = 724;
			barkerContainer.y = 1;
			
			barker = new VPlayer();
			barker.autoSizeOff();
			barker.setSmoothing();
			barker.setVidSize( { width:394, height:312 } );
			
			player = new VPlayer();
			player.autoSizeOff();
			player.setSmoothing();
			player.setVidSize( { width:1280, height:720 } )
			
			menuContainer = new MovieClip();
			
			theList = new listing();
			theList.x = 160;
			theList.y = 315;
			
			more = new moreChoices();			
			
			menuLoader = new URLLoader();
			menuLoader.addEventListener(Event.COMPLETE, menusLoaded, false, 0, true);
			menuLoader.load(new URLRequest("menus.xml"));
			
			enableKeyControlForMenus();
			
			//the progress bar in the library
			progress = new progressBar();
			progress.x = 65;
			progress.y = 558;			
			
			//for updating progress indicator when it's showing
			progressBarUpdater = new Timer(500);
			progressBarUpdater.addEventListener(TimerEvent.TIMER, pollPlayer, false, 0, true);
			
			//for autohiding progress bar after 5 seconds
			progressBarTimer = new Timer(5000, 1);
			progressBarTimer.addEventListener(TimerEvent.TIMER, hideProgressBar, false, 0, true);
			
			speedTimer = new Timer(100);
			
			//handles ON Demand and Last buttons globally
			stage.addEventListener(KeyboardEvent.KEY_DOWN, globalKeyHandler, false, 0, true);
			
			keyOKTimer = new Timer(1500, 1);
			keyOKTimer.addEventListener(TimerEvent.TIMER, setKeysOK);
		}
		
		
		
		private function enableKeyControlForMenus():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, listKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, infoScreenKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, videoKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, menuKeyPressed, false, 0, true);
		}
		
		
		
		private function enableKeyControlForLists():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, menuKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, infoScreenKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, videoKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, listKeyPressed, false, 0, true);
		}
		
		
		
		private function enableKeyControlForInfoScreen():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, listKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, menuKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, videoKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, infoScreenKeyPressed, false, 0, true);
		}
		
		
		
		private function enableKeyControlForVideo():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, listKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, menuKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, infoScreenKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, videoKeyPressed, false, 0, true);
		}
		
		
		/**
		 * Removes all key listeners
		 * leaves only the global listener that listens for o and l
		 */
		private function enableAttractLoopKeyControl():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, listKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, menuKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, infoScreenKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, videoKeyPressed);
		}		
		
		
		private function menusLoaded(e:Event):void
		{
			menuXML = new XML(e.target.data);			
			
			timeoutHelper.init(60000 * Number(menuXML.screenSaverTimeoutMinutes));			
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, showAttract, false, 0, true);
			timeoutHelper.startMonitoring();
			
			showIntro();
		}
		
		
		private function showIntro():void
		{
			introText = new welcome(); //lib clip			
			addChild(introText);
			
			var iTimer:Timer = new Timer(2000, 1);
			iTimer.addEventListener(TimerEvent.TIMER, removeIntroText, false, 0, true);
			iTimer.start();
		}		
		
		
		private function removeIntroText(e:TimerEvent):void
		{
			removeChild(introText);
			introText = null;
			
			//upper left info
			if(upperLeft == null){
				upperLeft = new UL(); //library clip
				addChild(upperLeft);
				upperLeft.x = 160;
			}
			
			if(bottomBar == null){
				bottomBar = new bottomBarMenu(); //lib clip
				bottomBar.x = 160;
				bottomBar.y = 677;// 700;// 668;
				addChild(bottomBar);
			}
			
			startClock();
			
			buildMenu("ondemand", 0);
			
			addChild(barkerContainer);
			
			barker.showVideo(barkerContainer);			
			barker.playVideo("video/ebarker.mp4");
			
			//loops the barker if it ends
			barker.addEventListener(VPlayer.STATUS_RECEIVED, barkerStatus, false, 0, true);
		}
		
		
		
		private function buildMenu(whichMenu:String, menuIndex:int, fromLast:Boolean = false):void
		{			
			var curButton:MovieClip ;
			
			upperLeft.listDataHolder.visible = false;
			
			//show ON Demand text
			upperLeft.od.visible = true;			
			
			removeMainInfoScreen();
			hideProgressBar();
			
			
			if (barker.isPaused()) {
				barker.resumeVideo();
			}
			
			//check for list
			var tMenu:XMLList = menuXML.menu.(@name == whichMenu && @list == "true").button;
			
			//Menu if length is 0, otherwise this is a list
			if(tMenu.length() == 0){			
				
				enableKeyControlForMenus();
				
				//show menu selection in ON Demand within upperLeft								
				upperLeft.od.theText.text = menuXML.menu.(@name == whichMenu).@display;				
				
				if (contains(theList)) { removeChild(theList); }
				
				if (curMenu != "" && !fromLast) {
					if(lastMenu[lastMenu.length - 1] != curMenu){
						//trace("pushing", curMenu);
						lastMenu.push(curMenu); //breadcrumb for when last/back button is pressed
					}
				}
				
				curMenu = whichMenu;
				curMenuPosition = menuIndex;	
				
				if(!contains(menuContainer)){
					addChild(menuContainer);
				}
				menuContainer.x = 160; 
				menuContainer.y = 320;
				
				//clear menu - removes more button too
				while (menuContainer.numChildren) {
					menuContainer.removeChildAt(0);
				}
				
				//all buttons in the currently displayed menu			
				var theMenu:XMLList = menuXML.menu.(@name == curMenu).button;
				totalMenuButtons = theMenu.length();
				
				//always show the more button - arrows are what change
				addMoreButton();
				more.visible = true;
				more.arrowUp.visible = true;
				more.arrowDown.visible = true;
				
				curMenuEndIndex = curMenuPosition + 10; //10 menu buttons at a time
				if (curMenuEndIndex >= theMenu.length()) {
					curMenuEndIndex = theMenu.length();
					
					//hide more button down arrow - if curMenuPosition is 0 then hide entire more button
					more.arrowDown.visible = false;
					if (curMenuPosition == 0) {
						//at beginning of menu - and not even 10 buttons - hide more
						more.visible = false;
					}
				}				
				
				if (curMenuPosition == 0) {
					more.arrowUp.visible = false;
				}
				
				if (curMenuEndIndex < theMenu.length() - 1) {					
					nextMenuStartIndex = curMenuEndIndex + 1;
				}
				
				var pos:Array;
				var btnIndex:int = 1;
				
				selectedButton = curMenuPosition;
				for (var i:int = curMenuPosition; i < curMenuEndIndex; i++) {
					pos = Utility.gridLoc(btnIndex, 2);
					
					var btn:MovieClip = new MenuButton();
					menuContainer.addChild(btn);
					btn.theText.text = theMenu[i];
					btn.currentText = theMenu[i];
					btn.buttonIndex = i;
					btn.theMenu = theMenu[i].@menu;
					btn.addEventListener("buttonHighlighted", updateUpperLeftText, false, 0, true);
					
					//highlight the first button by default
					if (btnIndex == 1) {
						btn.highlight();
					}
					
					btn.x = 68 + ((pos[0] - 1) * 417);
					btn.y = 22 + ((pos[1] - 1) * 57);
					
					btnIndex++;
				}
				
			}else {
				//length was not 0 - so this is a list
				if (curMenu != "" && !fromLast) {
					//trace("pushing", curMenu);
					lastMenu.push(curMenu); //breadcrumb for when last/back button is pressed
				}
				
				displayList(whichMenu, menuXML.menu.(@name == whichMenu).@display);
			}
		}
		
		
		
		private function menuKeyPressed(e:KeyboardEvent):void
		{
			var whichKey:int = e.keyCode;
			
			timeoutHelper.buttonClicked();
			
			if (whichKey == 37) {
				//left arrow - only works from right column
				if (selectedButton % 2 != 0) {
					changeHighlight(selectedButton, false);
					selectedButton -= 1;
					changeHighlight(selectedButton, true);
				}
			}
			if (whichKey == 38) {
				//up arrow
				if(selectedButton >= 2){
					changeHighlight(selectedButton, false);
					selectedButton -= 2;					
					changeHighlight(selectedButton, true);
					if (selectedButton < curMenuPosition && curMenuPosition > 0) {
						buildMenu(curMenu, curMenuPosition - 10);
					}
				}
			}
			if (whichKey == 39) {
				//right arrow - only works from left column
				if (selectedButton % 2 == 0) {
					if(selectedButton + 1 < totalMenuButtons){
						changeHighlight(selectedButton, false);
						selectedButton += 1;
						changeHighlight(selectedButton, true);
					}
				}
			}
			if (whichKey == 40) {
				//down arrow
				changeHighlight(selectedButton, false);
				selectedButton += 2;
				if (selectedButton >= curMenuEndIndex) {
					//go to next section of current menu if it's there
					if(selectedButton < totalMenuButtons){
						buildMenu(curMenu, curMenuEndIndex);
					}else {
						selectedButton -= 2;
						changeHighlight(selectedButton, true);
					}
				}else{
					changeHighlight(selectedButton, true);
				}
			}
			
			if (whichKey == 13 && keysOK) {
				//enter
				var curButton:MovieClip = getMenuButton(selectedButton);
				
				if (curButton.theMenu != "") {					
					buildMenu(curButton.theMenu, 0);
				}else {
					curButton.normal();
					curButton.notAvailable();
				}
			}
			
		}
		
		
		private function setKeysOK(e:TimerEvent):void
		{
			keysOK = true;
		}
		private function globalKeyHandler(e:KeyboardEvent):void
		{
			var whichKey:int = e.keyCode;
			
			timeoutHelper.buttonClicked();
			
			if (whichKey == 79) {
				if (keysOK) {					
					keysOK = false;
					keyOKTimer.reset();
					keyOKTimer.start();
					//o - on demand button
					if (attractClip) {
						if (contains(attractClip)) {
							hd.stop();
							attractClip.logo.doStop();
							removeChild(attractClip);
							attractClip = null;
							timeoutHelper.startMonitoring();
							showIntro();
						}
					}else{
						lastMenu = new Array(); //clear breadcrumbs
						curMenu = "";
						buildMenu("ondemand", 0);
					}
				}
			}
			
			if (whichKey == 76) {
				var theLast:String;
				// l - last button -- not avail if attract loop is showing
				if (attractClip) {
					if (!contains(attractClip)) {
						if (lastMenu.length != 0) {
							theLast = lastMenu.pop();
							buildMenu(theLast, 0, true);
						}
					}
				}else {
					//attract clip still null
					if (lastMenu.length != 0) {
						theLast = lastMenu.pop();
						buildMenu(theLast, 0, true);
					}
					
				}
			}
		}
		
		
		
		private function changeHighlight(ind:int, onOff:Boolean):void
		{
			var i:int = menuContainer.numChildren;
			for (var j:int = 0; j < i; j++) {
				if (MovieClip(menuContainer.getChildAt(j)).buttonIndex == ind) {
					if (onOff) {
						MovieClip(menuContainer.getChildAt(j)).highlight();
					}else {
						MovieClip(menuContainer.getChildAt(j)).normal();
					}
					break;
				}
			}
		}
		
		
		
		/**
		 * Retrieves theMenu from the current buttonIndex - the highlighted button
		 * theMenu is injected into the button within buildMenu
		 * 
		 * @param	ind
		 * @return
		 */
		private function getMenuButton(ind:int):MovieClip
		{
			var i:int = menuContainer.numChildren;
			for (var j:int = 0; j < i; j++) {
				if (MovieClip(menuContainer.getChildAt(j)).buttonIndex == ind) {
					return MovieClip(menuContainer.getChildAt(j));
					break;
				}
			}
			return null;
		}
		
		
		
		private function addMoreButton():void
		{
			more.x = 360;
			more.y = 316;
			menuContainer.addChild(more);			
		}
		
		
		
		/**
		 * Used when a menu is displayed
		 * Called whenever a button is highlighted
		 * @param	e
		 */
		private function updateUpperLeftText(e:Event):void
		{
			upperLeft.theSelection.text = e.currentTarget.theText.text;
		}
		
		
		
		/**
		 *
		 * @param	e
		 */
		private function advanceMenu(e:MouseEvent):void
		{
			curMenuPosition += 10;
			buildMenu(curMenu, curMenuPosition);
		}
		
		
		
		private function startClock():void
		{
			clockTimer = new Timer(30000);
			clockTimer.addEventListener(TimerEvent.TIMER, updateClock, false, 0, true);
			clockTimer.start();
			
			updateClock();
		}
		
		
		
		private function updateClock(e:TimerEvent = null):void
		{
			var time:Date = new Date();
			var ampm:String = "am";
			var h:int = time.getHours();
			var m:String = String(time.getMinutes());
			if (m.length == 1) {
				m = "0" + m;
			}
			if (h > 11) {
				ampm = "pm";
			}
			if (h > 12) {
				h -= 12;
			}
			upperLeft.theTime.text = h + ":" + m + ampm;
			
			if (contains(mainInfo)) {
				mainInfo.theTime.text = h + ":" + m + ampm;
			}
		}
		
		
		
		private function displayList(whichList:String, listTitle:String = ""):void
		{		
			enableKeyControlForLists();
			
			if(!contains(theList)){
				addChild(theList);
			}
			theList.theTitle.text = listTitle;
			
			curListPosition = 0;
			curList = whichList;
			
			//erase any text in the upper left from the menu display
			upperLeft.theSelection.text = "";
			//hide ON Demand text
			upperLeft.od.visible = false;
			
			//clear data holder for list items
			upperLeft.listDataHolder.visible = true;
			upperLeft.listDataHolder.theTitle.text = "";
			upperLeft.listDataHolder.thePrice.text = "";
			upperLeft.listDataHolder.theLength.text = "";
			upperLeft.listDataHolder.theYear.text = "";
			upperLeft.listDataHolder.theDescription.text = "";
			
			selectedListButton = 1;
			populateList();
			
			enableKeyControlForLists();
			
		}
		
		
		
		private function populateList():void
		{
			var thisItem:MovieClip;
			var i:int;
			
			//clear old listing
			for (i = 1; i < 8; i++) {
				thisItem = theList["item" + i];
				thisItem.normal();
				thisItem.theText.text = "";
				thisItem.theNew.text = "";
				thisItem.theMenu = "";
				thisItem.theData = { target:"", length:"", available:"", price:"", year:"", rating:"", description:"" };
				thisItem.removeEventListener("listingItemHighlighted", showListingInfo);
			}
			
			var list:XMLList = menuXML.menu.(@name == curList).button;
			totalListItems = list.length();
			var curIndex:int = 1;			
			
			if (curListPosition < 0) {
				curListPosition = 0;
				selectedListButton = 1;
			}			
			
			//arrow buttons
			theList.upArrow.visible = false;
			theList.downArrow.visible = true;
			if (curListPosition > 0) {
				theList.upArrow.visible = true;
			}
			
			var lastListItem:int = curListPosition + 7;
			
			if (lastListItem > totalListItems) { 
				lastListItem = totalListItems;
				theList.downArrow.visible = false;
			}
			
			for (i = curListPosition; i < lastListItem; i++) {
				thisItem = theList["item" + curIndex];
				thisItem.theText.text = list[i];
				thisItem.currentText = list[i];
				thisItem.theMenu = list[i].@menu;
				
				//populate data object
				if(list[i].@target.length() != 0){
					thisItem.theData.target = list[i].@target;
					thisItem.theData.length = list[i].@length;
					thisItem.theData.available = list[i].@available;
					thisItem.theData.price = list[i].@price;
					thisItem.theData.year = list[i].@year;
					thisItem.theData.rating = list[i].@rating;
					thisItem.theData.description = list[i].@description;
				}
				
				thisItem.addEventListener("listingItemHighlighted", showListingInfo, false, 0, true);
				curIndex++;
			}
			
			theList["item" + selectedListButton].highlight();
		}
		
		
		
		private function listKeyPressed(e:KeyboardEvent):void
		{
			var whichKey:int = e.keyCode;
			
			timeoutHelper.buttonClicked();
			
			if (whichKey == 38) {
				//up arrow
				theList["item" + selectedListButton].normal();
				selectedListButton--;
				if (selectedListButton < 1) {
					curListPosition -= 7;
					selectedListButton = 7;
					populateList();
				}else{
					theList["item" + selectedListButton].highlight();
				}
			}
			
			if (whichKey == 40) {
				//down arrow				
				if (selectedListButton + curListPosition < totalListItems) {
					theList["item" + selectedListButton].normal();
					selectedListButton++;
					if (selectedListButton > 7) {
						curListPosition += 7;
						selectedListButton = 1;
						populateList();
					}else{
						theList["item" + selectedListButton].highlight();
					}
				}
			}
			
			if (whichKey == 13) {
				//Enter - OK/Select
				var nextMen:String = theList["item" + selectedListButton].theMenu;
				var targ:String = theList["item" + selectedListButton].theData.target;
				
				if (nextMen != "") {
					//if a listItem has a menu property - it is another list menu
					lastMenu.push(curList); //push current list to lastMenu array
					displayList(nextMen, theList["item" + selectedListButton].theText.text);
				}else{
				
					//if targ has data need to show the info screen (mainInfo) where user can buy/play/etc.
					if (targ != "") {
						lastMenu.push(curList);
						showMainInfoScreen();
					}else {
						theList["item" + selectedListButton].normal()
						theList["item" + selectedListButton].notAvailable();
					}
				}
			}
		}
		
		
		
		/**
		 * Called by listener when an item is highlighted
		 * @param	e
		 */
		private function showListingInfo(e:Event):void
		{			
			//{ target:"", length:"", available:"", price:"", year:"", rating:"", description:"" }
			
			var theData:Object = e.currentTarget.theData;
			
			currentMainVideo = theData.target;
			
			upperLeft.listDataHolder.theTitle.text = e.currentTarget.theText.text;
			upperLeft.listDataHolder.thePrice.text = theData.price;
			upperLeft.listDataHolder.theLength.text = theData.length;
			upperLeft.listDataHolder.theYear.text = theData.year;
			upperLeft.listDataHolder.theDescription.htmlText = theData.description;
			
			//update the progress bar component with the data
			progress.theTitle.text = e.currentTarget.theText.text;
			progress.prog.x = 168; //progress bar vertical line indicator - starting position at video 0:00
			progress.sTime.text = "0:00";
			progress.eTime.text = "-:--";
			progress.cTime.text = "0:00";
			progress.theButton.gotoAndStop("play"); //show play icon
		}
		
		
		
		/**
		 * Key listener for when the main info screen is showing
		 * cycles through the icons at the bottom
		 * only allows left, right, enter
		 * @param	e
		 */
		private function infoScreenKeyPressed(e:KeyboardEvent):void
		{
			var whichKey:int = e.keyCode;
			
			timeoutHelper.buttonClicked();
			
			if (whichKey == 37) {
				//left
				infoIcons[currentIcon].normal();
				currentIcon--;
				if (currentIcon < 0) { 
					currentIcon = infoIcons.length - 1;
				}
				
			}
			if (whichKey == 39) {
				//right
				infoIcons[currentIcon].normal();
				currentIcon++;
				if (currentIcon >= infoIcons.length) {
					currentIcon = 0;
				}
			}
			infoIcons[currentIcon].highlight();
			
			if (whichKey == 13  && keysOK) {
				//enter
				if (currentIcon == 0) {
					//last button - same as pressing last on the remote
					if (lastMenu.length != 0) {
						var theLast:String = lastMenu.pop();
						buildMenu(theLast, 0, true);
					}
				}
				if (currentIcon == 1) {
					//buy or eye button - either way play the video
					playMainVideo();
				}
			}
		}
		
		
		
		private function removeMainInfoScreen():void
		{
			if (contains(mainInfo)) {
				if(theRatingIcon != null){
					mainInfo.removeChild(theRatingIcon);
				}
				
				removeChild(mainInfo);
			}
			
			hideBlacker();
			player.hideVideo();
			progressBarUpdater.reset();
		}
		
		
		
		/**
		 * Called when Enter is pressed on a list item that has a target
		 */
		private function showMainInfoScreen():void
		{
			enableKeyControlForInfoScreen();
			
			if (!contains(mainInfo)) {
				addChild(mainInfo);
			}
			mainInfo.x = 160;
			
			//position CC and Dolby icons
			mainInfo.iconCC.x = 720;
			mainInfo.iconDolby.x = 770;
			mainInfo.iconDollar.x = 866;
			
			barker.pauseVideo();
			
			updateClock();
			
			var whichItem:ListingItem = theList["item" + selectedListButton];
			var theData:Object = whichItem.theData;
			
			mainInfo.theDescription.htmlText = theData.description;
			mainInfo.thePrice.text = theData.price;
			mainInfo.theYear.text = theData.year;
			mainInfo.theTitle.text = whichItem.theText.text;
			mainInfo.theLength.text = theData.length;		
			
			//shows BUY in the button
			mainInfo.iconBuy.gotoAndStop(1);
			
			var rating:String = theData.rating;
			switch(rating) {
				case "R":
					theRatingIcon = new ratingR(); //lib clip
					break;
				case "TV-14":
					theRatingIcon = new ratingTV14();
					break;
				case "TV-Y":
					theRatingIcon = new ratingTVY();
					break;
				case "TV-MA":
					theRatingIcon = new ratingTVMA();
					break;
				case "TV-G":
					theRatingIcon = new ratingTVG();
					break;
				default:
					theRatingIcon = null;
					break;
			}
			
			if (theRatingIcon != null) {
				
				theRatingIcon.x = 820;
				theRatingIcon.y = 197;
				
				//hide dollar sign and slide icons to the right if this is free
				if (theData.price == "Free") {
					mainInfo.iconDollar.visible = false;
					mainInfo.iconCC.x = 752;
					mainInfo.iconDolby.x = 802;
					theRatingIcon.x = 852;
					
					//show eye in the buy button
					mainInfo.iconBuy.gotoAndStop(2);
				}				
				
				mainInfo.addChild(theRatingIcon);
			}else {
				
				//this video has no rating
				if (theData.price == "Free") {
					mainInfo.iconDollar.visible = false;
					mainInfo.iconCC.x = 802;
					mainInfo.iconDolby.x = 852;
					
					//show eye in the buy button
					mainInfo.iconBuy.gotoAndStop(2);
				}
			}
			
			//highlight buy/free button by default
			for (var i:int = 0; i < infoIcons.length; i++) {
				infoIcons[i].normal();
			}
			currentIcon = 1;
			infoIcons[currentIcon].highlight();
		}
		
		
		
		private function playMainVideo ():void
		{
			stopSeeking();
			
			if (!contains(blacker)) {
				addChild(blacker);
			}
			player.showVideo(this);
			player.addEventListener(VPlayer.STATUS_RECEIVED, vidStatus, false, 0, true);			
			player.playVideo(currentMainVideo); //currentMainVideo is set in showListingInfo()
			//listen for metaData and show progress when received
			player.addEventListener(VPlayer.META_RECEIVED, updateEndTime, false, 0, true);
			
			enableKeyControlForVideo();
		}
		
		
		
		/**
		 * Called by listener once metaData has been received for the playing video
		 * Intiially shows progress bar for 5 seconds
		 * @param	e
		 */
		private function updateEndTime(e:Event):void
		{
			player.removeEventListener(VPlayer.META_RECEIVED, updateEndTime);
			var dur:Number = player.getDuration();
			
			var size:Object = player.getVidSize();
			var ratio:Number = 1280 / size.width;
			if (ratio * size.height > 720) {
				ratio = 720 / size.height;
			}
			
			player.setVidSize( { width:size.width * ratio, height:size.height * ratio } );
			
			player.centerVideo(1280, 720);
			
			var min:int = Math.floor(dur / 60);
			var sec:int = dur % 60;
			
			if(sec < 10){
				progress.eTime.text = min + ":0" + sec;
			}else {
				progress.eTime.text = min + ":" + sec;
			}
			
			pixelsPerSecond = 850 / dur; //850 is total width of progress bar
			
			showProgressBar();
			autoHideProgressBar();
		}
		
		
		
		private function autoHideProgressBar():void
		{
			//start timer for autohiding the bar
			progressBarTimer.reset();
			progressBarTimer.start();
		}
		
		
		
		/**
		 * Called by timer when the progressBarUpdater timer is running
		 * @param	e
		 */
		private function pollPlayer(e:TimerEvent):void
		{
			var curSec:Number = player.getPlayheadTime();
			
			var ip:Number = 168 + (curSec * pixelsPerSecond);
			
			progress.prog.x = ip;
			
			var min:int = Math.floor(curSec / 60);
			var sec:int = curSec % 60;
			
			if(sec < 10){
				progress.cTime.text = min + ":0" + sec;
			}else {
				progress.cTime.text = min + ":" + sec;
			}
		}
		
		
		
		private function showProgressBar():void
		{
			if (!contains(progress)) {
				addChild(progress);
			}
			
			//start timer running so pollPlayer() runs
			progressBarUpdater.start();
		}
		
		
		
		/**
		 * Called after 5 seconds by progressBarTimer
		 * @param	e
		 */
		private function hideProgressBar(e:TimerEvent = null):void
		{
			progressBarTimer.reset();
			
			if (contains(progress)) {
				removeChild(progress);
			}
			
			//stop calling pollPlayer()
			progressBarUpdater.reset();
		}
		
		
		
		private function videoKeyPressed(e:KeyboardEvent):void
		{
			var whichKey:int = e.keyCode;
			
			timeoutHelper.buttonClicked();
			
			if (whichKey == 85) {
				//pause - u key
				stopSeeking();
				player.pauseVideo();
				showProgressBar();
				progress.theButton.gotoAndStop("pause");
				autoHideProgressBar();
			}
			if (whichKey == 80) {
				//play - p key
				stopSeeking();
				player.resumeVideo();
				showProgressBar();
				progress.theButton.gotoAndStop("play");
				autoHideProgressBar();
			}
			if (whichKey == 83) {
				//stop - s key
				stopSeeking();
				player.stopVideo();
				showProgressBar();
				progress.theButton.gotoAndStop("stop");
				autoHideProgressBar();
			}
			if (whichKey == 82) {
				//rewind - r key
				speedTimer.addEventListener(TimerEvent.TIMER, rewindSeek, false, 0, true);
				speedTimer.removeEventListener(TimerEvent.TIMER, ffSeek);
				speedTimer.start();
				progressBarTimer.reset();
				showProgressBar();
				progress.theButton.gotoAndStop("rewind");
			}
			if (whichKey == 70) {
				//fastForward - f key
				speedTimer.addEventListener(TimerEvent.TIMER, ffSeek, false, 0, true);
				speedTimer.removeEventListener(TimerEvent.TIMER, rewindSeek);				
				speedTimer.start();
				progressBarTimer.reset();
				showProgressBar();
				progress.theButton.gotoAndStop("fastForward");
			}
		}
		
		
		
		private function stopSeeking():void
		{
			speedTimer.reset();
			speedTimer.removeEventListener(TimerEvent.TIMER, rewindSeek);
			speedTimer.removeEventListener(TimerEvent.TIMER, ffSeek);			
		}
		
		
		
		private function ffSeek(e:TimerEvent):void
		{
			player.forward();
		}
		
		
		
		private function rewindSeek(e:TimerEvent):void
		{
			player.rewind();
		}
		
		
		private function hideBlacker():void
		{
			if (contains(blacker)) {
				removeChild(blacker);
			}
		}
		
		
		private function vidStatus(e:Event):void
		{
			if (player.getStatus() == "NetStream.Play.Stop") {
				player.hideVideo();
				hideProgressBar();
				hideBlacker();
				
				//disable video key control
				enableKeyControlForInfoScreen();
			}
		}
		
		
		
		private function barkerStatus(e:Event):void
		{
			if (barker.getStatus() == "NetStream.Play.Stop") {
				//loop
				barker.playVideo("video/ebarker.mp4");
			}
		}
		
		
		private function showAttract(e:Event):void
		{
			player.hideVideo();
			hideBlacker();
			hideProgressBar();
			barker.pauseVideo();
			
			timeoutHelper.stopMonitoring();
			
			enableAttractLoopKeyControl();
			
			if (attractClip == null) {
				attractClip = new screenSaver();
				hd = new Drops(attractClip);
			}
			if (!contains(attractClip)) {
				addChild(attractClip);
			}
			attractClip.logo.doStart();			
		}
		
	}
	
}