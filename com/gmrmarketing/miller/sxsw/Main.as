package com.gmrmarketing.miller.sxsw
{	
	import com.facebook.graph.Facebook;
	import com.sagecollective.utilities.TimeoutHelper;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import com.gmrmarketing.miller.sxsw.*;
	import com.gmrmarketing.miller.sxsw.Facebook;
	import flash.events.Event;
	import flash.display.StageDisplayState;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	import flash.utils.Timer;
	
	public class Main extends MovieClip
	{
		private var timeoutHelper:TimeoutHelper;
		
		private var orbs:Orbs;
		
		private var intro:Intro;
		private var ageGate:AgeGate;
		private var preview:Preview;
		private var share:Share;
		private var terms:Terms;
		private var dialog:Dialog;
		private var facebook:Facebook;
		private var webServices:WebServices;
		private var localImage:LocalImage;
		
		private var cq:CornerQuit;
		
		private var process:NativeProcess;
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;
		
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			Mouse.hide();
			
			orbs = new Orbs();
			
			intro = new Intro();
			ageGate = new AgeGate();
			preview = new Preview();
			share = new Share();
			terms = new Terms();
			dialog = new Dialog();
			webServices = new WebServices();
			localImage = new LocalImage();
			
			facebook = new Facebook();
			facebook.addEventListener(Facebook.LOGIN_FAIL, facebookLoginFailed, false, 0, true);
			facebook.addEventListener(Facebook.PHOTO_POSTED, facebookPosted, false, 0, true);
			facebook.addEventListener(Facebook.PHOTO_POSTING, facebookPosting, false, 0, true);
			
			timeoutHelper = TimeoutHelper.getInstance();
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, appTimedOut, false, 0, true);			
			timeoutHelper.init();
			timeoutHelper.startMonitoring();
			
			//for opening and closing the onscreen keyboard
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			
			showKeyboard();
			hideKeyboard();
			
			orbs.show(this);
			orbs.animate(true);
			
			cq = new CornerQuit(false);	
			cq.init(this, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApp, false, 0, true);
			
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		private function init(e:Event = null, showAgeSign:int = 0):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			timeoutHelper.buttonClicked();
			
			hideKeyboard();
			
			previewAdded(); //hides gate and removes listeners
			preview.removeEventListener(Preview.PREVIEW_ADDED, previewAdded);
			preview.removeEventListener(Preview.PHOTO_TAKEN, showShare);
			preview.hide();
			share.removeEventListener(Share.SHARE_ADDED, shareAdded);
			share.hide();
			
			intro.show(this);
			intro.addEventListener(Intro.INTRO_CLICKED, showAgeGate, false, 0, true);
			
			switch(showAgeSign) {
				case 1:
					dialog.show(this, "SORRY", "In order to participate in the Miller Genuine Draft experience, you must be at least 21 years old.");
					break;
				case 2:
					dialog.show(this, "DONE!", "Thanks for using the Miller Genuine Draft poster maker.");
			}
		}
		
		
		private function appTimedOut(e:Event):void
		{
			init();
		}
		
		
		private function showAgeGate(e:Event):void
		{
			intro.fade();
			ageGate.show(this);
			cq.moveToTop();
			ageGate.addEventListener(AgeGate.GATE_ADDED, gateAdded, false, 0, true);
			ageGate.addEventListener(AgeGate.AGE_VERIFIED, ageVerified, false, 0, true);
			ageGate.addEventListener(AgeGate.UNDER_AGE, underAge, false, 0, true);
			ageGate.addEventListener(AgeGate.TERMS_CLICKED, showTerms, false, 0, true);
		}
		
		
		private function gateAdded(e:Event):void
		{
			intro.hide();
		}
		
		
		private function underAge(e:Event):void
		{
			init(null, 1); //1 causes the underage dialog to appear
		}
		
		
		private function showTerms(e:Event):void
		{
			timeoutHelper.buttonClicked();
			terms.show(this);			
		}
		
		
		private function ageVerified(e:Event):void
		{
			ageGate.fade();
			
			preview.addEventListener(Preview.PREVIEW_ADDED, previewAdded, false, 0, true);
			preview.addEventListener(Preview.PHOTO_TAKEN, showShare, false, 0, true);
			preview.show(this);
			cq.moveToTop();
		}
		
		
		private function previewAdded(e:Event = null):void
		{
			terms.hide();
			ageGate.hide();
			ageGate.removeEventListener(AgeGate.GATE_ADDED, gateAdded);
			ageGate.removeEventListener(AgeGate.AGE_VERIFIED, ageVerified);
			ageGate.removeEventListener(AgeGate.UNDER_AGE, underAge);
			ageGate.removeEventListener(AgeGate.TERMS_CLICKED, showTerms);
		}
		
		
		/**
		 * Called when PHOTO_TAKEN is dispatched from Preview
		 * @param	e
		 */
		private function showShare(e:Event):void
		{
			preview.fade();
			preview.removeEventListener(Preview.PREVIEW_ADDED, previewAdded);
			preview.removeEventListener(Preview.PHOTO_TAKEN, showShare);
			
			share.show(this, preview.getPoster());
			
			
			
			share.addEventListener(Share.SHARE_ADDED, shareAdded, false, 0, true);
			share.addEventListener(Share.SHARE_FACEBOOK, facebookLogin, false, 0, true);			
			share.addEventListener(Share.SHARE_FINISHED, shareFinished, false, 0, true);
			share.addEventListener(Share.SHARE_EMAIL_ERROR, badEmail, false, 0, true);
			share.addEventListener(Share.SHARE_EMAIL, goodEmail, false, 0, true);
			share.addEventListener(Share.SHARE_SPIN, goodSpin, false, 0, true);
			share.addEventListener(Share.SHARE_SPIN_ERROR, badSpin, false, 0, true);
			share.addEventListener(Share.SHOW_KBD, showKeyboard, false, 0, true);
			share.addEventListener(Share.HIDE_KBD, hideKeyboard, false, 0, true);
			
			cq.moveToTop();
		}
		
		
		private function shareAdded(e:Event):void
		{
			preview.hide();			
			share.removeEventListener(Share.SHARE_ADDED, shareAdded);			
			
			//compress the original - ready it for saving with localImage.save
			localImage.compress(preview.getOriginal());
		}
		
		
		private function badEmail(e:Event):void
		{
			timeoutHelper.buttonClicked();
			dialog.show(this, "ERROR", "From and To must be valid email addresses.");
		}
		
		
		/**
		 * Called from pressing the submit button in the email dialog when all fields are valid
		 * @param	e
		 */
		private function goodEmail(e:Event):void
		{
			timeoutHelper.buttonClicked();
			//first save the poster
			webServices.addEventListener(WebServices.IMAGE_SAVED, sendEmail, false, 0, true);
			webServices.addEventListener(WebServices.IMAGE_SAVE_ERROR, saveError, false, 0, true);
			var tempTimer:Timer = new Timer(200, 1);
			tempTimer.addEventListener(TimerEvent.TIMER, beginSave, false, 0, true);
			tempTimer.start();
			share.showSaveIndicator();
		}
		
		
		private function beginSave(e:TimerEvent):void
		{
			timeoutHelper.buttonClicked();
			webServices.savePoster(preview.getPoster());
		}
		
		
		private function saveError(e:Event):void
		{
			timeoutHelper.buttonClicked();
			dialog.show(this, "ERROR", "An error occured while saving your poster. Please try again");
		}
		
		
		/**
		 * Called once the web services has saved the image
		 * has to wait for the save to complete
		 * @param	e
		 */
		private function sendEmail(e:Event):void
		{
			timeoutHelper.buttonClicked();
			webServices.removeEventListener(WebServices.IMAGE_SAVED, sendEmail);
			webServices.removeEventListener(WebServices.IMAGE_SAVE_ERROR, saveError);
			
			var emails:Object = share.getEmailData(); //object with from and to properties
			webServices.addEventListener(WebServices.EMAIL_SENT, emailComplete, false, 0, true);
			webServices.addEventListener(WebServices.EMAIL_ERROR, emailError, false, 0, true);
			webServices.emailSubmit(emails.from, emails.to);
			
			//save the image with the name as the id given from the web service
			localImage.save(webServices.getImageID());
			
			share.showEmailIndicator();
		}
		
		
		private function emailComplete(e:Event):void
		{
			timeoutHelper.buttonClicked();
			//turn off email sending inidicator
			share.hideEmailIndicator();
			share.hideEmail();
			
			dialog.show(this, "COMPLETE", "Your poster has been shared");			
			
			webServices.removeEventListener(WebServices.IMAGE_SAVED, sendEmail);
			webServices.removeEventListener(WebServices.IMAGE_SAVE_ERROR, saveError);
			webServices.removeEventListener(WebServices.EMAIL_SENT, emailComplete);
			webServices.removeEventListener(WebServices.EMAIL_ERROR, emailError);
		}
		
		private function emailError(e:Event):void
		{
			timeoutHelper.buttonClicked();
			share.hideEmailIndicator();
			dialog.show(this, "ERROR", "An Error occured while sending your email. Please try again.");
		}
		
		
		/**
		 * Called from pressing the submit button in the spin dialog when all fields are valid
		 * @param	e
		 */
		private function goodSpin(e:Event):void
		{
			timeoutHelper.buttonClicked();			
			
			webServices.addEventListener(WebServices.IMAGE_SAVED, sendSpin, false, 0, true);
			webServices.addEventListener(WebServices.IMAGE_SAVE_ERROR, saveError, false, 0, true);
			
			var tempTimer:Timer = new Timer(200, 1);
			tempTimer.addEventListener(TimerEvent.TIMER, beginSpin, false, 0, true);
			tempTimer.start();
			
			share.showSpinIndicator();
		}
		
		private function beginSpin(e:TimerEvent):void
		{
			timeoutHelper.buttonClicked();
			webServices.savePoster(preview.getPoster());
		}
		
		private function sendSpin(e:Event):void
		{
			var spinData:Object = share.getSpinData();
			webServices.addEventListener(WebServices.SPIN_SAVED, spinComplete, false, 0, true);
			webServices.addEventListener(WebServices.SPIN_ERROR, spinError, false, 0, true);
			webServices.spinSubmit(spinData.name, spinData.email, spinData.phone);
		}
		
		private function badSpin(e:Event):void
		{
			timeoutHelper.buttonClicked();
			dialog.show(this, "ERROR", "Please complete the form using your first and last name, and a valid phone number and email.");
		}
		private function spinComplete(e:Event):void
		{
			share.hideSpinIndicator();
			share.hideSpin();
			
			timeoutHelper.buttonClicked();
			
			dialog.show(this, "COMPLETE", "You've been entered for a chance to be featured in SPIN Magazine");
			
			webServices.removeEventListener(WebServices.SPIN_SAVED, spinComplete);
			webServices.removeEventListener(WebServices.SPIN_ERROR, spinError);
			webServices.removeEventListener(WebServices.IMAGE_SAVED, sendSpin);
			webServices.removeEventListener(WebServices.IMAGE_SAVE_ERROR, saveError);
		}
		
		private function spinError(e:Event):void
		{
			webServices.removeEventListener(WebServices.SPIN_SAVED, spinComplete);
			webServices.removeEventListener(WebServices.SPIN_ERROR, spinError);
			webServices.removeEventListener(WebServices.IMAGE_SAVED, sendSpin);
			webServices.removeEventListener(WebServices.IMAGE_SAVE_ERROR, saveError);
			share.hideSpinIndicator();
			timeoutHelper.buttonClicked();
			dialog.show(this, "ERROR", "And error occured while submitting your entry. Please try again.");
		}
		
		
		private function facebookLogin(e:Event):void
		{
			timeoutHelper.buttonClicked();
			showKeyboard();			
			facebook.init(preview.getPoster());//sends full size card
		}
		
		private function facebookLoginFailed(e:Event):void
		{
			timeoutHelper.buttonClicked();
			dialog.show(this, "ERROR", "Facebook login failed.");
		}
		
		//Called on PHOTO_POSTING event from facebook
		private function facebookPosting(e:Event):void
		{			
			timeoutHelper.buttonClicked();
			hideKeyboard();
			dialog.show(this, "PROCESSING","Your poster is uploading, please wait a moment...", true);
		}
		
		private function facebookPosted(e:Event):void
		{
			timeoutHelper.buttonClicked();
			hideKeyboard();
			dialog.show(this, "SUCCESS", "Your poster has uploaded to Facebook!");
			
			//save the image with the name as the id given from the web service
			localImage.save(webServices.getImageID());
		}
		
		
		
		private function shareFinished(e:Event):void
		{
			share.removeEventListener(Share.SHARE_FACEBOOK, facebookLogin);			
			share.removeEventListener(Share.SHARE_FINISHED, shareFinished);
			share.removeEventListener(Share.SHARE_EMAIL_ERROR, badEmail);
			share.removeEventListener(Share.SHARE_EMAIL, goodEmail);
			share.removeEventListener(Share.SHARE_SPIN, goodSpin);
			share.removeEventListener(Share.SHARE_SPIN_ERROR, badSpin);
			share.removeEventListener(Share.SHOW_KBD, showKeyboard);
			share.removeEventListener(Share.HIDE_KBD, hideKeyboard);
			
			init(null, 2); //2 causes the thanks for participating dialog to appear
		}
		
		
		private function showKeyboard(e:Event = null):void
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
		
		
		private function hideKeyboard(e:Event = null):void
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