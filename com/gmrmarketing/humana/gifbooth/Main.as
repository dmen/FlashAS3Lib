package com.gmrmarketing.humana.gifbooth
{	
	import com.gmrmarketing.morris.GoodItem;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.ui.Mouse;
	import flash.display.*;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	
	public class Main extends MovieClip
	{
		private var intro:Intro;		
		private var takePhoto:TakePhoto;
		private var review:Review;
		private var receive:Receive;
		private var emp:EmailPhone;
		private var emReview:EmailReview;
		private var thanks:Thanks;
		private var config:ConfigDialog;
		
		private var mainContainer:Sprite;
		private var dialogContainer:Sprite;
		private var cornerContainer:Sprite;
		
		private var cc:CornerQuit;
		private var configCC:CornerQuit;
		private var tim:TimeoutHelper;
		
		private var print:Print;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();
			
			mainContainer = new Sprite();
			dialogContainer = new Sprite();
			cornerContainer = new Sprite();
			addChild(mainContainer);			
			addChild(cornerContainer);
			addChild(dialogContainer);

			intro = new Intro();
			intro.container = mainContainer;
			
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
			
			config = new ConfigDialog();
			config.container = dialogContainer;
			
			cc = new CornerQuit();
			cc.init(cornerContainer, "ul");
			cc.addEventListener(CornerQuit.CORNER_QUIT, quitApp);
			
			configCC = new CornerQuit();
			configCC.init(cornerContainer, "ur");
			configCC.addEventListener(CornerQuit.CORNER_QUIT, showConfigDialog);
			
			tim = TimeoutHelper.getInstance();
			tim.init(90000);
			tim.addEventListener(TimeoutHelper.TIMED_OUT, doReset);
			
			print = new Print();
			
			init();
		}
	
		
		private function init(e:Event = null):void
		{	
			intro.addEventListener(Intro.BEGIN, showTakePhoto, false, 0, true);
			intro.show();
		}
	
		
		private function showTakePhoto(e:Event = null):void
		{
			intro.removeEventListener(Intro.BEGIN, showTakePhoto);
			intro.hide();
			
			takePhoto.addEventListener(TakePhoto.COMPLETE, showReview, false, 0, true);
			takePhoto.show(config.numSeconds, config.everyNth, config.maxFrames);
		}		
	
		
		private function showReview(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.COMPLETE, showReview);
			
			review.addEventListener(Review.SHOWING, hideTakePhoto, false, 0, true);
			review.show(takePhoto.video);//array of bitmapData's
			review.addEventListener(Review.RETAKE, retakePhotos, false, 0, true);
			review.addEventListener(Review.NEXT, showReceive, false, 0, true);
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
			review.hide();
			showTakePhoto();
		}
		
		
		private function showReceive(e:Event):void
		{			
			review.removeEventListener(Review.RETAKE, retakePhotos);
			review.removeEventListener(Review.NEXT, showReceive);
			review.removeEventListener(Review.SHOWING, hideTakePhoto);
			
			receive.addEventListener(Receive.SHOWING, hideReview, false, 0, true);
			receive.addEventListener(Receive.CANCEL, finish, false, 0, true);
			receive.addEventListener(Receive.COMPLETE, showReceiveChoice, false, 0, true);
			receive.show();
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
			receive.removeEventListener(Receive.CANCEL, finish);
			
			var c:Object = receive.choice;//email,text,print keys
			var s:String = ""
			if (c.email && c.text) {
				s = "both";
			}else if (c.email) {
				s = "email";
			}else if (c.text) {
				s = "text";
			}
			
			if (s == "") {
				//user selected print only
				showThanks();
			}else{			
				emp.addEventListener(EmailPhone.SHOWING, hideReceive, false, 0, true);
				emp.addEventListener(EmailPhone.BACK, showReceive, false, 0, true);
				emp.addEventListener(EmailPhone.COMPLETE, empComplete, false, 0, true);
				emp.show(s);
			}
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
		
		
		private function showThanks(e:Event = null):void
		{			
			emReview.removeEventListener(EmailReview.COMPLETE, showThanks);
			thanks.addEventListener(Thanks.COMPLETE, finish, false, 0, true);
			
			var data:Array = emp.data; //array of objects with email,phone,opt keys
			
			var o:Object = { };//for sending to thanks
			o.email = "";
			o.phone = "";
			o.printed = receive.choice.print;//true false - used by Hubble to call printAPI or not
			
			var emails:Array = [];
			var phones:Array = [];
			
			for (var i:int = 0; i < data.length; i++) {				
				if (data[i].email != "") {
					emails.push(data[i].email);
					if (data[i].opt) {
						o["opt" + String(emails.length)] = "true";//matches opt index with email index
					}
				}
				if (data[i].phone != "") {
					phones.push(data[i].phone);
				}
			}
			
			//turn arrays into comma separated lists
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
			
			tim.buttonClicked();
			
			if (o.email == "" && o.phone == "") {
				//print only
				o.email = "printOnly"
			}
			
			thanks.show(takePhoto.video, o);	//sends to Hubble
			tim.stopMonitoring();
			
			//print?
			if (o.printed) {
				print.doPrint(takePhoto.video);
			}
		}
		
		
		/**
		 * callback for COMPLETE event from Thanks
		 * @param	e
		 */
		private function finish(e:Event):void
		{
			tim.stopMonitoring();
			
			receive.removeEventListener(Receive.SHOWING, hideReview);
			receive.removeEventListener(Receive.COMPLETE, showReceiveChoice);
			receive.removeEventListener(Receive.CANCEL, finish);
			
			thanks.removeEventListener(Thanks.COMPLETE, finish);
			emReview.hide();			
			
			emp.clear();
			receive.clear();
			
			intro.addEventListener(Intro.SHOWING, hideThanks, false, 0, true);
			init();		
		}
		
		
		private function hideThanks(e:Event):void
		{
			intro.removeEventListener(Intro.SHOWING, hideThanks);
			receive.hide();//can get to finish from pressing cancel in receive
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
			
			//takePhoto.removeEventListener(TakePhoto.SHOWING, hideIntro);
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
			
			intro.addEventListener(Intro.SHOWING, hideThanks, false, 0, true);
			init();
		}
		
		
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		private function showConfigDialog(e:Event):void
		{
			config.show();
		}
		
	}
}