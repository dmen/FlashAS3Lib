/**
 * Document class for people.fla - people.swf
 * 
 * loads people.xml
 */


package com.gmrmarketing.website
{	
	import flash.display.LoaderInfo; //for flashvars
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import gs.TweenLite;
	import gs.easing.*;
	import gs.plugins.*;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import com.reintroducing.utils.StageManager;
	import com.reintroducing.events.StageManagerEvent;
	import flash.filters.DropShadowFilter;


	public class People extends MovieClip
	{			
		private const IMAGE_X:int = 515;
		private const IMAGE_Y:int = 60;
		private const SQUARE_SIZE:int = 104; //size of individual grid squares
		private const SCALED_SIZE:int = 122;
		private const BUFFER:int = 8; //space between squares - used for positioning faces on the grid		
		
		private var xmlLoaderMain:URLLoader = new URLLoader();
		private var xmlDataMain:XML = new XML();
		
		private var xmlLoaderCaseStudies:URLLoader = new URLLoader();
		private var xmlDataCaseStudies:XML = new XML();
		
		private var mainImageLoader:Loader;
		private var detailImageLoader:Loader;		
		
		private var peopleXML:XMLList; //list of persons in the category - leadership - talent
		
		private var theImages:XMLList; //all images defined in casestudies_main.xml - used for fading between
		private var curImage:int; //counter for going through theImages		
		private var mainHolder:MovieClip; //container for the side images		
		
		private var faces:Array; //references to the faces in the main image 'cube'		
		
		private var detail:detailClip; //library clips
		private var theBorder:border;
		
		private var ds:DropShadowFilter;		
		
		private var stageMan:StageManager;
		
		private var language:String;
		private var basePath:String;
		
		private var numFacesToLoad:int;
		private var curFaceLoaded:int;
		/**
		 * CONSTRUCTOR
		 */
		public function People()
		{
			//flashvars
			if (loaderInfo.parameters.language == undefined) {
				language = "en"; //default to english
			}
			basePath = language + "/"; //prepended to image path from xml
			
			TweenPlugin.activate([TintPlugin]);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);

			background.width = stage.stageWidth;
			background.height = stage.stageHeight;			

			logo.addEventListener(MouseEvent.CLICK, gotoHomepage);
			logo.mouseEnabled = true;
			logo.buttonMode = true;

			detail = new detailClip(); //library clips
			theBorder = new border();
			
			faces = new Array(); //contains loader instances for removing			
			
			detailImageLoader = new Loader();
			
			ds = new DropShadowFilter(2, 0, 0x000000, .6, 6, 6);
			detail.filters = [ds];
			
			mainHolder = new MovieClip();
			addChild(mainHolder);
			mainHolder.x = IMAGE_X;
			mainHolder.y = IMAGE_Y;			
			
			var req:URLRequest = new URLRequest("people.xml");			
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
		 * The following methods are called by MouseEvent.CLICK
		 */
		private function doLeadership(e:MouseEvent = null):void
		{
			parseXML("leadership");
		}
		
		private function doTalent(e:MouseEvent = null):void
		{
			parseXML("talent");
		}
		
		
		/**
		 * Called once people.xml has been loaded		
		 * 
		 * @param	e Event.COMPLETE
		 */
		private function mainXMLLoaded(e:Event):void
		{
			xmlLoaderMain.removeEventListener(Event.COMPLETE, mainXMLLoaded);
			xmlDataMain = new XML(e.target.data);
			
			headline.autoSize = TextFieldAutoSize.LEFT;
			subTitle.autoSize = TextFieldAutoSize.LEFT;
			content.autoSize = TextFieldAutoSize.LEFT;
			headline.text = xmlDataMain.title;
			subTitle.text = xmlDataMain.subtitle;
			subTitle.y = headline.y + headline.textHeight + 18;
			content.htmlText = xmlDataMain.bodycopy;
			content.y = subTitle.y + subTitle.textHeight + 15;
			
			leadershipTxt.text = xmlDataMain.leadershipbutton;
			talentTxt.text = xmlDataMain.talentbutton;		
			if(xmlDataMain.leadershipbutton == ""){
				//trace("hide leadership button")
				leadershipButton.enabled = false;
				talentButton.enabled = false;				
				vertLine.visible = false;
				}
			
			leadershipTxt.y = content.y + content.textHeight + 20;
			talentTxt.y = leadershipTxt.y;
			vertLine.y = leadershipTxt.y;
			leadershipButton.y = leadershipTxt.y;
			talentButton.y = leadershipTxt.y;
			leadershipButton.addEventListener(MouseEvent.CLICK, doLeadership, false, 0, true);
			talentButton.addEventListener(MouseEvent.CLICK, doTalent, false, 0, true);
			leadershipButton.buttonMode = true;
			talentButton.buttonMode = true;
		
			// XMLList of all images in casestudies_main.xml
			theImages = xmlDataMain.categories.category.image;			
			curImage = 0;
			
			parseXML();
		}
		
		
		/**
		 * Called by clicking the category menu buttons
		 * 
		 * @param	theCategory - String - Category ID in the casestudies_main.xml file
		 */
		private function parseXML(theCategory:String = "leadership"):void 
		
		{
			if (theCategory == "leadership") {
				TweenLite.to(leadershipTxt, 0, { tint:0xE5AA28 } );
				TweenLite.to(talentTxt, 0, { tint:0x595C63 } );
			}else {
				TweenLite.to(leadershipTxt, 0, { tint:0x595C63 } );
				TweenLite.to(talentTxt, 0, { tint:0xE5AA28 } );
			}
			
			peopleXML = xmlDataMain[theCategory].person;				
			
			if (contains(detail)) {
				killDetail();
			}
			//remove any old faces from grid
			for (var j = 0; j < faces.length; j++)
			{
				if (contains(faces[j])) {
					faces[j].removeChildAt(0);
					removeChild(faces[j]);
				}
			}
			faces = new Array();			
			
			numFacesToLoad = peopleXML.length();
			curFaceLoaded = 0;
			
			for (var i:int = 0; i < peopleXML.length(); i++) {
				var imageURL:String = peopleXML[i].image;				
				var pos:Array = peopleXML[i].cubepos.split(",");
				loadFace(imageURL, pos, i);				
			}			
		}		
	
		
		
		/**
		 * Called in loop from parseXML, for each person attached to the grid
		 * 
		 * @param	theURL
		 * @param	pos
		 * @param	caseID
		 */
		private function loadFace(theURL:String, pos:Array, arrayIndex:int):void
		{
			var faceContainer:MovieClip = new people_mc();
			
			faceContainer.buttonMode = true;
			faceContainer.index = arrayIndex;
			faceContainer.nameHolder.theText.text = peopleXML[arrayIndex].name;
			faceContainer.nameHolder.alpha = 0;
	
			var faceLoader = new Loader();
			faceContainer.addChildAt(faceLoader,1);
			
			faces.push(faceContainer); //push to faces so we have references for removing
			
			//position logo based on cubepos in the xml
			faceContainer.x = IMAGE_X + ((SQUARE_SIZE * (pos[0] - 1)) + ((pos[0] - 1) * BUFFER));
			faceContainer.y = IMAGE_Y + ((SQUARE_SIZE * (pos[1] - 1)) + ((pos[1] - 1) * BUFFER));		
			
			faceContainer.startX = faceContainer.x;
			faceContainer.startY = faceContainer.y;
			//for centering face when it scales
			faceContainer.scaledX = faceContainer.x - ((SCALED_SIZE - SQUARE_SIZE) * .5);
			faceContainer.scaledY = faceContainer.y - ((SCALED_SIZE - SQUARE_SIZE) * .5);
				
			faceContainer.alpha = 0;
			addChild(faceContainer);
			
			faceLoader.load(new URLRequest(theURL));
			faceLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeListenerFace, false, 0, true);
			faceLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, faceError, false, 0, true);
			
			curFaceLoaded++;
			if (curFaceLoaded == numFacesToLoad) {
				TweenLite.to(faceContainer, .5, { alpha:1, onComplete:enableFaces } )
			}else {
				TweenLite.to(faceContainer, .5, { alpha:1 } )
			}
		}
		
		
		private function faceError(e:IOErrorEvent):void
		{
			trace(e);
		}
		
		
		/**
		 * image finished loading
		 * 
		 * @param	e COMPLETE Event
		 */
		private function completeListenerFace(e:Event):void 
		{			
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}
			
			//fit faces to grid size
			bit.width = bit.height = SQUARE_SIZE;
		}
		
		
		private function enableFaces():void
		{
			for (var i:int = 0; i < faces.length; i++){
				faces[i].addEventListener(MouseEvent.CLICK, clickFace, false, 0, true);
				faces[i].addEventListener(MouseEvent.MOUSE_OVER, overFace, false, 0, true);
				faces[i].addEventListener(MouseEvent.MOUSE_OUT, outFace, false, 0, true);
				faces[i].buttonMode = true;
			}
		}
		
		
		private function disableFaces():void
		{
			for (var i:int = 0; i < faces.length; i++){
				faces[i].removeEventListener(MouseEvent.CLICK, clickFace);
				faces[i].removeEventListener(MouseEvent.MOUSE_OVER, overFace);
				faces[i].removeEventListener(MouseEvent.MOUSE_OUT, outFace);
				faces[i].buttonMode = false;
			}
		}
		
		
		private function overFace(e:MouseEvent):void
		{
			TweenLite.to(e.currentTarget, .1, { width:SCALED_SIZE, height:SCALED_SIZE, x:e.currentTarget.scaledX, y:e.currentTarget.scaledY, ease:Linear.easeNone } );
			TweenLite.to(e.currentTarget.nameHolder, .4, { alpha:1 } );
			
			if (!contains(theBorder)) {
				addChild(theBorder);
				theBorder.alpha = 0;
				theBorder.x = e.currentTarget.scaledX;
				theBorder.y = e.currentTarget.scaledY;
			}
			
			TweenLite.to(theBorder, .3, { alpha:1 } );
		}
		
		
		private function outFace(e:MouseEvent):void
		{
			TweenLite.to(e.currentTarget, .2, { width:SQUARE_SIZE, height:SQUARE_SIZE, x:e.currentTarget.startX, y:e.currentTarget.startY } );
			TweenLite.to(e.currentTarget.nameHolder, .2, { alpha:0 } );
			if (contains(theBorder)) {
				removeChild(theBorder);
			}
		}
		
		
		/**
		 * Parse proper case study out of casestudies.xml
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function clickFace(e:MouseEvent):void
		{
			var arrayInd:int = e.currentTarget.index;
			
			TweenLite.to(e.currentTarget, .2, { width:SQUARE_SIZE, height:SQUARE_SIZE, x:e.currentTarget.startX, y:e.currentTarget.startY } );
			TweenLite.to(e.currentTarget.nameHolder, .2, { alpha:0 } );
			if (contains(theBorder)) {
				removeChild(theBorder);
			}
			
			detailImageLoader.load(new URLRequest(peopleXML[arrayInd].image));
			detail.photoHolder.addChild(detailImageLoader);			
			
			addChild(detail);
			detail.x = 555;
			detail.y = 95;
			
			detail.peopleTitle.autoSize = TextFieldAutoSize.LEFT;
			detail.peopleDescription.autoSize = TextFieldAutoSize.LEFT;			
			
			detail.peopleTitle.htmlText = peopleXML[arrayInd].position;
			detail.peopleDescription.htmlText = peopleXML[arrayInd].description;
			
			detail.popBg.height = Math.max(352, 25 + detail.peopleDescription.textHeight);
			
			detail.closeButton.addEventListener(MouseEvent.CLICK, removeDetail, false, 0, true);
			detail.closeButton.buttonMode = true;
			
			detail.alpha = 0;			
			TweenLite.to(detail, 1, { alpha:1 } );
			
			disableFaces();
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
		 * Fades out the detail clip then calls killDetail to remove child objects
		 * @param	e
		 */
		private function removeDetail(e:MouseEvent = null):void
		{				
			TweenLite.to(detail, .5, { alpha:0, onComplete:killDetail } );
		}
		
		
		
		
		/**
		 * Removes child objects from the detail clip
		 * and then removes detail clip from the stage
		 * 
		 * Called from removeDetail, by TweenLite.onComplete
		 */
		private function killDetail():void
		{	
			enableFaces();
			
			detail.peopleTitle.htmlText = "";
			detail.peopleDescription.htmlText = "";
			detail.closeButton.removeEventListener(MouseEvent.CLICK, removeDetail);
			detail.closeButton.buttonMode = false;
			
			//remove image
			if (detail.photoHolder.contains(detailImageLoader)) {
				detail.photoHolder.removeChild(detailImageLoader);				
			}
			
			removeChild(detail);		
		}
	}
}