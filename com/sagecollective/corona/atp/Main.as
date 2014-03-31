/**
 * CONTROLLER
 */

package com.sagecollective.corona.atp
{	
	import com.sagecollective.utilities.CornerQuit;
	import com.sagecollective.utilities.VPlayer;
	import com.sagecollective.utilities.TimeoutHelper;
	import com.sagecollective.corona.atp.AmbientSound;
	import com.sagecollective.corona.atp.Terms;
	import flash.display.*;	
	import com.sagecollective.corona.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.system.fscommand;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	import com.greensock.TweenMax;
	import flash.utils.getDefinitionByName;	
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	
	public class Main extends MovieClip
	{
		private var ambience:AmbientSound;
		
		private var theClouds:Clouds;
		
		private var theIntro:Intro;
		private var theInstructions:Instructions;		
		private var admin:Stats;
		
		private var theIntroContainer:Sprite;
		private var theMainContainer:Sprite;		
		
		private var dialog:Dialog;
		private var globalClose:MovieClip;
		
		private var cornerAdmin:CornerQuit;
		private var cornerQuit:CornerQuit;
		private var thePrinter:PrintCard;		
		
		private var facebook:Facebook;
		private var email:Email;
		
		private var process:NativeProcess;
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;
		
		private var vPlayer:VPlayer;
		private var relaxResponsibly:MovieClip;
		
		private var timeoutHelper:TimeoutHelper;
		
		private var terms:Terms;
		
		private var facebookTimer:Timer;
		
		
		
		
		public function Main()
		{
			ambience = new AmbientSound();
			
			//FULL_SCREEN_INTERACTIVE required for keyboard input in AIR
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			
			Mouse.hide();
			
			dialog = new Dialog(this);
			
			globalClose = new globalCloseBtn(); //lib clip
			globalClose.x = 38;
			globalClose.y = 1000;			
			globalClose.addEventListener(MouseEvent.MOUSE_DOWN, closeClicked, false, 0, true);
			
			theIntroContainer = new Sprite();
			theMainContainer = new Sprite();	
			
			theIntro = new Intro(theIntroContainer);
			theIntro.addEventListener(Intro.INTERACTION_STARTED, statsStarted, false, 0, true);			
			
			theInstructions = new Instructions(theMainContainer);
			
			theClouds = new Clouds(this);			
			
			admin = new Stats(this);
			admin.addEventListener(Stats.STATS_CLOSED, statsClosed, false, 0, true);
			
			thePrinter = new PrintCard();
			thePrinter.addEventListener(PrintCard.PRINT_ERROR, printerError, false, 0, true);
			
			facebook = new Facebook();
			facebook.addEventListener(Facebook.LOGIN_FAIL, facebookLoginFailed, false, 0, true);
			facebook.addEventListener(Facebook.PHOTO_POSTED, facebookPosted, false, 0, true);
			facebook.addEventListener(Facebook.PHOTO_POSTING, facebookPosting, false, 0, true);
			
			email = new Email(this);
			//email.addEventListener
			
			terms = new Terms(); //terms and conditions / privacy policy
			
			//for opening and closing the onscreen keyboard
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			
			vPlayer = new VPlayer();
			vPlayer.showVideo(this);
			vPlayer.playVideo("waves.f4v");
			//vPlayer.addEventListener(VPlayer.STATUS_RECEIVED, gotVideoStatus, false, 0, true);
			vPlayer.addEventListener(VPlayer.CUE_RECEIVED, gotVideoCue, false, 0, true);
			
			cornerAdmin = new CornerQuit(false);//debug off
			cornerAdmin.init(this, "ul");
			cornerAdmin.customLoc(1, new Point(0,0));
			cornerAdmin.addEventListener(CornerQuit.CORNER_QUIT, showAdmin, false, 0, true);
			
			cornerQuit = new CornerQuit(false);//debug off
			cornerQuit.init(this, "ur");
			cornerQuit.customLoc(1, new Point(1770, 0));
			cornerQuit.addEventListener(CornerQuit.CORNER_QUIT, quitApp, false, 0, true);
			
			relaxResponsibly = new relax();
			relaxResponsibly.x = 1718;
			relaxResponsibly.y = 963;			
			
			timeoutHelper = TimeoutHelper.getInstance();
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, appTimedOut, false, 0, true);
			timeoutHelper.init();
			timeoutHelper.startMonitoring();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		
		private function init(e:Event = null):void
		{			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			facebook.closeWindow();
			
			hideKeyboard();
			
			theClouds.start();
			if(!contains(theIntroContainer)){
				addChild(theIntroContainer);
			}
			theIntro.addEventListener(Intro.AGE_VERIFIED, removeItems, false, 0, true);
			theIntro.addEventListener(Intro.SHOW_TERMS, showTerms, false, 0, true);
			if(!contains(globalClose)){
				addChild(globalClose);
			}
			if(!contains(relaxResponsibly)){
				addChild(relaxResponsibly);
				relaxResponsibly.addEventListener(MouseEvent.MOUSE_DOWN, cornerTerms, false, 0, true);
			}else {
				removeChild(relaxResponsibly);
				addChild(relaxResponsibly);
				relaxResponsibly.addEventListener(MouseEvent.MOUSE_DOWN, cornerTerms, false, 0, true);
			}
			theIntro.addLime();
			theIntro.addEventListener(Intro.RESET, introReset, false, 0, true);
		}
		
		
		private function gotVideoCue(E:Event):void
		{
			vPlayer.replay();
		}
		/*
		private function gotVideoStatus(e:Event):void
		{
			//loop
			if(vPlayer.getStatus() == "NetStream.Play.Stop"){
				vPlayer.playVideo("waves.f4v");
			}
		}
		*/
		
		private function introReset(e:Event):void
		{
			closeClicked();
		}
		
		private function hideDialog(e:Event):void
		{
			dialog.hide();
			hideKeyboard();
		}
		
		/**
		 * Called when age verified is dispatched by Intro
		 * Calls removeItems in Intro to clear the screen
		 * @param	e
		 */
		private function removeItems(e:Event):void
		{
			theIntro.removeEventListener(Intro.AGE_VERIFIED, removeItems);			
			theIntro.addEventListener(Intro.ITEMS_REMOVED, showInstructions, false, 0, true);
			theIntro.removeEventListener(Intro.RESET, introReset);
			theIntro.removeEventListener(Intro.SHOW_TERMS, showTerms);
			theIntro.removeItems();
		}
		
		//called by clicking the relax responsibly graphic at bottom right
		private function cornerTerms(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			showTerms();
		}
		private function showTerms(e:Event = null):void
		{
			//trace("showTerms", contains(theIntroContainer));
			if (contains(theIntroContainer)) {
				theIntro.removeAgeGateListener();
			}
			terms.show(this);
			terms.addEventListener(Terms.TERMS_MOVED, updateTimeout, false, 0, true);
			terms.addEventListener(Terms.TERMS_CLOSED, termsClosed, false, 0, true);
		}
		private function termsClosed(e:Event):void
		{
			if (contains(theIntroContainer)) {
				theIntro.addAgeGateListener();
			}
			terms.removeEventListener(Terms.TERMS_MOVED, updateTimeout);
			terms.removeEventListener(Terms.TERMS_CLOSED, termsClosed);
		}
		/**
		 * Called whenever the terms is scrolled
		 * @param	e
		 */
		private function updateTimeout(e:Event):void
		{
			timeoutHelper.buttonClicked();
		}
		
		/**
		 * Callback from the Intro removing items
		 * @param	e
		 */
		private function showInstructions(e:Event):void
		{
			theIntro.removeEventListener(Intro.ITEMS_REMOVED, showInstructions);			
			clearContainer(theIntroContainer);
			
			addChild(theMainContainer);
			
			theInstructions.addEventListener(Instructions.ITEMS_REMOVED, showPhotoIntro, false, 0, true);
			theInstructions.addEventListener(Instructions.RESET, doReset, false, 0, true);
			theInstructions.addEventListener(Instructions.PRINT_CARD, printCard, false, 0, true);
			theInstructions.addEventListener(Instructions.SHARE_FACEBOOK, facebookLogin, false, 0, true);
			theInstructions.addEventListener(Instructions.SHARE_EMAIL, showEmail, false, 0, true);
			theInstructions.addEventListener(Instructions.HIDE_DIALOG, hideDialog, false, 0, true);
			theInstructions.addEventListener(Instructions.SHARE_AGREE, shareError, false, 0, true);
			
			theInstructions.init(getStamp());			
			
			cornerAdmin.moveToTop();
			cornerQuit.moveToTop();
		}
		
		
		private function showPhotoIntro(e:Event):void
		{
			theInstructions.removeEventListener(Instructions.ITEMS_REMOVED, showPhotoIntro);
			theInstructions.removeEventListener(Instructions.RESET, doReset);
			theInstructions.removeEventListener(Instructions.PRINT_CARD, printCard);
			theInstructions.removeEventListener(Instructions.SHARE_FACEBOOK, facebookLogin);
			theInstructions.removeEventListener(Instructions.SHARE_EMAIL, showEmail);
			theInstructions.removeEventListener(Instructions.HIDE_DIALOG, hideDialog);
			theInstructions.removeEventListener(Instructions.SHARE_AGREE, shareError);
		}
		
		private function shareError(e:Event):void
		{
			dialog.show("You must check the box before sharing", null, false, 2000);
		}
		
		/**
		 * Clears the container of all items
		 * and removes the container from the display list
		 * @param	theContainer
		 */
		private function clearContainer(theContainer:DisplayObjectContainer):void
		{
			while (theContainer.numChildren) {
				theContainer.removeChildAt(0);
			}
			
			removeChild(theContainer);
		}
		
		
		/**
		 * This is called if the container object has removeItems() called 
		 * with reset true - when reset is true the container
		 * dispatches a reset event - that then calls this - which
		 * calls init() to restart the intro sequence
		 * @param	e
		 */
		private function doReset(e:Event):void
		{
			if (contains(theMainContainer)) {
				clearContainer(theMainContainer);
			}
			if (contains(globalClose)) {
				removeChild(globalClose);
			}
			terms.hide();
			
			init();
		}
		
		
		/**
		 * called by listener when the admin is closed
		 * @param	e
		 */
		private function statsClosed(e:Event):void
		{
			e.stopImmediatePropagation();
			closeClicked();
		}
		/**
		 * Called by clicking the global close button
		 * Calls the removeItems() method within the object to animate its items off screen
		 * calls removeItems() with reset=true so that a RESET is dispatched - this causes
		 * doReset() to be called above
		 * returns to the intro state
		 * 
		 * @param	e MOUSE_DOWN mouse event
		 */
		private function closeClicked(e:MouseEvent = null):void
		{			
			//prevent mouse event bubbling to the stage
			if(e){
				e.stopImmediatePropagation();
			}
			
			if (contains(theIntroContainer)) {
				theIntro.killTimeoutCards();
				theIntro.removeItems(true);				
			}
			
			if (contains(theMainContainer)) {
				theInstructions.removeItems(true);
				theInstructions.disposeCam();
			}
			terms.hide();
			
			timeoutHelper.buttonClicked();
			email.hide();
		}
		
		/**
		 * Called by listener on the TimeoutHelper class
		 * resets the app
		 * @param	e
		 */
		private function appTimedOut(e:Event):void
		{
			if (contains(theIntroContainer)) {			
				theIntro.timedOut();			
			}else {
				//if (contains(theMainContainer)) {
					//theInstructions.disposeCam();
				//}
				closeClicked();
			}
		}
		
		
		private function getStamp():BitmapData
		{
			if(admin.getStamp() && admin.getStamp() != ""){
				var libClass:Class = getDefinitionByName(admin.getStamp()) as Class;
				return new libClass() as BitmapData;
			}else {
				return new BitmapData(1, 1, true);
			}
		}
		
		/**
		 * Called when instructions dispatches a PRINT_CARD event from showSocial()
		 * ie - once the image has been accepted
		 * @param	e
		 */
		private function printCard(e:Event):void
		{
			statsPrinted();
			var card:Bitmap = theInstructions.getCard();
			//addChild(card);
			thePrinter.printContent(card.bitmapData);
		}
		
		
		/**
		 * Called by listener if a printer error occurs
		 * Event is dispatched from PrintCard.printError()
		 * @param	e Event
		 */
		private function printerError(e:Event):void
		{
			dialog.show("A printer error occured. Please check the printer");
		}
		
		
		/**
		 * Called by listener on instructions
		 * called when SHARE_FACEBOOK is dispatched from Instruction.shareOnFB()
		 * @param	e
		 */
		private function facebookLogin(e:Event):void
		{
			showKeyboard();			
			facebook.init(theInstructions.getCard(), admin.getLinks());//sends full size card
		}
		
		private function facebookLoginFailed(e:Event):void
		{
			//trace("login failed event");
			
			//dialog.show("Facebook login failed.", null, true);//just show continue
			theInstructions.enableFBButton();
			//hideKeyboard();
		}
		
		
		private function facebookPosting(e:Event):void
		{
			statsShared();
			hideKeyboard();
			
			facebookTimer = new Timer(5000);
			facebookTimer.addEventListener(TimerEvent.TIMER, waitForFacebook, false, 0, true);
			facebookTimer.start();
			
			dialog.show("Your postcard is uploading to Facebook, please wait a moment...", null, false, 0, true);//no continue - final true to show rotator
		}
		
		
		private function waitForFacebook(e:TimerEvent):void
		{
			timeoutHelper.buttonClicked();
		}
		
		
		private function facebookPosted(e:Event):void
		{
			facebookTimer.stop();
			facebookTimer.removeEventListener(TimerEvent.TIMER, waitForFacebook);
			dialog.show("Your postcard has successfully uploaded to Facebook!", null, true, 3000);//continue and auto hide after 3 seconds
			theInstructions.enableFBButton();
		}
		
		
		/**
		 * Called by listener on instructions
		 * called when SHARE_EMAIL is dispatched from Instructions.shareEmail()
		 * @param	e
		 */
		private function showEmail(e:Event):void
		{
			email.init(theInstructions.getCard(), admin.getVenue(), theIntro.getBirthdate());//send preview image & venue
			email.addEventListener(Email.EMAIL_CANCELED, emailCanceled, false, 0, true);
			//call cancel on send as well - as it clears listeners and resets email/social			
			email.addEventListener(Email.EMAIL_SENT, statsEmailed, false, 0, true);
			email.addEventListener(Email.ALL_EMAIL_SENT, emailsComplete, false, 0, true);
			theInstructions.hideSocial();
			showKeyboard();
		}
		
		
		private function emailCanceled(e:Event):void
		{
			email.removeEventListener(Email.EMAIL_CANCELED, emailCanceled);			
			email.removeEventListener(Email.EMAIL_SENT, statsEmailed);
			email.removeEventListener(Email.ALL_EMAIL_SENT, emailsComplete);
			
			theInstructions.showSocial();
			email.hide();
			hideKeyboard();
		}
		
		/**
		 * Called when all emails have completed sending
		 * @param	e
		 */
		private function emailsComplete(e:Event):void
		{
			email.removeEventListener(Email.EMAIL_CANCELED, emailCanceled);			
			email.removeEventListener(Email.EMAIL_SENT, statsEmailed);
			email.removeEventListener(Email.ALL_EMAIL_SENT, emailsComplete);
			theInstructions.showSocial();
			email.addEventListener(Email.SLOW_HIDE_FINISHED, killEmail, false, 0, true);
			email.hideSlow();
		}
		
		private function killEmail(e:Event):void
		{
			email.removeEventListener(Email.SLOW_HIDE_FINISHED, killEmail);
			email.hide();
			hideKeyboard();
		}
		
		/**
		 * Called by tapping four times at lower left
		 * 
		 * @param	e CORNER_QUIT Event
		 */
		private function showAdmin(e:Event):void
		{
			timeoutHelper.buttonClicked();
			admin.show();
		}
		
		
		/**
		 * Called by listener on Intro - event is sent from intro.addAgeGate()
		 */
		private function statsStarted(e:Event):void
		{
			admin.updateData("started");
		}
		//called from printCard()
		private function statsPrinted():void
		{
			admin.updateData("printed");
		}
		//called from facebookPosting()
		private function statsShared():void
		{
			admin.updateData("shared");
		}
		private function statsEmailed(e:Event):void
		{
			admin.updateData("emailed");
		}
		
		
		private function showKeyboard():void
		{
			try{
				if(NativeProcess.isSupported){				
					var file:File = File.desktopDirectory.resolvePath("showKB.exe");
					nativeProcessStartupInfo.executable = file;
					
					process = new NativeProcess();
					process.start(nativeProcessStartupInfo);
				}
			}catch (e:Error) {
				
			}
		}
		
		
		private function hideKeyboard():void
		{
			try{
				if(NativeProcess.isSupported){
					var file:File = File.desktopDirectory.resolvePath("hideKB.exe");
					nativeProcessStartupInfo.executable = file;
					
					process = new NativeProcess();
					process.start(nativeProcessStartupInfo);
				}
			}catch (e:Error) {
			
			}
		}
		
		
		private function quitApp(e:Event):void
		{			
			NativeApplication.nativeApplication.exit();
		}
	}
	
}