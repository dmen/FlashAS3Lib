/**
 * NEW VERSION - 2/19/10 - FOR NEW CUBE VIDEOS
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
	import flash.display.LoaderInfo; //for flashvars
	
	import flash.display.Loader;	
	import flash.display.Sprite;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import gs.TweenLite;
	import gs.plugins.*;
	import gs.easing.*;
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
	
	import com.gmrmarketing.utilities.Tracer;
	
	
	public class Main2 extends MovieClip
	{		
		private const VID_FOLDER:String = "assets/video_cube_transitions/";
		
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;
		private var logoVideo:Video;
		
		private var practiceLoader:Loader;
		private var categoryClicked:int = -1;
		
		//category strings for swfAddress - indexes match category numbers assigned in enableMenu()
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
		private var playVid:playGlow;
		private var introHead:introHeadline;
		private var introCopy:introBody;
		private var closeButton:closeBtn;		
		private var background:bg;
		private var bigVideoNavigation:vidNav;
		
		private var navigation:Sprite; //contains instances of navTxt
		private var theNavWidth:Number = 0;
		
		//set in playCube - 1 - 5 gor gmr1.flv - gmr6.flv
		private var currentVidNumber:int = 0;
		
		private var isNavDocked:Boolean = false;		
		private var logoButton:gmrLogo;
		
		private var swfAddressMenuChange:Boolean = false;
		
		private var language:String = "";
		private var basePath:String = "";
		
		private var xmlLoader:URLLoader;
		private var introXML:XML;
		
		private var tracer:Tracer;
		
		
		public function Main2()
		{
			//flashvars		
			if (loaderInfo.parameters.language == "en") {
				language = "en";
			}
			
			
			
			//stage management
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			stage.addEventListener(Event.RESIZE, didResize);		
			
			logoButton = new gmrLogo();
			
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
			
			vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };
			bigVidStream.client = { onMetaData:bigMetaDataHandler, onCuePoint:cuePointHandler };
			
			logoVideo = new Video();			
			bigVideo = new Video();
			
            logoVideo.attachNetStream(vidStream);
			bigVideo.attachNetStream(bigVidStream);
            
			
			
			//used when the big video is playing
			closeButton = new closeBtn(); //lib clip
			bigVideoNavigation = new vidNav();
			
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, urlChange);			
			
			//library clips
			playVid = new playGlow();
			introHead = new introHeadline();
			introCopy = new introBody();
			
			navigation = new Sprite();			
			
			didResize(); //size bg to browser
			
			xmlLoader = new URLLoader();
			var req:URLRequest = new URLRequest(basePath + "intro.xml");			
			xmlLoader.addEventListener(Event.COMPLETE, introXMLLoaded);
			xmlLoader.load(req);
			
			tracer = new Tracer(this);
		}
		
		
		private function introXMLLoaded(e:Event):void
		{
			xmlLoader.removeEventListener(Event.COMPLETE, introXMLLoaded);
			introXML = new XML(e.target.data);			
			buildMenu();
		}
		
		
		/**
		 * Builds the menu inside the navigation sprite - called from
		 * introXMLLoaded once the intro.xml file has been loaded
		 */
		private function buildMenu():void
		{	 
			theNavWidth = 0;
			var xMenu:XMLList = introXML.menu.choices.choice;
			var theCat:int;
			var orig:String;
			for (var i:int = 0; i < xMenu.length(); i++) {
				var btn:navTxt = new navTxt();
				theCat = -1;
				orig = xMenu[i].@original;				
				switch(orig) {					
					case "Sports":						
						theCat = 0;
						break;
					case "Entertainment":						
						theCat = 1;
						break;
					case "Lifestyle":						
						theCat = 2;
						break;
					case "Retail":						
						theCat = 3;
						break;
					case "Digital":						
						theCat = 4;
						break;
					case "Consulting":						
						theCat = 5;
						break;
					case "Corporate":
						theCat = 6;
						break;
				}
				btn.cat = theCat;				
				if (language == "ch") { btn.theText.embedFonts = false; }
				btn.theText.text = xMenu[i];
				if (btn.theText.textWidth > theNavWidth) {
					theNavWidth = btn.theText.textWidth;
				}
				btn.y = i * 20;			
				navigation.addChild(btn);
				
			}
			enableMenu();
		}
		
		
		
		/**
		 * Adds mouse listeners to the buttons inside the navigation clip
		 */
		private function enableMenu():void
		{
			var c:int = navigation.numChildren;
			for (var i:int = 0; i < c; i++) {
				var btn:MovieClip = MovieClip(navigation.getChildAt(i));
				btn.buttonMode = true;
				btn.addEventListener(MouseEvent.CLICK, menuClick, false, 0, true);
				btn.addEventListener(MouseEvent.MOUSE_OVER, menuHilite, false, 0, true);
				btn.addEventListener(MouseEvent.MOUSE_OUT, menuUnHilite, false, 0, true);
			}			
		}
		
		
		
		/**
		 * Called from startPractices()
		 * disables the navigation object
		 */
		private function disableMenu():void 
		{
			var c:int = navigation.numChildren;
			var m:MovieClip;
			for (var i = 0; i < c; i++) {
				m = MovieClip(navigation.getChildAt(i));
				m.buttonMode = false;
				m.removeEventListener(MouseEvent.CLICK, menuClick);
			}			
		}
		
		
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
				if(!isNavDocked){
					startPractices();
				}else {
					//nav already docked - load new practices or show intro
					if (categoryClicked == -1) {
						//no category - show intro
						unDockNav();
					}else {
						//category found
						loadPractices();
					}
				}
			}else {
				//came from SWFAddress
				closeBig();
				if (cat == -1) {
					//show intro
					killTweens();
					removeNav();
					removeIntroElements();
					playCube(1);
				}else {
					//swfAddress category - dock menu and load the practice
					killTweens();
					removeNav();
					removeIntroElements();
					dockNav();				
					loadPractices();
				}
			}
		}
		
		
		
		/**
		 * Places logo and navigation at upper left
		 */
		private function dockNav():void
		{
			if (contains(logoVideo)) {				
				removeChild(logoVideo);				
			}
			logoVideo.alpha = .5;
			
			//setup to play video 5
			//vidStream.close();
			//vidStream.play(VID_FOLDER + "gmr5.flv");		
			//vidStream.seek(1);
			//vidStream.pause();
			
			//setup to match 4
			//logoVideo.width = 448; logoVideo.height = 454; logoVideo.x = -167; logoVideo.y = -150;
			
			
			if(!isNavDocked){
				isNavDocked = true;
				
				enableMenu();
				
				if (!contains(navigation)) {
					addChild(navigation);
				}
				
				navigation.alpha = 0;				
				navigation.x = 3;				
				navigation.y = 80;
				navigation.scaleX = navigation.scaleY = 1;
				
				TweenLite.to(navigation, 1, { y:145, alpha:1, delay:.75} );
				
				if (!contains(logoButton)) {
					addChild(logoButton);
					logoButton.x = 0;
					logoButton.y = 18;
					logoButton.alpha = 1;
				}
				
				//TweenLite.to(logoButton, .5, { alpha:1 } );
				logoButton.addEventListener(MouseEvent.CLICK, menuClick, false, 0, true);
				logoButton.cat = -1;
				logoButton.buttonMode = true;
			}
		}
		
		
		/**
		 * Called from menuClick when the GMR logo is clicked - ie cat = -1
		 * Animates the menu docking and then plays cube 5
		 */
		private function unDockNav():void
		{
			isNavDocked = false;
			disableMenu();
			if (contains(practiceLoader)) {
				TweenLite.to(practiceLoader, .5, { alpha:0, onComplete:removeIntroElements } );
			}
			//logoButton.alpha = 0;
			TweenLite.to(navigation, .5, { y:50, alpha:0, onComplete:removeUndockedNav } );
		}
		
		private function removeUndockedNav()
		{
			removeNav();
			playCube(5);
			TweenLite.to(logoVideo, 3, { x:0, y:0, width:624, height:624, onComplete:showIntroNavigation } );		
		}
		
		/**
		 * Called from menuClick() when SWFAddress is used to show the intro
		 * ie - mouse event is null, and category is -1
		 */
		private function removeNav():void
		{
			if (contains(navigation)) {
				removeChild(navigation);
			}
			if (contains(logoButton)) {
				logoButton.removeEventListener(MouseEvent.CLICK, menuClick);
				removeChild(logoButton);
			}			
			isNavDocked = false;
		}
		
		
		/**
		 * Removes intro text and play video button
		 */
		private function removeIntroElements():void
		{		
			
			if (contains(practiceLoader)) {				
				removeChild(practiceLoader);				
			}
			if (contains(introCopy)) {
				removeChild(introCopy);
				removeChild(introHead);				
			}
			//play video button
			if (contains(playVid)) {
				removeChild(playVid);
			}	
		}
		
		private function killTweens():void
		{
			TweenLite.killTweensOf(logoVideo);
			TweenLite.killTweensOf(bigVideo);
			TweenLite.killTweensOf(navigation);
			TweenLite.killTweensOf(practiceLoader);
			TweenLite.killTweensOf(playVid);
			TweenLite.killTweensOf(introHead);
			TweenLite.killTweensOf(introCopy);
			if (contains(bigVideo)) { removeChild(bigVideo); }
			if (contains(closeButton)) { removeChild(closeButton); }
		}
		
		/**
		 * Slides the cube video to the left and then calls showIntroNavigation
		 * to bring in the menu above it
		 * Called from statusHandler
		 */
		private function moveVideoLeft():void
		{
			TweenLite.to(logoVideo, .75, { x:0, onComplete:showIntroNavigation } );
		}
		
		
		/**
		 * Shows the navigation menu above the video cube
		 * Called from moveVideoLeft() and undockNav()
		 */
		private function showIntroNavigation():void
		{
			isNavDocked = false;
			
			if(!contains(navigation)){
				addChild(navigation);
			}
			
			introHead.x = 450;
			introHead.y = 100;
			
			navigation.x = logoVideo.x + 224;
			navigation.y = introHead.y + 10;
			navigation.scaleX = navigation.scaleY = 1.5;
			navigation.alpha = 1;
			enableMenu();
			
			//play video button that goes in the cube - English only
			if(language == "en"){
				addChildAt(playVid, 3);
				playVid.x = (logoVideo.x + logoVideo.width / 2) - 10;
				playVid.y = logoVideo.y + 360;
				playVid.scaleX = playVid.scaleY = .8;
				playVid.addEventListener(MouseEvent.CLICK, startMainVideo, false, 0, true);			
				playVid.buttonMode = true;			
				playVid.alpha = 1;
			}		
			
			//use device fonts for chinese
			if (language == "ch") {
				introHead.theText.embedFonts = false;
				introCopy.theText.embedFonts = false;
			}
			introHead.theText.autoSize = TextFieldAutoSize.LEFT;
			introHead.theText.htmlText = introXML.title;
			addChild(introHead);			
			introHead.alpha = 1;
			introCopy.x = 450;		
			introCopy.autoSize = TextFieldAutoSize.LEFT;
			introCopy.theText.htmlText = introXML.body;
			introCopy.y = introHead.y + introHead.theText.textHeight + 15;
			
			addChild(introCopy);
			introCopy.alpha = 1;
		
			TweenLite.from(navigation, 1.5, { alpha:0, y:navigation.y + 130 } );
			if(contains(playVid)){
				TweenLite.from(playVid, 1.5, { alpha:0, delay:1 } );
			}
			TweenLite.from(introHead, 3, { alpha:0, delay:1 } );
			TweenLite.from(introCopy, 3, { alpha:0, delay:1.5 } );
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
		
		
		/**
		 * Called from menuClick when the nav is not docked and a regular menu click is received
		 * ie when the introNavigation is showing
		 */
		private function startPractices():void
		{			
			disableMenu();
			TweenLite.to(introCopy, .75, { alpha:0 } );			
			TweenLite.to(introHead, .75, { alpha:0, onComplete:moveNavLeft } );
			TweenLite.to(navigation, .75, { alpha:0, y:navigation.y + 130 } );
			if(contains(playVid)){
				TweenLite.to(playVid, .75, { alpha:0 } );
				playVid.removeEventListener(MouseEvent.CLICK, startMainVideo);
				playVid.buttonMode = false;
			}
			playCube(4);
		}
		
		
		/**
		 * Called from startPractices()
		 * moves the logo cube to upper left menu position and then calls loadPractices when complete
		 */
		private function moveNavLeft()
		{			
			logoVideo.smoothing = true;			
			TweenLite.to(logoVideo, 2.6, { width:448, height:454, x:-168, y:-150, ease:Cubic.easeIn, onComplete:loadPractices} );
		}
		
		
		private function loadPractices():void
		{	
			removeIntroElements();		
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
		 * Plays a GMR cube video
		 * 
		 * @param	whichVid integer cube number 1-5
		 * @param 	Number of seconds in to start at
		 */
		private function playCube(whichVid:int, start:Number = 0):void
		{		
			tracer.doTrace("play cube: " + whichVid);
			
			if (!contains(logoVideo)) {
				addChild(logoVideo);				
			}
			if (whichVid != 1){
				logoVideo.alpha = 1;
			}else {
				logoVideo.alpha = 0;
				TweenLite.to(logoVideo, 0, { alpha:1, delay:.3 } );
			}
			currentVidNumber = whichVid;
			vidStream.play(VID_FOLDER + "gmr" + String(currentVidNumber) + ".flv");	
			if(start != 0){
				vidStream.seek(start);
			}
		}
		
		
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
			closeButton.removeEventListener(MouseEvent.CLICK, closeBigVideo);
			bigVideoNavigation.btnPause.removeEventListener(MouseEvent.CLICK, pauseBigVideo);
			bigVideoNavigation.btnPlay.removeEventListener(MouseEvent.CLICK, resumeBigVideo);
			bigVideoNavigation.btnStop.removeEventListener(MouseEvent.CLICK, stopBigVideo);
		}
		
		
		private function closeBigVideo(e:MouseEvent):void
		{
			closeBig();
			playCube(3);
		}
		
		
		/**
		 * Called by clicking the Watch Video button on the open cube
		 * 
		 * @param	e
		 */
		private function startMainVideo(e:MouseEvent = null):void
		{
			TweenLite.to(introCopy, .5, { alpha:0} );
			TweenLite.to(introHead, .5, { alpha:0, delay:.25, onComplete:playMainVideo } );
			
			TweenLite.to(navigation, .5, { alpha:0, y:navigation.y + 100 } );
			if (contains(playVid)) {
				TweenLite.to(playVid, .5, { alpha:0} );
			}			
		}
		
		
		/**
		 * Called from startMainVideo once the screen has been cleared
		 * Relies on cuePointNav to call playEngagementVid() when logo video is close to the end
		 */
		private function playMainVideo()
		{
			removeNav();
			removeIntroElements();			
			playCube(2);			
			//move video to center
			TweenLite.to(logoVideo, 4, { x:(stage.stageWidth - logoVideo.width) / 2,  ease:Cubic.easeIn } );			
		}
		
		
		/**
		 * called from cuePointHandler when video #2 is nearly complete
		 * vid 2 is the cube coming from center screen to big
		 */
		private function playEngagementVid()
		{
			addChild(bigVideo);
			TweenLite.to(logoVideo, .5, { alpha:0 } );
			TweenLite.from(bigVideo, .5, { alpha:0 } );
			currentVidNumber = 6;
			
			//big yellow intro video
			bigVidStream.play(VID_FOLDER + "GMREngagementVideo.flv");	
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
		 * Net status handler for big yellow and logo cube video
		 * Moves the video left at the end of cube 1 and 3 videos
		 * 
		 * @param	e
		 */
		private function statusHandler(e:NetStatusEvent):void 
		{ 			
			//trace("status", e.info.code);
			if(currentVidNumber == 1 || currentVidNumber == 3){
				if (e.info.code == "NetStream.Play.Stop") {					
					moveVideoLeft();
				}
			}
			if (currentVidNumber == 2) {
				if (e.info.code == "NetStream.Play.Stop") {
					//playEngagementVid();
				}
			}			
			//cube moves to upper left logo position
			if (currentVidNumber == 4) {
				if (e.info.code == "NetStream.Play.Stop") {	
					//dockNav() is now called in the cuePointHandler() when vid 4 is close to the end, instead
					//of all the way at the end.					
					//dockNav();
				}
			}
		}		
		
		
		
		/**
		 * meta data handler for the cube
		 * 
		 * @param	infoObject
		 */
		private function metaDataHandler(infoObject:Object):void 
		{			
			//logoVideo.alpha = 1;
			if(currentVidNumber != 5){
				logoVideo.width = infoObject.width;
				logoVideo.height = infoObject.height;
			}				
			
			if (currentVidNumber == 1 || currentVidNumber == 3) {				
				//center horizontally
				logoVideo.x = (stage.stageWidth - infoObject.width) * .5;
				logoVideo.y = 14;// (stage.stageHeight - infoObject.height) * .5;
				//trace((stage.stageHeight - infoObject.height) * .5);
			}			
		}
		
		
		/**
		 * meta data handler for the big yellow video
		 * 
		 * @param	infoObject
		 */
		private function bigMetaDataHandler(infoObject:Object):void 
		{			
			bigVideo.width = infoObject.width;
			bigVideo.height = infoObject.height;			
			bigVideo.x = (stage.stageWidth - infoObject.width) * .5;
			bigVideo.y = 50;// (stage.stageHeight - infoObject.height) * .5;
			
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
		}
		
		
		
		/**
		 * Cue point handler for both the cube and the big yellow video
		 * 
		 * @param	infoObject
		 */
		private function cuePointHandler(infoObject:Object):void 
		{
			var cueName = infoObject.name;		
			
			//happens near end of vid 4
			if (cueName == "cuenav" && currentVidNumber == 4) {				
				dockNav();
			}
			
			//received from video 2 near end
			if (cueName == "cuevideo") {
				playEngagementVid();
			}
		}
	}
}
