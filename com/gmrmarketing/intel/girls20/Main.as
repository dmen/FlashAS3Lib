package com.gmrmarketing.intel.girls20
{
	import com.gmrmarketing.nissan.RestartDialog;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;		
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.*;	
	import flash.media.*;
	import flash.utils.Timer;
	import flash.display.StageDisplayState;
	import flash.desktop.NativeApplication;
	import com.greensock.TweenMax;
	import com.gmrmarketing.website.VPlayer;
	import com.gmrmarketing.utilities.GUID;
	import com.gmrmarketing.utilities.OSKeyboard;
	import com.gmrmarketing.utilities.KbdEvent;
	import com.gmrmarketing.utilities.Validator;
	import com.gmrmarketing.utilities.AIRFile;
	import com.gmrmarketing.intel.girls20.Dialog;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.intel.girls20.ComboBox;
	import com.gmrmarketing.intel.girls20.AutoPost;
	import flash.ui.Mouse;
	
	
	public class Main extends MovieClip
	{	
		private var landingPage:MovieClip;
		private var page2:MovieClip;
		private var page3:MovieClip;
		private var page4:MovieClip; //form
		private var page5:MovieClip; //thanks
		
		private var vid:VPlayer;
		private var blackCircle:MovieClip;
		
		private var cam:Camera;
		private var mic:Microphone;
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;
		
		private var vidTimer:Timer;
		private var curCount:int;
		
		private var keyboard:MovieClip;//lib clip linked to OSKeyboard
		private var currentFormField:String;
		private var allowedMobile:Array;
		private var dlg:MovieClip; //lib clip linked to Dialog
		
		private var userGUID:String; //guid name given to the flv - passed to Aaron's web service
		private var airFile:AIRFile;
		
		private var cq:CornerQuit;
		private var timeOut:Timer;
		private var didTimeOut:Boolean;
		private var cursorCounter:int;
		
		private var countryCombo:ComboBox; //country dropdown on p4
		private var release:MovieClip; //lib clip - privacyRelease
		private var touchtext:MovieClip; //touch to begin text placed over video when timeout occurs
		
		private var recordedVideo:Boolean; //true after the user records their video - used to delete
		//the recorded video if the timeout handler runs before the form data has posted/saved
		
		private var autoPost:AutoPost; //auto posts to web service if it finds any files in c:/intelgirls20/
		//this is the folder that form data is stored in if the web service can't be posted to
		
		private var restartDialog:MovieClip; //lib clip
		
		
		
		
		public function Main()
		{	
			stage.displayState = StageDisplayState.FULL_SCREEN;
			Mouse.hide();
			
			landingPage = new p1();
			page2 = new p2();
			page3 = new p3();
			page4 = new p4();
			
			release = new privacyRelease();
			release.x = 425;
			release.y = 15;
			
			restartDialog = new restart();
			
			countryCombo = new ComboBox();
			countryCombo.populate(CountryList.getCountries());
			page4.addChild(countryCombo);
			countryCombo.x = 649;
			countryCombo.y = 446;		
			
			vid = new VPlayer();
			blackCircle = new tranCircle();
			
			vidTimer = new Timer(1000);
			vidTimer.addEventListener(TimerEvent.TIMER, decrementCount, false, 0, true);
			
			cam = Camera.getCamera();
			
			keyboard = new OSKeyboard();
			
			//defines characters allowed in the phone number field
			allowedMobile = new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", " ");
			
			dlg = new Dialog(this);
			
			airFile = new AIRFile();
			
			cq = new CornerQuit();
			cq.init(this, "ullr");
			cq.customLoc(2, new Point(1770, 930));
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			timeOut = new Timer(120000, 1);//2min
			timeOut.addEventListener(TimerEvent.TIMER, appTimedOut, false, 0, true);
			
			touchtext = new touchToBegin();
			touchtext.x = 28;
			touchtext.y = 75;
			touchtext.alpha = .8;
			
			autoPost = new AutoPost();
			
			init();
		}
		
		
		/**
		 * Shows the Landing Page - with touch to begin
		 */
		private function init():void
		{
			while (numChildren) {
				removeChildAt(0);
			}
			addChild(landingPage);
			cq.moveToTop();
			curCount = 30;
			landingPage.alpha = 0;
			TweenMax.to(landingPage, 1, { alpha:1 } );
			stage.addEventListener(MouseEvent.MOUSE_DOWN, tran, false, 0, true);
			
			didTimeOut = false;
			
			recordedVideo = false;
			
			resetTimeOut();
		}
		
		
		private function tran(e:MouseEvent):void
		{
			resetTimeOut();
			
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, tran);
			addChild(blackCircle);
			blackCircle.x = mouseX;
			blackCircle.y = mouseY;
			blackCircle.width = blackCircle.height = 48;
			TweenMax.to(blackCircle, 1, { width:5000, height:5000, onComplete:playIntroVideo } );
		}
		
		
		private function playIntroVideo():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, tran);
			if(contains(landingPage)){
				removeChild(landingPage);
			}
			
			vid.showVideo(this);
			vid.addEventListener(VPlayer.STATUS_RECEIVED, vidStatus, false, 0, true);
			vid.playVideo("assets/bumpIn.f4v");
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, vidClick, false, 0, true);
			
			if (didTimeOut) {
				addChild(touchtext);
			}
			
			cq.moveToTop();
		}
		
		private function vidClick(e:MouseEvent):void
		{
			/*
			vid.hideVideo();
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, vidClick);
			doPage2();
			*/
			if (didTimeOut) {
				vid.hideVideo();
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, vidClick);
				init();
			}
			
		}
		
		private function vidStatus(e:Event):void
		{
			var s:String = vid.getStatus();
			
			if (s == "NetStream.Play.Stop") {
				
				vid.hideVideo();
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, vidClick);
				
				if (didTimeOut) {
					init();
				}else{
					doPage2();
				}
			}
		}
		
		
		private function doPage2():void
		{
			if(contains(blackCircle)){
				removeChild(blackCircle);
			}
			if (contains(touchtext)) {
				removeChild(touchtext);
			}
						
			addChild(page2);
			cq.moveToTop();
			page2.alpha = 0;
			TweenMax.to(page2, 1, { alpha:1 } );
			
			page2.btnGetStarted.addEventListener(MouseEvent.MOUSE_DOWN, vidPage, false, 0, true);
			page2.btnRestart.addEventListener(MouseEvent.MOUSE_DOWN, restartPressed, false, 0, true);
			
			resetTimeOut();
		}
		
		
		private function vidPage(e:MouseEvent):void
		{
			resetTimeOut();
			
			page2.btnGetStarted.removeEventListener(MouseEvent.MOUSE_DOWN, vidPage);
			page2.btnRestart.removeEventListener(MouseEvent.MOUSE_DOWN, restartPressed);
			
			removeChild(page2);			
			
			addChild(page3);
			cq.moveToTop();
			
			page3.btnText.text = "START RECORDING";
			page3.btnText.x = 1108;
			page3.arrow.x = 1404;
			page3.btnText.alpha = .3;
			page3.arrow.alpha = .3;
			page3.sTimer.theTimer.text = "30";
			
			page3.begin.alpha = 0;
			page3.begin.x = 1060;
			page3.begin.y = 413;
			page3.begin.scaleX = page3.begin.scaleY = .7;
			
			vidConnection = new NetConnection();
			vidConnection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);	
			vidConnection.connect("rtmp://localhost/intel/g20");
			
			cam.setQuality(0, 94);
			cam.setMode(711, 400, 30, true);
			
			//show video on stage
			page3.vid.attachCamera(cam);
			
			mic = Microphone.getMicrophone();	
		}
		
		
		private function statusHandler(e:NetStatusEvent):void
		{
			resetTimeOut();
			
			if (e.info.code == "NetConnection.Connect.Success")
			{		
				vidStream = new NetStream(vidConnection);
				vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };	
				
				page3.btn.addEventListener(MouseEvent.MOUSE_DOWN, beginRecording, false, 0, true);
				page3.btnRestart.addEventListener(MouseEvent.MOUSE_DOWN, restartPressed, false, 0, true);
				
				TweenMax.to(page3.btnText, .5, { alpha:1 } );
				TweenMax.to(page3.arrow, .5, { alpha:1 } );
			}
		}
		
		
		private function beginRecording(e:MouseEvent):void
		{
			resetTimeOut();
			
			mic.setSilenceLevel(0);			
			mic.rate = 22; //0-10 only for SPEEX
			
			vidStream.attachCamera(cam);
			vidStream.attachAudio(mic);
			userGUID = GUID.create();
			vidStream.publish(userGUID, "record"); //makes a sorenson flv
			//vidStream.publish("mp4:" + userGUID + ".f4v", "record");
			
			page3.btnText.text = "FINISHED";
			//page3.btnText.x = 1178;
			//page3.arrow.x = 1330;
			TweenMax.to(page3.btnText, .5, { x:1178 } );
			TweenMax.to(page3.arrow, .5, { x:1330 } );			
			
			TweenMax.to(page3.begin, 1, { alpha:1.2, scaleX:1.2, scaleY:1 } );
			TweenMax.to(page3.begin, .5, { alpha:0, delay:1, overwrite:0, onComplete:killBegin } );
			
			page3.btn.removeEventListener(MouseEvent.MOUSE_DOWN, beginRecording);
			page3.btn.addEventListener(MouseEvent.MOUSE_DOWN, stopRecording, false, 0, true);
			
			vidTimer.start(); //calls decrementCount()
		}
		private function killBegin():void
		{
			page3.begin.y = -500;
		}
		
		
		/**
		 * Called by clicking the Finished button
		 * Called from decrementCount() when the 30 seconds is up
		 * @param	e
		 */
		private function stopRecording(e:MouseEvent = null):void
		{
			vidStream.close();
			vidStream.attachCamera(null);
			vidStream.attachAudio(null);
			vidTimer.stop();
			
			//close the connection to FMS - fixes problem with 10 connection max
			vidConnection.close();
			
			recordedVideo = true;
			doPage4();
		}
		
		
		private function metaDataHandler(infoObject:Object):void
		{}

		
		private function cuePointHandler(infoObject:Object):void
		{}		
		
		
		private function decrementCount(e:TimerEvent):void
		{
			curCount--;
			page3.sTimer.theTimer.text = String(curCount);
			if (curCount <= 0) {
				stopRecording();
			}
		}
		
		
		private function doPage4():void
		{
			resetTimeOut();
			
			if (contains(restartDialog)) {
				removeChild(restartDialog);
				restartDialog.btnOK.removeEventListener(MouseEvent.MOUSE_DOWN, restartConfirmed);
				restartDialog.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, restartCanceled);
			}
			
			removeChild(page3);
			page3.btn.removeEventListener(MouseEvent.MOUSE_DOWN, stopRecording);
			page3.btnRestart.removeEventListener(MouseEvent.MOUSE_DOWN, restartPressed);
					
			addChild(page4);
			page4.keyboard.y = 1200;
			cq.moveToTop();
			page4.alpha = 0;
			page4.insertion.alpha = 0;
			
			moveIndicator();
			
			currentFormField = "email";
			
			page4.theEmail.text = "";
			page4.theEmailConfirm.text = "";
			page4.theMobile.text = "";
			countryCombo.reset(); //clears selection
			
			//default to US
			countryCombo.setSelection("United States");
			
			//MovieClip(release.optIn).gotoAndStop(1);//reset/uncheck checkbox
			//trace(MovieClip(release.optIn).currentFrame);
			
			TweenMax.to(page4, 1, { alpha:1, onComplete:showKeyboard } );
			
			page4.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, moveIndicator, false, 0, true);
			page4.btnEmailConfirm.addEventListener(MouseEvent.MOUSE_DOWN, moveIndicator, false, 0, true);
			//page4.btnCountry.addEventListener(MouseEvent.MOUSE_DOWN, moveIndicator, false, 0, true);
			page4.btnMobile.addEventListener(MouseEvent.MOUSE_DOWN, moveIndicator, false, 0, true);
			
			page4.btnShowRelease.addEventListener(MouseEvent.MOUSE_DOWN, showRelease, false, 0, true);	//privacy release	
			page4.btnRestart.addEventListener(MouseEvent.MOUSE_DOWN, restartPressed, false, 0, true);
		}
		
		
		private function toggleReleaseCheck(e:MouseEvent):void
		{
			if (release.optIn.currentFrame == 1) {
				release.optIn.gotoAndStop(2);
			}else {
				release.optIn.gotoAndStop(1);
			}
		}
		
		
		private function showRelease(e:MouseEvent):void
		{
			resetTimeOut();
			release.alpha = 0;
			addChild(release);
			release.optIn.gotoAndStop(1);//reset/uncheck checkbox
			TweenMax.to(release, .5, { alpha:1 } );
			release.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, hideRelease, false, 0, true);
			release.btnCheckRelease.addEventListener(MouseEvent.MOUSE_DOWN, toggleReleaseCheck, false, 0, true);
		}
		
		
		private function hideRelease(e:MouseEvent):void
		{
			resetTimeOut();
			release.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, hideRelease);
			release.btnCheckRelease.removeEventListener(MouseEvent.MOUSE_DOWN, toggleReleaseCheck);
			TweenMax.to(release, .5, { alpha:0, onComplete:killRelease } );
		}
		
		
		private function killRelease():void
		{
			removeChild(release);
		}
		
		
		private function showKeyboard():void
		{
			TweenMax.to(page4.keyboard, .5, { y:690 } );
			page4.keyboard.addEventListener(KbdEvent.KEY_CLICK, keyClicked, false, 0, true);
			
			page4.insertion.x = page4.theEmail.x + page4.theEmail.textWidth + 4;
			page4.insertion.y = page4.theEmail.y + 4;
			
			page4.insertion.addEventListener(Event.ENTER_FRAME, flashCursor, false, 0, true);			
			cursorCounter = 0;
		}
		
		
		private function keyClicked(e:KbdEvent):void
		{
			resetTimeOut();
			
			var c:String = e.char;
			
			if (c != "submit") {
				
				switch(currentFormField)
				{
					case "email":
						if (c == "backspace") {
							if(page4.theEmail.text.length > 0){
								page4.theEmail.text = String(page4.theEmail.text).substr(0, page4.theEmail.text.length - 1);
							}
						}else {
							if(page4.theEmail.text.length < 40){
								page4.theEmail.appendText(c);
							}
						}
						
						page4.insertion.x = page4.theEmail.x + page4.theEmail.textWidth + 5;
						page4.insertion.y = page4.theEmail.y + 4;
						
						break;
						
					case "emailConfirm":
						if (c == "backspace") {
							if(page4.theEmailConfirm.text.length > 0){
								page4.theEmailConfirm.text = String(page4.theEmailConfirm.text).substr(0, page4.theEmailConfirm.text.length - 1);
							}
						}else {
							if(page4.theEmailConfirm.text.length < 40){
								page4.theEmailConfirm.appendText(c);
							}
						}
						
						page4.insertion.x = page4.theEmailConfirm.x + page4.theEmailConfirm.textWidth + 5;
						page4.insertion.y = page4.theEmailConfirm.y + 4;
						
						break;
					
					case "mobile":
						if (c == "backspace") {
							if(page4.theMobile.text.length > 0){
								page4.theMobile.text = String(page4.theMobile.text).substr(0, page4.theMobile.text.length - 1);
							}
						}else {
							if(page4.theMobile.text.length < 34 && allowedMobile.indexOf(c) != -1){
								page4.theMobile.appendText(c);
							}
						}
						
						page4.insertion.x = page4.theMobile.x + page4.theMobile.textWidth + 5;
						page4.insertion.y = page4.theMobile.y + 4;
			
						break;
				}
				countryCombo.keyPressed(c);
			}else {
				//submit pressed
				
				if (page4.theEmail.text == "" && page4.theMobile.text == "") {
					dlg.show("Please enter your email\nor phone number");
				}else {
					
					//either email or mobile has text in it
					if (page4.theEmail.text != "") {
						if(page4.theEmail.text == page4.theEmailConfirm.text){
							if (!Validator.isValidEmail(page4.theEmail.text)) {
								dlg.show("Invalid email");
								return;
							}
						}else {
							//email and confirm don't match
							dlg.show("Email and Confirmation must match");
							return;
						}
					}
					
					//too many phone number formats - don't validate
					if (page4.theMobile.text != "") {
						
						//remove all spaces
						var p:String = page4.theMobile.text;
						var myPattern:RegExp = / /g;
						var n:String = p.replace(myPattern, "");
						if (n.length == 0) {
							dlg.show("Invalid phone number");
							return;
						}
						
						//make sure they entered a country if they enter a phone
						if (countryCombo.getSelection() == "") {
							dlg.show("A country is required when entering your mobile phone number");
							return;
						}
					}
					
					//good to go
					postToService();
				}
			}
		}
		
		private function flashCursor(e:Event):void
		{
			cursorCounter++;
			if (cursorCounter % 15 == 0) {
				if (page4.insertion.alpha < 1) {
					page4.insertion.alpha = 1;					
				}else {
					page4.insertion.alpha = 0;					
				}
			}
		}
		
		private function moveIndicator(e:MouseEvent = null):void
		{
			resetTimeOut();
			
			var yLoc:int;
			
			var m:MovieClip;
			if (e == null) {
				m = page4.btnEmail;
			}else {
				m = MovieClip(e.currentTarget);
			}
			
			switch(m) {
				case page4.btnEmail:
					yLoc = 316;
					currentFormField = "email";
					page4.insertion.x = page4.theEmail.x + page4.theEmail.textWidth + 5;
					page4.insertion.y = page4.theEmail.y + 4;
					break;
				case page4.btnEmailConfirm:
					yLoc = 386;
					currentFormField = "emailConfirm";
					page4.insertion.x = page4.theEmailConfirm.x + page4.theEmailConfirm.textWidth + 5;
					page4.insertion.y = page4.theEmailConfirm.y + 4;
					break;		
				case page4.btnMobile:
					yLoc = 534;
					currentFormField = "mobile";
					page4.insertion.x = page4.theMobile.x + page4.theMobile.textWidth + 5;
					page4.insertion.y = page4.theMobile.y + 4;
					break;
			}	
			TweenMax.to(page4.indicator, .5, { y:yLoc } );
		}
		
	

		
		//method duplicated in AutoPost.postNext()
		private function postToService():void
		{			
			resetTimeOut();
			
			var request:URLRequest = new URLRequest("http://intelgirls20.gmrstage.com/Home/Register");
						
			var poster:URLLoader = new URLLoader();
			
			//CAVEAT: IOErrorEvent.IO_ERROR will not be thrown when the format is set to URLLoaderDataFormat.VARIABLES
			//this is due to that constant being "variables" and not "VARIABLES" as it should be... bug
			//workaround is to just use the string "VARIABLES"
			poster.dataFormat = "VARIABLES";
			
			var variables:URLVariables = new URLVariables();		
			
			variables.id = userGUID;
			variables.email = page4.theEmail.text; 
			variables.phone = page4.theMobile.text;
			variables.country = countryCombo.getSelection();
			variables.optin = release.optIn.currentFrame == 1 ? "false" : "true";
			
			request.data = variables;
			request.method = URLRequestMethod.GET;
			
			poster.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			poster.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);			
			
			try{
				poster.load(request);
			}catch (e:Error) {
				dataError();
			}
		}
		
		
		private function dataPosted(e:Event = null):void
		{
			recordedVideo = false;
			
			resetTimeOut();
			
			//last post successful have autoPost check for any error files
			autoPost.check();
			
			removeChild(page4);
			page4.insertion.removeEventListener(Event.ENTER_FRAME, flashCursor);
			page4.btnRestart.removeEventListener(MouseEvent.MOUSE_DOWN, restartPressed);
			
			page5 = new pThanks(); //lib clip
			addChild(page5);
			cq.moveToTop();
			page5.alpha = 0;
			TweenMax.to(page5, 1, { alpha:1, onComplete:fadeThanks } );			
		}
		
		
		private function fadeThanks():void
		{
			TweenMax.to(page5, 2, { alpha:0, delay:3, onComplete:startOver } );
		}
		
		
		private function startOver():void
		{
			removeChild(page5);
			init();
		}
		
		
		/**
		 * Writes to a local file if the web service is not available
		 * @param	e
		 */
		private function dataError(e:IOErrorEvent = null):void
		{
			recordedVideo = false;
			
			var saveOb:Object = new Object();
			
			saveOb.id = userGUID;
			saveOb.email = page4.theEmail.text; 
			saveOb.phone = page4.theMobile.text;
			saveOb.country = countryCombo.getSelection();
			saveOb.optin = release.optIn.currentFrame == 1 ? "false" : "true";
			
			airFile.writeData(saveOb, "c:/intelgirls20/", userGUID);
			
			dataPosted();
		}
		
		
		/**
		 * Show the restart dialog
		 * @param	e
		 */
		private function restartPressed(e:MouseEvent):void
		{
			resetTimeOut();
			
			restartDialog.alpha = 0;
			addChild(restartDialog);
			TweenMax.to(restartDialog, .5, { alpha:1 } );
			restartDialog.btnOK.addEventListener(MouseEvent.MOUSE_DOWN, restartConfirmed, false, 0, true);
			restartDialog.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, restartCanceled, false, 0, true);
		}
		
		
		private function restartConfirmed(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			page3.btn.removeEventListener(MouseEvent.MOUSE_DOWN, stopRecording);
			if(vidStream){
				vidStream.close();
				vidStream.attachCamera(null);
				vidStream.attachAudio(null);
				vidTimer.stop();
			}
			
			if (recordedVideo) {				
				//user recorded a video but restarted before the form data saved
				//delete the video file the made - userGUID.flv				
				airFile.deleteFile("c:/Program Files/Adobe/Flash Media Server 4.5/applications/intel/streams/g20/", userGUID + ".flv");
				recordedVideo = false;
			}
			init();
		}
		
		
		private function restartCanceled(e:MouseEvent):void
		{
			TweenMax.to(restartDialog, .5, { alpha:0, onComplete:killRestart } );
			restartDialog.btnOK.removeEventListener(MouseEvent.MOUSE_DOWN, restartConfirmed);
			restartDialog.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, restartCanceled);
		}
		
		
		private function killRestart():void
		{
			removeChild(restartDialog);
		}
		
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		private function resetTimeOut():void
		{
			timeOut.reset();
			timeOut.start();
		}
		
		
		private function appTimedOut(e:TimerEvent):void
		{			
			if (recordedVideo) {
				//user recorded a video but walked away before the form data saved
				//delete the video file they made - userGUID.flv				
				airFile.deleteFile("c:/Program Files/Adobe/Flash Media Server 4.5/applications/intel/streams/g20/", userGUID + ".flv");
			}
			if (contains(restartDialog)) {
				removeChild(restartDialog);
				restartDialog.btnOK.removeEventListener(MouseEvent.MOUSE_DOWN, restartConfirmed);
				restartDialog.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, restartCanceled);
			}
			didTimeOut = true;
			playIntroVideo();
		}
		
	}
	
}