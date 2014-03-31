/**
* Document class for practice parent
* gmr_practice_parent_dave2.fla which publishes to gmr_practices.swf
* 
* loaded by main movie - Main.as / gmr_practices_shell.swf
* 
* This is the movie containing the individual practices
* 
* loads engagementcube.xml & casestudies.xml
* loads casestudies_main.xml in order to use the config section
* 
*/

package com.gmrmarketing.website
{
	import flash.display.LoaderInfo; //for flashvars
	
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.ColorShortcuts;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;	
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.display.StageScaleMode;
	import com.reintroducing.utils.StageManager;
	import com.reintroducing.events.StageManagerEvent;

	
	public class PracticeParent extends MovieClip
	{
		ColorShortcuts.init();

		//setup glow filters
		private var filt1:GlowFilter = new GlowFilter(0x1A1A1A, .3, 15, 15);
		private var filt2:GlowFilter = new GlowFilter(0x1A1A1A, .3, 10, 10);		

		//Assign the swf to a category number with var categoryAssign:
		//0=Sports, 1=Entertainment, 2=Lifestyle, 3=Retail, 4=Digital, 5=Consulting, 6=Corporate

		private var categoryAssign:Number = 5; //this is the index of the category within engagementcube.xml
		
		private var menuWidth:Number; //passed into init from main movie - the width of the navigation menu for setting the width
		//of the white behindMenu clip
		
		private var theCategory:String;

		//number of subcategories in the main category - set in parseEngagementCubeXML()
		private var subcategoryQuantity:int;
	
		private var iconSelected:String = "";
		private var elementsReceded:Boolean = false;
		private var stageOffsetX:Number = 0;//for moving x position of stage elements
		
		private var _i:Number; //George is a retard
		
		//private var _tempIconDetail:MovieClip;
		
		private var _n:int;//used for passing value of n (casestudy ID) from function parseEngagementCube to function parseCasestudiesXML
		private var total_n:int;//counts total number of casestudy logos
		private var _total_n:int;
		private var _casestudyInput:XML;

		private var myArray:Array = new Array();
		private var callCasestudyImageID:int;
		private var _o:int; //George is a dumb shit
		private var firsttime:Boolean = true;
		
		private var clientLogoContainer:MovieClip;				
		private var casestudyID:int;
		
		private var childthumbLength:int;
		private var casestudyChildthumbContainer:MovieClip;
		//private var selectText:MovieClip;
		
		private var configLoader:URLLoader = new URLLoader();
		private var config:XMLList;
		
		private var xmlLoaderEngagementCube:URLLoader = new URLLoader();
		private var xmlDataEngagementCube:XML = new XML();
		
		private var xmlLoaderCaseStudies:URLLoader = new URLLoader();
		private var xmlDataCaseStudies:XML = new XML();
		
		private var categoryXML:XMLList; //xml for the category - parsed from engagementcube.xml
		private var subCatXML:XMLList;
		
		private var casestudyMainimageURLLoader:Loader;
		
		private var stageMan:StageManager;
		
		private var originalRatio:Number = 1.588; //aspect ratio for 1280x806 images
		
		private var language:String;
		private var basePath:String;
		

		
		
		public function PracticeParent()
		{			
			//flashvars
			if (loaderInfo.parameters.language == undefined) {
				language = "en"; //default to english
			}
			basePath = language + "/"; //prepended to image path from xml
			
			//initPractice(6); //TESTING
		}
		
		
		
		/**
		 * Called from main movie - Main.as
		 * in practicesLoaded() when this swf has been loaded
		 * 
		 * defaults to sports if no category is passed in
		 * 
		 * @param	catAssign
		 */
		public function initPractice(catAssign:int = 0, navWidth:Number = 121)
		{	
			categoryAssign = catAssign;
			menuWidth = navWidth;
			
			switch(categoryAssign) {
				case 0:
					theCategory = "SPORTS";
					break;
				case 1:
					theCategory = "ENTERTAINMENT";
					break;
				case 2:
					theCategory = "LIFESTYLE";
					break;
				case 3:
					theCategory = "RETAIL";
					break;
				case 4:
					theCategory = "DIGITAL";
					break;
				case 5:
					theCategory = "CONSULTING";
					break;				
				case 6:
					theCategory = "MOBILE";
					break;
				case 7:
					theCategory = "CORPORATE";
					break;	
			}
			
			
			xmlDataEngagementCube.ignoreWhite = true;
			xmlDataCaseStudies.ignoreWhite = true;
			//load  XML	
			xmlLoaderEngagementCube.addEventListener(Event.COMPLETE, engagementCubeLoaded, false, 0, true);
			xmlLoaderEngagementCube.load(new URLRequest("engagementcube.xml"));
			
			//get case studies main in order to use config data
			configLoader.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			configLoader.load(new URLRequest("casestudies_main.xml"));
			
			//icon details hold the headline and content info for the selected category
			//TODO: make just one detail clip...
			removeChild(iconDetail1);
			removeChild(iconDetail2);
			removeChild(iconDetail3);
			removeChild(iconDetail4);
			iconDetail1.alpha = 0;
			iconDetail2.alpha = 0;
			iconDetail3.alpha = 0;
			iconDetail4.alpha = 0;	
			
			
			stageMan = StageManager.getInstance(stage, "instant", 0, null);
			if (!stageMan.itemAdded(casestudyDetail.emptyholder)){
				stageMan.addItem(casestudyDetail.emptyholder, "TL");
				stageMan.addItem(casestudyDetail.interactivitymask, "TL");		
			
				stage.addEventListener(Event.RESIZE, onStageResize);
			}
			resetCasestudyDetail();			
		}
		
		
		
		
		private function onStageResize(e:Event = null):void
		{
			if(stage.stageWidth > 1024){
				casestudyDetail.emptyholder.width = stage.stageWidth;
				casestudyDetail.emptyholder.height = stage.stageWidth / originalRatio;
				
			}
			if (stage.stageHeight > 768) {
				
				casestudyDetail.emptyholder.height = stage.stageHeight;
				casestudyDetail.emptyholder.width = stage.stageHeight * originalRatio;
				
			}
			casestudyDetail.interactivitymask.width = stage.stageWidth;
			casestudyDetail.interactivitymask.height = stage.stageHeight;
		}		
	
		
		/**
		 * Called when the engagementcube.xml is done loading
		 * @param	e COMPLETE event
		 */
		private function engagementCubeLoaded(e:Event):void 
		{	
			xmlLoaderEngagementCube.removeEventListener(Event.COMPLETE, engagementCubeLoaded);
			xmlDataEngagementCube = new XML(e.target.data);
			xmlLoaderCaseStudies.addEventListener(Event.COMPLETE, caseStudiesLoaded);
			xmlLoaderCaseStudies.load(new URLRequest("casestudies.xml"));
		}
		
		
		/**
		 * Called when the casestudies_main.xml file is loaded
		 * Gets the config section from the xml
		 * 
		 * @param	e
		 */
		private function configLoaded(e:Event):void
		{
			configLoader.removeEventListener(Event.COMPLETE, configLoaded);
			config = new XML(e.target.data).config;			
		}
		
		
		/**
		 * Called when casestudies.xml is done loading
		 * @param	e COMPLETE event
		 */
		private function caseStudiesLoaded(e:Event):void 
		{
			xmlLoaderCaseStudies.removeEventListener(Event.COMPLETE, caseStudiesLoaded);
			xmlDataCaseStudies = new XML(e.target.data);			
			parseEngagementCubeXML();
		}

		
		/**
		 * Called from caseStudiesLoaded()
		 * engagementcube.xml and casestudies.xml are now loaded
		 * sets subcategoryQuantity and calls initAnimation()
		 */
		private function parseEngagementCubeXML():void 
		{
			categoryXML = xmlDataEngagementCube.category.(@ID == theCategory); //xml for theCategory
			
			headlineLanding.headline.autoSize = TextFieldAutoSize.LEFT;			
			
			subCatXML = categoryXML.subcategory; //subcategory xml list for this category
			
			subcategoryQuantity = subCatXML.length();
			
			if (theCategory != "MOBILE") {
				headlineLanding.headline.htmlText = categoryXML.headline;
				initAnimation();
			}else {
				//Mobile - hide everything that initAnimation does.
				box1.alpha = box2.alpha = box3.alpha = box4.alpha = 0;
				box1.y = box2.y = box3.y = box4.y = -5000;
				subcatName1.alpha = subcatName2.alpha = subcatName3.alpha = subcatName4.alpha = 0;
				icon1.alpha = icon2.alpha = icon3.alpha = icon4.alpha = 0;
				icon1.x = icon2.x = icon3.x = icon4.x = -5000;
				iconBtn1.x = iconBtn2.x = iconBtn3.x = iconBtn4.x = -5000;
				
				addButtons();
			}
			
			var pat:RegExp = /[#-]/g;  //replace # and - globally
			var pat2:RegExp = /#/g;  //replace # globally
			
			for (var i:int = 0; i < subcategoryQuantity; i++){
				_i = i;
				
				var head:String = subCatXML[i].@ID;
				//convert #'s to spaces				
				var newHead:String = head.replace(pat2, " ");
				var subHead:String = head.replace(pat, "");
				
				if (theCategory != "MOBILE") {
					this["subcatName" + (i + 1)].subcatname.autoSize = TextFieldAutoSize.LEFT;
					this["subcatName" + (i + 1)].subcatname.text =  newHead; //headline text in the gray boxes
				}
				
				var iconDetail:MovieClip = this["iconDetail" + (i + 1)];
				
				iconDetail.subcatname.text = subHead;
				iconDetail.subcatheadline.htmlText = subCatXML[i].headlinesubcat;
				iconDetail.subcatcontent.htmlText = subCatXML[i].content;
				iconDetail.casestudysubhead.theText.text = config.featuredclientstext;
				
				//load people image
				var subcatimageURLLoader:Loader = new Loader();
				subcatimageURLLoader.load(new URLRequest(subCatXML[i].subcategoryimage));				
				subcatimageURLLoader.name = "icon" + (i + 1);
				subcatimageURLLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeListener, false, 0, true);	
				
				var caseStudyIDs:XMLList = subCatXML[i].casestudy; //list of case studies for subcategory				
				if(caseStudyIDs.length()){
					parseCasestudiesXML(caseStudyIDs);
				}else {
					iconDetail.casestudysubhead.alpha = 0;
				}
			}			
		}


		/**
		 * People image loaded - pl
		 * 
		 * uses the four empty icon clips on stage icon1 - icon4
		 * 
		 * @param	e COMPLETE event
		 */
		function completeListener(e:Event):void 
		{	
			e.target.removeEventListener(Event.COMPLETE, completeListener);
			
			var subcatImageURL:XMLList = xmlDataEngagementCube.category[categoryAssign].subcategory.subcategoryimage.text();
			
			var targetLoader:Loader = Loader(e.target.loader);
			
			//for smoothing -- converts target MC to bitmap
			var bit:Bitmap = e.target.content;
			
			for (var k:int = 0; k < subcatImageURL.length(); k++){				
				var tempIconName:String = "icon" + (k + 1);
				
				//for smoothing
				if(bit != null){
					bit.smoothing = true;
				}
				
				if(tempIconName == targetLoader.name) {					
		    		this["icon" + (k+1)].subcatimageholder.addChild(targetLoader);
				}
			}
			if (theCategory == "MOBILE") {
				selectIcon1();
			}
		}

		
		/**
		 * Called from parseEngagementCubeXML()
		 * 
		 * @param caseStudies XMLList of case study id's for this subcategory
		 */
		function parseCasestudiesXML(caseStudyIDs:XMLList):void 
		{			
			for (var n:int = 0; n < caseStudyIDs.length(); n++){							
				_n = n;	
				var act:Boolean = true;
				if (caseStudyIDs[n].@active != "true") {
				 act = false;
				}
				loadClientlogo(caseStudyIDs[n], act);				
			}
		}

		
		/**
		 * Loads logo from xmlDataCaseStudies xml object with the given id
		 * 
		 * @param	id case study id
		 * @param	isActive Boolean - true if the logo can be clicked on to get the case study info
		 */
		function loadClientlogo(id:String, isActive:Boolean):void 
		{				
			total_n = total_n + 1;		
			//_casestudyInput = casestudyInput;
			
			var clientlogoURL:String = xmlDataCaseStudies.casestudy.(@id == id).clientlogo;	
			
			var clientlogoURLLoader = new Loader();			
			clientlogoURLLoader.load(new URLRequest(clientlogoURL));
			clientlogoURLLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeListenerClientLogo, false, 0, true);	
			
			//create clientLogoContainer/casestudy ID			

			createClientlogoContainer();
			clientLogoContainer.addChild(clientlogoURLLoader);
			if (isActive) {
				//if this case study is active, add plus sign and Mouse listeners
				var pl:MovieClip = new active();
				pl.name = "plussign";
				clientLogoContainer.addChild(pl); // + sign
				var vm:MovieClip = new active2();//view more
				vm.name = "viewmore";
				vm.theText.text = config.viewcasestudytext;
				clientLogoContainer.addChild(vm);
				vm.alpha = 0;
				clientLogoContainer.name = String(id);
				clientLogoContainer.addEventListener(MouseEvent.CLICK, loadCaseStudy);			
				clientLogoContainer.addEventListener(MouseEvent.MOUSE_OVER, showVM);
				clientLogoContainer.addEventListener(MouseEvent.MOUSE_OUT, hideVM);
				clientLogoContainer.buttonMode = true;
			}
		}
		
		
		public function showVM(e:MouseEvent)
		{
			var vm = e.currentTarget.getChildByName("viewmore");
			var pl = e.currentTarget.getChildByName("plussign");
			Tweener.addTween(vm, { time:1, alpha:1 } );
			Tweener.addTween(pl.bg, { time:1, _color:0xE5AA28 } );
		}
		
		
		public function hideVM(e:MouseEvent)
		{
			var vm = e.currentTarget.getChildByName("viewmore");
			var pl = e.currentTarget.getChildByName("plussign");
			Tweener.addTween(vm, { time:1, alpha:0 } );
			Tweener.addTween(pl.bg, { time:1, _color:0x6D737C } );
		}


		/**
		 * Called when client case study logo has been loaded
		 * @param	e COMPLETE event
		 */
		function completeListenerClientLogo(e:Event):void 
		{
			_total_n = _total_n+1;		
			//var clientlogoURL:XMLList = _casestudyInput.casestudy[_total_n - 1].clientlogo;					
		
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}
		}


		//creates containers for logos within iconDetail movieclips		
		function createClientlogoContainer():void
		{
			clientLogoContainer = new MovieClip();
			var tempIconDetail:MovieClip = this["iconDetail" + (_i + 1)];

			tempIconDetail.addChild(clientLogoContainer);
			
			clientLogoContainer.x = (_n * 96);
			clientLogoContainer.y = 280; //hardcoded position of case study logos
			clientLogoContainer.scaleX = .82;
			clientLogoContainer.scaleY = .82;
		}
		

		function resetCasestudyDetail():void
		{
			resetCasestudyChildimage();
			removeChild(casestudyDetail);
			casestudyDetail.closebtn.x = casestudyDetail.closebtn.y = -19; //get x button off stage
			casestudyDetail.alpha = 0;
			casestudyDetail.btnBack.alpha = 0;
			casestudyDetail.emptyholder.alpha = 0;
			casestudyDetail.casestudyBox.alpha = 0;
			casestudyDetail.theTitle.alpha = 0;
			casestudyDetail.subheadstrategy.alpha = 0;
			casestudyDetail.theStrategy.alpha = 0;
			casestudyDetail.subheadresults.alpha = 0;
			casestudyDetail.results.alpha = 0;
			casestudyDetail.emptyholder2.alpha = 0;
			casestudyDetail.emptyholder3.alpha = 0;
			casestudyDetail.closebtn.alpha = 0;
			
			//casestudyDetail.behindMenu.width = Math.max(120, menuWidth + 26);
			
			
			for(var p:int = 0; p < _o; p++) {
		      casestudyDetail.emptyholder2.removeChild(myArray[p]);				
		    }

			myArray = new Array();

			if (firsttime == false){
				casestudyDetail.emptyholder.removeChildAt(0); 
				casestudyDetail.emptyholder2.removeChildAt(0);			
			}
			firsttime = false;	
			
			//Make sure no prior children in the holder
			while (casestudyDetail.emptyholder.numChildren) {
				casestudyDetail.emptyholder.removeChildAt(0);
			}
		}

		
		/**
		 * Called by clicking one of the client logo containers
		 * 
		 * @param	e CLICK MouseEvent
		 */
		function loadCaseStudy(e:MouseEvent):void
		{	
			casestudyID = e.currentTarget.name;
			
			var theCase:XMLList = xmlDataCaseStudies.casestudy.(@id == casestudyID);			
			
			var casestudyChildimageURL:XMLList = theCase.childimage;
			var casestudyChildthumbURL:XMLList = theCase.childthumb;

			addChild(casestudyDetail);
			
			for (var o:int = 0; o < casestudyChildthumbURL.length(); o++){
				_o = o;

				childthumbLength = casestudyChildthumbURL.length();

				var casestudyChildthumbURLLoader = new Loader();
				casestudyChildthumbURLLoader.load(new URLRequest(casestudyChildthumbURL[o]));
				casestudyChildthumbURLLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeListenerCasestudyChildthumb);

				casestudyChildthumbURLLoader.name = _o;//not sure if this is right

				createChildthumbContainer();
				casestudyChildthumbContainer.addChild(casestudyChildthumbURLLoader);
				Tweener.addTween(casestudyDetail.emptyholder2, {alpha:1, time:1, delay:2});
				casestudyChildthumbContainer.addEventListener(MouseEvent.CLICK, callCasestudyImage);
				casestudyChildthumbContainer.buttonMode = true;				

			}
			
			//use device fonts if Chinese
			if (language == "ch") {
				casestudyDetail.theTitle.embedFonts = false;
				casestudyDetail.theStrategy.embedFonts = false;
				casestudyDetail.theResults.embedFonts = false;
				casestudyDetail.btnBack.backTxt.embedFonts = false;
				casestudyDetail.subheadstrategy.strategy.embedFonts = false;
				casestudyDetail.subheadresults.results.embedFonts = false;
			}		
			
			//config back button and subheads from xml
			casestudyDetail.btnBack.backTxt.text = config.backbuttontext.toString();
			casestudyDetail.subheadstrategy.strategy.text = config.strategytext.toString();
			casestudyDetail.subheadresults.results.text = config.resultstext.toString();			
			
			casestudyDetail.theTitle.text = theCase.title;
			casestudyDetail.theStrategy.text = theCase.strategy;
			casestudyDetail.results.text = theCase.results;
			
			casestudyMainimageURLLoader = new Loader();
			casestudyMainimageURLLoader.load(new URLRequest(theCase.mainimage));
			casestudyMainimageURLLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeListenerCasestudyMainimage);

			casestudyDetail.casestudyBox.filters = [filt1];
			casestudyDetail.btnBack.filters = [filt2];
			casestudyDetail.theTitle.filters = [filt2];
			casestudyDetail.subheadstrategy.filters = [filt2];
			casestudyDetail.theStrategy.filters = [filt2];
			casestudyDetail.subheadresults.filters = [filt2];
			casestudyDetail.results.filters = [filt2];

			casestudyDetail.casestudyBox.x += 100;
			var casestudyBoxLocation:int = casestudyDetail.casestudyBox.x-100;
			
			Tweener.addTween(casestudyDetail, {alpha:1, time:1});
			Tweener.addTween(casestudyDetail.emptyholder, {alpha:1, time:1});
			Tweener.addTween(casestudyDetail.casestudyBox, {alpha:.9, time:1, delay:.25});

			Tweener.addTween(casestudyDetail.casestudyBox, {x:casestudyBoxLocation, time:.5, delay:.25, transition:"easeOutExpo"});
			Tweener.addTween(casestudyDetail.theTitle, {alpha:1, time:1, delay:.75});
			Tweener.addTween(casestudyDetail.subheadstrategy, {alpha:1, time:1, delay:1});
			Tweener.addTween(casestudyDetail.theStrategy, {alpha:1, time:1, delay:1.25});
			Tweener.addTween(casestudyDetail.subheadresults, {alpha:1, time:1, delay:1.5});
			Tweener.addTween(casestudyDetail.results, {alpha:1, time:1, delay:1.75});

			Tweener.addTween(casestudyDetail.btnBack, { alpha:1, time:1, delay:1.25 } );
			
			casestudyDetail.interactivitymask.width = stage.stageWidth;
			casestudyDetail.interactivitymask.height = stage.stageHeight;
		}



		//casestudy mainimage completeListener
		function completeListenerCasestudyMainimage(e:Event):void 
		{	
			var bit:Bitmap = e.target.content;			
			if(bit != null){
				bit.smoothing = true;
			}
			
			//Make sure no prior children in the holder
			while (casestudyDetail.emptyholder.numChildren) {
				casestudyDetail.emptyholder.removeChildAt(0);
			}
			
		    casestudyDetail.emptyholder.addChild(casestudyMainimageURLLoader);
			onStageResize();			
		}



		//casestudy childthumb completeListener		
		function completeListenerCasestudyChildthumb(e:Event):void 
		{
			var bit:Bitmap = e.target.content;			
			if(bit != null){
				bit.smoothing = true;
			}
		}

		
		function createChildthumbContainer():void
		{
			var childthumbXAdjust:int;
			
			if (childthumbLength == 4){childthumbXAdjust = 0};
			if (childthumbLength == 3){childthumbXAdjust = 20};
			if (childthumbLength == 2){childthumbXAdjust = 50};
			
			casestudyChildthumbContainer = new MovieClip();
			casestudyDetail.emptyholder2.addChild(casestudyChildthumbContainer);
			myArray.push(casestudyChildthumbContainer);

			casestudyChildthumbContainer.x = (869 - (childthumbXAdjust * 1.2)) - (_o * (84 + childthumbXAdjust));

			casestudyChildthumbContainer.y = 425;
			casestudyChildthumbContainer.scaleX = .8;
			casestudyChildthumbContainer.scaleY = .8;

		}

		
		function callCasestudyImage(e:MouseEvent):void
		{
			callCasestudyImageID = e.target.name;			
			var theCase:XMLList = xmlDataCaseStudies.casestudy.(@id == casestudyID);
			var imURL:String = theCase.childimage[callCasestudyImageID];
					
			var casestudyChildimageURLLoader = new Loader();
			casestudyChildimageURLLoader.load(new URLRequest(imURL));
			casestudyChildimageURLLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeListenerCasestudyChildimage, false, 0, true);
		}

		
		/**
		 * Called when the clicked thumbnail is done loading - shows the associated image
		 * @param	e
		 */
		function completeListenerCasestudyChildimage(e:Event):void 
		{
			var targetLoader:Loader = Loader(e.target.loader);
			var bit:Bitmap = e.target.content;			
			if(bit != null){
				bit.smoothing = true;
			}
			targetLoader.x = 512 - ((targetLoader.width / 2) * .8);
			targetLoader.y = 324 - ((targetLoader.height / 2) * .8);
			targetLoader.scaleX = targetLoader.scaleY = .8;			
			casestudyDetail.emptyholder3.scaleX = casestudyDetail.emptyholder3.scaleY = .8;			
			casestudyDetail.emptyholder3.addChild(targetLoader);
			
			casestudyDetail.emptyholder3.filters = [filt1];
			
			Tweener.addTween(casestudyDetail.emptyholder3, {alpha:1, scaleX:1, scaleY:1, time:1});		
			casestudyDetail.emptyholder3.x = targetLoader.width * .2;
			casestudyDetail.emptyholder3.y = targetLoader.height * .2;
			
			Tweener.addTween(casestudyDetail.emptyholder3, {x:0, y:0, time:1});			
			
			//addChild(casestudyDetail.interactivitymask);
			//Tweener.addTween(casestudyDetail.interactivitymask, {alpha:.4, time:1});
			addChild(casestudyDetail.closebtn);
			
			casestudyDetail.closebtn.filters = [filt2];
			
			Tweener.addTween(casestudyDetail.closebtn, {alpha:1, time:1, delay:.75});
			casestudyDetail.closebtn.x	= 512 + ((targetLoader.width / 2));;
			casestudyDetail.closebtn.y	= 324 - ((targetLoader.height / 2));
		}


		/**
		 * Called from parseEngagementCubeXML()
		 * once the number of sub categories is known (var subcategoryQuantity)
		 */
		public function initAnimation():void
		{	
			box1.alpha = box2.alpha = box3.alpha = box4.alpha = 0;
			box1.y = box2.y = box3.y = box4.y = -5000;
			subcatName1.alpha = subcatName2.alpha = subcatName3.alpha = subcatName4.alpha = 0;
			icon1.alpha = icon2.alpha = icon3.alpha = icon4.alpha = 0;
			icon1.x = icon2.x = icon3.x = icon4.x = -5000;
			iconBtn1.x = iconBtn2.x = iconBtn3.x = iconBtn4.x = -5000
			
			var boxWidth = 124;			
			var betweenSpace = 66;
			var totSpace = (subcategoryQuantity * boxWidth) + ((subcategoryQuantity - 1) * betweenSpace);
			var remSpace = 764 - totSpace;
			var startX:Number = 260 + remSpace * .5;			
			var leftEdge:Number = startX;
			
			for (var i:int = 1; i <= subcategoryQuantity; i++) {
				var theBox:MovieClip = this["box" + i];
				this["subcatName" + i].x = startX;
				this["icon" + i].x = startX;				
				this["iconBtn" + i].x = startX - boxWidth / 2; //half of box width because the boxes are center aligned
				
				theBox.alpha = 0; theBox.x = 542; theBox.y = 343; theBox.scaleX = theBox.scaleY = .25;
				Tweener.addTween(theBox, {alpha:1, time:.5, delay:i-1, transition:"easeOut"});			
				Tweener.addTween(theBox, {x:startX, y:414, time:2, delay:i - 1, transition:"easeOut"});// formerly, "x:258"			
				Tweener.addTween(theBox, { scaleX:1, scaleY:1, time:1.5, transition:"easeOut" } );
				
				Tweener.addTween(this["icon" + i], { alpha:1, delay:i, transition:"easeOut"} );
				Tweener.addTween(this["subcatName" + i], {alpha:1, time:1, delay:i, transition:"easeOut"});
			
				startX += boxWidth + betweenSpace;
			}
			var totalBoxWidth:Number = ((subcategoryQuantity - 1) * (boxWidth + betweenSpace)) + boxWidth;			
			//var diff:Number = (headlineLanding.width - boxWidth) * .5;		
			//headlineLanding.x = leftEdge - diff;
			
			//text box at bottom - contains the headline text for the given category
			headlineLanding.alpha = 0;
			
			Tweener.addTween(headlineLanding, { alpha:1, time:1, delay:subcategoryQuantity + 1 } );
			
			Tweener.addTween(box1, { delay:3, onComplete:addButtons } );//onComplete turns on main buttons		
		}


		//button setup
		function addButtons():void
		{			
			for (var i:int = 1; i <= subcategoryQuantity; i++) {
				this["iconBtn" + i].buttonMode = true;
			}		
			
			iconBtn1.addEventListener(MouseEvent.CLICK, icon1Click);
			iconBtn2.addEventListener(MouseEvent.CLICK, icon2Click);
			iconBtn3.addEventListener(MouseEvent.CLICK, icon3Click);
			iconBtn4.addEventListener(MouseEvent.CLICK, icon4Click);
			
			casestudyDetail.btnBack.buttonMode = true;		
			casestudyDetail.btnBack.addEventListener(MouseEvent.CLICK, btnBackClick);
			
			casestudyDetail.closebtn.buttonMode = true;
			casestudyDetail.closebtn.useHandCursor = true;
			casestudyDetail.closebtn.addEventListener(MouseEvent.CLICK, closebtnClick)
			
			
			if (subcategoryQuantity == 3) {
				removeChild(iconBtn4);
			}

			//mouseover and mouseout event listeners, stupid george style
			iconBtn1.addEventListener (MouseEvent.MOUSE_OVER, function() {
				if(elementsReceded && iconSelected != "icon1"){
					Tweener.addTween(subcatName1, {alpha:1, time:.5});
				}
			});
			iconBtn1.addEventListener (MouseEvent.MOUSE_OUT, function() {
				if(elementsReceded){
					Tweener.addTween(subcatName1, {alpha:0, time:.5});
				}
			});
			
			
			iconBtn2.addEventListener (MouseEvent.MOUSE_OVER, function() {
				if(elementsReceded && iconSelected != "icon2"){
					Tweener.addTween(subcatName2, {alpha:1, time:.5});
				}
			});
			iconBtn2.addEventListener (MouseEvent.MOUSE_OUT, function() {
				if(elementsReceded){
					Tweener.addTween(subcatName2, {alpha:0, time:.5});
				}
			});
			
			
			iconBtn3.addEventListener (MouseEvent.MOUSE_OVER, function() {
				if(elementsReceded && iconSelected != "icon3"){
					Tweener.addTween(subcatName3, {alpha:1, time:.5});
				}
			});
			iconBtn3.addEventListener (MouseEvent.MOUSE_OUT, function() {
				if(elementsReceded){
					Tweener.addTween(subcatName3, {alpha:0, time:.5});
				}
			});
			
			
			iconBtn4.addEventListener (MouseEvent.MOUSE_OVER, function() {
				if(elementsReceded && iconSelected != "icon4"){
					Tweener.addTween(subcatName4, {alpha:1, time:.5});
				}
			});
			iconBtn4.addEventListener (MouseEvent.MOUSE_OUT, function() {
				if(elementsReceded){
					Tweener.addTween(subcatName4, {alpha:0, time:.5});
				}
			});

		}


		//on "click" functions
		function btnBackClick(e:Event):void
		{
			Tweener.removeAllTweens(); //kill any current tweens
			
			Tweener.addTween(casestudyDetail, {alpha:0, time:1, onComplete:resetCasestudyDetail});
		}

		
		
		/**
		 * Called by clicking the close button in the case study detail - button that
		 * closes the larger image that is opened by clicking the thumbnail
		 * 
		 * @param	e
		 */
		function closebtnClick(e:Event):void
		{
			Tweener.removeAllTweens(); //kill any current tweens
			Tweener.addTween(casestudyDetail.closebtn, {alpha:0, time:1});
			Tweener.addTween(casestudyDetail.interactivitymask, {alpha:0, time:1});
			Tweener.addTween(casestudyDetail.emptyholder3, {alpha:0, time:1, onComplete:resetCasestudyChildimage});
		}

		
		function resetCasestudyChildimage():void
		{
			//trace("resetCasestudyChildimage");
			casestudyDetail.closebtn.x = casestudyDetail.closebtn.y = -19;
			//trace(casestudyDetail.emptyholder3.numChildren);
			while(casestudyDetail.emptyholder3.numChildren){
				casestudyDetail.emptyholder3.removeChildAt(0);
			}
			/*
			if(contains(casestudyDetail.interactivitymask)){
				removeChild(casestudyDetail.interactivitymask);	
			}
			*/
		}


		function icon1Click(e:Event):void
		{
			
			removeTweens();
			selectIcon1();
			recedeIcon2();
			recedeIcon3();
			recedeIcon4();
			if(elementsReceded == false){
				recedeElements();
			}
		}

		
		function icon2Click(e:Event):void
		{
			removeTweens();
			recedeIcon1();
			selectIcon2();
			recedeIcon3();
			recedeIcon4();
			if(elementsReceded == false){
				recedeElements();
			}
		}

		
		function icon3Click(e:Event):void
		{
			removeTweens();
			recedeIcon1();
			recedeIcon2();
			selectIcon3();
			recedeIcon4();
			if(elementsReceded == false){
				recedeElements();
			}
		}

		
		function icon4Click(e:Event):void
		{
			removeTweens();
			recedeIcon1();
			recedeIcon2();
			recedeIcon3();
			selectIcon4();
			if(elementsReceded == false){
				recedeElements();
			}
		}


		function removeTweens():void
		{
			Tweener.removeTweens(headlineLanding);

			Tweener.removeTweens(icon1);
			Tweener.removeTweens(icon2);
			Tweener.removeTweens(icon3);
			Tweener.removeTweens(icon4);
			
			Tweener.removeTweens(box1);
			Tweener.removeTweens(box2);
			Tweener.removeTweens(box3);
			Tweener.removeTweens(box4);
				
			Tweener.removeTweens(subcatName1);
			Tweener.removeTweens(subcatName2);
			Tweener.removeTweens(subcatName3);
			Tweener.removeTweens(subcatName4);
		}



		function recedeIcon1():void
		{
			Tweener.addTween(icon1, {alpha:.5, x:50 , y:370, scaleX:.2, scaleY:.2, time:.75, transition:"easeInOutExpo"});
			iconBtn1.useHandCursor = true;
			Tweener.addTween(iconDetail1, {alpha:0, time:.5, onComplete:function() { if(contains(iconDetail1)){removeChild(iconDetail1); }}});
			addChildAt(icon1, 1);
			
		}
		
		
		function recedeIcon2():void
		{
			Tweener.addTween(icon2, {alpha:.5, x:95 , y:370, scaleX:.2, scaleY:.2, time:.75, transition:"easeInOutExpo"});
			iconBtn2.useHandCursor = true;
			Tweener.addTween(iconDetail2, {alpha:0, time:.5, onComplete:function() { if(contains(iconDetail2)){removeChild(iconDetail2); }}});
			addChildAt(icon2, 1);
		}
		
		
		function recedeIcon3():void
		{
			Tweener.addTween(icon3, {alpha:.5, x:140 , y:370, scaleX:.2, scaleY:.2, time:.75, transition:"easeInOutExpo"});
			iconBtn3.useHandCursor = true;
			Tweener.addTween(iconDetail3, {alpha:0, time:.5, onComplete:function() { if(contains(iconDetail3)){ removeChild(iconDetail3); }}});
			addChildAt(icon3, 1);
		}
		
		
		function recedeIcon4():void
		{
			Tweener.addTween(icon4, {alpha:.5, x:185 , y:370, scaleX:.2, scaleY:.2, time:.75, transition:"easeInOutExpo"});
			iconBtn4.useHandCursor = true;
			Tweener.addTween(iconDetail4, {alpha:0, time:.5, onComplete:function() { if(contains(iconDetail4)){ removeChild(iconDetail4); }}});
			addChildAt(icon4, 1);
		}

		
		function selectIcon1():void
		{
			Tweener.addTween(subcatName1, { alpha:0, time:.75 } );
			if(theCategory != "MOBILE"){
				if (categoryAssign == 5 ){
					Tweener.addTween(icon1, {alpha:1, x:338 , y:327, scaleX:.820, scaleY:.820, time:.75, transition:"easeInOutExpo"});		
				}else{
					Tweener.addTween(icon1, {alpha:1, x:310 , y:327, scaleX:.9, scaleY:.9, time:.75, transition:"easeInOutExpo"});	
				}
			}else {
				//If mobile then just fade in darryl
				icon1.x = 310;
				icon1.y = 327;
				icon1.alpha = 0;
				icon1.scaleX = icon1.scaleY = .9;
				Tweener.addTween(icon1, {alpha:1, time:.75, transition:"easeInOutExpo"});					
			}
			iconSelected = "icon1";
			iconBtn1.useHandCursor = false;
			addChild(iconDetail1);
			Tweener.addTween(iconDetail1, {alpha:1, time:1, delay:1});
		}		
		
		
		function selectIcon2():void
		{
			Tweener.addTween(subcatName2, {alpha:0, time:.75});
			
			if (categoryAssign == 2 ){
				Tweener.addTween(icon2, {alpha:1, x:300 , y:327,scaleX:.84, scaleY:.84, time:.75, transition:"easeInOutExpo"});			
			}else if(categoryAssign == 4 ){
				Tweener.addTween(icon2, {alpha:1, x:300 , y:327,scaleX:.8, scaleY:.8, time:.75, transition:"easeInOutExpo"});		
			}else{
				Tweener.addTween(icon2, {alpha:1, x:310 , y:327,scaleX:.9, scaleY:.9, time:.75, transition:"easeInOutExpo"});		
			}
			iconSelected = "icon2";
			iconBtn2.useHandCursor = false;
			addChild(iconDetail2);
			Tweener.addTween(iconDetail2, {alpha:1, time:1, delay:1});
		}
		
		
		function selectIcon3():void
		{
			Tweener.addTween(subcatName3, {alpha:0, time:.75});
			Tweener.addTween(icon3, { alpha:1, x:310 , y:327, scaleX:.9, scaleY:.9, time:.75, transition:"easeInOutExpo" } );
			iconSelected = "icon3";
			iconBtn3.useHandCursor = false;
			addChild(iconDetail3);
			Tweener.addTween(iconDetail3, {alpha:1, time:1, delay:1});
		}
		
		function selectIcon4():void
		{
			Tweener.addTween(subcatName4, {alpha:0, time:.75});
			Tweener.addTween(icon4, {alpha:1, x:310 , y:327, scaleX:.9, scaleY:.9, time:.75, transition:"easeInOutExpo"});
			iconSelected = "icon4";
			iconBtn4.useHandCursor = false;
			addChild(iconDetail4);
			Tweener.addTween(iconDetail4, {alpha:1, time:1, delay:1});
		}
		

		function recedeElements():void
		{
			Tweener.addTween(box1, {alpha:0, time:.75});
			Tweener.addTween(box2, {alpha:0, time:.75});
			Tweener.addTween(box3, {alpha:0, time:.75});
			Tweener.addTween(box4, { alpha:0, time:.75 } );
			selectText.theText.text = config.selecttext;
			Tweener.addTween(selectText, {alpha:1, time:1.25,delay:.75});			
			Tweener.addTween(subcatName1, {scaleX:.8, scaleY:.8, delay:.75});
			Tweener.addTween(subcatName2, {scaleX:.8, scaleY:.8, delay:.75});
			Tweener.addTween(subcatName3, {scaleX:.8, scaleY:.8, delay:.75});
			Tweener.addTween(subcatName4, {scaleX:.8, scaleY:.8, delay:.75});
			Tweener.addTween(subcatName1, {x:50 , y:300, delay:.75});
			Tweener.addTween(subcatName2, {x:95 , y:300, delay:.75});
			Tweener.addTween(subcatName3, {x:140 , y:300, delay:.75});
			Tweener.addTween(subcatName4, {x:185 , y:300, delay:.75});
			Tweener.addTween(subcatName1, {alpha:0, time:.75});
			Tweener.addTween(subcatName2, {alpha:0, time:.75});
			Tweener.addTween(subcatName3, {alpha:0, time:.75});
			Tweener.addTween(subcatName4, {alpha:0, time:.75});
			Tweener.addTween(iconBtn1, {x:30, y:290, scaleX:.24, scaleY:.24, time:.75, transition:"easeInOutExpo"});			
			Tweener.addTween(iconBtn2, {x:75, y:290, scaleX:.24, scaleY:.24, time:.75, transition:"easeInOutExpo"});			
			Tweener.addTween(iconBtn3, {x:120, y:290, scaleX:.24, scaleY:.24, time:.75, transition:"easeInOutExpo"});			
			Tweener.addTween(iconBtn4, {x:165, y:290, scaleX:.24, scaleY:.24, time:.75, transition:"easeInOutExpo"});			
			Tweener.addTween(headlineLanding, {alpha:0, time:1, onComplete:switchBoolean});			
		}
		
		/**
		 * Called from recedeElements once the tweens are complete
		 */
		private function switchBoolean():void
		{
			elementsReceded = true;
		}
	}	
}