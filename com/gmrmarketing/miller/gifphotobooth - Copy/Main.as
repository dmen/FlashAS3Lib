package com.gmrmarketing.miller.gifphotobooth
{	
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.ui.Mouse;
	import flash.display.*;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var ageGate:AgeGate;
		private var takePhoto:TakePhoto;
		private var review:Review;
		private var email:Email;
		private var thanks:Thanks;
		
		private var mainContainer:Sprite;
		private var dripContainer:Sprite;
		private var cornerContainer:Sprite;
		
		private var cc:CornerQuit;
		private var ageToggle:CornerQuit;
		private var ageEnabled:Boolean;
		private var tim:TimeoutHelper;
		
		private var drips:Drips;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
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
			
			email = new Email();
			email.container = mainContainer;
			
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
			tim.init(60000);
			tim.addEventListener(TimeoutHelper.TIMED_OUT, doReset);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
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
		}
		
		private function showAgeGate(e:Event):void
		{
			intro.removeEventListener(Intro.BEGIN, showAgeGate);
			tim.startMonitoring();
			
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
			drips.bg = takePhoto.bg;
		}
		
		
		private function hideIntro(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOWING, hideIntro);
			intro.hide();
			ageGate.hide();
		}
		
		
		private function showReview(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.COMPLETE, showReview);
			
			review.show(takePhoto.video);//array of bitmapData's
			review.addEventListener(Review.RETAKE, retakePhotos, false, 0, true);
			review.addEventListener(Review.NEXT, showEmail, false, 0, true);
			drips.bg = review.bg;
		}
		
		
		private function retakePhotos(e:Event):void
		{
			review.removeEventListener(Review.RETAKE, retakePhotos);
			review.removeEventListener(Review.NEXT, showEmail);
			review.hide();
			ageGateComplete();
		}
		
		
		private function showEmail(e:Event):void
		{
			review.removeEventListener(Review.RETAKE, retakePhotos);
			review.removeEventListener(Review.NEXT, showEmail);
			
			email.addEventListener(Email.SHOWING, hideReview, false, 0, true);
			email.addEventListener(Email.COMPLETE, showThanks, false, 0, true);
			email.show();
			drips.bg = email.bg;
		}
		
		
		private function hideReview(e:Event):void
		{
			email.removeEventListener(Email.SHOWING, hideReview);
			review.hide();
		}
		
		
		private function showThanks(e:Event):void
		{
			email.removeEventListener(Email.COMPLETE, showThanks);
			thanks.addEventListener(Thanks.COMPLETE, finish, false, 0, true);
			
			var o:Object = email.data; //email, phone, opt1, opt2, opt3 keys
			if(ageEnabled){
				o.dob = ageGate.dob;
			}else {
				o.dob = ageGate.defaultDOB;//1900-01-01
			}
			
			thanks.show(takePhoto.video, o);
			drips.bg = thanks.bg;
		}
		
		
		private function finish(e:Event):void
		{
			tim.stopMonitoring();
			
			thanks.removeEventListener(Thanks.COMPLETE, finish);
			email.hide();
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
		
		
		private function hideThanks(e:Event):void
		{
			intro.removeEventListener(Intro.SHOWING, hideThanks);
			thanks.hide();
		}
		
		
		private function doReset(e:Event = null):void
		{
			tim.stopMonitoring();
			
			ageGate.removeEventListener(AgeGate.COMPLETE, ageGateComplete);
			ageGate.hide();
			takePhoto.removeEventListener(TakePhoto.SHOWING, hideIntro);
			takePhoto.removeEventListener(TakePhoto.COMPLETE, showReview);
			takePhoto.hide();
			review.removeEventListener(Review.RETAKE, retakePhotos);
			review.removeEventListener(Review.NEXT, showEmail);
			review.hide();
			email.removeEventListener(Email.SHOWING, hideReview);
			email.removeEventListener(Email.COMPLETE, showThanks);
			email.hide();
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