//VOD server iPad

package com.gmrmarketing.comcast.vodipad
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import com.gmrmarketing.utilities.Utility;
	import flash.events.*;	
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import com.gmrmarketing.comcast.flex.MenuButton;
	import com.gmrmarketing.comcast.flex.ListingItem;
	import com.gmrmarketing.website.VPlayer;
	import flash.system.fscommand;
	import flash.ui.Mouse;
	import com.greensock.TweenMax;
	import com.gmrmarketing.comcast.flex.Drops;
	import com.gmrmarketing.comcast.scratchoff.PrizeWheel;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.comcast.vodipad.Admin2;
	import com.gmrmarketing.comcast.vodipad.WinPaths;
	import com.gmrmarketing.comcast.vodipad.Reporting;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	

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
		
		private var hd:Drops;
		
		private var blacker:blackBack; //lib clip
		
		//private var keysOK:Boolean = true;
		///private var keyOKTimer:Timer;
		
		private var lastButton:MovieClip;		
		
		//Game vars
		private const GAME_TIME:int = 30;
		private var winStrings:Array; //clip names to find
		private var theWinner:String; //string from the winStrings array
		private var secTimer:Timer; //calls updateCountdown every 1 sec
		private var currentCount:int; //current number of seconds remaining
		private var beginScreen:MovieClip; //beginGame lib clip
		private var endScreen:MovieClip;
		private var spinner:PrizeWheel;
		private var cornerAdmin:CornerQuit;
		private var admin:Admin2;
		private var spinBG:MovieClip;
		private var prizeDialog:MovieClip;
		
		private var menuJump:String;
		private var menuJumpTimer:Timer;
		
		private var channel:SoundChannel;
		private var sound:Sound;
		private var buzzSound:Sound;
		private var vol:SoundTransform;
		
		private var reporting:Reporting; //file class
		
		
		
		public function Main720()
		{			
			winStrings = WinPaths.getFreedomRegionWinPaths();
			
			blacker = new blackBack();
			
			mainInfo = new infoScreen();
			infoIcons = new Array(mainInfo.iconBack, mainInfo.iconBuy, mainInfo.iconLock, mainInfo.iconPreview);
			
			barkerContainer = new MovieClip();
			barkerContainer.x = 596;
			barkerContainer.y = 23;
			
			barker = new VPlayer();
			barker.autoSizeOff();
			barker.setSmoothing();
			barker.setVidSize( { width:394, height:312 } );
			
			player = new VPlayer();
			player.autoSizeOff();
			player.setSmoothing();
			player.setVidSize( { width:1024, height:768 } )
			
			menuContainer = new MovieClip();
			
			theList = new listing();
			theList.x = 32;
			theList.y = 337;
			
			menuLoader = new URLLoader();
			menuLoader.addEventListener(Event.COMPLETE, menusLoaded, false, 0, true);
			menuLoader.load(new URLRequest("menus.xml"));
			
			//keyOKTimer = new Timer(1500, 1);
			//keyOKTimer.addEventListener(TimerEvent.TIMER, setKeysOK);
			
			secTimer = new Timer(1000);
			secTimer.addEventListener(TimerEvent.TIMER, updateCountdown, false, 0, true);
			
			beginScreen = new beginGame();
			endScreen = new endGame();			
			
			spinBG = new spinnerBG(); //lib clip
			
			prizeDialog = new thePrizeDialog();
			prizeDialog.x = 290;
			prizeDialog.y = 246;
			
			barker.showVideo(barkerContainer);
			barker.playVideo("video/ebarker.flv");
			
			cornerAdmin = new CornerQuit();
			cornerAdmin.init(this, "ur");
			cornerAdmin.addEventListener(CornerQuit.CORNER_QUIT, showAdmin, false, 0, true);
			
			menuJumpTimer = new Timer(200, 1);
			menuJumpTimer.addEventListener(TimerEvent.TIMER, doMenuJump, false, 0, true);
			
			sound = new timerBeep(); //library sounds
			buzzSound = new buzzer();
			vol = new SoundTransform();
			vol.volume = .1;
			
			reporting = new Reporting();
		}
		
		
		/**
		 * Called once menus.xml is loaded
		 * @param	e
		 */
		private function menusLoaded(e:Event):void
		{
			menuXML = new XML(e.target.data);	
			init();
		}
		
		
		private function init(e:MouseEvent = null):void
		{
			endScreen.removeEventListener(MouseEvent.CLICK, init);
			
			if (contains(endScreen)) {
				removeChild(endScreen);
			}
			if (contains(prizeDialog)) {
				removeChild(prizeDialog);
			}
			
			//upper left info
			if(upperLeft == null){
				upperLeft = new UL(); //library clip
				addChild(upperLeft);
				upperLeft.x = 32;
				upperLeft.y = 22;
			}
			
			if(bottomBar == null){
				bottomBar = new bottomBarMenu(); //lib clip
				bottomBar.x = 32;
				bottomBar.y = 699;// 677
				addChild(bottomBar);
			}
			bottomBar.btnOD.addEventListener(MouseEvent.CLICK, ODPressed, false, 0, true);
			bottomBar.btnBack.addEventListener(MouseEvent.CLICK, lastPressed, false, 0, true);
			
			startClock();
			
			lastMenu = new Array();
			curMenu = "";
			
			buildMenu("ondemand", 0);
			
			addChild(barkerContainer);
			
			
			//loops the barker if it ends
			barker.addEventListener(VPlayer.STATUS_RECEIVED, barkerStatus, false, 0, true);
			
			//add begin screen that calls startGame on click
			var i:int = Math.floor(Math.random() * winStrings.length);
			theWinner = winStrings[i][0];
			beginScreen.theVid.text = winStrings[i][1];
			upperLeft.theFind.text = winStrings[i][1];
			
			upperLeft.theFind.y = 223 + ((63 - upperLeft.theFind.textHeight) / 2);
			
			upperLeft.theCountdown.text = String(GAME_TIME);
			
			beginScreen.alpha = 0;
			addChild(beginScreen);
			TweenMax.to(beginScreen, 1, { alpha:1, onComplete:addStartListener } );
			
			
			cornerAdmin.moveToTop();
		}
		
		private function addStartListener():void
		{
			beginScreen.addEventListener(MouseEvent.CLICK, startGame, false, 0, true);
		}
		
		
		private function startGame(e:MouseEvent):void
		{
			beginScreen.removeEventListener(MouseEvent.CLICK, startGame);
			removeChild(beginScreen);
			currentCount = GAME_TIME;
			startCountdown();
			reporting.gameStarted();
		}
		
		
		private function gameOver(didWin:Boolean):void
		{			
			endScreen.alpha = 0;
			addChild(endScreen);
			
			cornerAdmin.moveToTop();
			
			secTimer.reset();
			if (didWin) {
				endScreen.t1.text = "Congratulations on finding the XFINITY On Demand video!";
				endScreen.t2.text = "Now spin the prize wheel and don’t forget to check out\nXFINITY On Demand at home!";
				endScreen.t3.text = "TOUCH SCREEN TO SPIN THE WHEEL";
				TweenMax.to(endScreen, 1, { alpha:1, onComplete:addWheelListener } );
				reporting.gameWon();
				//TweenMax.to(endScreen, 1, { alpha:1, onComplete:addInitListener } );	
			}else {
				endScreen.t1.text = "GAME OVER";
				endScreen.t2.text = "";
				endScreen.t3.text = "TOUCH SCREEN TO PLAY AGAIN";
				TweenMax.to(endScreen, 1, { alpha:1, onComplete:addInitListener } );	
				reporting.gameLost();
			}
		}
		
		private function addWheelListener():void
		{
			endScreen.addEventListener(MouseEvent.CLICK, showWheel, false, 0, true);
		}
		
		private function addInitListener():void
		{
			endScreen.addEventListener(MouseEvent.CLICK, init, false, 0, true);
		}
		
		
		private function buildMenu(whichMenu:String, menuIndex:int, fromLast:Boolean = false):void
		{			
			var curButton:MovieClip ;
			
			//upperLeft.listDataHolder.visible = false;
			
			//show ON Demand text
			upperLeft.od.visible = true;			
			
			removeMainInfoScreen();
			
			if (barker.isPaused()) {
				barker.resumeVideo();
			}
			
			//check for list
			var tMenu:XMLList = menuXML.menu.(@name == whichMenu && @list == "true").button;
			
			//Menu if length is 0, otherwise this is a list
			if(tMenu.length() == 0){
				
				//show menu selection in ON Demand within upperLeft								
				upperLeft.od.theText.text = menuXML.menu.(@name == whichMenu).@display;				
				
				if (contains(theList)) { removeChild(theList); }
				
				if (curMenu != "" && !fromLast) {
					if(lastMenu[lastMenu.length - 1] != curMenu){						
						lastMenu.push(curMenu); //breadcrumb for when last/back button is pressed
					}
				}
				
				curMenu = whichMenu;
				curMenuPosition = menuIndex;	
				
				if(!contains(menuContainer)){
					addChild(menuContainer);
				}
				menuContainer.x = 32; 
				menuContainer.y = 350;
				
				//clear menu - removes more button too
				while (menuContainer.numChildren) {
					menuContainer.removeChildAt(0);
				}
				
				//all buttons in the currently displayed menu			
				var theMenu:XMLList = menuXML.menu.(@name == curMenu).button;
				totalMenuButtons = theMenu.length();				
				
				curMenuEndIndex = curMenuPosition + 10; //10 menu buttons at a time
				if (curMenuEndIndex >= theMenu.length()) {
					curMenuEndIndex = theMenu.length();
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
					btn.addEventListener(MouseEvent.CLICK, buttonPressed, false, 0, true);
					
					//highlight the first button by default
					if (btnIndex == 1) {
						//btn.highlight(); //don't highlight on the ipad
						lastButton = btn;
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
		
		
		
		/**
		 * for iPad - called by mouseClicking on a menu button
		 * @param	e
		 */
		private function buttonPressed(e:MouseEvent):void
		{
			if (lastButton != null) {
				lastButton.normal();
			}
			lastButton = MovieClip(e.currentTarget);			
			
			if (lastButton.theMenu != "") {	
				lastButton.highlight();
				menuJump = lastButton.theMenu;
				menuJumpTimer.start();
			}else {
				lastButton.normal();
				lastButton.notAvailable();
			}
		}
		private function doMenuJump(e:TimerEvent):void
		{
			buildMenu(lastButton.theMenu, 0);
		}
		/*
		private function setKeysOK(e:TimerEvent):void
		{
			keysOK = true;
		}
		*/
		private function ODPressed(e:MouseEvent):void
		{
			//if (keysOK) {					
					//keysOK = false;
					//keyOKTimer.reset();
					//keyOKTimer.start();
					//o - on demand button
					
					lastMenu = new Array(); //clear breadcrumbs
					curMenu = "";
					buildMenu("ondemand", 0);					
				//}
		}
		private function lastPressed(e:MouseEvent):void
		{
			//attract clip still null
			if (lastMenu.length != 0) {				
				buildMenu(lastMenu.pop(), 0, true);
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

		
		
		/**
		 * Used when a menu is displayed
		 * Called whenever a button is highlighted
		 * @param	e
		 */
		private function updateUpperLeftText(e:Event):void
		{
			//upperLeft.theSelection.text = e.currentTarget.theText.text;
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
		private function startCountdown():void
		{
			//calls updateCountdown every 1 sec
			secTimer.start();
		}
		private function updateCountdown(e:TimerEvent):void
		{
			currentCount--;
			upperLeft.theCountdown.text = String(currentCount);
			if (currentCount < 11) {
				channel = sound.play();
				channel.soundTransform = vol;
			}
			if (currentCount <= 0) {
				upperLeft.theCountdown.text = "0";
				channel = buzzSound.play();
				gameOver(false);
			}			
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
			if(!contains(theList)){
				addChild(theList);
			}
			theList.theTitle.text = listTitle;
			
			curListPosition = 0;
			curList = whichList;
	
			//hide ON Demand text
			upperLeft.od.visible = false;			
			
			selectedListButton = 1;
			populateList();			
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
			theList.downArrow.visible = false;
			/*
			if (curListPosition > 0) {
				theList.upArrow.visible = true;
			}
			*/
			var lastListItem:int = curListPosition + 7;
			
			if (lastListItem > totalListItems) { 
				lastListItem = totalListItems;
				//theList.downArrow.visible = false;
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
				thisItem.addEventListener(MouseEvent.CLICK, listItemClicked, false, 0, true);
				curIndex++;
			}
			
			//theList["item" + selectedListButton].highlight();
			lastButton = null;
		}
		
		
		private function listItemClicked(e:MouseEvent):void
		{
			if (lastButton != null) {
				lastButton.normal();
			}
			lastButton = MovieClip(e.currentTarget);
			
			var nextMen:String = e.currentTarget.theMenu;
			currentMainVideo = e.currentTarget.theData.target;
			
			if (e.currentTarget.theText.text == theWinner) {
				lastButton.highlight();
				gameOver(true);				
			}else{
			
				if (nextMen != "") {
					//if a listItem has a menu property - it is another list menu
					lastMenu.push(curList); //push current list to lastMenu array
					displayList(nextMen, e.currentTarget.theText.text);
				}else{
				
					//if targ has data need to show the info screen (mainInfo) where user can buy/play/etc.
					if (currentMainVideo != "") {
						lastMenu.push(curList);
						showMainInfoScreen();
					}else {
						e.currentTarget.normal();
						e.currentTarget.notAvailable();
					}
				}
			}
		}
		
		
		private function showWheel(e:MouseEvent):void
		{
			lastMenu = new Array();
			
			endScreen.removeEventListener(MouseEvent.CLICK, showWheel);
			removeChild(endScreen);
			barker.pauseVideo();
			
			removeChild(barkerContainer);
			removeChild(upperLeft);
			removeChild(menuContainer);
			removeChild(bottomBar);
			removeChild(theList);
			
			addChild(spinBG);
			
			spinner = new PrizeWheel(stage);
			spinner.addEventListener("doneSpinning", doneSpinning, false, 0, true);
			addChild(spinner);
		}
		
		
		private function doneSpinning(e:Event):void
		{
			spinner.removeEventListener("doneSpinning", doneSpinning);
			
			//get prize returns a two element array - prize  & description
			var whichPrize:Array = spinner.getPrize();
			
			reporting.addPrize(whichPrize[0]);
			
			prizeDialog.thePrize.htmlText = whichPrize[0] + "<br/>" + whichPrize[1] ;
			prizeDialog.alpha = 0;			
			addChild(prizeDialog);
			TweenMax.to(prizeDialog, 1, { alpha:1, onComplete:listenForReplay } );			
		}
		
		private function listenForReplay():void
		{
			prizeDialog.addEventListener(MouseEvent.CLICK, replay, false, 0, true);
		}
		
		
		private function replay(e:MouseEvent):void
		{
			prizeDialog.removeEventListener(MouseEvent.CLICK, replay);
			removeChild(spinBG);
			removeChild(prizeDialog);
			removeChild(spinner);
			spinner = null;			
			
			addChild(upperLeft);
			addChild(menuContainer);
			addChild(barkerContainer);
			addChild(bottomBar);
			
			init();
		}
		
		
		/**
		 * Called by listener when an item is highlighted
		 * event is dispatched from ListingItem.highlight()
		 * @param	e
		 */
		private function showListingInfo(e:Event):void
		{	
			var theData:Object = e.currentTarget.theData;
			
			currentMainVideo = theData.target;
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
		}
		
		
		
		/**
		 * Called when Enter is pressed on a list item that has a target
		 */
		private function showMainInfoScreen():void
		{
			if (!contains(mainInfo)) {
				addChild(mainInfo);
			}
			mainInfo.x = 32;
			
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
				
				theRatingIcon.x = 692;
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
			infoIcons[currentIcon].addEventListener(MouseEvent.CLICK, playMainVideo, false, 0, true);
		}
		
		
		/**
		 * Called by clicking on the eye/buy icon
		 * @param	e
		 */
		private function playMainVideo (e:MouseEvent = null):void
		{
			if (!contains(blacker)) {
				addChild(blacker);
			}
			player.showVideo(this);
			player.addEventListener(VPlayer.STATUS_RECEIVED, vidStatus, false, 0, true);			
			player.playVideo(currentMainVideo); //currentMainVideo is set in showListingInfo()
			//listen for metaData and show progress when received
			player.addEventListener(VPlayer.META_RECEIVED, updateEndTime, false, 0, true);
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
			var ratio:Number = 1024 / size.width;
			if (ratio * size.height > 768) {
				ratio = 768 / size.height;
			}
			
			player.setVidSize( { width:size.width * ratio, height:size.height * ratio } );
			
			player.centerVideo(1024, 768);
			
			var min:int = Math.floor(dur / 60);
			var sec:int = dur % 60;			
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
				hideBlacker();	
			}
		}		
		
		
		private function barkerStatus(e:Event):void
		{
			if (barker.getStatus() == "NetStream.Play.Stop") {
				//loop
				barker.playVideo("video/ebarker.flv");
			}
		}
		
		
		
		private function showAdmin(e:Event = null):void
		{
			barker.pauseVideo();
			secTimer.stop();			
			admin = new Admin2(reporting.getData());
			addChild(admin);
			admin.addEventListener("closeAdmin", closeAdmin, false, 0, true);
			admin.addEventListener("resetReporting", resetReporting, false, 0, true);
		}
		
		private function closeAdmin(e:Event):void
		{			
			admin.removeEventListener("closeAdmin", closeAdmin);			
			removeChild(admin);
			admin = null;
			init();
		}
		
		private function resetReporting(e:Event):void
		{
			reporting.reset();
			admin.setReportingObject(reporting.getData());
			admin.reportingClicked();
		}
		
	}	
}