package com.gmrmarketing.banshee
{
	import flash.display.LoaderInfo; //for flashvars
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundMixer;
	import flash.media.ID3Info;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.display.Loader;
	import flash.text.TextFormat;
	import com.greensock.TweenLite;
	import flash.ui.Mouse;
	import flash.net.navigateToURL;
	import flash.filters.DropShadowFilter;
	import flash.utils.ByteArray;
	import flash.system.Security;
	import flash.errors.EOFError;
	import flash.utils.Timer;
	 import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.SecurityErrorEvent;
	
	
	
	public class Player extends MovieClip
	{
		private var xmlLoader:URLLoader;
		private var bgImage:Loader;
		private var colorBackgroundAdded:Boolean = false;
		private var track:Sound;
		private var allData:XML;
		private var trackList:XMLList;
		private var channel:SoundChannel;
		private var theContext:SoundLoaderContext;
		
		private var loadBar:Sprite;
		private var playBar:Sprite;
		
		private var currentTrackTitle:currentTrackText; //lib clip
		private var currentTrackIndex:int; //index in the trackList of the currently playing song
		
		private var trackButtonTexFormat:TextFormat = new TextFormat();
		private var currentTrackTexFormat:TextFormat = new TextFormat();
		private var buyTexFormat:TextFormat = new TextFormat();
		
		private var stopButton:Sprite;
		private var playButton:Sprite;
		private var pauseButton:Sprite;
		private var prevButton:Sprite;
		private var nextButton:Sprite;		
		private var buyButton:Sprite; //uses buyText clip in the library
		private var buyClose:Sprite; //close button for the buyPopup
		
		private var pausePosition:Number = 0;
		private var isPaused:Boolean;
		
		private var iconList:Array;
		private var curLink:Array; //temp array used to store icon and url as each icon is loaded
		private var totalIconWidth:int;
		private var maxIconHeight:int;
		private var buyPopup:Sprite;
		private var buyPopupShowing:Boolean = false;
		
		private var dropShadow:DropShadowFilter; //drop shadow for the buy icons
		
		private var bytes:ByteArray = new ByteArray(); //for sound viz
		private var visHolder:Sprite;		
		private var visFFT:Boolean = true;
		private var heightMultiplier:Number;
		private var vizTimer:Timer;
		
		private var myURL:String;
		private var myFolder:String;
		private var loadFrom:String;
		
		private var trackFullyLoaded:Boolean = false; //true in trackLoaded - used by monitorPlayback
		
		private var s3URL:String = "rtmpe://s1apoylgks09wv.cloudfront.net/cfx/st";
		private var s3Bucket:String;
		private var cl:Object; //netconnection client
		private var nc:NetConnection;
		private var ns:NetStream;
		private var currentTrackBytes:int; //set in playTrack - retrieved from the XML
		
		
			
		public function Player()
		{
			currentTrackIndex = -1;
			
			myURL = loaderInfo.parameters.url;
			if (myURL == null) { myURL = ""; }
			loadFrom = myURL;
			
			theContext = new SoundLoaderContext(3000); //set buffer to three seconds
			
			dropShadow = new DropShadowFilter(0, 0, 0, 1, 4, 4, 1, 2);
			
			channel = new SoundChannel();
			track = new Sound();
			
			currentTrackTitle = new currentTrackText(); //title in the loader/progress bar
			
			cl = new Object();
			cl.onBWDone = onBWDone;
			cl.onPlayStatus = onPlayStatus;
			cl.onMetaData = onMetaData;
						
			
			nc = new NetConnection();
			nc.client = cl;
			
			nc.addEventListener(NetStatusEvent.NET_STATUS, status, false, 0, true);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			nc.connect("rtmpe://s1apoylgks09wv.cloudfront.net/cfx/st");
			
			xmlLoader = new URLLoader();
			xmlLoader.load(new URLRequest(loadFrom + "playerdata.xml"));
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);			
		}
		
		
		private function status(e:NetStatusEvent):void
		{			
			if (e.info.code == "NetConnection.Connect.Success") {
				connectStream();
			}else {
				trace(e.info.code);			 
			}
		}
		
		
		private function connectStream():void
		{
			ns = new NetStream(nc);
			ns.client = cl;
			ns.addEventListener(NetStatusEvent.NET_STATUS, status, false, 0, true);
		}
		
		private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			trace("Security Error", e);
		}
		
		public function onMetaData(info:Object):void
		{
			trace("onMetaData:", info.duration, info.framerate);
		}
		
		public function onBWDone():void
		{
			trace("bwd");			
		}
		
		
		public function onPlayStatus(info:Object):void
		{
			trace("onPlayStatus:", info.code);
			if (info.code == "NetStream.Play.Complete") {				
				playNextTrack();
			}
		}
		
		
		
		
		
		/**
		 * Called when playerdata.xml is done loading
		 * @param	e
		 */
		private function xmlLoaded(e:Event):void
		{			
			xmlLoader.removeEventListener(Event.COMPLETE, xmlLoaded);
			//xmlLoader.removeEventListener(ProgressEvent.PROGRESS, xmlProgress);
			
			allData = new XML(e.target.data);			
			trackList = allData.tracks.track;
			
			s3Bucket = allData.bucket;			
			
			buildTrackButtons();
			buildBars();
			buildControlButtons();
			buildBuyPopup();
			
			//add background colored rect if background is defined in the colors section of the XML
			if (allData.colors.background != "") {
				colorBackgroundAdded = true;
				var back:Sprite = new Sprite();
				back.graphics.beginFill(Number("0x" + allData.colors.background));
				back.graphics.drawRect(0, 0, 300, 396);
				back.graphics.endFill();
				addChildAt(back, 0);
			}
			
			var bg:String = allData.backgroundImage;			
			if (bg != "") {
				bgImage = new Loader();
				bgImage.load(new URLRequest(loadFrom + bg));
				bgImage.contentLoaderInfo.addEventListener(Event.COMPLETE, backgroundLoaded, false, 0, true);
			}
			
			//kick off the player if autoPlay is on
			if(allData.autoPlay == "yes"){
				playTrack(0);
			}
			
			if (allData.visualizer.show == "yes") {
				
				visHolder = new Sprite();
				addChild(visHolder);
				visHolder.mouseEnabled = false;
				visHolder.x = 0;
				visHolder.y = 340 + Number(allData.visualizer.yAdjust);			
				if (allData.visualizer.useFFT == "no") { visFFT = false; }
				heightMultiplier = Number(allData.visualizer.theHeight);
			
				vizTimer = new Timer(40);
				vizTimer.addEventListener(TimerEvent.TIMER, displayVisualizer);
				vizTimer.start();
			}
			
			addChild(currentTrackTitle);
			currentTrackTexFormat.color = Number("0x" + allData.colors.currentTrackTitle);
			currentTrackTexFormat.size = Number(allData.currentTrackTextSize);		
			currentTrackTitle.x = 1;
			currentTrackTitle.y = 304 + Number(allData.currentTrackTextYAdjust);
		}	
		
		
		
		/**
		 * Places instances of trackButton lib cip over the background image
		 * Called from xmlLoaded() once the xml data is loaded
		 */
		private function buildTrackButtons():void
		{
			var butHeight:int = Math.floor(300 / trackList.length()); //determine height of the bg graphic			
			
			trackButtonTexFormat.size = Number(allData.trackButtonTextSize);
			
			trackButtonTexFormat.color = Number("0x" + allData.colors.trackButtonText);
			
			var sy:int = 0; //start y
			
			for (var i:int = 0; i < trackList.length(); i++) {
				
				//rectangle behind button text - shows on rollover
				var butBG:Sprite = new Sprite();
				butBG.graphics.beginFill(Number("0x" + allData.colors.trackButtonRollOver));
				butBG.graphics.drawRect(0, 0, 300, butHeight);
				butBG.graphics.endFill();
				
				var aButton:trackButton = new trackButton(); //lib clip - text field only
				aButton.addChildAt(butBG, 0); //add bg rollover graphic behind text
				
				addChild(aButton);
				aButton.x = 0;
				aButton.y = sy;
				//aButton.height = butHeight;
				aButton.alpha = 0;
				aButton.trackIndex = i;
				aButton.theText.text = trackList[i].title;
				aButton.theText.setTextFormat(trackButtonTexFormat);
				
				aButton.theText.y = Math.floor((butHeight - aButton.theText.height) * .5) + Number(allData.trackButtonTextYAdjust);
				
				sy += butHeight;
				aButton.buttonMode = true;
				aButton.theText.mouseEnabled = false;
				aButton.addEventListener(MouseEvent.MOUSE_OVER, trackButtonHover, false, 0, true);
				aButton.addEventListener(MouseEvent.MOUSE_OUT, trackButtonOut, false, 0, true);
				aButton.addEventListener(MouseEvent.CLICK, trackButtonPressed, false, 0, true);
			}
		}
		
		
		
		/**
		 * Builds the progress and loader bars
		 * Graphic rectangles - 300x40
		 * Called from xmlLoaded()
		 */
		private function buildBars():void
		{
			loadBar = new Sprite();
			playBar = new Sprite();
			
			loadBar.graphics.beginFill(Number("0x" + allData.colors.loaderBar));
			loadBar.graphics.drawRect(0, 0, 300, 40);
			loadBar.graphics.endFill();			
			
			playBar.graphics.beginFill(Number("0x" + allData.colors.progressBar));
			playBar.graphics.drawRect(0, 0, 300, 40);
			playBar.graphics.endFill();
			playBar.mouseEnabled = false;			
			
			addChild(loadBar);			
			loadBar.x = 0;
			loadBar.y = 300;
			loadBar.scaleX = 0;			
			
			addChild(playBar);			
			playBar.x = 0;
			playBar.y = 300;
			playBar.scaleX = 0;	
		}
		
		
		/**
		 * Called from xmlLoaded()
		 */
		private function buildControlButtons():void
		{
			//PLAY
			playButton = new Sprite();
			
			var playBG:Sprite = new Sprite()
			playBG.graphics.beginFill(Number("0x" + allData.colors.controlButtonBackground));
			playBG.graphics.drawRect(0, 0, 37, 37);
			playBG.graphics.endFill();
			
			var playFG:Sprite = new Sprite();
			playFG.graphics.beginFill(Number("0x" + allData.colors.controlButtonHilite));
			playFG.graphics.drawRect(0, 0, 37, 37);
			playFG.graphics.endFill();
			playFG.visible = false;
			
			var playC:Sprite = new Sprite();
			playC.graphics.beginFill(Number("0x" + allData.colors.controlButtonControl));
			playC.graphics.moveTo(0, 0);
			playC.graphics.lineTo(0, 17);
			playC.graphics.lineTo(17, 8);
			playC.graphics.lineTo(0, 0);
			playC.graphics.endFill();
			
			playButton.addChild(playBG);
			playButton.addChild(playFG);
			playButton.addChild(playC);
			playC.x = 10;
			playC.y = 10;
			
			
			//PAUSE
			pauseButton = new Sprite();
			
			var pauseBG:Sprite = new Sprite();
			pauseBG.graphics.beginFill(Number("0x" + allData.colors.controlButtonBackground));
			pauseBG.graphics.drawRect(0, 0, 37, 37);
			pauseBG.graphics.endFill();
			
			var pauseFG:Sprite = new Sprite();
			pauseFG.graphics.beginFill(Number("0x" + allData.colors.controlButtonHilite));
			pauseFG.graphics.drawRect(0, 0, 37, 37);
			pauseFG.graphics.endFill();
			pauseFG.visible = false;
			
			var pauseC:Sprite = new Sprite();
			pauseC.graphics.beginFill(Number("0x" + allData.colors.controlButtonControl));
			pauseC.graphics.drawRect(0, 0, 7, 17);
			pauseC.graphics.drawRect(10, 0, 7, 17);
			pauseC.graphics.endFill();
			
			pauseButton.addChild(pauseBG);
			pauseButton.addChild(pauseFG);
			pauseButton.addChild(pauseC);
			pauseC.x = 10;
			pauseC.y = 10;
			
			//STOP
			stopButton = new Sprite();
			
			var stopBG:Sprite = new Sprite()
			stopBG.graphics.beginFill(Number("0x" + allData.colors.controlButtonBackground));
			stopBG.graphics.drawRect(0, 0, 37, 37);
			stopBG.graphics.endFill();
			
			var stopFG:Sprite = new Sprite();
			stopFG.graphics.beginFill(Number("0x" + allData.colors.controlButtonHilite));
			stopFG.graphics.drawRect(0, 0, 37, 37);
			stopFG.graphics.endFill();
			stopFG.visible = false;
			
			var stopC:Sprite = new Sprite();
			stopC.graphics.beginFill(Number("0x" + allData.colors.controlButtonControl));
			stopC.graphics.drawRect(0, 0, 17, 17);
			stopC.graphics.endFill();
			
			stopButton.addChild(stopBG);
			stopButton.addChild(stopFG);
			stopButton.addChild(stopC);			
			stopC.x = 10;
			stopC.y = 10;
			
			//PREV BUTTON
			prevButton = new Sprite();
			
			var prevBG:Sprite = new Sprite()
			prevBG.graphics.beginFill(Number("0x" + allData.colors.controlButtonBackground));
			prevBG.graphics.drawRect(0, 0, 37, 37);
			prevBG.graphics.endFill();
			
			var prevFG:Sprite = new Sprite();
			prevFG.graphics.beginFill(Number("0x" + allData.colors.controlButtonHilite));
			prevFG.graphics.drawRect(0, 0, 37, 37);
			prevFG.graphics.endFill();
			prevFG.visible = false;
			
			var prevC:Sprite = new Sprite();
			prevC.graphics.beginFill(Number("0x" + allData.colors.controlButtonControl));
			prevC.graphics.moveTo(0, 0);
			prevC.graphics.lineTo(0, 17);
			prevC.graphics.lineTo(9, 8);
			prevC.graphics.lineTo(0, 0);
			prevC.graphics.endFill();
			prevC.graphics.beginFill(Number("0x" + allData.colors.controlButtonControl));
			prevC.graphics.moveTo(8, 0);
			prevC.graphics.lineTo(8, 17);
			prevC.graphics.lineTo(17, 8);
			prevC.graphics.lineTo(8, 0);			
			prevC.graphics.endFill();
			prevC.scaleX = -1;
			
			prevButton.addChild(prevBG);
			prevButton.addChild(prevFG);
			prevButton.addChild(prevC);
			prevC.x = 26;
			prevC.y = 10;
			
			//NEXT BUTTON
			nextButton = new Sprite();
			
			var nextBG:Sprite = new Sprite()
			nextBG.graphics.beginFill(Number("0x" + allData.colors.controlButtonBackground));
			nextBG.graphics.drawRect(0, 0, 37, 37);
			nextBG.graphics.endFill();
			
			var nextFG:Sprite = new Sprite();
			nextFG.graphics.beginFill(Number("0x" + allData.colors.controlButtonHilite));
			nextFG.graphics.drawRect(0, 0, 37, 37);
			nextFG.graphics.endFill();
			nextFG.visible = false;
			
			var nextC:Sprite = new Sprite();
			nextC.graphics.beginFill(Number("0x" + allData.colors.controlButtonControl));
			nextC.graphics.moveTo(0, 0);
			nextC.graphics.lineTo(0, 17);
			nextC.graphics.lineTo(9, 8);
			nextC.graphics.lineTo(0, 0);
			nextC.graphics.endFill();
			nextC.graphics.beginFill(Number("0x" + allData.colors.controlButtonControl));
			nextC.graphics.moveTo(8, 0);
			nextC.graphics.lineTo(8, 17);
			nextC.graphics.lineTo(17, 8);
			nextC.graphics.lineTo(8, 0);			
			nextC.graphics.endFill();
			
			nextButton.addChild(nextBG);
			nextButton.addChild(nextFG);
			nextButton.addChild(nextC);
			nextC.x = 11;
			nextC.y = 10;
			
			//BUY
			buyButton = new Sprite();
			
			var buyBG:Sprite = new Sprite()
			buyBG.graphics.beginFill(Number("0x" + allData.colors.controlButtonBackground));
			buyBG.graphics.drawRect(0, 0, 69, 37);
			buyBG.graphics.endFill();
			
			var buyFG:Sprite = new Sprite();
			buyFG.graphics.beginFill(Number("0x" + allData.colors.controlButtonHilite));
			buyFG.graphics.drawRect(0, 0, 69, 37);
			buyFG.graphics.endFill();			
			buyFG.visible = false;
			
			var buyC:buyText = new buyText(); //library clip
			buyTexFormat.color = Number("0x" + allData.colors.controlButtonControl);
			buyC.theText.setTextFormat(buyTexFormat);
			buyC.theText.mouseEnabled = false;
			
			buyButton.addChild(buyBG);
			buyButton.addChild(buyFG);
			buyButton.addChild(buyC);
			buyC.x = 4;
			buyC.y = 8;			
			
			
			//ADD BUTTONS TO STAGE			
			addChild(playButton);
			playButton.x = 8;
			playButton.y = 350;
			
			addChild(pauseButton);
			pauseButton.x = 51;
			pauseButton.y = 350;
			
			addChild(stopButton);
			stopButton.x = 95;
			stopButton.y = 350;
			
			addChild(prevButton);
			prevButton.x = 138;
			prevButton.y = 350;
			
			addChild(nextButton);
			nextButton.x = 181;
			nextButton.y = 350;
			
			addChild(buyButton);
			buyButton.x = 224;
			buyButton.y = 350;
			
			playButton.buttonMode = true;
			playButton.addEventListener(MouseEvent.MOUSE_OVER, overControl, false, 0, true);
			playButton.addEventListener(MouseEvent.MOUSE_OUT, outControl, false, 0, true);
			playButton.addEventListener(MouseEvent.CLICK, playSound, false, 0, true);
			
			pauseButton.buttonMode = true;
			pauseButton.addEventListener(MouseEvent.MOUSE_OVER, overControl, false, 0, true);
			pauseButton.addEventListener(MouseEvent.MOUSE_OUT, outControl, false, 0, true);
			pauseButton.addEventListener(MouseEvent.CLICK, pauseSound, false, 0, true);
			
			stopButton.buttonMode = true;
			stopButton.addEventListener(MouseEvent.MOUSE_OVER, overControl, false, 0, true);
			stopButton.addEventListener(MouseEvent.MOUSE_OUT, outControl, false, 0, true);
			stopButton.addEventListener(MouseEvent.CLICK, stopSound, false, 0, true);
			
			prevButton.buttonMode = true;
			prevButton.addEventListener(MouseEvent.MOUSE_OVER, overControl, false, 0, true);
			prevButton.addEventListener(MouseEvent.MOUSE_OUT, outControl, false, 0, true);
			prevButton.addEventListener(MouseEvent.CLICK, prevTrack, false, 0, true);
			
			nextButton.buttonMode = true;
			nextButton.addEventListener(MouseEvent.MOUSE_OVER, overControl, false, 0, true);
			nextButton.addEventListener(MouseEvent.MOUSE_OUT, outControl, false, 0, true);
			nextButton.addEventListener(MouseEvent.CLICK, nextTrack, false, 0, true);
			
			//buy button listeners are added in buildBuyPopup if there are purchase icons in the xml
		}
		
		
		/**
		 * Builds the popup that shows when the buy button is pressed
		 * uses the purchaseLinks section from the XML
		 * Called from xmlLoaded()
		 */
		private function buildBuyPopup():void
		{
			buyPopup = new Sprite(); //icon container
			
			//colored rectangle for the close button
			buyClose = new Sprite();
			buyClose.graphics.beginFill(Number("0x" + allData.colors.purchaseWindowBackground));
			buyClose.graphics.drawRect(0, 0, 12, 12);
			buyClose.graphics.endFill();
			//x
			buyClose.graphics.lineStyle(1, Number("0x" + allData.colors.controlButtonControl));
			buyClose.graphics.moveTo(3, 3);
			buyClose.graphics.lineTo(9, 9);
			buyClose.graphics.moveTo(9, 3);
			buyClose.graphics.lineTo(3, 9);
			
			buyClose.buttonMode = true;
			
			totalIconWidth = 0;
			maxIconHeight = 0;
			
			iconList = new Array();			
			var theLinks:XMLList = allData.purchaseLinks.link;
			for (var i:int = 0; i < theLinks.length(); i++) {
				iconList.push([theLinks[i].icon, theLinks[i].url]);
			}
			
			if (iconList.length) {
				buyButton.buttonMode = true;
				buyButton.addEventListener(MouseEvent.MOUSE_OVER, overControl, false, 0, true);
				buyButton.addEventListener(MouseEvent.MOUSE_OUT, outBuyButton, false, 0, true);
				buyButton.addEventListener(MouseEvent.CLICK, showBuyPopup, false, 0, true);
				
				loadIcon();
			}else {
				//no purchase icons in the XML - gray out the BUY button
				buyButton.alpha = .3;
			}
		}
		
		private function loadIcon():void
		{
			var iconLoader:Loader = new Loader();
			curLink = iconList.splice(0, 1)[0];
			iconLoader.load(new URLRequest(loadFrom + curLink[0]));
			iconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoaded, false, 0, true);
		}
		
		private function iconLoaded(e:Event):void
		{
			var bit:Bitmap = e.target.content;
			totalIconWidth += bit.width;
			if (bit.height > maxIconHeight) { maxIconHeight = bit.height; }
			var bitHolder:MovieClip = new MovieClip(); //add bitmap to a movie clip in order to inject the url
			bitHolder.addChild(bit);
			bitHolder.theURL = curLink[1];
			bitHolder.buttonMode = true;			
			bitHolder.addEventListener(MouseEvent.CLICK, iconClicked, false, 0, true);
			bitHolder.filters = [dropShadow];
			buyPopup.addChild(bitHolder);
			
			if (iconList.length) {
				loadIcon();
			}else {
				//icons done loading
				var numIcons:int = allData.purchaseLinks.link.length();
				var windowWidth:int = totalIconWidth + ( 5 * (numIcons - 1)) + 10;
				var windowHeight:int = maxIconHeight + 10;
				
				//colored rectangle for the popup window background
				var bg:Sprite = new Sprite();
				bg.graphics.beginFill(Number("0x" + allData.colors.purchaseWindowBackground));
				bg.graphics.drawRect(0, 0, windowWidth, windowHeight);
				bg.graphics.endFill();
				buyPopup.addChildAt(bg, 0);
				
				//space icons
				var startX:int = 5;
				for (var i:int = 1; i < buyPopup.numChildren; i++) {
					var ic:MovieClip = MovieClip(buyPopup.getChildAt(i));
					ic.x = startX;
					ic.y = (windowHeight - ic.height) * .5;
					startX += ic.width + 5;
				}
				buyPopup.x = 295 - windowWidth;
				buyPopup.y = 345 - windowHeight;
				
				buyClose.x = buyPopup.x + buyPopup.width - buyClose.width;
				buyClose.y = buyPopup.y - buyClose.height;
			}
		}
		
		
		private function showBuyPopup(e:MouseEvent):void
		{
			if(!buyPopupShowing){
				addChild(buyPopup);
				addChild(buyClose);
				buyPopup.alpha = 0;
				buyClose.alpha = 0;
				var toY:int = buyPopup.y;
				buyPopup.y += 15;
				TweenLite.to(buyPopup, .5, { alpha:1, y:toY } );
				TweenLite.to(buyClose, .5, { alpha:1, delay:.5 } );
				buyClose.addEventListener(MouseEvent.CLICK, showBuyPopup, false, 0, true);
				buyPopupShowing = true;
			}else {
				removeChild(buyPopup);
				removeChild(buyClose);
				buyPopupShowing = false;
				outBuyButton();
			}
		}
		
		
		
		/**
		 * Called by clicking one of the icons in the buyPopup window
		 * @param	e
		 */
		private function iconClicked(e:MouseEvent):void
		{
			navigateToURL(new URLRequest(e.currentTarget.theURL), "_blank");
		}
		
		
		/**
		 * Listeners to hilite/unhilight the control buttons
		 * @param	e
		 */
		private function overControl(e:MouseEvent):void
		{
			e.currentTarget.getChildAt(1).visible = true;
		}
		private function outControl(e:MouseEvent):void
		{
			e.currentTarget.getChildAt(1).visible = false;
		}
		
		/**
		 * Separate handler for the buy button only so it turns the
		 * highlight off only if the popup isn't showing
		 * @param	e
		 */		
		private function outBuyButton(e:MouseEvent = null):void
		{
			if(!buyPopupShowing){
				buyButton.getChildAt(1).visible = false;
			}
		}
		
		
		/**
		 * Listeners for the track buttons on top the graphic
		 * @param	e
		 */
		private function trackButtonHover(e:MouseEvent):void
		{
			TweenLite.to(e.currentTarget, .5, { alpha:1 } );
		}		
		private function trackButtonOut(e:MouseEvent):void
		{
			TweenLite.to(e.currentTarget, .5, { alpha:0 } );
		}
		private function trackButtonPressed(e:MouseEvent):void
		{
			playTrack(e.currentTarget.trackIndex);
		}
		
		
		/**
		 * Control button click handlers
		 * @param	e
		 */
		private function stopSound(e:MouseEvent = null):void
		{			
			//channel.stop();
			//channel = new SoundChannel(); //so monitor loop zeros the progress bar scale
			//pausePosition = 0;
			isPaused = true;
			ns.seek(0);
			ns.pause();
		}
		
		private function pauseSound(e:MouseEvent):void
		{
			//pausePosition = channel.position;
			isPaused = true;
			//channel.stop();
			ns.pause();
		}
		
		/**
		 * Called by clicking the play button
		 * @param	e
		 */
		private function playSound(e:MouseEvent):void
		{
			if (currentTrackIndex == -1) {
				playNextTrack();
			}else{
				if(isPaused){
					//channel = track.play(pausePosition);
					ns.resume();
					isPaused = false;
				}
			}
		}
		
		private function prevTrack(e:MouseEvent):void
		{			
			currentTrackIndex--;
			if (currentTrackIndex < 0) {
				currentTrackIndex = trackList.length() - 1;
			}
			playTrack(currentTrackIndex);
		}
		
		private function nextTrack(e:MouseEvent):void
		{
			playNextTrack();
		}
		
		
		/**
		 * Called from monitorPlayback() when song is finished
		 * Called from nextButtonClick()
		 * increments currentTrackIndex and then calls playTrack()
		 * 
		 * @param	e
		 */
		private function playNextTrack(e:Event = null):void
		{			
			currentTrackIndex++;
			if (currentTrackIndex >= trackList.length()) {
				currentTrackIndex = 0;
			}
			playTrack(currentTrackIndex);
		}
		
		
		
		/**
		 * Plays the track in the trackList at the given index
		 * 
		 * @param	trackIndex index in the trackList
		 */
		private function playTrack(trackIndex:int):void
		{	
			ns.close();
			loadBar.scaleX = 0;
			playBar.scaleX = 0;
			
			//track.removeEventListener(ProgressEvent.PROGRESS, showTrackLoadingProgress);
			//track.removeEventListener(Event.COMPLETE, trackLoaded);
			//channel.removeEventListener(Event.SOUND_COMPLETE, playNextTrack);
			//loadBar.removeEventListener(MouseEvent.CLICK, loadBarClicked);
			removeEventListener(Event.ENTER_FRAME, monitorPlayback);
			
			
			currentTrackIndex = trackIndex;
			
			//var req:URLRequest = new URLRequest(loadFrom + trackList[currentTrackIndex].file);
			
			//channel.stop();
			
			//track = new Sound(); //must make a new sound object each time a track is played
			//track.load(req, theContext);
			//channel = track.play();
			
			ns.play("mp3:" + s3Bucket + trackList[currentTrackIndex].file);
			
			isPaused = false;
			
			currentTrackTitle.theText.text = trackList[currentTrackIndex].title;
			currentTrackTitle.theText.setTextFormat(currentTrackTexFormat);
			currentTrackTitle.mouseEnabled = false;
			currentTrackTitle.theText.mouseEnabled = false;
			
			//trackFullyLoaded = false;
			//track.addEventListener(ProgressEvent.PROGRESS, showTrackLoadingProgress, false, 0, true);
			//track.addEventListener(Event.COMPLETE, trackLoaded, false, 0, true);
			//track.addEventListener(Event.ID3, id3Handler, false, 0, true);

			currentTrackBytes = parseInt(trackList[currentTrackIndex].size);
			addEventListener(Event.ENTER_FRAME, monitorPlayback, false, 0, true);
			
		}
		
		
		private function id3Handler(e:Event):void
		{
			trace("id3", e);
			var id3:ID3Info = track.id3;
			 for (var propName:String in id3) {
               trace(propName + " = " + id3[propName] + "\n");
            }
			trace(track.id3.TLEN);

		}
		
		private function showTrackLoadingProgress(e:ProgressEvent):void
		{			
			loadBar.scaleX = e.bytesLoaded / e.bytesTotal;	
		}
		
		
		/**
		 * Removes listeners when track is done loading
		 * @param	e COMPLETE event
		 */
		private function trackLoaded(e:Event):void
		{
			track.removeEventListener(ProgressEvent.PROGRESS, showTrackLoadingProgress);
			track.removeEventListener(Event.COMPLETE, trackLoaded);
			
			//enable clicking on the loading bar now that the track is fully loaded
			loadBar.addEventListener(MouseEvent.CLICK, loadBarClicked, false, 0, true);
			
			trackFullyLoaded = true;
		}
		
		
		
		/**
		 * Called by ENTER_FRAME - scales the playBar based on the songs current position
		 * Shows the visualizer if it's set on in the XML
		 * 
		 * @param	e ENTER_FRAME event
		 */
		private function monitorPlayback(e:Event):void
		{	
			//trace(ns.info.audioByteCount);
			playBar.scaleX = ns.info.audioByteCount / currentTrackBytes;
			/*
			if (!trackFullyLoaded) {
				//estimate of duration before track is loaded
				var duration:Number = (track.bytesTotal / (track.bytesLoaded / track.length));
				playBar.scaleX = channel.position / duration;
			}else{			
				playBar.scaleX = channel.position / track.length;
			}
			
			if (playBar.scaleX >= .999) { playNextTrack(); }			
			*/
			
		}
		
		/**
		 * Caleld by vizTimer on timer event
		 * @param	e
		 */
		private function displayVisualizer(e:TimerEvent):void
		{			
			SoundMixer.computeSpectrum(bytes, visFFT);
			
			visHolder.graphics.clear();				
			visHolder.graphics.lineStyle(1, Number("0x" + allData.visualizer.lineColor), Number(allData.visualizer.lineAlpha));	
			visHolder.graphics.beginFill(Number("0x" + allData.visualizer.fillColor), Number(allData.visualizer.fillAlpha));
			visHolder.graphics.moveTo(0, 0);
			var t:Number;
			
			var widthRatio:Number = 300 / 512;
			for (var i:int = 0; i < 512; i += 2) {
				try{
					t = bytes.readFloat() * heightMultiplier;  	
					//visHolder.graphics.drawRect(i * widthRatio, 0, 2, -n);
					visHolder.graphics.lineTo(i * widthRatio, -t);					
				}
				catch (e:EOFError) {
					trace("c");
				}
			}
			
			visHolder.graphics.lineTo(i * widthRatio, 0);
			visHolder.graphics.lineTo(0, 0);
		}
		
		
		/**
		 * Called if the loader bar is clicked on - skips the current
		 * song to the click spot
		 * @param	e
		 */
		private function loadBarClicked(e:MouseEvent):void
		{
			if (!isPaused) {
				channel.stop();
				var ratio = track.length / 300; //milliseconds per pixel				
				channel = track.play(ratio * e.localX);
			}
		}
		
		
		/**
		 * Called once the bg image has been loaded
		 * Places the child at index 0 so it goes behind the track buttons if they appear first
		 * @param	e
		 */
		private function backgroundLoaded(e:Event):void
		{
			bgImage.contentLoaderInfo.removeEventListener(Event.COMPLETE, backgroundLoaded);
			
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}
			
			if(colorBackgroundAdded){
				addChildAt(bgImage, 1);
			}else {
				addChildAt(bgImage, 0);
			}
			bgImage.x = 0;
			bgImage.y = 0;
			bgImage.width = 300;
			bgImage.height = 300;
		}
	}	
}