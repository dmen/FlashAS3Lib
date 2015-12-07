package com.gmrmarketing.holiday2015
{	
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.display.*;	
	import flash.events.*;
	import flash.geom.*;	
	import flash.ui.Mouse;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.queue.Queue;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		
		private var bg:Background;
		private var intro:Intro;
		private var take:Take;
		private var email:Email;
		private var thanks:Thanks;
		private var buttonBar:ButtonBar;
		private var whiteFlash:WhiteFlash;
		private var userImage:Bitmap;
		
		private var queue:Queue;
		
		private var cc:CornerQuit;
		private var ee:CornerQuit;//for easter egg
		private var cornerContainer:Sprite;
		
		private var tim:TimeoutHelper;
		
		private var originalUserImage:BitmapData; //image obtained in countComplete()
		
		
		public function Main()
		{			
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			queue = new Queue();
			queue.fileName = "holiday2015";
			queue.service = new HubbleServiceExtender();
			queue.start();
			
			mainContainer = new Sprite();
			cornerContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(cornerContainer);
			
			bg = new Background();
			bg.container = mainContainer;			
			
			intro = new Intro();
			intro.container = mainContainer;
			
			take = new Take();
			take.container = mainContainer;
			
			email = new Email();
			email.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
			buttonBar = new ButtonBar();
			buttonBar.container = mainContainer;
			
			whiteFlash = new WhiteFlash();
			whiteFlash.container = mainContainer;
			
			cc = new CornerQuit();
			cc.init(cornerContainer, "ul");
			cc.addEventListener(CornerQuit.CORNER_QUIT, quitApplication);
			
			ee = new CornerQuit();
			ee.init(cornerContainer, "ur");
			ee.addEventListener(CornerQuit.CORNER_QUIT, toggleEaster);
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, doReset, false, 0, true);
			tim.init(60000);
			
			bg.show();
			
			init();
		}
		
		
		private function init():void
		{
			tim.stopMonitoring();
			
			bg.showBlack();
			
			intro.addEventListener(Intro.COMPLETE, hideIntro, false, 0, true);
			intro.show();
		}
		
		
		private function hideIntro(e:Event):void
		{
			intro.removeEventListener(Intro.COMPLETE, hideIntro);
			intro.addEventListener(Intro.HIDDEN, showTake, false, 0, true);
			intro.hide();
		}
		
		
		private function showTake(e:Event):void
		{			
			tim.startMonitoring();
			
			intro.removeEventListener(Intro.HIDDEN, showTake);
			
			bg.hideBlack();	
			
			take.show();
			take.addEventListener(Take.OVERLAY_CHANGED, updateUserPic, false, 0, true);
			
			buttonBar.show();
			buttonBar.addEventListener(ButtonBar.TAKE, startCountdown, false, 0, true);
		}
		
		private function updateUserPic(e:Event):void
		{
			if (userImage) {
				var bmd:BitmapData = new BitmapData(870, 865);				
				var pics:Array = take.pic; //user image,overlay				
				bmd.copyPixels(originalUserImage, new Rectangle(0, 0, 870, 865), new Point(0, 0));	
				bmd.copyPixels(pics[1], new Rectangle(0, 0, 870, 865), new Point(0, 0), null, null, true);
				userImage.bitmapData = bmd;
			}
		}
		
		
		private function startCountdown(e:Event):void
		{	
			tim.buttonClicked();
			buttonBar.removeEventListener(ButtonBar.TAKE, startCountdown);
			buttonBar.addEventListener(ButtonBar.COUNT, countComplete, false, 0, true);
			buttonBar.startCountdown();
		}
		
		
		private function countComplete(e:Event):void
		{
			buttonBar.removeEventListener(ButtonBar.COUNT, countComplete);
			whiteFlash.show();
			
			var pics:Array = take.pic; //user image,overlay
			originalUserImage = pics[0];
			
			var composed:BitmapData = new BitmapData(870, 865);
			composed.copyPixels(pics[0], new Rectangle(0, 0, 870, 865), new Point(0, 0));	
			composed.copyPixels(pics[1], new Rectangle(0, 0, 870, 865), new Point(0, 0), null, null, true);	
			
			userImage = new Bitmap(composed);
			userImage.x = 537;
			userImage.y = 57;
			userImage.alpha = 0;
			mainContainer.addChild(userImage);
			
			TweenMax.to(userImage, .5, { alpha:1 } );
			
			buttonBar.addEventListener(ButtonBar.RETAKE, doRetake, false, 0, true);			
			buttonBar.addEventListener(ButtonBar.CONT, doContinue, false, 0, true);
			buttonBar.showRetake();
		}
		
		
		private function doRetake(e:Event):void
		{
			tim.buttonClicked();
			TweenMax.to(userImage, .5, { alpha:0, onComplete:killUser } );
			
			buttonBar.removeEventListener(ButtonBar.RETAKE, doRetake);
			buttonBar.removeEventListener(ButtonBar.CONT, doContinue);
			buttonBar.reset();
			buttonBar.addEventListener(ButtonBar.TAKE, startCountdown, false, 0, true);
		}
		
		
		private function killUser():void
		{
			mainContainer.removeChild(userImage);
		}
		
		
		private function doContinue(e:Event):void
		{
			tim.buttonClicked();
			buttonBar.removeEventListener(ButtonBar.RETAKE, doRetake);
			buttonBar.removeEventListener(ButtonBar.CONT, doContinue);
			
			TweenMax.to(userImage, .5, { alpha:0, onComplete:killUser } );
			
			take.removeEventListener(Take.OVERLAY_CHANGED, updateUserPic);
			take.addEventListener(Take.HIDDEN, showEmail, false, 0, true);			
			take.hide();
		}
		
		
		private function showEmail(e:Event):void
		{
			take.removeEventListener(Take.HIDDEN, showEmail);
			
			buttonBar.addEventListener(ButtonBar.EMAIL, validateEmail, false, 0, true);
			buttonBar.addEventListener(ButtonBar.CANCEL, doReset, false, 0, true);
			buttonBar.showEmail();
			
			email.addEventListener(Email.COMPLETE, emailComplete, false, 0, true);
			email.show();
		}
		
		
		private function validateEmail(e:Event):void
		{
			tim.buttonClicked();
			email.checkEmail();
		}
		
		
		private function emailComplete(e:Event):void
		{
			buttonBar.removeEventListener(ButtonBar.EMAIL, validateEmail);
			buttonBar.removeEventListener(ButtonBar.CANCEL, doReset);
			email.removeEventListener(Email.COMPLETE, emailComplete);
			
			email.addEventListener(Email.HIDDEN, showThanks, false, 0, true);
			email.hide();
		}
		
		
		private function showThanks(e:Event):void
		{		
			tim.buttonClicked();
			email.removeEventListener(Email.HIDDEN, showThanks);
			
			thanks.addEventListener(Thanks.COMPLETE, restart, false, 0, true);
			thanks.show(userImage.bitmapData);//encodes to B64	
			
			buttonBar.hideEmail();
		}
		
		
		private function doReset(e:Event):void
		{			
			intro.removeEventListener(Intro.COMPLETE, hideIntro);
			intro.removeEventListener(Intro.HIDDEN, showTake);
			intro.hide();
			
			take.removeEventListener(Take.HIDDEN, showEmail);
			take.removeEventListener(Take.OVERLAY_CHANGED, updateUserPic);
			take.hide();
			
			email.removeEventListener(Email.COMPLETE, emailComplete);
			email.removeEventListener(Email.HIDDEN, showThanks);
			email.hide();
			
			thanks.removeEventListener(Thanks.COMPLETE, restart);
			thanks.hide();
			
			buttonBar.removeEventListener(ButtonBar.TAKE, startCountdown);
			buttonBar.removeEventListener(ButtonBar.COUNT, countComplete);
			buttonBar.removeEventListener(ButtonBar.EMAIL, validateEmail);
			buttonBar.removeEventListener(ButtonBar.CANCEL, doReset);
			buttonBar.removeEventListener(ButtonBar.RETAKE, doRetake);
			buttonBar.removeEventListener(ButtonBar.CONT, doContinue);
			buttonBar.hide();
			
			if (userImage) {
				if (mainContainer.contains(userImage)) {
					mainContainer.removeChild(userImage);
				}
			}
			
			TweenMax.delayedCall(4, init);//wait for hide/hiddens to run in all screens
		}
		
		
		private function restart(e:Event):void
		{			
			queue.add( { image:thanks.imageString, email:email.theEmail } );
			
			thanks.removeEventListener(Thanks.COMPLETE, restart);
			thanks.hide();
			
			init();
		}
		
		private function toggleEaster(e:Event):void
		{
			take.egg();
		}
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}