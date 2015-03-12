package com.gmrmarketing.jimbeam.devilscut
{
	import fl.data.SimpleDataProvider;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	//import fl.data.DataProvider;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.events.*;
	import com.gmrmarketing.jimbeam.devilscut.TextOptions;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Validator;
	import com.gmrmarketing.utilities.Spinner;
	import flash.utils.getTimer;
	import com.gmrmarketing.utilities.SharedObjectWrapper;
	import com.gmrmarketing.jimbeam.devilscut.Dialog;
	import com.gmrmarketing.jimbeam.devilscut.Recap;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.ui.Mouse;
	
	
	public class Main extends MovieClip
	{
		private var intro:MovieClip;
		private var page2:MovieClip;
		private var pageSweeps:MovieClip; //new 9/15/11 - MardiGras Sweeps
		private var page3:MovieClip;
		
		private var fire:MovieClip;
		private var fireMask:MovieClip;
		
		private var pactText:TextOptions;
		
		private var updateTextTimer:Timer;
		
		private var monthSpinner:Spinner;
		private var daySpinner:Spinner;
		private var yearSpinner:Spinner;
		
		private var smokeOne:MovieClip;
		
		private var bottomFire:MovieClip;
		
		private var months:Array;
		private var days:Array;
		private var years:Array;
		
		private var so:SharedObjectWrapper;
		//the current user data
		private var userData:Object;
		
		private var dialog:Dialog;
		private var recap:Recap;
		
		private var isSweeps:Boolean = false;
		
		private var cq:CornerQuit;
		
		
		
		public function Main()
		{	
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
stage.scaleMode = StageScaleMode.EXACT_FIT;
Mouse.hide();

			pactText = new TextOptions();
			dialog = new Dialog(this);
			
			months = new Array("JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER");
			days = new Array();
			for (var i:int = 1; i < 32; i++) {
				days.push(String(i));
			}
			var cur:Date = new Date();
			years = new Array();
			for (i = cur.getFullYear(); i > 1910; i--) {
				years.push(String(i));
			}				
			
			monthSpinner = new Spinner();
			monthSpinner.setChoices(months);
			
			daySpinner = new Spinner();
			daySpinner.setChoices(days);
			
			yearSpinner = new Spinner();
			yearSpinner.setChoices(years);
			
			fire = new theFire();
			fire.width = 788;
			fire.height = 1044;
			fire.stop();
			fire.x = -10;
			fire.y = -10;
			//fire.cacheAsBitmap = true;
			//fire.cacheAsBitmapMatrix = new Matrix();
			
			fireMask = new theFireMask();			
			fireMask.width = 788;
			fireMask.height = 1044;
			fireMask.stop();
			fireMask.x = -10;
			fireMask.y = -10;
			fireMask.cacheAsBitmap = true;
			//fireMask.cacheAsBitmapMatrix = new Matrix();
			
			intro = new theIntro(); //lib clips
			page2 = new p2();
			pageSweeps = new mardiForm();
			page3 = new p3();
			
			//intro.cacheAsBitmap = true;
			//intro.cacheAsBitmapMatrix = new Matrix();
			page2.cacheAsBitmap = true;
			//page2.cacheAsBitmapMatrix = new Matrix();
			//page3.cacheAsBitmap = true;
			//page3.cacheAsBitmapMatrix = new Matrix();
			
			smokeOne = new smoke1();
			//smokeOne.cacheAsBitmap = true;
			//smokeOne.cacheAsBitmapMatrix = new Matrix();
			
			bottomFire = new botFire();
			bottomFire.x = 0;
			bottomFire.y = 1024;
			bottomFire.stop();
			
			//formTimer = new Timer(1000, 1);
			//formTimer.addEventListener(TimerEvent.TIMER, formSubmitted, false, 0, true);
			
			//calls updateMainText() every 1/2 sec so the name updates as the user types
			updateTextTimer = new Timer(500);
			updateTextTimer.addEventListener(TimerEvent.TIMER, updateMainText, false, 0, true);
			
			so = new SharedObjectWrapper();			
			userData = new Object();
			
			cq = new CornerQuit();
			cq.init(this, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, showRecap, false, 0, true);
			recap = new Recap();
			
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);			
		}
		
		
		private function init(e:Event = null):void
		{
			trace("init");
			intro.removeEventListener(MouseEvent.CLICK, init);
			removeEventListener(Event.ADDED_TO_STAGE, init);			
			
			pactText.randomize();
			
			if (contains(intro)) {
				removeChild(intro);
			}
			
			intro.boldNew.alpha = 0;
			intro.btnStart.alpha = 0;
			intro.btnStart.mouseEnabled = false;
			
			addChild(intro);
			cq.moveToTop();
			
			intro.unleash.cacheAsBitmap = true;
			intro.unleash.alpha = 0;			
			
			monthSpinner.show(intro, 159, 590);
			daySpinner.show(intro, 319, 590);
			yearSpinner.show(intro, 479, 590);
			monthSpinner.reset();
			daySpinner.reset();
			yearSpinner.reset();
			
			userData.mobile = "";
			userData.inSweeps = false;
			userData.birthDate = "";
			
			intro.btnSubmit.visible = true;
			intro.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, checkBirthDate, false, 0, true);
		}
		
		private function showRecap(e:Event):void
		{
			recap.show(this);
		}
		
		private function checkBirthDate(e:MouseEvent):void
		{
			var today:Date = new Date();
			var bDay:Date = new Date(parseInt(yearSpinner.getStringChoice()), monthSpinner.getIndexChoice(), parseInt(daySpinner.getStringChoice()));
			
			var yrs:int = today.getFullYear() - bDay.getFullYear();
			
			if (today.getMonth() < bDay.getMonth() || (today.getMonth() == bDay.getMonth() && bDay.getDay() < today.getDay())) {
				yrs--;
			}
			
			if (yrs < 21) {
				monthSpinner.disable();
				daySpinner.disable();
				yearSpinner.disable();
				//TweenMax.to(intro.sorry, 1, { alpha:1, onComplete:startOver } );
				dialog.show("Sorry, you must be 21 or older to sign the contract.", init);
			}else {
				doP15();
				userData.birthDate = String(bDay.getMonth() + 1) + "-" + String(bDay.getDay()) + "-" + String(bDay.getFullYear());
			}
		}
		
		
		/*
		private function startOver():void
		{
			intro.addEventListener(MouseEvent.CLICK, init, false, 0, true);
		}
		*/
		
		
		private function doP15():void
		{
			monthSpinner.hide();
			daySpinner.hide();
			yearSpinner.hide();
			
			intro.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, checkBirthDate);
			intro.btnSubmit.visible = false;			
			
			intro.btnStart.mouseEnabled = true;
			intro.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, doP2, false, 0, true);
			
			TweenMax.to(intro.btnStart, 2, { alpha:1 } );
			TweenMax.to(intro.boldNew, 2, { alpha:1 } );
			TweenMax.to(intro.unleash, 2, { alpha:1, delay:1.5 } );
		}
		
		
		
		
		private function doP2(e:MouseEvent):void
		{
			intro.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, doP2);
			
			page2.alpha = 0;				
			
			userData.inSweeps = false;
			
			userData.s1 = pactText.getString();
			userData.s2 = pactText.getString();		
			userData.s3 = pactText.getString();

			page2.t1.htmlText = "<ul><li>" + userData.s1 + "\n</li><li>" + userData.s2 + "\n</li><li>" + userData.s3 + "</li></ul>";
			//page2.t1s.htmlText = "<ul><li>" + userData.s1 + "</li><br/><li>" + userData.s2 + "</li><br/><li>" + userData.s3 + "</li></ul>";
			
			page2.theName.text = "";
			page2.theEmail.text = "";			
			
			updateMainText();
			
			addChild(page2);			
			
			page2.btnMardiGras.visible = isSweeps == true ? true : false;			
			
			page2.smoker.mouseEnabled = false;
			page2.optIn.gotoAndStop(1); //reset check
			TweenMax.to(page2, .5, { alpha:1, onComplete:removeIntro } );
		}
		
	
		/**
		 * Shows the Page 2 form
		 */
		private function removeIntro():void
		{	
			removeChild(intro);
			intro.unleash.mask = null;
			
			//cache bottomFire
			bottomFire.visible = false;
			addChild(bottomFire);
			bottomFire.addEventListener("bottomFireDone", bottomFireStopCache, false, 0, true);
			bottomFire.play();
			
			page2.btnPress.addEventListener(MouseEvent.MOUSE_DOWN, startFormSubmit, false, 0, true);
			
			if(isSweeps){
				page2.btnMardiGras.addEventListener(MouseEvent.MOUSE_DOWN, showSweepsForm, false, 0, true);
			}
			
			//opt in
			page2.optIn.addEventListener(MouseEvent.MOUSE_DOWN, optInClicked, false, 0, true);
			
			updateTextTimer.start();
		}
		
		
		/**
		 * Called from clicking hot chick at upper right
		 * @param	e
		 */
		private function showSweepsForm(e:MouseEvent):void
		{
			addChild(pageSweeps);			
			
			if (page2.theName.text != "") {
				pageSweeps.theName.text = page2.theName.text;
			}else {
				pageSweeps.theName.text = "";
			}
			if (page2.theEmail.text != "") {
				pageSweeps.theEmail.text = page2.theEmail.text;
			}else {
				pageSweeps.theEmail.text = "";
			}
			if (userData.mobile != "") {
				pageSweeps.thePhone.text = userData.mobile;
			}else {
				pageSweeps.thePhone.text = "";
			}
			if (page2.optIn.currentFrame == 1) {
				pageSweeps.formCheck.alpha = 0;
			}else {
				pageSweeps.formCheck.alpha = 1;
			}
			
			pageSweeps.alpha = 0;
			TweenMax.to(pageSweeps, 1, { alpha:1 } );
			
			pageSweeps.thePhone.restrict = "0-9-.";
			pageSweeps.theName.restrict = "a-zA-Z ";
			
			pageSweeps.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelSweeps, false, 0, true);
			pageSweeps.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, submitSweeps, false, 0, true);
		}
		
		
		private function cancelSweeps(e:MouseEvent = null):void
		{
			userData.inSweeps = false;			
			
			pageSweeps.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelSweeps);
			pageSweeps.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submitSweeps);
			
			TweenMax.to(pageSweeps, 1, { alpha:0, onComplete:killSweeps } );
		}
		
		private function killSweeps():void
		{
			removeChild(pageSweeps);
		}
		
		
		private function submitSweeps(e:MouseEvent):void
		{
			var n:String = pageSweeps.theName.text;
			var na:Array = n.split(" ");
			
			if (na.length < 2) {
				dialog.show("Please enter a valid first and last name");
				return;
			}
			
			if (!Validator.isValidEmail(pageSweeps.theEmail.text)) {
				dialog.show("Please enter a valid email address");
				return;
			}
			
			if (!Validator.isValidPhoneNumber(pageSweeps.thePhone.text)) {
				dialog.show("Please enter a valid phone number with area code");
				return;
			}
			
			dialog.show("Thank you for entering");
			
			page2.theName.text = pageSweeps.theName.text;
			page2.theEmail.text = pageSweeps.theEmail.text;			
			userData.mobile = pageSweeps.thePhone.text;
			userData.inSweeps = true;
			
			pageSweeps.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelSweeps);
			pageSweeps.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submitSweeps);
			
			TweenMax.to(pageSweeps, 1, { alpha:0, onComplete:killSweeps } );
		}
		
		
		private function bottomFireStopCache(e:Event):void
		{
			bottomFire.removeEventListener("bottomFireDone", bottomFireStopCache);
			bottomFire.gotoAndStop(1);
			removeChild(bottomFire);
			bottomFire.visible = true;
		}		
		
		
		private function optInClicked(e:MouseEvent):void
		{
			if (page2.optIn.currentFrame == 1) {
				page2.optIn.gotoAndStop(2);
			}else {
				page2.optIn.gotoAndStop(1);
			}
		}
		
		
		/**
		 * Called by timer so the name updates as the user types
		 * @param	e
		 */
		private function updateMainText(e:TimerEvent = null):void
		{			
			var showText:String;		
			if (page2.theName.text == "") {
				showText = "NAME";
			}else {
				showText = page2.theName.text
			};
			
			var s:String = "You, <font color='#990000'>" + showText.toUpperCase() + "</font>, will in turn UNLEASH YOUR SPIRIT tonight. Suggestions include:";
			
			page2.mainText.htmlText = s;			
		}
		
		
		
		private function startFormSubmit(e:MouseEvent):void
		{
			var n:String = page2.theName.text;
			var na:Array = n.split(" ");
			
			if (na.length < 2) {
				dialog.show("Please enter a valid first and last name");
				//page2.errorName.alpha = 1;
				//TweenMax.to(page2.errorName, 1, { alpha:0, delay:1 } );
				return;
			}
			
			if(page2.theEmail.text != ""){
				if (!Validator.isValidEmail(page2.theEmail.text)) {
					dialog.show("If entering email, please use a valid address");
					//page2.errorEmail.alpha = 1;
					//TweenMax.to(page2.errorEmail, 1, { alpha:0, delay:1 } );
					return;
				}
			}
			
			page2.optIn.removeEventListener(MouseEvent.MOUSE_DOWN, optInClicked);			
			page2.btnPress.removeEventListener(MouseEvent.MOUSE_DOWN, startFormSubmit);
			
			page2.smoker.gotoAndPlay(2);
			page2.smoker.addEventListener("smokerDone", formSubmitted, false, 0, true)
			//formTimer.start();
			//TweenMax.to(page2.btnPress, 1, { scaleX:1.1, scaleY:1.1 } );
		}
		
		
		/**
		 * Called by timer when the submit button has been pressed for two seconds
		 * @param	e
		 */
		private function formSubmitted(e:Event):void
		{
			page2.smoker.gotoAndStop(1);
			page2.smoker.removeEventListener("smokerDone", formSubmitted);
				
			//formTimer.reset();
			updateTextTimer.reset();			
			
			//page2.btnPress.removeEventListener(MouseEvent.MOUSE_UP, endFormSubmit);
			
			addChild(page3);
			addChild(fireMask);
			fireMask.addEventListener("fireComplete", startSmoke, false, 0, true);
			
			page3.mask = fireMask;
			
			addChild(fire);
			
			fire.play();
			fireMask.play();
		}
		
		
		/**
		 * Called by clicking on page3 at the end of the interaction
		 * @param	e
		 */
		private function restart(e:MouseEvent):void
		{
			TweenMax.killAll();
			page3.removeEventListener(MouseEvent.CLICK, restart);
			smokeOne.gotoAndStop(1);
			fireMask.gotoAndStop(1);
			fire.gotoAndStop(1);
			removeChild(smokeOne);
			removeChild(page3);
			removeChild(fireMask);
			bottomFire.stop();
			removeChild(bottomFire);
			page3.mask = null;
			init();
		}
		
		
		
		/**
		 * Called when the fire transition is complete
		 * @param	e
		 */
		private function startSmoke(e:Event):void
		{
			fireMask.removeEventListener("fireComplete", startSmoke);
			page2.btnPress.scaleX = page2.btnPress.scaleY = 1;
			removeChild(page2);
			removeChild(fire);			
			
			page3.addEventListener(MouseEvent.CLICK, restart, false, 0, true);
			
			smokeOne.alpha = .7;			
			addChild(smokeOne);
			smokeOne.mouseEnabled = false;
			
			bottomFire.y = 644;
			bottomFire.alpha = 0;
			addChild(bottomFire);
			bottomFire.play();
			bottomFire.mouseEnabled = false;
			TweenMax.to(bottomFire, .5, { alpha:1} );

			smokeOne.x = 250;
			smokeOne.y = 850;
			
			userData.name = page2.theName.text;
			userData.email = page2.theEmail.text;
			userData.optin = page2.optIn.currentFrame == 2 ? 1 : 0;			
			sendData();
			
			tweenSmoke();
		}		
		
		
		private function tweenSmoke():void
		{
			TweenMax.to(smokeOne, 30, { y:-830, ease:Linear.easeNone,  onComplete:resetSmoke} );			
		}
		
		
		private function resetSmoke():void
		{			
			smokeOne.x = -400 + Math.random() * 750;			
			smokeOne.y = 850;
			tweenSmoke();
		}
		
		
		/**
		 * Called from startSmoke once the fire transition is over		
		 */
		private function sendData():void
		{
			var request:URLRequest = new URLRequest("http://dservices.mangoapi.com/devilscut/capture.php?r=" + String(getTimer()) );
			
			var vars:URLVariables = new URLVariables();
			vars.thename = userData.name;
			vars.theemail = userData.email;
			vars.birthdate = userData.birthDate;
			vars.mobile = userData.mobile;
			vars.insweeps = userData.inSweeps == true ? "true" : "false";
			vars.optin = userData.optin;			
			vars.s1 = userData.s1;
			vars.s2 = userData.s2;
			vars.s3 = userData.s3;
			request.data = vars;
			request.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, sendError, false, 0, true);			
			lo.addEventListener(Event.COMPLETE, saveDone, false, 0, true);			
			
			try{
				lo.load(request);
			}catch (e:Error) {				
				sendError();
			}			
		}
		
		
		private function sendError(e:IOErrorEvent = null):void
		{			
			saveUserLocal();
		}
		
		
		private function saveDone(e:Event):void
		{
			var success:String = e.target.data; //true or false
			if (success == "false") {
				saveUserLocal();
			}
		}
		
		
		private function saveUserLocal():void
		{
			//trace("saving local",userData.name);
			//so.addObject(userData);
		}
		
	}
	
}