package com.gmrmarketing.miller.gifphotobooth
{	
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.ui.Mouse;
	import flash.display.*;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.LoggerAIR;
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var ageGate:AgeGate;
		private var takePhoto:TakePhoto;
		private var review:Review;
		private var receive:Receive;
		private var emp:EmailPhone;
		private var emReview:EmailReview;
		private var thanks:Thanks;
		
		private var mainContainer:Sprite;
		private var dripContainer:Sprite;
		private var cornerContainer:Sprite;
		
		private var cc:CornerQuit;
		private var ageToggle:CornerQuit;
		private var ageEnabled:Boolean;
		private var tim:TimeoutHelper;
		
		private var drips:Drips;
		private var log:Logger;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();
			
			mainContainer = new Sprite();
			dripContainer = new Sprite();
			cornerContainer = new Sprite();
			addChild(mainContainer);
			addChild(dripContainer);
			addChild(cornerContainer);

			intro = new Intro();
			intro.container = mainContainer;
			
			ageGate = new AgeGate();
			ageGate.container = mainContainer;
			
			takePhoto = new TakePhoto();
			takePhoto.container = mainContainer;
			
			review = new Review();
			review.container = mainContainer;
			
			receive = new Receive();
			receive.container = mainContainer;
			
			emp = new EmailPhone();
			emp.container = mainContainer;
			
			emReview = new EmailReview();
			emReview.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
			drips = new Drips(dripContainer);
			
			cc = new CornerQuit();
			cc.init(cornerContainer, "ul");
			cc.addEventListener(CornerQuit.CORNER_QUIT, quitApp);
			
			ageToggle = new CornerQuit();
			ageToggle.init(cornerContainer, "lr");
			ageToggle.addEventListener(CornerQuit.CORNER_QUIT, toggleAgeGate);
			
			ageEnabled = true;
			
			tim = TimeoutHelper.getInstance();
			tim.init(90000);
			tim.addEventListener(TimeoutHelper.TIMED_OUT, doReset);
			
			log = Logger.getInstance();
			log.logger = new LoggerAIR();//will make kiosklog.txt log on the desktop
			log.log("APPLICATION START");
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		/**
		 * callback on upperRight CornerQuit - four taps
		 * toggles visibility of the age gate on the intro screen
		 * @param	e
		 */
		private function toggleAgeGate(e:Event):void
		{
			ageEnabled = !ageEnabled;
			doReset();
		}
		
		
		private function init(e:Event = null):void
		{			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			intro.addEventListener(Intro.BEGIN, showAgeGate);
			intro.show();
			
			drips.regSpeed();
			drips.image = "can";
			drips.bg = intro.bg;			
		}
		
		
		private function showAgeGate(e:Event):void
		{
			intro.removeEventListener(Intro.BEGIN, showAgeGate);
			tim.startMonitoring();
			
			drips.pause();
			
			ageGate.show();
			ageGate.addEventListener(AgeGate.COMPLETE, ageGateComplete);
		}
		
		
		private function ageGateComplete(e:Event = null):void
		{
			ageGate.removeEventListener(AgeGate.COMPLETE, ageGateComplete);
			tim.startMonitoring();
			
			takePhoto.addEventListener(TakePhoto.SHOWING, hideIntro);
			takePhoto.addEventListener(TakePhoto.COMPLETE, showReview);
			takePhoto.show();
			
			drips.fastSpeed();
			drips.image = "bottle";
			drips.bg = takePhoto.bg;			
		}
		
		
		private function hideIntro(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOWING, hideIntro);
			intro.hide();
			review.hide();
			ageGate.hide();
		}
		
		
		private function showReview(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.COMPLETE, showReview);
			
			review.addEventListener(Review.SHOWING, hideTakePhoto, false, 0, true);
			review.show(takePhoto.video);//array of bitmapData's
			review.addEventListener(Review.RETAKE, retakePhotos, false, 0, true);
			review.addEventListener(Review.NEXT, showReceive, false, 0, true);
			drips.bg = review.bg;
		}
		
		private function hideTakePhoto(e:Event):void
		{
			review.removeEventListener(Review.SHOWING, hideTakePhoto);
			takePhoto.hide();
		}
		
		private function retakePhotos(e:Event):void
		{
			review.removeEventListener(Review.SHOWING, hideTakePhoto);
			review.removeEventListener(Review.RETAKE, retakePhotos);
			review.removeEventListener(Review.NEXT, showReceive);
			//review.hide();
			ageGateComplete();
		}
		
		
		private function showReceive(e:Event):void
		{			
			review.removeEventListener(Review.RETAKE, retakePhotos);
			review.removeEventListener(Review.NEXT, showReceive);
			review.removeEventListener(Review.SHOWING, hideTakePhoto);
			
			receive.addEventListener(Receive.SHOWING, hideReview, false, 0, true);
			receive.addEventListener(Receive.COMPLETE, showReceiveChoice, false, 0, true);
			receive.show();
			drips.bg = receive.bg;
			drips.regSpeed();
		}
		
		
		private function hideReview(e:Event):void
		{
			receive.removeEventListener(Receive.SHOWING, hideReview);
			review.hide();
			
			emp.hide();//in case of back button in emp
			emp.removeEventListener(EmailPhone.SHOWING, hideReceive);
			emp.removeEventListener(EmailPhone.BACK, showReceive);
			emp.removeEventListener(EmailPhone.COMPLETE, empComplete);
		}

		
		/**
		 * called when receive is complete - ie when used picked email,text or both
		 * @param	e
		 */
		private function showReceiveChoice(e:Event = null):void
		{
			emReview.removeEventListener(EmailReview.ADD_PERSON, showReceiveChoice);
			receive.removeEventListener(Receive.SHOWING, hideReview);
			receive.removeEventListener(Receive.COMPLETE, showReceiveChoice);
			
			var c:Object = receive.choice;//object with email,text,both keys - one will be true
			
			var choice:String;
			if (c.email) {
				choice = "email";
			}else if (c.text) {
				choice = "text";
			}else {
				choice = "both";
			}
			
			emp.addEventListener(EmailPhone.SHOWING, hideReceive, false, 0, true);
			emp.addEventListener(EmailPhone.BACK, showReceive, false, 0, true);
			emp.addEventListener(EmailPhone.COMPLETE, empComplete, false, 0, true);
			emp.show(choice);
			drips.bg = emp.bg;
		}
		
		
		private function hideReceive(e:Event):void
		{
			emp.removeEventListener(EmailPhone.SHOWING, hideReceive);
			receive.hide();
			emReview.hide();
		}
		
		
		private function empComplete(e:Event):void
		{
			emp.removeEventListener(EmailPhone.SHOWING, hideReceive);
			emp.removeEventListener(EmailPhone.BACK, showReceive);
			emp.removeEventListener(EmailPhone.COMPLETE, empComplete);
			
			emReview.addEventListener(EmailReview.SHOWING, hideEmp, false, 0, true);
			emReview.addEventListener(EmailReview.ADD_PERSON, showReceiveChoice, false, 0, true);
			emReview.addEventListener(EmailReview.COMPLETE, showThanks, false, 0, true);
			emReview.show(emp.data);
			drips.bg = emReview.bg;
		}
		
		
		private function hideEmp(e:Event):void
		{
			emReview.removeEventListener(EmailReview.SHOWING, hideEmp);
			emp.hide();
		}
		
		
		private function reviewAdd(e:Event):void
		{
			emReview.removeEventListener(EmailReview.ADD_PERSON, reviewAdd);
			emReview.addEventListener(EmailReview.SHOWING, hideEmp);
			emReview.addEventListener(EmailReview.COMPLETE, showThanks);
			showReceiveChoice();
		}
		
		
		private function showThanks(e:Event):void
		{			
			emReview.removeEventListener(EmailReview.COMPLETE, showThanks);
			thanks.addEventListener(Thanks.COMPLETE, finish, false, 0, true);
			
			var data:Array = emp.data; //array of objects
			
			var o:Object = { };//for sending to thanks
			o.email = "";
			o.phone = "";			
			o.opt1 = data[0].opt;
			o.opt2 = false;
			o.opt3 = false;
			o.opt4 = false;
			o.opt5 = false;
			
			if (data.length > 1) {
				o.opt2 = data[1].opt
			}
			if (data.length > 2) {
				o.opt3 = data[2].opt
			}
			if (data.length > 3) {
				o.opt4 = data[3].opt
			}
			if (data.length > 4) {
				o.opt4 = data[4].opt
			}
			
			var emails:Array = [];
			var phones:Array = [];
			
			for (var i:int = 0; i < data.length; i++) {
				if (data[i].email != "") {
					emails.push(data[i].email);
				}
				if (data[i].phone != "") {
					phones.push(data[i].phone);
				}
			}
			
			if (emails.length > 0) {
				o.email = emails.shift();
			}
			while(emails.length) {
				o.email += "," + emails.shift();
			}
			
			if (phones.length > 0) {
				o.phone = phones.shift();
			}
			while (phones.length) {
				o.phone += "," + phones.shift();
			}
			
			if(ageEnabled){
				o.dob = ageGate.dob;
			}else {
				o.dob = ageGate.defaultDOB;//1900-01-01
			}
			
			tim.buttonClicked();
			
			drips.pause();
			thanks.show(takePhoto.video, o);			
		}
		
		
		/**
		 * callback for COMPLETE event from Thanks
		 * @param	e
		 */
		private function finish(e:Event):void
		{
			tim.stopMonitoring();
			
			thanks.removeEventListener(Thanks.COMPLETE, finish);
			emReview.hide();			
			
			if(ageEnabled){
				intro.addEventListener(Intro.BEGIN, showAgeGate);
				intro.removeEventListener(Intro.BEGIN, ageGateComplete);
			}else {
				intro.addEventListener(Intro.BEGIN, ageGateComplete);
				intro.removeEventListener(Intro.BEGIN, showAgeGate);
			}
			emp.clear();
			
			drips.pause();
			drips.regSpeed();
			drips.image = "can";
			drips.bg = intro.bg;	
			
			intro.addEventListener(Intro.SHOWING, hideThanks, false, 0, true);
			intro.show();			
		}
		
		
		private function hideThanks(e:Event):void
		{
			intro.removeEventListener(Intro.SHOWING, hideThanks);
			thanks.hide();
		}
		
		
		/**
		 * callback on TimeoutHelper - tim timeout
		 * also called from toggleAgeGate()
		 * @param	e
		 */
		private function doReset(e:Event = null):void
		{
			tim.stopMonitoring();
			
			ageGate.removeEventListener(AgeGate.COMPLETE, ageGateComplete);
			ageGate.hide();
			takePhoto.removeEventListener(TakePhoto.SHOWING, hideIntro);
			takePhoto.removeEventListener(TakePhoto.COMPLETE, showReview);
			takePhoto.hide();
			review.removeEventListener(Review.RETAKE, retakePhotos);
			
			review.hide();
			emp.removeEventListener(EmailPhone.SHOWING, hideReceive);
			emp.removeEventListener(EmailPhone.BACK, showReceive);
			emp.removeEventListener(EmailPhone.COMPLETE, empComplete);
			emp.clear();			
			emp.hide();
			
			emReview.removeEventListener(EmailReview.SHOWING, hideEmp);
			emReview.removeEventListener(EmailReview.ADD_PERSON, showReceiveChoice);
			emReview.removeEventListener(EmailReview.COMPLETE, showThanks);
			emReview.hide();
			
			thanks.removeEventListener(Thanks.COMPLETE, finish);
			thanks.hide();
			drips.pause();
			
			if(ageEnabled){
				intro.addEventListener(Intro.BEGIN, showAgeGate);
				intro.removeEventListener(Intro.BEGIN, ageGateComplete);
			}else {
				intro.addEventListener(Intro.BEGIN, ageGateComplete);
				intro.removeEventListener(Intro.BEGIN, showAgeGate);
			}
			
			intro.addEventListener(Intro.SHOWING, hideThanks, false, 0, true);
			intro.show();
		}
		
		
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
	}
}