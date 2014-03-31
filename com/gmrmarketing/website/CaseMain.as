/**
 * Document class for gmr_case_studies_dave.fla which publishes to gmr_case_studies.swf
 * 
 * This is the standalone case studies movie with the image grid and case study logos in the grid
 * logo positions in the grid are defined in casestudies_main.xml
 * 
 * actual case studies are defined in casestudies.xml
 * 
 * loads casestudies_main.xml & casestudies.xml
 */


package com.gmrmarketing.website
{	
	import flash.display.LoaderInfo; //for flashvars
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import com.reintroducing.utils.StageManager;
	import com.reintroducing.events.StageManagerEvent;

	public class CaseMain extends MovieClip
	{			
		private const IMAGE_X:int = 575;
		private const IMAGE_Y:int = 60;
		private const SQUARE_SIZE:int = 88; //size of individual grid squares
		private const BUFFER:int = 8; //space between squares - used for positioning logos on the grid
		private const LOAD_SPEED:int = 3000; //time to load a new main image
		
		private var xmlLoaderMain:URLLoader = new URLLoader();
		private var xmlDataMain:XML = new XML();
		
		private var xmlLoaderCaseStudies:URLLoader = new URLLoader();
		private var xmlDataCaseStudies:XML = new XML();
		
		private var mainImageLoader:Loader;
		private var detailImageLoader:Loader;
		
		private var categoryXML:XMLList; //XML of current category
		private var casesXML:XMLList; //case study logos and id within the category
		
		private var theImages:XMLList; //all images defined in casestudies_main.xml - used for fading between
		private var curImage:int; //counter for going through theImages		
		private var mainHolder:MovieClip; //container for the side images
		private var attractTimer:Timer;
		
		private var logos:Array; //references to the logos in the main image 'cube'		
		
		private var detail:caseStudyDetail; //library clip
		private var btnClose:closeBtn; //library clip
		
		private var thumbImages:XMLList; //set in logoClicked - list of images that go with the thumbs
		
		private var stageMan:StageManager;
		private var originalRatio:Number = 1.588; //aspect ratio for 1280x806 images
		
		private var theMenu:XMLList;
		private var config:XMLList;
		
		private var btnSports:MovieClip;
		private var btnEntertainment:MovieClip;
		private var btnLifestyle:MovieClip;
		private var btnRetail:MovieClip;
		private var btnDigital:MovieClip;
		private var btnCorporate:MovieClip;
		private var btnConsulting:MovieClip;
		private var btnMobile:MovieClip;
		
		private var language:String;
		private var basePath:String;
		
		
		
		/**
		 * CONSTRUCTOR
		 */
		public function CaseMain()
		{
			//flashvars
			if (loaderInfo.parameters.language == undefined) {
				language = "en"; //default to english
			}
			basePath = language + "/"; //prepended to image path from xml
			
			TweenPlugin.activate([ColorMatrixFilterPlugin]);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);

			background.width = stage.stageWidth;
			background.height = stage.stageHeight;			

			logo.addEventListener(MouseEvent.CLICK, gotoHomepage);
			logo.mouseEnabled = true;
			logo.buttonMode = true;

			detail = new caseStudyDetail(); //library clip
			btnClose = new closeBtn();
			
			logos = new Array(); //contains logo loader instances for removing			
			
			detailImageLoader = new Loader();
			
			mainHolder = new MovieClip();
			addChild(mainHolder);
			mainHolder.x = IMAGE_X;
			mainHolder.y = IMAGE_Y;
			
			var m:MovieClip = new maskSide(); //library clip
			m.x = IMAGE_X;
			m.y = IMAGE_Y;
			mainHolder.mask = m;
			
			var req:URLRequest = new URLRequest("casestudies_main.xml");			
			xmlLoaderMain.addEventListener(Event.COMPLETE, mainXMLLoaded);
			xmlLoaderMain.load(req);		
		}
		
		
		/**
		 * StageManager listener - resizes background if the movie size is changed
		 * 
		 * @param	event
		 */
		private function onStageResize(event:Event = null):void
		{
			background.width = stage.stageWidth;
			background.height = stage.stageHeight;
			
			if (contains(detail)) {
				
				detail.interactivitymask.width = stage.stageWidth;
				detail.interactivitymask.height = stage.stageHeight;
				
				if(detail.bigImage.numChildren > 0){
					if(stage.stageWidth > 1024){
						detail.bigImage.width = stage.stageWidth;
						detail.bigImage.height = stage.stageWidth / originalRatio;					
					}
					if (stage.stageHeight > 768) {					
						detail.bigImage.height = stage.stageHeight;
						detail.bigImage.width = stage.stageHeight * originalRatio;					
					}
				}
			}
		}
		
		
		/**
		 * Called when the GMR logo is clicked
		 * 
		 * @param	event MouseEvent.CLICK
		 */
		private function gotoHomepage(event:MouseEvent):void 
		{
			navigateToURL(new URLRequest("default.aspx"), "_parent");
		} 
		
		
		/**
		 * The following methods are called by MouseEvent.CLICK when the category menu buttons are clicked
		 */
		private function doMobile(e:MouseEvent = null):void
		{
			parseXML("MOBILE");
		}
		
		private function doSports(e:MouseEvent = null):void
		{
			parseXML("SPORTS");
		}
		
		private function doEntertainment(e:MouseEvent = null):void
		{
			parseXML("ENTERTAINMENT");
		}
		
		private function doLifestyle(e:MouseEvent = null):void
		{
			parseXML("LIFESTYLE");
		}
		
		private function doRetail(e:MouseEvent = null):void
		{
			parseXML("RETAIL");
		}
		
		private function doDigital(e:MouseEvent = null):void
		{
			parseXML("DIGITAL");
		}
		
		private function doCorporate(e:MouseEvent = null):void
		{
			parseXML("CORPORATE");
		}
		
		private function doConsulting(e:MouseEvent = null):void
		{
			parseXML("CONSULTING");
		}
		
		private function doDefault(e:MouseEvent = null):void
		{
			parseXML("DEFAULT");
		}
		
		
		
		
		
		
		/**
		 * Called from caseStudiesLoaded
		 * Uses the original button name - Sports, Entertainment, Lifestyle, Retail, Digital, Corporate, Mobile
		 */
		private function parseMenu():void 
		{			
			theMenu = xmlDataMain.menu;
			config = xmlDataMain.config;
			
			//use device fonts for chinese
			if (language == "ch") { menuTitle.embedFonts = false;}
			menuTitle.text = theMenu.title;
			menuTitle.y = 280;
			
			var menuChoices:XMLList = theMenu.choices.choice;
			var numButtons:int = menuChoices.length();
			var menuLineWidth:int = 16; //width of the separator between menu choices
			var startX:int = 145;
			var startY:int = 300;
			
			for each(var aButton:XML in menuChoices) {				
				switch(aButton.@original.toString()) {
					case "Sports":
						btnSports = new menuButton();
						//use device fonts for chinese
						if (language == "ch") { btnSports.theText.embedFonts = false;}
						btnSports.theText.text = aButton.toString();
						btnSports.theText.autoSize = TextFieldAutoSize.LEFT;
						btnSports.y = startY;
						btnSports.x = startX;
						btnSports.theCover.width = btnSports.width;
						startY += btnSports.height;
						addChild(btnSports);
						btnSports.addEventListener(MouseEvent.CLICK, doSports, false, 0, true);
						btnSports.buttonMode = true;
						break;
					case "Entertainment":
						btnEntertainment = new menuButton();
						//use device fonts for chinese
						if (language == "ch") { btnEntertainment.theText.embedFonts = false;}
						btnEntertainment.theText.text = aButton.toString();
						btnEntertainment.theText.autoSize = TextFieldAutoSize.LEFT;
						btnEntertainment.y = startY;
						btnEntertainment.x = startX;
						btnEntertainment.theCover.width = btnEntertainment.width;
						startY += btnEntertainment.height;
						addChild(btnEntertainment);
						btnEntertainment.addEventListener(MouseEvent.CLICK, doEntertainment, false, 0, true);
						btnEntertainment.buttonMode = true;
						break;
					case "Lifestyle":
						btnLifestyle = new menuButton();
						//use device fonts for chinese
						if (language == "ch") { btnLifestyle.theText.embedFonts = false;}
						btnLifestyle.theText.text = aButton.toString();
						btnLifestyle.theText.autoSize = TextFieldAutoSize.LEFT;
						btnLifestyle.y = startY;
						btnLifestyle.x = startX;
						btnLifestyle.theCover.width = btnLifestyle.width;
						startY += btnLifestyle.height;
						addChild(btnLifestyle);
						btnLifestyle.addEventListener(MouseEvent.CLICK, doLifestyle, false, 0, true);
						btnLifestyle.buttonMode = true;
						break;
					case "Retail":
						btnRetail = new menuButton();
						//use device fonts for chinese
						if (language == "ch") { btnRetail.theText.embedFonts = false;}
						btnRetail.theText.text = aButton.toString();
						btnRetail.theText.autoSize = TextFieldAutoSize.LEFT;
						btnRetail.y = startY;
						btnRetail.x = startX;
						btnRetail.theCover.width = btnRetail.width;
						startY += btnRetail.height;
						addChild(btnRetail);
						btnRetail.addEventListener(MouseEvent.CLICK, doRetail, false, 0, true);
						btnRetail.buttonMode = true;
						break;
					case "Digital":
						btnDigital = new menuButton();
						//use device fonts for chinese
						if (language == "ch") { btnDigital.theText.embedFonts = false;}
						btnDigital.theText.text = aButton.toString();
						btnDigital.theText.autoSize = TextFieldAutoSize.LEFT;
						btnDigital.y = startY;
						btnDigital.x = startX;
						btnDigital.theCover.width = btnDigital.width;
						startY += btnDigital.height;
						addChild(btnDigital);
						btnDigital.addEventListener(MouseEvent.CLICK, doDigital, false, 0, true);
						btnDigital.buttonMode = true;
						break;
					case "Corporate":
						btnCorporate = new menuButton();
						//use device fonts for chinese
						if (language == "ch") { btnCorporate.theText.embedFonts = false;}
						btnCorporate.theText.text = aButton.toString();
						btnCorporate.theText.autoSize = TextFieldAutoSize.LEFT;
						btnCorporate.y = startY;
						btnCorporate.x = startX;
						btnCorporate.theCover.width = btnCorporate.width;
						startY += btnCorporate.height;
						addChild(btnCorporate);
						btnCorporate.addEventListener(MouseEvent.CLICK, doCorporate, false, 0, true);
						btnCorporate.buttonMode = true;
						break;
					case "Consulting":
						btnConsulting = new menuButton();
						//use device fonts for chinese
						if (language == "ch") { btnConsulting.theText.embedFonts = false;}
						btnConsulting.theText.text = aButton.toString();
						btnConsulting.theText.autoSize = TextFieldAutoSize.LEFT;
						btnConsulting.y = startY;
						btnConsulting.x = startX;
						btnConsulting.theCover.width = btnConsulting.width;
						startY += btnConsulting.height;
						addChild(btnConsulting);
						btnConsulting.addEventListener(MouseEvent.CLICK, doConsulting, false, 0, true);
						btnConsulting.buttonMode = true;
						break;
					case "Mobile":
						btnMobile = new menuButton();
						//use device fonts for chinese
						if (language == "ch") { btnMobile.theText.embedFonts = false;}
						btnMobile.theText.text = aButton.toString();
						btnMobile.theText.autoSize = TextFieldAutoSize.LEFT;
						btnMobile.y = startY;
						btnMobile.x = startX;
						btnMobile.theCover.width = btnMobile.width;
						startY += btnMobile.height;
						addChild(btnMobile);
						btnMobile.addEventListener(MouseEvent.CLICK, doMobile, false, 0, true);
						btnMobile.buttonMode = true;
						break;
				}
				
				
				
				//put pipe chars between buttons
				numButtons--;
				/*
				if(numButtons > 0){
					var ml:menuLine = new menuLine();
					ml.y = startY;
					ml.x = startX + 8;
					startX += menuLineWidth;
					addChild(ml);
				}
				*/
			}
		}
		
		
		/**
		 * Called once casestudies_main.xml has been loaded
		 * loads the casestudies.xml
		 * 
		 * @param	e Event.COMPLETE
		 */
		private function mainXMLLoaded(e:Event):void
		{
			xmlLoaderMain.removeEventListener(Event.COMPLETE, mainXMLLoaded);
			xmlDataMain = new XML(e.target.data);
			
			// XMLList of all images in casestudies_main.xml
			theImages = xmlDataMain.categories.category.image;			
			curImage = 0;			
			
			//parseMenu();
			
			xmlLoaderCaseStudies.addEventListener(Event.COMPLETE, caseStudiesLoaded, false, 0, true);
			xmlLoaderCaseStudies.load(new URLRequest("casestudies.xml"));
		}
		
		
		/**
		 * Called once casestudies.xml has been loaded
		 * 
		 * @param	e Event.COMPLETE
		 */
		private function caseStudiesLoaded(e:Event):void 
		{
			xmlLoaderCaseStudies.removeEventListener(Event.COMPLETE, caseStudiesLoaded);
			xmlDataCaseStudies = new XML(e.target.data);
			
			doDefault();
			parseMenu();
		}
		
		
		/**
		 * Called by clicking the category menu buttons
		 * populates the image grid
		 * 
		 * @param	theCategory - String - Category ID in the casestudies_main.xml file
		 */
		private function parseXML(theCategory:String = "SPORTS"):void 
		{
			categoryXML = xmlDataMain.categories.category.(@ID == theCategory); //xml for theCategory			
			
			//use device fonts for Chinese
			if (language == "ch") {
				headline.embedFonts = false;
				content.embedFonts = false;
			}
			headline.text = categoryXML.headline;
			content.text = categoryXML.thetext;
			var b:TextFormat = new TextFormat();
			b.size = 12;
			content.setTextFormat(b);
			
			content.y = headline.y + headline.textHeight + 18;
			
			casesXML = categoryXML.casestudy; //xml list of case studies containing id and cube position
			
			//remove any old logos from grid
			for (var j = 0; j < logos.length; j++)
			{
				if (contains(logos[j])) {
					logos[j].removeChildAt(0);
					removeChild(logos[j]);
				}
			}
			logos = new Array();
			
			//load logos into the grid
			for (var i:int = 0; i < casesXML.length(); i++) {
				var clientlogoURL:String = xmlDataCaseStudies.casestudy.(@id == casesXML[i].id).clientlogo;
				var pos:Array = casesXML[i].cubepos.split(","); //grid position like 1,1
				loadClientLogo(clientlogoURL, pos, casesXML[i].id);
			}
			
			//remove all main images once user selects a category
			if (theCategory != "DEFAULT") {
				var n:int = mainHolder.numChildren;
			
				for (var k:int = 0; k < n; k++) {
					mainHolder.removeChildAt(0);
				}
				attractTimer.reset(); //stop and reset the timer that changes the images in grid before a category is picked
			}
			
			loadMainImage(categoryXML.image);	
		}
		
		
		
		/**
		 * Loads main, masked, side image
		 * @param	imURL
		 */
		private function loadMainImage(imURL:String):void
		{			
			mainImageLoader = new Loader();		
			mainImageLoader.load(new URLRequest(imURL));			
			mainImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeListener, false, 0, true);
			mainImageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, clientLogoError, false, 0, true);
		}
		
		
		/**
		 * Called in loop from parseXML, for each logo attached to the grid
		 * injects id into new logo so when it's clicked logoClicked knows which case id to load
		 * 
		 * @param	theURL
		 * @param	pos
		 * @param	caseID
		 */
		private function loadClientLogo(theURL:String, pos:Array, caseID:String):void
		{
			var logoContainer:MovieClip = new MovieClip();
			logoContainer.addEventListener(MouseEvent.CLICK, logoClicked, false, 0, true);
			logoContainer.buttonMode = true;
			logoContainer.id = caseID;
			
			var clientlogoURLLoader = new Loader();
			logoContainer.addChildAt(clientlogoURLLoader,0);
			
			logos.push(logoContainer); //push to logos so we have references for removing
			
			//position logo based on cubepos in the xml
			logoContainer.x = IMAGE_X + ((SQUARE_SIZE * (pos[0] - 1)) + ((pos[0] - 1) * BUFFER));
			logoContainer.y = IMAGE_Y + ((SQUARE_SIZE * (pos[1] - 1)) + ((pos[1] - 1) * BUFFER));		
			
			addChild(logoContainer);
			
			clientlogoURLLoader.load(new URLRequest(theURL));
			clientlogoURLLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeListenerClientLogo, false, 0, true);
			clientlogoURLLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, clientLogoError, false, 0, true);		
		}
		
		
		/**
		 * Main side image complete
		 * 
		 * @param	e Event.COMPLETE
		 */
		private function completeListener(e:Event):void
		{
			mainHolder.addChild(mainImageLoader);			
			
			mainImageLoader.alpha = 0;
			
			if (categoryXML.@ID == "DEFAULT") {
				TweenLite.to(mainImageLoader, 1, { alpha:1 } );
				
				var n:int = mainHolder.numChildren - 2; //leave two images in place		
				for (var k:int = 0; k < n; k++) {					
					mainHolder.removeChildAt(0);					
				}				
				
				attractTimer = new Timer(LOAD_SPEED, 1);
				attractTimer.addEventListener(TimerEvent.TIMER, loadNextMain, false, 0, true);
				attractTimer.start();
				
			}else{
				TweenLite.to(mainImageLoader, 1, { alpha:.2, colorMatrixFilter:{amount:1, saturation:0} } );
			}			
		}
		
		/**
		 * Called by timer during the 'attract loop' - loads the next image into the grid area
		 * 
		 * @param	e TimerEvent.TIMER
		 */
		private function loadNextMain(e:TimerEvent)
		{
			curImage++;
			if (curImage >= theImages.length()) { curImage = 0; }
			loadMainImage(theImages[curImage]);
		}
		
		
		/**
		 * Loaded logo finished
		 * 
		 * @param	e COMPLETE Event
		 */
		private function completeListenerClientLogo(e:Event):void
		{			
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}
			
			//fit logos to grid size
			bit.width = bit.height = SQUARE_SIZE;
			
			//fade in logo
			bit.alpha = 0;
			TweenLite.to(bit, 1, { alpha:1 } );
		}
		
		private function clientLogoError(e:IOErrorEvent):void
		{
			//logo url not found
		}
		
		
		
		/**
		 * Parse proper case study out of casestudies.xml
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function logoClicked(e:MouseEvent):void
		{
			var caseID = e.currentTarget.id;
			var theCase:XMLList = xmlDataCaseStudies.casestudy.(@id == caseID);
			
			var thumbs:XMLList = theCase.childthumb;
			thumbImages = theCase.childimage;
			
			addChild(detail);
			detail.logo.addEventListener(MouseEvent.CLICK, gotoHomepage, false, 0, true);
			detail.logo.buttonMode = true;
			
			//fade in case study sequentially
			detail.alpha = 1;
			detail.interactivitymask.alpha = 0;
			detail.casestudyBox.alpha = 0;
			detail.theTitle.alpha = 0;
			detail.subheadstrategy.alpha = 0;
			detail.theStrategy.alpha = 0;
			detail.subheadresults.alpha = 0;
			detail.theResults.alpha = 0;
			
			TweenLite.to(detail.interactivitymask, .5, { alpha:.4 } );
			TweenLite.to(detail.casestudyBox, .5, { alpha:.9, delay:.25 } );
			TweenLite.to(detail.theTitle, .5, { alpha:1, delay:.5 } );
			TweenLite.to(detail.subheadstrategy, .5, { alpha:1, delay:.75 } );
			TweenLite.to(detail.theStrategy, .5, { alpha:1, delay:1 } );
			TweenLite.to(detail.subheadresults, .5, { alpha:1, delay:1.25 } );
			TweenLite.to(detail.theResults, .5, { alpha:1, delay:1.5, onComplete:loadThumbs, onCompleteParams:[thumbs] } );
			
			//use device fonts if Chinese
			if (language == "ch") {
				detail.theTitle.embedFonts = false;
				detail.theStrategy.embedFonts = false;
				detail.theResults.embedFonts = false;
				detail.btnBack.backTxt.embedFonts = false;
				detail.subheadstrategy.strategy.embedFonts = false;
				detail.subheadresults.results.embedFonts = false;
			}
			
			detail.theTitle.text = theCase.title;
			detail.theStrategy.text = theCase.strategy;
			detail.theResults.text = theCase.results;
			
			//config back button and subheads from xml
			detail.btnBack.backTxt.text = config.backbuttontext.toString();
			detail.subheadstrategy.strategy.text = config.strategytext.toString();
			detail.subheadresults.results.text = config.resultstext.toString();
			
			detail.btnBack.addEventListener(MouseEvent.CLICK, removeDetail, false, 0, true);
			detail.btnBack.buttonMode = true;
			
			onStageResize(); //makes the interactivity mask the proper size
			
			//load in the big background image into detail.bigImage
			var loader:Loader = new Loader();			
			detail.bigImage.addChild(loader);
			loader.load(new URLRequest(theCase.mainimage));
			//loader.load(new URLRequest(categoryXML.image));			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, smoothImage2, false, 0, true);			
		}
		
		
		/**
		 * Called by TweenLite.onComplete from logoClicked, once the detail clip has been built
		 * 
		 * @param	thumbList XMLList of thumb images to load into detail clip
		 */
		private function loadThumbs(thumbList:XMLList):void
		{
			var boxWidth = 385; //width of detail 'box' that holds detail info
			
			for (var i = 0; i < thumbList.length(); i++) {
				var aThumb = thumbList[i];
				var loader = new Loader();
				var cont:MovieClip = new MovieClip(); //create a clip so buttonMode can be used - can't be used on loader
				//cont.ind = String(i);
				cont.addChild(loader);
				loader.name = String(i);				
				loader.x = 93 * i;				
				loader.scaleX = loader.scaleY = .8;
				detail.thumbContainer.addChild(cont);
				cont.buttonMode = true;
				loader.load(new URLRequest(aThumb));
				loader.addEventListener(MouseEvent.CLICK, showImage, false, 0, true);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, smoothImage, false, 0, true);
			}
		}
		
		
		/**
		 * Turns on bitmap smoothing for the loaded image 
		 * Used for the thumbs in the detail section
		 * 
		 * @param	e Event.COMPLETE
		 */
		private function smoothImage(e:Event):void 
		{
			//center thumb container - left edge of 'box' is at 563 - width is 385
			detail.thumbContainer.x = 563 + ((385 - detail.thumbContainer.width) / 2);
			
			var bit:Bitmap = e.target.content;			
			if(bit != null){
				bit.smoothing = true;
			}
			bit.alpha = 0;
			TweenLite.to(bit, .5, { alpha:1 } );
		}
		
		
		/**
		 * Turns on bitmap smoothing for the loaded image
		 * Save as above, but this one calls onStageResize in order to size
		 * the newly loaded big bg image
		 * 
		 * @param	e Event.COMPLETE
		 */
		private function smoothImage2(e:Event):void 
		{
			var bit:Bitmap = e.target.content;			
			if(bit != null){
				bit.smoothing = true;
			}
			
			//fade in bg image
			bit.alpha = 0;
			TweenLite.to(bit, .5, { alpha:1 } );
			
			onStageResize();
		}

		
		/**
		 * Just smooths the loaded bitmap
		 * Used for the image associated with a thumb
		 * 
		 * @param	e Event.COMPLETE
		 */
		private function smoothImage3(e:Event):void 
		{			
			var bit:Bitmap = e.target.content;			
			if(bit != null){
				bit.smoothing = true;
			}		
		}
		
		
		/**
		 * Called by clicking a thumb within the detail clip
		 * Shows image associated with thumb
		 * 
		 * @param	e MouseEvent.CLICK
		 */
		private function showImage(e:MouseEvent = null):void
		{
			var thumbIndex:int = parseInt(e.currentTarget.name);			
			detailImageLoader.load(new URLRequest(thumbImages[thumbIndex]));
			detailImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, smoothImage3, false, 0, true);
			detailImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, revealImage, false, 0, true);
			detailImageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, badFile, false, 0, true);
		}
		
		
		/**
		 * Brings in a large detail image, once loaded
		 * 
		 * @param	e Event.COMPLETE
		 */
		private function revealImage(e:Event):void
		{
			detail.addChild(detailImageLoader);
			
			detailImageLoader.x = (stage.stageWidth - detailImageLoader.width) / 2;
			detailImageLoader.y = (stage.stageHeight - detailImageLoader.height) / 2;
			detailImageLoader.scaleX = detailImageLoader.scaleY = 1;//.4;
			detailImageLoader.alpha = 0;
			TweenLite.to(detailImageLoader, .5, { alpha:1, scaleX:1, scaleY:1, ease:Quart.easeOut, onComplete:addClose } );			
		}
		
		
		/**
		 * Called if the specified big image can't be found
		 * @param	e
		 */
		private function badFile(e:IOErrorEvent)
		{
			trace("bad file in XML");
		}
		
		
		/**
		 * Adds the image close button, once the image has been fully revealed
		 */
		private function addClose()
		{
			detail.addChild(btnClose);
			btnClose.alpha = 0;			
			btnClose.x = detailImageLoader.x + detailImageLoader.width - 10;
			btnClose.y = detailImageLoader.y - 10;
			TweenLite.to(btnClose, .5, { alpha:1} );
			btnClose.addEventListener(MouseEvent.CLICK, removePic, false, 0, true);
			btnClose.buttonMode = true;
		}
		
		
		/**
		 * Fades out the detail clip then calls killDetail to remove child objects
		 * @param	e
		 */
		private function removeDetail(e:MouseEvent):void
		{				
			TweenLite.to(detail, .5, { alpha:0, onComplete:killDetail } );
		}
		
		
		/**
		 * Called by clicking the close button on a detail pic
		 * @param	e MouseEvent.CLICK
		 */
		private function removePic(e:MouseEvent)
		{			
			detail.removeChild(btnClose);
			TweenLite.to(detailImageLoader, 1, { alpha:0, onComplete:killPic } );
		}
		
		
		/**
		 * Called from removePic, by TweenLite
		 */
		private function killPic()
		{
			detail.removeChild(detailImageLoader);
		}
		
		
		/**
		 * Removes child objects from the detail clip
		 * and then removes detail clip from the stage
		 * 
		 * Called from removeDetail, by TweenLite.onComplete
		 */
		private function killDetail():void
		{	
			//remove thumbs from detail.thumbContainer
			var n:int = detail.thumbContainer.numChildren;
			
			for (var i:int = 0; i < n; i++) {
				var c:MovieClip = MovieClip(detail.thumbContainer.getChildAt(0));
				c.removeChildAt(0);
				detail.thumbContainer.removeChild(c);
			}
			
			//remove large bg image
			detail.bigImage.removeChildAt(0);
			
			//remove imageLoader
			if (detail.contains(detailImageLoader)) {
				detail.removeChild(detailImageLoader);
				detail.removeChild(btnClose);
			}
			
			removeChild(detail);		
		}
	}
}