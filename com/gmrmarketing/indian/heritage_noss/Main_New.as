/**
 * Uses new GMR Flash keyboard
 * Updated 11/2012
 * 		Removes screen saver
 */
package com.gmrmarketing.indian.heritage_noss
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.ui.Mouse;	
	import net.hires.debug.Stats;	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.geom.*;
	import com.gmrmarketing.indian.heritage.Data;
	import com.gmrmarketing.indian.heritage.BigImage;
	import com.gmrmarketing.indian.heritage.DataStore;
	import com.gmrmarketing.indian.heritage.Admin;
	import com.gmrmarketing.indian.heritage.MainMenu;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.CSVWriter;
	import flash.desktop.NativeApplication; //for quitting
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextField;
	import com.gmrmarketing.website.VPlayer;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.gmrmarketing.utilities.Validator;
	
	
	public class Main_New extends MovieClip
	{
		private static const PILLAR_Y:int = 1005;
		private static const HEARTH_Y:int = 963;
		
		private var swfLoader:Loader;
		
		private var sectionIntro:MovieClip; //intro clip of the current section
		private var imagesNav:MovieClip; //screen two - screen full of images and text
		private var modalBackground:MovieClip; //background for full size image		
		
		private var zoomIcon:MovieClip; //zoom icon to go lower right on detail images
		private var touchAnImage:MovieClip; //touch an image text to go on screen two bottom
		
		private var numImagesInNav:int; //set in loadSection - the number of images on screen two
		private var loopSpacingAdjust:int; //adjustment for looping the titles in the intro screens
		private var initialImageData:Array; //starting locations and sizes for the screen two images - populated in swfLoaded
		
		private var roll:Sprite; //roll image holder for the page roll transition
		private var rollCopy:Bitmap;//bitmap holder for rollCopyData
		private var rollCopyData:BitmapData;//for copying the transition chunk into the roll
		private var rollMask:Shape; //mask shape for removing the intro screen
		private var rollGradient:Bitmap;//library clips
		private var rollHightlight:Bitmap;
		private var rollShadow:Bitmap;
		private var rollX:int; //x loc of the roll
		
		private var introBitmapData:BitmapData;//image of intro screen for copyPixeling from
		
		private var currentImageIndex:int; //currently viewed image in the section - initially set in imageClicked(), modified in prevClicked() and nextClicked()
		private var prevImageIndex:int;
		private var nextImageIndex:int;
		
		private var data:Data;//data object for getting image xml data 
		private var sectionData:DataStore; //for getting and storing the section - racing,heritage, etc
		private var bigImage:BigImage; //for showing the large image when user clicks in detail view
		private var bigClose:MovieClip; //x button in lower left of zoomed image - lib clip
		
		private var timeoutHelper:TimeoutHelper; //for screen saver timeout
		private var cq:CornerQuit;//four tap corner to quit app - upper left
		
		private var adminCorner:CornerQuit;//four tap corner to open admin menu - upper right
		private var adminMenu:Admin; //controller for the admin menu
		private var mainMenu:MainMenu; //controller for the bottom menu
		private var hearthMode:Boolean; //true when the bottom menu nav is showing - set by admin menu in adminSelected()
		private var currentSection:String; //current section - set in loadSection()
		
		private var format:TextFormat; //for changing letterSpacing  in the date field on the detail view - used in showImageData()
		
		private var vPlayer:VPlayer; //for road ahead videos
		
		private var csv:CSVWriter;
		
		private var kbd:KeyBoard;


		
		public function Main_New()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();	
						
			bigClose = new btnClose(); //library clip
			bigClose.x = 22;
			bigClose.y = PILLAR_Y;
			
			bigImage = new BigImage();
			
			zoomIcon = new zoom(); //library clip
			touchAnImage = new touchImage(); //library clip
			touchAnImage.x = 6;			
			
			roll = new Sprite();
			
			rollMask = new Shape();
			rollMask.graphics.beginFill(0xffff00,1);
			rollMask.graphics.drawRect(0,0,1920,1480);			
			rollMask.graphics.endFill();
			
			rollGradient = new Bitmap(new rollGrad());
			rollHightlight = new Bitmap(new rollHigh());
			rollShadow = new Bitmap(new rollShad());
			rollCopyData = new BitmapData(rollGradient.width, rollGradient.height);
			rollCopy = new Bitmap(rollCopyData);
			rollCopy.smoothing = true;
			
			roll.addChild(rollCopy);
			rollCopy.scaleX = -1;
			rollCopy.x = rollGradient.width;
			roll.addChild(rollGradient);
			roll.addChild(rollHightlight);
			roll.addChild(rollShadow);
			rollX = 1920; //starting loc of the roll
			roll.x = rollX;
			rollShadow.x = roll.width;
			
			timeoutHelper = TimeoutHelper.getInstance();
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, doReset, false, 0, true);
			timeoutHelper.init(120000);//two minutes
			timeoutHelper.startMonitoring();
			
			cq = new CornerQuit();
			cq.init(this, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, killApp, false, 0, true);
			
			adminMenu = new Admin();			
			mainMenu = new MainMenu();//bottom menu and main nav for hearth mode
			hearthMode = false;
			
			adminCorner = new CornerQuit();
			adminCorner.init(this, "ur");
			adminCorner.customLoc(1, new Point(1770, 0));
			adminCorner.addEventListener(CornerQuit.CORNER_QUIT, showAdminMenu, false, 0, true);
			
			swfLoader = new Loader();
			
			format = new TextFormat();
			format.letterSpacing = -5;
			format.kerning = true;
			
			sectionData = new DataStore();
			
			vPlayer = new VPlayer();
			vPlayer.showVideo(this);
			vPlayer.useTimeoutHelper(); //calls timeoutHelper.buttonClicked() every 10sec while video is playing			
			
			csv = new CSVWriter();//for writing csv file
			csv.setFileName("indianData.csv"); //file will be on desktop
			
			kbd = new KeyBoard();
			kbd.addEventListener(KeyBoard.KBD, kbdResetTimeout, false, 0, true);//calls timeoutHelper.buttonClicked() whenever a keyboard key is pressed
			kbd.loadKeyFile("indianKeyboard.xml");
			kbd.x = 285;
			kbd.y = 712;
			
			data = new Data();
			data.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			data.addEventListener(Data.ERROR, killApp, false, 0, true);
			data.load();
		}
		
		
		/**
		 * Called when the XML has loaded
		 * @param	e
		 */
		private function xmlLoaded(e:Event):void
		{
			data.removeEventListener(Event.COMPLETE, xmlLoaded);
			data.removeEventListener(Data.ERROR, killApp);
			
			if (sectionData.getSection() == "") {
				//no section defined
				loadSection("all");//show hearth
			}else {
				loadSection(sectionData.getSection());
			}
		}
		
		
		/**
		 * Called if an error occurs loading the XML - app quits
		 * Called by CornerQuit
		 * @param	e
		 */
		private function killApp(e:Event = null):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		/**
		 * Loads the pillar swf
		 * @param	section
		 */
		private function loadSection(section:String = "racing"):void
		{			
			kbd.hide();
			TweenMax.killTweensOf(kbd);
			//uncheckPhone();
			currentSection = section;
			
			switch(currentSection) {
				case "racing":					
					numImagesInNav = 7;
					loopSpacingAdjust = 140;
					break;
				case "heritage":
					numImagesInNav = 6;
					loopSpacingAdjust = 130;
					break;
				case "innovation":
					numImagesInNav = 7;
					loopSpacingAdjust = 150;
					break;
				case "scout":
					numImagesInNav = 5;
					loopSpacingAdjust = 130;
					break;
				case "faithful":
					numImagesInNav = 5;
					loopSpacingAdjust = 120;
					break;
				case "war":
					numImagesInNav = 5;
					loopSpacingAdjust = 170;
					break;
				case "ahead":
					numImagesInNav = 2;
					loopSpacingAdjust = 170;
					break;
			}
			
			if (currentSection == "all" || hearthMode == true) {
				hearthMode = true;				
				mainMenu.show(this);//show bottom menu and bg menu
				cq.moveToTop();
				adminCorner.moveToTop();
				mainMenu.addEventListener(MainMenu.ITEM_PICKED, mainMenuSelection, false, 0, true);
			}
			
			if(currentSection != "all"){
				swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoaded, false, 0, true);
				swfLoader.load(new URLRequest(section + ".swf"));
				
				data.setSection(currentSection);//sets the xml data
				
				mainMenu.hideBG();//hide bg image menu
			}
			
			
		}		
		
		
		/**
		 * Gets the library clips from the loaded swf
		 * Creates the counter below the images
		 * @param	e
		 */
		private function swfLoaded(e:Event):void
		{			
			swfLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, swfLoaded);
			
			//get clip references
			var introRef:Class = e.target.applicationDomain.getDefinition("intro") as Class;
			var imagesRef:Class = e.target.applicationDomain.getDefinition("images") as Class;
			var modalRef:Class = e.target.applicationDomain.getDefinition("imageBG") as Class;
			
			sectionIntro = new introRef() as MovieClip;
			imagesNav = new imagesRef() as MovieClip;			
			modalBackground = new modalRef() as MovieClip;
			
			//for full size image
			if (hearthMode) {
				bigClose.y = HEARTH_Y;
			}else {
				bigClose.y = PILLAR_Y
			}
			bigImage.init(this, bigClose, modalBackground);
			
			initialImageData = new Array();
			for (var i:int = 1; i <= numImagesInNav; i++) {
				initialImageData.push( {x:imagesNav["im" + i].x, y:imagesNav["im" + i].y, width:imagesNav["im" + i].width, height:imagesNav["im" + i].height} );				
			}
			
			if (hearthMode) {
				currentImageIndex = 1;
				showImageNav();
				showTouchAnImage();
			}else{
				//showIntro(); //no screen saver
				removeIntro();
			}
		}
		
		
		/**
		 * Shows the screen saver
		 * Called from swfLoaded() if hearthMode is false
		 * called from doReset() when a timeout occurs
		 * 
		 */
		/*
		private function showIntro():void
		{			
			timeoutHelper.buttonClicked();
			currentImageIndex = 1;
			if(!contains(sectionIntro)){
				addChild(sectionIntro);
			}
			cq.moveToTop();
			adminCorner.moveToTop();
			//addChild(new Stats());
			sectionIntro.addEventListener(Event.ENTER_FRAME, updateTitle, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, removeIntro, false, 0, true);
		}
		*/
		
		
		/**
		 * Moves the title text and logo across the screen
		 * @param	e
		 */
		/*
		private function updateTitle(e:Event):void
		{
			sectionIntro.title.x -= 2;
			if (sectionIntro.title.x < - sectionIntro.title.width / 2 - loopSpacingAdjust) {
				sectionIntro.title.x = 0;
			}
		}
		*/
		
		
		/**
		 * Called by tapping anywhere on the intro screen saver
		 * @param	e
		 */
		private function removeIntro(e:MouseEvent = null):void
		{
			timeoutHelper.buttonClicked();
			
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, removeIntro);
			//sectionIntro.removeEventListener(Event.ENTER_FRAME, updateTitle);
			
			if (hearthMode) {
				//killIntro();
				swfLoader.unload();
				sectionIntro = new MovieClip();
				imagesNav = new MovieClip();
				modalBackground = new MovieClip();
				//bottom nav readded in loadSection if hearthmode is true
				while (numChildren) {
					removeChildAt(0);
				}
				loadSection("all");//show hearth main nav
				
			}else {
				//in a section already
			
				showImageNav();
				showTouchAnImage();
				/*
				introBitmapData = new BitmapData(1920, 1080);
				introBitmapData.draw(sectionIntro);//draws current intro into bitmap for copying into roll
				addChild(rollMask);
				sectionIntro.mask = rollMask;
				
				addChild(roll);
				rollX = 1720; //starting loc of the roll
				roll.rotation = 0;
				rollMask.rotation = 0;
				roll.x = rollX;
				rollMask.x = 0;
				rollMask.y = -200;
				addEventListener(Event.ENTER_FRAME, updateRoll, false, 0, true);	
				*/
			}
		}
		
		
		
		/**
		 * Moves the roll right to left and copyPixels the introBitmapData into it
		 * @param	e
		 */
		/*
		private function updateRoll(e:Event):void
		{
			rollCopyData.copyPixels(introBitmapData, new Rectangle(rollX, 0, 400, 1920), new Point(0,0));
			roll.x = rollX;
			roll.rotation += .1;
			rollX -= 50;
			rollMask.x -= 50;
			rollMask.rotation += .1;
			if (rollX <= -roll.width) {
				killIntro();
			}
		}*/
		
		
		/**
		 * Called from updateRoll once the roll leaves the screen
		 * removes all intro objects
		 * Called from removeIntro() if hearthMode = true
		 */
		/*
		private function killIntro():void
		{	
			timeoutHelper.buttonClicked();
			
			removeEventListener(Event.ENTER_FRAME, updateRoll);
			if(contains(sectionIntro)){
				removeChild(sectionIntro);
			}
			if(contains(roll)){
				removeChild(roll);
			}
			if(contains(rollMask)){
				removeChild(rollMask);
			}
			if(introBitmapData){
				introBitmapData.dispose();
			}
			sectionIntro.mask = null;
		}*/
		
		
		/**
		 * Called from removeIntro() as the roll transtion is starting
		 * Adds the imageNav behind the intro and animates the images on
		 */
		private function showImageNav():void
		{
			cq.moveToTop();
			adminCorner.moveToTop();
			timeoutHelper.buttonClicked();
			addChildAt(imagesNav, 0);//add screen behind intro for page roll transition			
			hideArrows();
			
			TweenMax.from(imagesNav.title, 1, { alpha:0, delay:1 } );
			TweenMax.from(imagesNav.theText, 1, { alpha:0, delay:1 } );			
			
			var fromX:int;
			var fromY:int;
			var fromRot:Number;
			
			for (var i:int = 1; i <= numImagesInNav; i++) {
				
				fromX = Math.round(250 + Math.random() * 300);
				fromY = Math.round(250 + Math.random() * 300);
				
				if (Math.random() < .5) {
					fromX = -fromX;
				}else {
					fromX = 1920 + fromX;
				}
				if (Math.random() < .5) {
					fromY = -fromY;
				}else {
					fromY = 1080 + fromY;
				}
				
				fromRot = 5 + Math.random() * 10;
				if (Math.random() < .5) {
					fromRot = -fromRot;
				}
				
				TweenMax.from(imagesNav["im" + i], .5, { alpha:0, x:initialImageData[i - 1].x + fromX, y:initialImageData[i - 1].y + fromY, rotation:fromRot, delay:.4 + (.15 * (i - 1)) } );
				MovieClip(imagesNav["im" + i]).mouseChildren = false;
				if (currentSection == "ahead") {
					MovieClip(imagesNav["im" + i]).addEventListener(MouseEvent.MOUSE_DOWN, videoClicked, false, 0, true);
				}else{
					MovieClip(imagesNav["im" + i]).addEventListener(MouseEvent.MOUSE_DOWN, imageClicked, false, 0, true);					
				}
			}
			
			//if road ahead show the keyboard and init form
			if (currentSection == "ahead") {
				clearForm();
				TweenMax.delayedCall(1.5, enableForm);
			}
		}
		
		private function showArrows():void
		{
			imagesNav.arrows.visible = true;			
			addArrowListeners();
		}
		private function hideArrows():void
		{
			imagesNav.arrows.visible = false;
		}
		private function addArrowListeners():void
		{			
			//previous next buttons
			imagesNav.arrows.btnPrev.addEventListener(MouseEvent.MOUSE_DOWN, prevClicked, false, 0, true);
			imagesNav.arrows.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextClicked, false, 0, true);
		}
		private function removeArrowListeners():void
		{
			//remove listener to prevent multiple clicking and overwriting tweens - readded in addZoomListener when tweens complete
			imagesNav.arrows.btnPrev.removeEventListener(MouseEvent.MOUSE_DOWN, prevClicked);
			imagesNav.arrows.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextClicked);
		}
		
		/**
		 * Called by clicking any image on screen 2
		 * displays clicked image in center and removes others
		 * shows previous and next buttons
		 * @param	e
		 */
		private function imageClicked(e:MouseEvent):void
		{			
			removeImageListeners();
			timeoutHelper.buttonClicked();
			
			var image:MovieClip = MovieClip(e.currentTarget);
			currentImageIndex = parseInt(image.name.substr(2, 1));
			prevImageIndex = currentImageIndex == 1 ? numImagesInNav : currentImageIndex - 1;
			nextImageIndex = currentImageIndex == numImagesInNav ? 1 : currentImageIndex + 1;
			
			var size:Object = resizeImage();
			
			//fade out bg elements
			TweenMax.to(imagesNav.bg, 1, { alpha:0, onComplete:hideBGElements } );
			TweenMax.to(imagesNav.title, 1, { alpha:0 } );
			TweenMax.to(imagesNav.theText, 1, { alpha:0 } );
			
			//size and position the clicked image
			TweenMax.to(image, .75, { width:size.width, height:size.height, x:180, y:Math.round((1080 - size.height) * .5), onComplete:addZoomListener } );
			imagesNav.detailBG.theDate.theDate.text = "";
			imagesNav.detailBG.theDate.theS.alpha = 0;
			imagesNav.detailBG.description.text = "";
			TweenMax.delayedCall(.75, showImageData, [0]);//wait for image tween to complete before showing data and zoom
			TweenMax.delayedCall(.75, showZoomIcon);
			
			//move previous and next images into positions at left and right
			size = resizeImage(prevImageIndex);
			TweenMax.to(imagesNav["im" + prevImageIndex], .3, { width:size.width, height:size.height, x:-size.width + 150, y:Math.round((1080 - size.height) * .5) } );
			size = resizeImage(nextImageIndex);
			TweenMax.to(imagesNav["im" + nextImageIndex], .3, { width:size.width, height:size.height, x:1770, y:Math.round((1080 - size.height) * .5) } );
			
			//remove the remaining images
			for (var i:int = 1; i <= numImagesInNav; i++) {
				if (i != currentImageIndex && i != prevImageIndex && i != nextImageIndex) {
					TweenMax.to(imagesNav["im" + i], .3, { x:2000, y:170, delay:(i-1) * .05 } );
				}
			}			
			
			showArrows();
			
			//back
			imagesNav.detailBG.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, backToImageNav, false, 0, true);
			if (hearthMode) {
				//bottom nav showing
				imagesNav.detailBG.btnBackIcon.y = HEARTH_Y;
			}else {
				imagesNav.detailBG.btnBackIcon.y = PILLAR_Y;
			}
			
			hideTouchAnImage();
		}
		
		
		/**
		 * Called by clicking one of the two thumbnails in the road ahead section
		 * @param	e
		 */
		private function videoClicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();			
			//uncheckPhone();
			kbd.hide();
			var image:MovieClip = MovieClip(e.currentTarget);
			currentImageIndex = parseInt(image.name.substr(2, 1));
			
			var vidFile:String = data.getBigImage("im" + currentImageIndex);
			vPlayer.showVideo(modalBackground);
			vPlayer.playVideo("images/" + vidFile);
			//trace("videoClicked() - images/" + vidFile);
			vPlayer.addEventListener(VPlayer.META_RECEIVED, centerVid, false, 0, true);
			vPlayer.addEventListener(VPlayer.STATUS_RECEIVED, checkStatus, false, 0, true);
			
			modalBackground.addChild(bigClose);
			bigClose.alpha = 1;
			bigClose.x = 22;
			if(hearthMode){
				bigClose.y = HEARTH_Y;
			}else {
				bigClose.y = PILLAR_Y;
			}
			
			modalBackground.addEventListener(MouseEvent.MOUSE_DOWN, closeVideo, false, 0, true);
			addChild(modalBackground);
			
			cq.moveToTop();
			adminCorner.moveToTop();
		}
		private function centerVid(e:Event):void
		{
			vPlayer.removeEventListener(VPlayer.META_RECEIVED, centerVid);
			vPlayer.centerVideo(1920, 1080);
		}
		private function checkStatus(e:Event):void
		{
			if (vPlayer.getStatus() == "NetStream.Play.Stop") {
				vPlayer.removeEventListener(VPlayer.STATUS_RECEIVED, checkStatus);
				closeVideo();				
			}
		}
		private function closeVideo(e:MouseEvent = null):void
		{			
			vPlayer.hideVideo();
			enableForm();
			//checkPhone();
			vPlayer.removeEventListener(VPlayer.META_RECEIVED, centerVid);
			vPlayer.removeEventListener(VPlayer.STATUS_RECEIVED, checkStatus);
			modalBackground.removeChild(bigClose);
			removeChild(modalBackground);
		}
		
		
		/**
		 * Sets visible false on bg elements so they don't interfere with mouse presses
		 * Called by tweenmax once bg elements have faded out
		 */
		private function hideBGElements():void
		{
			imagesNav.bg.visible = false;
			imagesNav.title.visible = false;
			imagesNav.theText.visible = false;
		}
		
		
		
		/**
		 * Displays the date and text for the image referenced by currentImageIndex
		 * Called from imageClicked(), prevClicked(), nextClicked(), imageNumberClicked()
		 */
		private function showImageData(useDelay:Number = .75):void
		{
			TweenMax.killTweensOf(imagesNav.detailBG.theDate);
			TweenMax.killTweensOf(imagesNav.detailBG.description);
			
			var imData:Object = data.getImageData("im" + currentImageIndex);
			
			var theYear:String;
			var i:int = String(imData.year).indexOf("s");
			imagesNav.detailBG.theDate.theS.alpha = 0;			
			
			if (i != -1) {
				theYear = String(imData.year).substring(0, i);
				imagesNav.detailBG.theDate.theDate.text = theYear;
				imagesNav.detailBG.theDate.theDate.setTextFormat(format);
				//imagesNav.detailBG.theDate.theDate.autoSize = TextFieldAutoSize.LEFT;
				imagesNav.detailBG.theDate.theS.alpha = 1;
				imagesNav.detailBG.theDate.theS.x = 14 + imagesNav.detailBG.theDate.theDate.textWidth - 9; //14 is left margin
			}else {
				theYear = imData.year;
				imagesNav.detailBG.theDate.theDate.text = theYear;
				imagesNav.detailBG.theDate.theDate.setTextFormat(format);
				//imagesNav.detailBG.theDate.theDate.autoSize = TextFieldAutoSize.LEFT;
			}
			
			imagesNav.detailBG.description.text = imData.text;
			imagesNav.detailBG.theDate.alpha = 0;
			imagesNav.detailBG.description.alpha = 0;
			TweenMax.to(imagesNav.detailBG.theDate, .5, { alpha:1, delay:useDelay } );
			TweenMax.to(imagesNav.detailBG.description, .5, { alpha:1, delay:useDelay } );			
		}
		
		
		/**
		 * Shows the zoom icon in the lower right corner of the current image
		 * Requires the images to have the zp movie click at 50,50 from the corner
		 */
		private function showZoomIcon():void
		{
			var m:MovieClip = MovieClip(imagesNav["im" + currentImageIndex]);
			var p:Point = new Point(m.zp.x, m.zp.y);
			p = m.localToGlobal(p);
			
			if (!contains(zoomIcon)) {
				addChild(zoomIcon);				
			}
			
			zoomIcon.x = p.x;
			zoomIcon.y = p.y;			
			zoomIcon.alpha = 0;
			TweenMax.to(zoomIcon, 1, { alpha:1 } );
			zoomIcon.addEventListener(MouseEvent.MOUSE_DOWN, zoomImage, false, 0, true);
		}
		
		private function hideZoomIcon():void
		{
			if (contains(zoomIcon)) {
				removeChild(zoomIcon);	
				zoomIcon.removeEventListener(MouseEvent.MOUSE_DOWN, zoomImage);
			}
		}
		
		
		/**
		 * Adds click listener to the currently displayed detail image
		 */
		private function addZoomListener():void
		{
			MovieClip(imagesNav["im" + currentImageIndex]).addEventListener(MouseEvent.MOUSE_DOWN, zoomImage, false, 0, true);
			addArrowListeners();
		}
		
		
		private function removeZoomListener():void
		{
			if(MovieClip(imagesNav["im" + currentImageIndex])){
				MovieClip(imagesNav["im" + currentImageIndex]).removeEventListener(MouseEvent.MOUSE_DOWN, zoomImage);
			}
		}
		
		
		private function prevClicked(e:MouseEvent):void
		{
			hideZoomIcon();
			removeArrowListeners();
			removeZoomListener();
			timeoutHelper.buttonClicked();
			
			//slide prev, current and next to the right
			TweenMax.to(imagesNav["im" + nextImageIndex], .5, { x: 2100 } ); //get current right edge one off screen
			TweenMax.to(imagesNav["im" + currentImageIndex], .5, { x: 1770 } );//stop so a little shows at right edge
			TweenMax.to(imagesNav["im" + prevImageIndex], .5, { x:180, onComplete:addZoomListener } ); //move into main position
			TweenMax.delayedCall(.5, showZoomIcon); //show once main image is showing			
			
			currentImageIndex--;
			if (currentImageIndex < 1) {
				currentImageIndex = numImagesInNav;
			}
			prevImageIndex = currentImageIndex == 1 ? numImagesInNav : currentImageIndex - 1;
			nextImageIndex = currentImageIndex == numImagesInNav ? 1 : currentImageIndex + 1;
			
			//move next slide into position at left
			var size:Object = resizeImage(prevImageIndex);
			imagesNav["im" + prevImageIndex].x = -1200;
			TweenMax.to(imagesNav["im" + prevImageIndex], .3, { width:size.width, height:size.height, x:-size.width + 150, y:Math.round((1080 - size.height) * .5) } );
			
			showImageData();//shows associated text and date			
		}	
		
		
		private function nextClicked(e:MouseEvent):void
		{		
			hideZoomIcon(); 
			removeArrowListeners();
			removeZoomListener();
			timeoutHelper.buttonClicked();
			
			//slide prev, current and next to the left
			TweenMax.to(imagesNav["im" + prevImageIndex], .5, { x: -1200 } ); //get current left edge one off screen
			TweenMax.to(imagesNav["im" + currentImageIndex], .5, { x: -imagesNav["im" + currentImageIndex].width + 150 } );//stop so a little shows at left edge
			TweenMax.to(imagesNav["im" + nextImageIndex], .5, { x:180, onComplete:addZoomListener } ); //move into main position
			TweenMax.delayedCall(.5, showZoomIcon); //show once main image is showing			
			
			currentImageIndex++;
			if (currentImageIndex > numImagesInNav) {
				currentImageIndex = 1;				
			}
			prevImageIndex = currentImageIndex == 1 ? numImagesInNav : currentImageIndex - 1;
			nextImageIndex = currentImageIndex == numImagesInNav ? 1 : currentImageIndex + 1;
			
			//move next slide into position at right
			var size:Object = resizeImage(nextImageIndex);
			imagesNav["im" + nextImageIndex].x = 2000;
			TweenMax.to(imagesNav["im" + nextImageIndex], .3, { width:size.width, height:size.height, x:1770, y:Math.round((1080 - size.height) * .5) } );
			
			showImageData();//shows associated text and date			
		}		
		
		
		/**
		 * Called by pressing the back button in the image detail screen - screen 3 with prev/next arrows
		 * Returns to screen two
		 * @param	e
		 */
		private function backToImageNav(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			hideZoomIcon();
			removeZoomListener();
			
			//move the current one first
			TweenMax.to(imagesNav["im" + currentImageIndex], .3, { x:initialImageData[currentImageIndex-1].x, y:initialImageData[currentImageIndex-1].y, width:initialImageData[currentImageIndex-1].width, height:initialImageData[currentImageIndex-1].height, rotation:0 } );
			
			for (var i:int = 1; i <= numImagesInNav; i++) {
				if (i != currentImageIndex) {
					//MovieClip(imagesNav["im" + i]).rotation = 5 + Math.random() * 10;
					TweenMax.to(imagesNav["im" + i], .3, { x:initialImageData[i - 1].x, y:initialImageData[i - 1].y, width:initialImageData[i - 1].width, height:initialImageData[i - 1].height, rotation:0, delay:(i - 1) * .12 } );				
				}				
			}			
			
			//fade in bg elements
			imagesNav.bg.visible = true;
			imagesNav.title.visible = true;
			imagesNav.theText.visible = true;
			
			TweenMax.to(imagesNav.bg, 1, { alpha:1 } );
			TweenMax.to(imagesNav.title, 1, { alpha:1 } );
			TweenMax.to(imagesNav.theText, 1, { alpha:1 } );
			TweenMax.delayedCall((i-1)*.12, addImageClickedListeners);//wait to add listeners so you can't click image while it's going back to position
			
			showTouchAnImage();
			hideArrows();
		}
		
		private function addImageClickedListeners():void
		{
			for (var i:int = 1; i <= numImagesInNav; i++) {
				MovieClip(imagesNav["im" + i]).addEventListener(MouseEvent.MOUSE_DOWN, imageClicked, false, 0, true);
			}
		}
		
		/**
		 * Fades in the 'touch an image' text at bottom center
		 * on screen two
		 */
		private function showTouchAnImage():void
		{
			if(currentSection != "ahead"){
				touchAnImage.alpha = 0;
				if (!contains(touchAnImage)) {
					addChildAt(touchAnImage,1); //on top of imagesNav, but behind roll			
				}
				if (hearthMode) {
					touchAnImage.y = 975;
				}else {
					touchAnImage.y = 1017;
				}
				TweenMax.to(touchAnImage, 2, { alpha:1 } );
			}
		}
		
		private function hideTouchAnImage():void
		{
			TweenMax.to(touchAnImage, 1, { alpha:0, onComplete:killTouchAnImage } );
		}
		
		private function killTouchAnImage():void
		{
			if(contains(touchAnImage)){
				removeChild(touchAnImage);
			}
		}
		
		
		
		/**
		 * Called from imageClicked()
		 * removes click listeners on the screen two images because the detail image is showing
		 */
		private function removeImageListeners():void
		{
			for (var i:int = 1; i <= numImagesInNav; i++) {				
				MovieClip(imagesNav["im" + i]).removeEventListener(MouseEvent.MOUSE_DOWN, imageClicked);
			}
		}
		
		
		/**
		 * Called by clicking on the image in the image detail view
		 * Zooms the image to full screen
		 * @param	e
		 */
		private function zoomImage(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			bigImage.loadImage(data.getBigImage("im" + currentImageIndex));
		}
		
		
		/**
		 * Called by timeoutHelper timing out
		 * @param	e
		 */
		private function doReset(e:Event):void
		{	
			if(sectionIntro){
				if (!contains(sectionIntro) && !mainMenu.isBGShowing()) {
					
					//not on intro screen saver already
					mainMenu.reset();
					bigImage.hide();
					//hide kbd
					//uncheckPhone();
					adminMenu.hide();
					
					removeZoomListener();
					removeImageListeners();
					
					var m:MovieClip;
					for (var i:int = 1; i <= numImagesInNav; i++) {
						m = MovieClip(imagesNav["im" + i]);
						m.alpha = 1;
						m.x = initialImageData[i - 1].x;
						m.y = initialImageData[i - 1].y
						m.width = initialImageData[i - 1].width;
						m.height = initialImageData[i - 1].height;				
					}			
					
					imagesNav.bg.visible = true;
					imagesNav.title.visible = true;
					imagesNav.theText.visible = true;
					imagesNav.bg.alpha = 1;
					imagesNav.title.alpha = 1;
					imagesNav.theText.alpha = 1;				
					
					hideZoomIcon();
					hideTouchAnImage();
					//showIntro(); //no screen saver
					removeIntro();
				}
			}
		}
		
		
		
		/**
		 * Resize to 960x770 - keep aspect
		 * Uses the original image data in initialImageData
		 * Uses the currentImageIndex for calulating
		 * @return Object with width and height properties
		 */
		private function resizeImage(index:int = -1):Object
		{	
			if (index == -1) { index = currentImageIndex;}
			var ratio:Number = Math.min(960 / initialImageData[index - 1].width, 770 /  initialImageData[index - 1].height);			
			return { width:initialImageData[index - 1].width * ratio, height:initialImageData[index - 1].height * ratio };
		}
		
		
		/**
		 * Called by tapping four times at upper right
		 * @param	e
		 */
		private function showAdminMenu(e:Event = null):void
		{
			timeoutHelper.buttonClicked();
			adminMenu.show(this);
			adminMenu.addEventListener(Admin.ITEM_SELECTED, adminSelected, false, 0, true);
		}
		
		private function showMainMenu(e:Event = null):void
		{
			
		}
		
		
		/**
		 * Called by clicking save and exit in the admin menu
		 * @param	e
		 */
		private function adminSelected(e:Event):void
		{
			var s:String = adminMenu.getSection();
			
			sectionData.setSection(s);//set shared object
			adminMenu.removeEventListener(Admin.ITEM_SELECTED, adminSelected);
			adminMenu.hide();
			swfLoader.unload();
			sectionIntro = new MovieClip();
			imagesNav = new MovieClip();
			modalBackground = new MovieClip();
			while (numChildren) {
				removeChildAt(0);
			}
			hearthMode = false;
			if (s == "all") {
				hearthMode = true;
			}
			loadSection(s);
		}
		
		
		/**
		 * Called by pressing a button on the main - bottom menu
		 * @param	e Event MainMeun.ITEM_PICKED
		 */
		private function mainMenuSelection(e:Event):void
		{
			timeoutHelper.buttonClicked();
			swfLoader.unload();
			sectionIntro = new MovieClip();
			imagesNav = new MovieClip();
			modalBackground = new MovieClip();
			//bottom nav readded in loadSection if hearthmode is true
			while (numChildren) {
				removeChildAt(0);
			}
			loadSection(mainMenu.getSelection());
		}
		
		
		/**
		 * Called by TweenMax.delayedCall from showImageNav()
		 */
		private function enableForm():void
		{
			if(!contains(kbd)){
				addChild(kbd);
			}
			kbd.show();
			//kbd.setFocusFields([imagesNav.theForm.theName, imagesNav.theForm.theAddress, imagesNav.theForm.theCity,	imagesNav.theForm.theState,	imagesNav.theForm.theZip, imagesNav.theForm.theEmail, imagesNav.theForm.phone1,	imagesNav.theForm.phone2, imagesNav.theForm.phone3]);
			kbd.setFocusFields([imagesNav.theForm.fName, imagesNav.theForm.lName, imagesNav.theForm.theZip, imagesNav.theForm.theEmail]);
			
			TweenMax.from(kbd, 1, { alpha:0, y:kbd.y + 100 } );
			//checkPhone();
			stage.focus = imagesNav.theForm.fName;
			imagesNav.theForm.thanks.mouseEnabled = false;
			imagesNav.theForm.theZip.restrict = "0-9";
			//imagesNav.theForm.phone1.restrict = "0-9";			
			//imagesNav.theForm.phone2.restrict = "0-9";
			//imagesNav.theForm.phone3.restrict = "0-9";
			//imagesNav.theForm.phone1.addEventListener(MouseEvent.MOUSE_DOWN, clearField, false, 0, true);
			//imagesNav.theForm.phone2.addEventListener(MouseEvent.MOUSE_DOWN, clearField, false, 0, true);
			//imagesNav.theForm.phone3.addEventListener(MouseEvent.MOUSE_DOWN, clearField, false, 0, true);
			imagesNav.theForm.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, checkForm, false, 0, true);
		}
		
		/**
		 * auto-tabs the cursor when entering the phone number
		 * @param	e
		 */
		/*
		private function phoneTabCheck(e:Event):void
		{
			if (stage.focus == imagesNav.theForm.phone1 && imagesNav.theForm.phone1.text.length == 3) {
				stage.focus = imagesNav.theForm.phone2;
				imagesNav.theForm.phone2.text = "";
			}
			if (stage.focus == imagesNav.theForm.phone2 && imagesNav.theForm.phone2.text.length == 3) {
				stage.focus = imagesNav.theForm.phone3;
				imagesNav.theForm.phone3.text = "";
			}
			
		}*/
		
		private function clearField(e:MouseEvent):void
		{
			TextField(e.currentTarget).text = "";
		}
		/*
		private function uncheckPhone():void
		{			
			removeEventListener(Event.ENTER_FRAME, phoneTabCheck);
		}
		
		private function checkPhone():void
		{			
			addEventListener(Event.ENTER_FRAME, phoneTabCheck, false, 0, true);
		}*/
		
		/**
		 * Called by event listener on the Keyboard whenever a key is pressed
		 * @param	e
		 */
		private function kbdResetTimeout(e:Event):void
		{
			timeoutHelper.buttonClicked();
		}
		
		private function checkForm(e:MouseEvent):void
		{
			//if (imagesNav.theForm.theName.text == "" || imagesNav.theForm.theAddress.text == "" || imagesNav.theForm.theEmail.text == "" || imagesNav.theForm.theCity.text == "" || imagesNav.theForm.theState.text == "" || imagesNav.theForm.theZip.text == "") {
			if (imagesNav.theForm.fName.text == "" || imagesNav.theForm.lName.text == "" || imagesNav.theForm.theEmail.text == "" || imagesNav.theForm.theZip.text == "") {
				//imagesNav.theForm.error.theText.text = "Please fill out all required fields";
				imagesNav.theForm.error.theText.text = "All fields are required";
				imagesNav.theForm.error.alpha = 1;
				TweenMax.to(imagesNav.theForm.error, 2, { alpha:0, delay:2 } );
			}else if (!Validator.isValidEmail(imagesNav.theForm.theEmail.text)) {
				imagesNav.theForm.error.theText.text = "Please enter a valid email address";
				imagesNav.theForm.error.alpha = 1;
				TweenMax.to(imagesNav.theForm.error, 2, { alpha:0, delay:2 } );
			}else {
				//form ok
				//csv.writeLine([imagesNav.theForm.theName.text, imagesNav.theForm.theAddress.text, imagesNav.theForm.theCity.text, imagesNav.theForm.theState.text, imagesNav.theForm.theZip.text, imagesNav.theForm.theEmail.text, imagesNav.theForm.phone1.text, imagesNav.theForm.phone2.text + "-" + imagesNav.theForm.phone3.text]);
				csv.writeLine([imagesNav.theForm.fName.text, imagesNav.theForm.lName.text, imagesNav.theForm.theEmail.text, imagesNav.theForm.theZip.text]);
				imagesNav.theForm.thanks.alpha = 1;
				clearForm();
				TweenMax.to(imagesNav.theForm.thanks, 2, { alpha:0, delay:2, onComplete:clearForm } );
			}
		}
				
		
		private function clearForm():void
		{
			imagesNav.theForm.fName.text = "";
			imagesNav.theForm.lName.text = "";
			//imagesNav.theForm.theAddress.text = "";
			//imagesNav.theForm.theCity.text = "";
			//imagesNav.theForm.theState.text = "";
			imagesNav.theForm.theZip.text = "";
			imagesNav.theForm.theEmail.text = "";
			//imagesNav.theForm.phone1.text = "";
			//imagesNav.theForm.phone2.text = "";
			//imagesNav.theForm.phone3.text = "";				
		}
		
	}
	
}