/**
 * NEW VERSION - 2/19/10 - FOR NEW CUBE VIDEOS
 * 
 * THIS VERSION - 3 - IS FOR THE THIRD COLUMN WITH VIDEO LINKS
 * 
 * 
 * 
 * 
 * Document class for gmr_practices_shell_dave.fla
 * main intro of site with cube videos
 * publishes to gmr_practices_shell.swf
 * 
 * loads intro.xml
 * 
 * loads the practices file - gmr_practices_parent_dave2.fla which publishes to gmr_practices.swf
 * 
 * 
 * Logo Videos:
 * 
 * 1 - start small centered, shake, open, move down to bottom
 * 2 - moves up, while open, to fill screen
 * 3 - moves from full screen back to open bottom
 * 4 - closes, rotates - becomes flat logo for upper left menu
 * 5 - moves from upper left menu position, rotates, opens, moves down
 */

 
package com.gmrmarketing.website
{
	import adobe.utils.CustomActions;
	import flash.display.LoaderInfo; //for flashvars
	import flash.display.Bitmap;
	import flash.display.Loader;	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	import com.greensock.easing.*;
	
	import flash.display.MovieClip;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.*;
	import flash.net.navigateToURL;	
	
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import flash.display.Stage;	
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.utils.getDefinitionByName;
	
	//import com.gmrmarketing.utilities.Tracer;
	import flash.filters.DropShadowFilter;
	
	
	
	public class Main4 extends MovieClip
	{		
		private const VID_FOLDER:String = "assets/video_cube_transitions/";
		
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;	
		
		private var practiceLoader:Loader;
		private var categoryClicked:int = -1;
		
		//category strings for swfAddress - indexes match category numbers assigned in buildMenu()
		//used in urlChange() to get the category based on the string
		private var categories:Array = new Array("sports", "entertainment", "lifestyle", "retail", "digital", "consulting", "corporate");
		
		//array of buttons in the menu to link category number to button
		private var menuButtons:Array;
		
		//separate for the big yellow video
		private var bigVidConnection:NetConnection;
		private var bigVidStream:NetStream;
		private var bigVideo:Video;
		
		//library clips
		//private var navigation:nav;
		
		private var introHead:MovieClip;
		private var introCopy:MovieClip;
		private var closeButton:closeBtn;		
		private var background:bg;
		private var bigVideoNavigation:vidNav;
		
		private var navigation:Sprite; //contains instances of navTxt
		private var theNavWidth:Number = 0;
		
			
		private var logoButton:gmrLogo;		
		
		private var swfAddressMenuChange:Boolean = false;
		
		private var language:String = "";
		private var basePath:String = "";
		
		private var xmlLoader:URLLoader;
		private var introXML:XML;
		
		//private var tracer:Tracer;
		
		private var vidContainer:Sprite;
		private var thumbs:Sprite; //vid clips inside the container - so they can be masked
		private var upArrow:arrow_up; //lib clips
		private var dnArrow:arrow_dn;
		//private var igClip:ignitionClip; //library clip
		//private var igLoader:Loader;
		private var ds:DropShadowFilter;
		//private var igButton:igniteButton; //lib clip		
		
		private var iconMenu:Sprite; //practices icons
		private var selectedVideo:String;
		
		private var thumbMask:MovieClip;
		
		private var detail:detailHolder; //lib clip - detail for a rolled over ignition clip
		private var scrollSpeed:Number;
		private var lastVideo:MovieClip;
		private var detailLoader:Loader;
		
		
		private var lightsDimmer:Sprite;		
		
		private var originalThumbY:int;
		private var logoWidth:int = 112; 
		
		
		
		
		public function Main4()
		{
			TweenPlugin.activate([TintPlugin]);
			
			//black rect for behind the video
			lightsDimmer = new Sprite();
			lightsDimmer.graphics.beginFill(0x000000, 1);
			lightsDimmer.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			lightsDimmer.graphics.endFill();
			
			//flashvars		
			if (loaderInfo.parameters.language == "en") {
				language = "en";
			}			
			
			//stage management
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
					
			
			logoButton = new gmrLogo();
			
			//container for the ignition clips
			//added to display list in showIntroNavigation
			vidContainer = new Sprite();
			vidContainer.addChild(new engagementBG()); //background graphic
			
			upArrow = new arrow_up();
			upArrow.x = 329;//relative to bg
			upArrow.y = 479;
			vidContainer.addChild(upArrow);
			
			dnArrow = new arrow_dn();
			dnArrow.x = 349;//relative to bg
			dnArrow.y = 479;
			vidContainer.addChild(dnArrow);
			
			thumbs = new Sprite();
			vidContainer.addChild(thumbs);
			thumbs.x = 39; //relative to bg
			thumbs.y = 55;
			originalThumbY = 55;
			
			thumbMask = new engagementMask();			
			thumbMask.x = 35;
			thumbMask.y = 42;
			vidContainer.addChild(thumbMask);
			thumbs.mask = thumbMask;	
			
			detailLoader = new Loader();
			
			background = new bg();
			addChild(background); //library graphic - background gradient			
			
			practiceLoader = new Loader();
			
			vidConnection = new NetConnection();
			vidConnection.connect(null);
			vidStream = new NetStream(vidConnection);
			vidStream.bufferTime = 3;
			
			bigVidConnection = new NetConnection();
			bigVidConnection.connect(null);
			bigVidStream = new NetStream(bigVidConnection);
			
			vidStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			vidStream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			
			bigVidStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			bigVidStream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			
			bigVidStream.client = { onMetaData:bigMetaDataHandler, onCuePoint:cuePointHandler };			
			
			bigVideo = new Video();
			bigVideo.attachNetStream(bigVidStream);
			
			//used when the big video is playing
			closeButton = new closeBtn(); //lib clip
			bigVideoNavigation = new vidNav();
			
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, urlChange);			
			
			//library clips			
			iconMenu = new Sprite();
			
			navigation = new Sprite();			
			
			didResize(); //size bg to browser
			
			detail = new detailHolder();			
			ds = new DropShadowFilter(0, 0, 0x000000, .5, 4, 4, 1, 2);
			detail.filters = [ds];
			
		
			stage.addEventListener(Event.RESIZE, didResize);
			
			xmlLoader = new URLLoader();
			var req:URLRequest = new URLRequest(basePath + "intro.xml");
			xmlLoader.addEventListener(Event.COMPLETE, introXMLLoaded);
			xmlLoader.load(req);
		}
		
		
		
		private function introXMLLoaded(e:Event):void
		{
			trace("introXML loaded");
			xmlLoader.removeEventListener(Event.COMPLETE, introXMLLoaded);
			introXML = new XML(e.target.data);
			
			introHead = new introHeadline();
			introCopy = new introBody();
		
			buildMenu();
		}
		
		
		
		/**
		 * Builds the menu inside the navigation sprite - called from
		 * introXMLLoaded once the intro.xml file has been loaded
		 */
		private function buildMenu():void
		{	 
			trace("buildMenu");
			theNavWidth = 0;
			var xMenu:XMLList = introXML.menu.choices.choice;
			var theCat:int;
			var orig:String;
			for (var i:int = 0; i < xMenu.length(); i++) {
				var btn:navTxt = new navTxt();
				
				var iconBtn:MovieClip;
				var pt:Point = new Point();
				
				theCat = -1;
				orig = xMenu[i].@original;				
				switch(orig) {					
					case "Sports":						
						theCat = 0;
						iconBtn = new sports();
						pt.x = 0; pt.y = 6;//0
						break;
					case "Entertainment":						
						theCat = 1;
						iconBtn = new entertainment();
						pt.x = 47; pt.y = 0;//52
						break;
					case "Lifestyle":						
						theCat = 2;
						iconBtn = new lifestyle();
						pt.x = 110; pt.y = 5;//122
						break;
					case "Retail":						
						theCat = 3;
						iconBtn = new retail();
						pt.x = 198; pt.y = 1;//186
						break;
					case "Digital":						
						theCat = 4;
						iconBtn = new digital();
						pt.x = 255; pt.y = 4;//245
						break;
					case "Consulting":						
						theCat = 5;
						iconBtn = new consulting();
						pt.x = 318; pt.y = 8;//318
						break;
					case "Corporate":
						theCat = 6;
						iconBtn = new MovieClip();
						pt.x = -10; pt.y = -10;
						break;
				}
				
				btn.cat = theCat;
				iconBtn.cat = theCat;
				
				if (language == "ch") { btn.theText.embedFonts = false; }
				
				btn.theText.text = xMenu[i];
				iconBtn.theText.text = xMenu[i];
				iconBtn.theText.alpha = 0;
				
				if (btn.theText.textWidth > theNavWidth) {
					theNavWidth = btn.theText.textWidth;
				}
				btn.y = i * 20;			
				navigation.addChild(btn);
				
				iconBtn.x = pt.x;
				iconBtn.y = pt.y;
				iconBtn.alpha = 0;
				iconMenu.addChild(iconBtn);
				
			}
			//enableMenu();
			//showIntroNavigation();
		}
		
		
		
		/**
		 * Adds mouse listeners to the buttons inside the navigation clip
		 */
		private function enableMenu():void
		{
			var c:int = navigation.numChildren;
			var i:int;
			var btn:MovieClip;
			for (i = 0; i < c; i++) {
				btn = MovieClip(navigation.getChildAt(i));
				btn.buttonMode = true;
				btn.addEventListener(MouseEvent.CLICK, menuClick, false, 0, true);
				btn.addEventListener(MouseEvent.MOUSE_OVER, menuHilite, false, 0, true);
				btn.addEventListener(MouseEvent.MOUSE_OUT, menuUnHilite, false, 0, true);
			}
			c = iconMenu.numChildren;
			
			//icon menu
			for (i = 0; i < c; i++) {
				btn = MovieClip(iconMenu.getChildAt(i));
				btn.buttonMode = true;
				btn.addEventListener(MouseEvent.CLICK, menuClick, false, 0, true);
				btn.addEventListener(MouseEvent.CLICK, iconUnHilite, false, 0, true);
				btn.addEventListener(MouseEvent.MOUSE_OVER, iconHilite, false, 0, true);
				btn.addEventListener(MouseEvent.MOUSE_OUT, iconUnHilite, false, 0, true);
			}
		}
		
		
		
		/**
		 * rollovers for the menu buttons
		 * @param	e
		 */
		private function menuHilite(e:MouseEvent):void
		{			
			TweenLite.to(e.currentTarget, .25, { tint:0xe5aa28 } );
		}
		
		
		private function menuUnHilite(e:MouseEvent):void
		{
			if(e.currentTarget.cat != categoryClicked){
				TweenLite.to(e.currentTarget, .25, { tint:null } );
			}
		}
		
		
		//makes icon menu images bigger and shows text
		private function iconHilite(e:MouseEvent):void
		{			
			TweenLite.to(e.currentTarget, .25, { scaleX:1.2, scaleY:1.2 } );
			TweenLite.to(e.currentTarget.theText, .25, { alpha:1 } );
		}
		
		
		private function iconUnHilite(e:MouseEvent):void
		{
			//if(e.currentTarget.cat != categoryClicked){
				TweenLite.to(e.currentTarget, .25, { scaleX:1, scaleY:1 } );
				TweenLite.to(e.currentTarget.theText, .25, { alpha:0 } );
			//}
		}
		
		
		
		/**
		 * Called by listener attached to stage whenever the browser window size changes
		 * 
		 * Called initially, from constructor, to size the bg to the current browser size
		 * 
		 * @param	e RESIZE event
		 */
		private function didResize(e:Event = null):void
		{
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;			
			background.width = w;
			background.height = h;	
			
			lightsDimmer.width = w;
			lightsDimmer.height = h;			
			
			var remainder:int = stage.stageWidth - logoWidth;
			var contentWidth:int = 763; //text width + video container
			
			if(introHead){
				if(contains(introHead)){
					
					var left:int = Math.floor((remainder - contentWidth) * .5);
					introHead.x = logoWidth + left;
					introCopy.x = logoWidth + left;
					iconMenu.x = logoWidth + left - 15;
					vidContainer.x = 420 + logoWidth + left;
				}
			}
		}
		
		
		
		/**
		 * Called by SWFAddress listener whenever the browser URL changes 
		 * Called once when SWFAddress is instantiated
		 * 
		 * Calls menuClick() with the category number gotten from the categories array
		 * 
		 * @param	e SWFAddressEvent
		 */
		private function urlChange(e:SWFAddressEvent):void
		{		
			trace("url change");
			var address:String = SWFAddress.getValue().toLowerCase();
			
			var cat:String;
			if (address.substr(0, 1) == "/") {
				cat = address.substr(1);
			}else {
				cat = address;
			}		
		
			//category number 0 - 5
			//-1 if category not found
			var ind:Number = categories.indexOf(cat);
			
			menuClick(null, ind);		
		}
		
		
		
		private function getNavButton(category:int):*
		{
			var n:int = navigation.numChildren;
			for (var i:int = 0; i < n; i++) {
				if (MovieClip(navigation.getChildAt(i)).cat == category) {
					return MovieClip(navigation.getChildAt(i));
				}
			}
			return 0;
		}
		
		
		
		/**
		 * Called when a menu item is clicked on, or when SWFAddress calls urlChange()
		 * 
		 * @param	e MouseEvent - null if coming from urlChange (SWFAddress)
		 * @param	cat - index of the category in the categories array
		 */
		private function menuClick(e:MouseEvent = null, cat:int = -1)
		{		
			
			swfAddressMenuChange = e == null ? true : false;			
			
			//check to see if there's a current menu item hilited
			if (categoryClicked != -1) {
				//untint last button
				TweenLite.to(getNavButton(categoryClicked), .25, { tint:null } );				
			}
			
			//get category from swfAddress urlChange, or from cat property injected into button in buildMenu
			categoryClicked = e == null ? cat : e.currentTarget.cat;
			trace("menu click", categoryClicked);
			//tint current button yellow
			var mc:* = getNavButton(categoryClicked);
			if(mc != 0){
				TweenLite.to(mc, .25, { tint:0xE5AA28 } );
			}
			
			//set browser URL - DM Modified the setValue method of SWFAddress to accept
			//a second parameter - dispatch. If False SWFAddress will not dispatch a change event
			//this prevents the urlChange method from being called and in turn calling menuClick again
			//If we see issues with this then we'll have to break out a second menuClick function just
			//for swfaddress
			//trace("swfaddress.setValue - false");
			SWFAddress.setValue(categories[categoryClicked], false);			
			
			if (!swfAddressMenuChange) {
				//regular menu click happened
				
				
				if (categoryClicked == -1) {
					//no category - show intro
					//unDockNav();
					removeChild(practiceLoader);
					//showNavElements();
					//trace("neg 1");
				}else {
					//category found
					loadPractices();
				}
				
			}else {
				//came from SWFAddress - mouseEvent is null
				closeBig();
				if (cat == -1) {
					//show intro
					killTweens();					
					removeIntroElements();					
				}else {
					//swfAddress category
					trace("swfaddress category");
					killTweens();					
					removeIntroElements(); //called by loadPractices()									
					loadPractices();					
				}
			}
		}
		
		
		
		private function showNav():void
		{			
			if(!contains(navigation)){
				addChild(navigation);
			}
			navigation.alpha = 0;				
			navigation.x = 3;				
			navigation.y = 80;			
			
			TweenLite.to(navigation, 1, { y:145, alpha:1, delay:.75, onComplete:enableMenu } );
			
			if (!contains(logoButton)) {
				addChild(logoButton);
				logoButton.x = 0;
				logoButton.y = 18;
				logoButton.alpha = 1;
			}			
			
			logoButton.addEventListener(MouseEvent.CLICK, menuClick, false, 0, true);
			logoButton.cat = -1;
			logoButton.buttonMode = true;
		}
		
		
		private function removeNav():void
		{
			if (contains(navigation)) {
				removeChild(navigation);
			}
			if (contains(logoButton)) {
				//logoButton.removeEventListener(MouseEvent.CLICK, menuClick);
				removeChild(logoButton);
			}			
			
		}
		
		
		/**
		 * shows the nav and main elements
		 * called from buildMenu()
		 */
		private function showIntroElements():void
		{
			trace("show intro elements");			
			introHead.x = 180;
			introHead.y = 64;
			
			
			//use device fonts for chinese
			if (language == "ch") {
				introHead.theText.embedFonts = false;
				introCopy.theText.embedFonts = false;
			}
			introHead.theText.autoSize = TextFieldAutoSize.LEFT;
			introHead.theText.htmlText = introXML.title;
			addChild(introHead);			
			introHead.alpha = 1;
			introCopy.x = introHead.x;		
			introCopy.theText.autoSize = TextFieldAutoSize.LEFT;
			introCopy.theText.htmlText = introXML.body;
			introCopy.y = introHead.y + introHead.theText.textHeight + 15;
			
			addChild(introCopy);
			introCopy.alpha = 1;
			
			if(!contains(iconMenu)){
				addChild(iconMenu);
			}
			iconMenu.x = introHead.x - 15;
			iconMenu.y = introCopy.y + introCopy.theText.textHeight + 40;			
			
			var l:int = iconMenu.numChildren;
			for (var j:int = 0; j < l; j++) {
				TweenLite.to(iconMenu.getChildAt(j), .5, { alpha:1, delay:j * .25 } );
			}			
			
			//tween text in
			TweenLite.from(introHead, 3, { alpha:0, delay:1 } );
			TweenLite.from(introCopy, 3, { alpha:0, delay:1.5 } );
			
			
			//Ignition Channel			
			var numVids:int = introXML.videos.video.length();
			for (var i:int = 0; i < numVids; i++) {
				var thisVid:XML = introXML.videos.video[i];
				var vid:ignitionClip = new ignitionClip();
				
				//inject index so later on the index can be used to retrieve the xml record
				vid.videoIndex = i;
				
				vid.theCategory.text = thisVid.category;				
				vid.theTitle.text = thisVid.title;
				
				if(thisVid.playOnMainPage != ""){
					vid.link = "vid";
					vid.vid = thisVid.playOnMainPage;
				}else {
					vid.link = "file";
					vid.vid = thisVid.playAtLink;
				}
				
				vid.addEventListener(MouseEvent.MOUSE_OVER, showVidInfo, false, 0, true);				
				vid.buttonMode = true;
				
				thumbs.addChild(vid);				
				vid.y = 120 * i;
				
				var iLoader:Loader = new Loader();
				iLoader.load(new URLRequest(thisVid.image));
				vid.addChildAt(iLoader, 1);				
			}
			
			vidContainer.addChild(detail);
			detail.y = -2000;
			
			vidContainer.alpha = 0;
			addChild(vidContainer);
			vidContainer.x = 420 + introHead.x;
			vidContainer.y = 65;
			
			TweenLite.to(vidContainer, 3, { alpha:1, delay: 1.75 } );
			
			upArrow.buttonMode = true;
			dnArrow.buttonMode = true;
			upArrow.addEventListener(MouseEvent.CLICK, upClicked, false, 0, true);
			dnArrow.addEventListener(MouseEvent.CLICK, dnClicked, false, 0, true);					
		}
		
		
		/**
		 * Removes all elements except the navigation
		 */
		private function removeIntroElements():void
		{		
			
			if (contains(practiceLoader)) {				
				removeChild(practiceLoader);
			}
			if(introCopy != null){
				if (contains(introCopy)) {
					removeChild(introCopy);
					removeChild(introHead);				
				}
			}
			if (contains(vidContainer)) {
				removeChild(vidContainer);
			}
			if (contains(iconMenu)) {
				removeChild(iconMenu);
			}
		}
		
		
		private function killTweens():void
		{
			vidStream.close();
			
			TweenLite.killTweensOf(bigVideo);
			TweenLite.killTweensOf(navigation);
			TweenLite.killTweensOf(practiceLoader);			
			TweenLite.killTweensOf(introHead);
			TweenLite.killTweensOf(introCopy);
			
			if (contains(bigVideo)) { removeChild(bigVideo); }
			if (contains(closeButton)) { removeChild(closeButton); }
		}
		
		
		private function upClicked(e:MouseEvent):void
		{
			if (thumbs.y + 240 < originalThumbY) {
				TweenLite.to(thumbs, 1.5, { y:thumbs.y + 240 } );
			}else {
				TweenLite.to(thumbs, 1.5, { y:originalThumbY} );
			}
		}
		
		
		private function dnClicked(e:MouseEvent):void
		{
			//each vid button is 120 pixels tall
			var maskBottom:Number =  thumbMask.y + thumbMask.height;
			var thumbsBottom:Number = thumbs.y + thumbs.height;
			if (thumbsBottom >= maskBottom + 240) {
				TweenLite.to(thumbs, 1.5, { y:thumbs.y - 240 } );				
			}else {
				var diffY:Number = thumbsBottom - maskBottom;
				TweenLite.to(thumbs, 1, { y:thumbs.y - diffY } );
			}
		}
		
		
		
		
		/**
		 * Called from rolling over one of the video thumbnails in the vidContainer
		 * @param			 
		 */
		private function showVidInfo(e:MouseEvent):void
		{
			if (lastVideo != null) {
				lastVideo.addEventListener(MouseEvent.MOUSE_OVER, showVidInfo);
			}
			lastVideo = MovieClip(e.currentTarget);
			var pt:Point = thumbs.localToGlobal(new Point(lastVideo.x, lastVideo.y));
			
			detail.x = 205;
			
			var dy:int = pt.y - 30;
			if (dy < 30) { dy = 30;}
			
			detail.y = dy;
			
			detail.alpha = 0;
			detail.scaleX = .6;
			detail.scaleY = .4;
			
			TweenLite.to(detail, .5, { scaleX:1, scaleY:1, alpha:1, onComplete:checkMouseDetail } );			
		
			lastVideo.removeEventListener(MouseEvent.MOUSE_OVER, showVidInfo);
			detail.addEventListener(MouseEvent.ROLL_OUT, hideVidInfo, false, 0, true);
			detail.btnWatch.addEventListener(MouseEvent.CLICK, playVid, false, 0, true);
			detail.btnWatch.buttonMode = true;
			
			var thisVid:XML = introXML.videos.video[lastVideo.videoIndex];
			detail.theCategory.text = thisVid.category;
			detail.theTitle.text = thisVid.title;
			detail.theDescription.text = thisVid.description;
			
			detailLoader.unload();
			detailLoader.load(new URLRequest(thisVid.image));
			if (!detail.contains(detailLoader)) {
				detail.addChild(detailLoader);
				detailLoader.x = -175;
				detailLoader.y = -86;
			}			
		}
		
		/**
		 * Called by TweenLite.onComplete once the detail clip is expanded
		 * Hides the detail if the mouse is outside of it
		 */
		private function checkMouseDetail():void
		{
			var dl:int = (vidContainer.x + (detail.x - (detail.width * .5))); //detail left
			var dt:int = (vidContainer.y + (detail.y - (detail.height * .5))); //detail top
			var dr:int = (vidContainer.x + (detail.x + (detail.width * .5))); //detail right
			var db:int = (vidContainer.y + (detail.y + (detail.height * .5))); //detail bottom
			
			if (mouseX < dl || mouseX > dr || mouseY < dt || mouseY > db) {
				hideVidInfo();
			}
		}
		
	
		
		
		private function hideVidInfo(e:MouseEvent = null):void
		{			
			detail.removeEventListener(MouseEvent.ROLL_OUT, hideVidInfo);
			detail.btnWatch.removeEventListener(MouseEvent.CLICK, playVid);
			lastVideo.addEventListener(MouseEvent.MOUSE_OVER, showVidInfo);
			lastVideo = null;
			TweenLite.to(detail, .5, { alpha:0, onComplete:removeDetail } );			
		}
		
		
		private function removeDetail():void
		{
			
			detail.y = -2000;	
		}
		
		
		private function playVid(e:MouseEvent):void
		{
			if(lastVideo.link == "vid"){
				selectedVideo = lastVideo.vid;
				startMainVideo();
			}else {
				navigateToURL(new URLRequest(lastVideo.vid), "_self");
			}
		}
		
		
		
		/**
		 * Called by clicking the contact button in the main intro text
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function contactClicked(e:MouseEvent):void
		{
			navigateToURL(new URLRequest("http://www.gmrmarketing.com/Contact"), "_self");
		}
		
		
		
		

		
		private function loadPractices():void
		{		
			trace("load preactices");
			practiceLoader.load(new URLRequest("../gmr_practices.swf"));
			practiceLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, practicesLoaded, false, 0, true);
		}
		
		
		private function practicesLoaded(e:Event):void
		{
			if (!contains(practiceLoader)) {				
				addChildAt(practiceLoader, 1); //add behind the logo
			}
			practiceLoader.alpha = 1;
			MovieClip(practiceLoader.content).initPractice(categoryClicked, theNavWidth );
		}
		
		
		
		
		
		
		
		//====================      VIDEO METHODS     ========================//
	
		
		/**
		 * Removes the big video - called from closeBigVideo() and swfAddressNav()
		 */
		private function closeBig():void
		{
			bigVidStream.seek(0);
			bigVidStream.pause();
			if(contains(bigVideo)){
				removeChild(bigVideo);
			}
			if(contains(closeButton)){
				removeChild(closeButton);
			}
			if(contains(bigVideoNavigation)){
				removeChild(bigVideoNavigation);
			}
			if (contains(lightsDimmer)) {
				removeChild(lightsDimmer);
			}
			closeButton.removeEventListener(MouseEvent.CLICK, closeBigVideo);
			bigVideoNavigation.btnPause.removeEventListener(MouseEvent.CLICK, pauseBigVideo);
			bigVideoNavigation.btnPlay.removeEventListener(MouseEvent.CLICK, resumeBigVideo);
			bigVideoNavigation.btnStop.removeEventListener(MouseEvent.CLICK, stopBigVideo);
			
			showNavElements();
		}
		
		
		/**
		 * Called from video close button
		 * @param	e
		 */
		private function closeBigVideo(e:MouseEvent):void
		{
			closeBig();			
		}
		
		
		/**
		 * Called by clicking the Watch Video button on the open cube
		 * 
		 * @param	e
		 */
		private function startMainVideo(e:MouseEvent = null):void
		{			
			TweenLite.to(navigation, .5, { alpha:0 } );
			TweenLite.to(logoButton, .5, { alpha:0 } );
			TweenLite.to(iconMenu, .5, { alpha:0 } );
			TweenLite.to(introCopy, .5, { alpha:0 } );
			TweenLite.to(vidContainer, .5, { alpha:0 } );
			TweenLite.to(introHead, .5, { alpha:0, onComplete:playEngagementVid } );
		}
		
		
		/**
		 * Called from closeBig()
		 */
		private function showNavElements():void
		{
			trace("show nav elements");
			if (!contains(logoButton)) {
				addChild(logoButton);
			}
			if (!contains(navigation)) {
				addChild(navigation);
			}
			if (!contains(iconMenu)) {
				addChild(iconMenu);
			}
			if(introCopy){
				if (!contains(introCopy)) {
					addChild(introCopy);
				}
				introCopy.alpha = 0;
			}
			if (!contains(vidContainer)) {
				addChild(vidContainer);
			}
			if(introHead){
				if (!contains(introHead)) {
					addChild(introHead);
				}
				introHead.alpha = 0;
			}
			navigation.alpha = 0;
			iconMenu.alpha = 0;			
			
			vidContainer.alpha = 0;
			TweenLite.to(logoButton, .5, { alpha:1 } );
			TweenLite.to(navigation, .5, { alpha:1 } );
			TweenLite.to(iconMenu, .5, { alpha:1 } );
			TweenLite.to(introCopy, .5, { alpha:1 } );
			TweenLite.to(vidContainer, .5, { alpha:1 } );
			TweenLite.to(introHead, .5, { alpha:1 } );
		}
		
		
		
		/**
		 * Called from startMainVideo()
		 */
		private function playEngagementVid()
		{
			removeNav();
			removeIntroElements();
			
			//alpha is tweened to 1 in bigMetaDataHandler() once the video is loaded and positioned
			bigVideo.alpha = 0;
			addChild(bigVideo);			
						
			bigVidStream.play(selectedVideo);	
		}
		
		
		private function pauseBigVideo(e:MouseEvent):void
		{
			bigVidStream.pause();
		}
		
		private function resumeBigVideo(e:MouseEvent):void
		{
			bigVidStream.resume();
		}
		
		private function stopBigVideo(e:MouseEvent):void
		{
			bigVidStream.seek(0);
			bigVidStream.pause();
		}
		
		
		private function asyncErrorHandler(e:AsyncErrorEvent):void 	{ trace("asynch:",e); }
		
		
		
		/**
		 * Net status handler for video
		
		 * 
		 * @param	e
		 */
		private function statusHandler(e:NetStatusEvent):void 
		{ 
		}		
		
		
		
		
		
		
		
		/**
		 * meta data handler for the video
		 * 
		 * @param	infoObject
		 */
		private function bigMetaDataHandler(infoObject:Object):void 
		{			
			bigVideo.width = infoObject.width;
			bigVideo.height = infoObject.height;			
			bigVideo.x = (stage.stageWidth - infoObject.width) * .5;
			bigVideo.y = Math.max(50, (stage.stageHeight - infoObject.height) * .5);
			
			if (!contains(lightsDimmer)) { addChildAt(lightsDimmer,1); }
			lightsDimmer.alpha = 0;			
			
			TweenLite.to(bigVideo, .25, { alpha:1 } );
			TweenLite.to(lightsDimmer, 2, {alpha:.8 } );
			
			if (!contains(closeButton)) { addChild(closeButton); }
			closeButton.x = bigVideo.x + bigVideo.width - 10;
			closeButton.y = bigVideo.y - 8;
			closeButton.addEventListener(MouseEvent.CLICK, closeBigVideo, false, 0, true);
			closeButton.buttonMode = true;
			
			//nav
			if (!contains(bigVideoNavigation)) { addChild(bigVideoNavigation); }			
			bigVideoNavigation.x = bigVideo.x + 10;
			bigVideoNavigation.y = bigVideo.y + bigVideo.height - 10;
			bigVideoNavigation.btnPause.addEventListener(MouseEvent.CLICK, pauseBigVideo, false, 0, true);
			bigVideoNavigation.btnPlay.addEventListener(MouseEvent.CLICK, resumeBigVideo, false, 0, true);
			bigVideoNavigation.btnStop.addEventListener(MouseEvent.CLICK, stopBigVideo, false, 0, true);
			
			bigVideoNavigation.btnPause.buttonMode = true;
			bigVideoNavigation.btnPlay.buttonMode = true;
			bigVideoNavigation.btnStop.buttonMode = true;
		}
		
		
		
		/**
		 * Cue point handler for both the cube and the big yellow video
		 * 
		 * @param	infoObject
		 */
		private function cuePointHandler(infoObject:Object):void 
		{
			var cueName = infoObject.name;			
		}
	}
}
