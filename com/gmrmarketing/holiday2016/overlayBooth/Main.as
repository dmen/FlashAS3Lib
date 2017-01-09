package com.gmrmarketing.holiday2016.overlayBooth
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.desktop.NativeApplication;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.queue.Queue;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.TimeoutHelper;
	//import com.gmrmarketing.particles.Snow;
	import com.gmrmarketing.particles.SnowParticles;
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		
		//private var snowContainer:Sprite;
		private var snowData:BitmapData;
		private var snowDisplay:Bitmap;
		private var snow:SnowParticles;
		
		private var cornerContainer:Sprite;
		private var intro:Intro;
		private var takePhoto:TakePhoto;
		private var whiteFlash:MovieClip;		
		private var userPhoto:BitmapData;
		private var email:Email;
		private var thanks:Thanks;
		private var queue:Queue;
		private var cq:CornerQuit;
		private var tmh:TimeoutHelper;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			Mouse.hide();

			//snowContainer = new Sprite();
			snowData = new BitmapData(1920, 1080, true, 0x00000000);
			snowDisplay = new Bitmap(snowData);
			
			mainContainer = new Sprite();			
			cornerContainer = new Sprite();
			//addChild(snowContainer);
			addChild(snowDisplay);
			addChild(mainContainer);			
			addChild(cornerContainer);			
			
			intro = new Intro();
			intro.container = mainContainer;
			
			takePhoto = new TakePhoto();
			takePhoto.container = mainContainer;
			
			whiteFlash = new mcWhite();
			
			email = new Email();
			email.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
			queue = new Queue();
			queue.fileName = "gmrholiday2016";
			queue.service = new HubbleServiceExtender();						
			queue.start();
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ur");
			cq.customLoc(1, new Point(885, 0));
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			snow = new SnowParticles([new part(),new part2(), new part3(), new part4(), new part5()], snowData, 3000);
			
			tmh = TimeoutHelper.getInstance();
			tmh.addEventListener(TimeoutHelper.TIMED_OUT, doReset, false, 0, true);
			tmh.init(120000);//2min			
			
			intro.addEventListener(Intro.COMPLETE, hideIntro, false, 0, true);
			intro.show();
		}
		
		
		/**
		 * called on Intro.COMPLETE event 
		 * ie when someone touches the screen
		 * starts timeout monitoring
		 * @param	e
		 */
		private function hideIntro(e:Event):void
		{	
			intro.removeEventListener(Intro.COMPLETE, hideIntro);
			intro.addEventListener(Intro.HIDDEN, showPhoto, false, 0, true);
			intro.hide();
		}
		
		
		private function showPhoto(e:Event):void
		{
			intro.removeEventListener(Intro.HIDDEN, showPhoto);
			
			takePhoto.addEventListener(TakePhoto.SHOW_WHITE, showWhite, false, 0, true);
			takePhoto.addEventListener(TakePhoto.COMPLETE, hideTakePhoto, false, 0, true);
			takePhoto.show();
			
			tmh.startMonitoring();
		}
		
		
		private function showWhite(e:Event):void
		{
			if (!mainContainer.contains(whiteFlash)){
				mainContainer.addChild(whiteFlash);
			}
			
			whiteFlash.alpha = 1;
			TweenMax.to(whiteFlash, 1, {alpha:0, onComplete:removeWhite});
			
			takePhoto.showReview();
		}
		
		
		private function removeWhite():void
		{
			if (mainContainer.contains(whiteFlash)){
				mainContainer.removeChild(whiteFlash);
			}
		}
		
		
		private function hideTakePhoto(e:Event):void
		{
			userPhoto = takePhoto.pic;
			
			takePhoto.removeEventListener(TakePhoto.SHOW_WHITE, showWhite);
			takePhoto.removeEventListener(TakePhoto.COMPLETE, hideTakePhoto);
			takePhoto.addEventListener(TakePhoto.HIDDEN, showEmail, false, 0, true);
			takePhoto.hide();			
		}
		
		
		private function showEmail(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.HIDDEN, showEmail);
			
			email.addEventListener(Email.COMPLETE, hideEmail, false, 0, true);
			email.addEventListener(Email.CANCELED, doReset, false, 0, true);
			email.show();
		}
		
		
		private function hideEmail(e:Event):void
		{
			email.removeEventListener(Email.COMPLETE, hideEmail);
			email.removeEventListener(Email.CANCELED, doReset);
			email.addEventListener(Email.HIDDEN, showThanks, false, 0, true);
			email.hide();
		}
		
		
		private function showThanks(e:Event):void
		{
			email.removeEventListener(Email.HIDDEN, showThanks);
			
			thanks.addEventListener(Thanks.COMPLETE, doRestart, false, 0, true);
			thanks.show(userPhoto);
		}
		
		
		private function doRestart(e:Event):void
		{
			thanks.removeEventListener(Thanks.COMPLETE, doRestart);
			thanks.addEventListener(Thanks.HIDDEN, restartComplete, false, 0, true);
			thanks.hide();
			
			var o:Object = new Object();
			o.image = thanks.imageString;
			o.email = email.theEmail;
			
			queue.add(o);
		}
		
		
		private function restartComplete(e:Event):void
		{
			thanks.removeEventListener(Thanks.HIDDEN, restartComplete);
			
			intro.addEventListener(Intro.COMPLETE, hideIntro, false, 0, true);
			intro.show();
			
			tmh.stopMonitoring();//don't monitor the intro
		}
		
		/**
		 * called when the timeoutHelper timesout
		 * @param	e
		 */
		private function doReset(e:Event):void
		{	
			thanks.removeEventListener(Thanks.COMPLETE, doRestart);
			thanks.removeEventListener(Thanks.HIDDEN, restartComplete);
			thanks.kill();
			
			email.removeEventListener(Email.HIDDEN, showThanks);
			email.removeEventListener(Email.COMPLETE, hideEmail);
			email.removeEventListener(Email.CANCELED, doReset);
			email.kill();
			
			takePhoto.removeEventListener(TakePhoto.HIDDEN, showEmail);
			takePhoto.removeEventListener(TakePhoto.SHOW_WHITE, showWhite);
			takePhoto.removeEventListener(TakePhoto.COMPLETE, hideTakePhoto);
			takePhoto.kill();
			
			intro.removeEventListener(Intro.HIDDEN, showPhoto);
			intro.addEventListener(Intro.COMPLETE, hideIntro, false, 0, true);
			intro.show();
			
			tmh.stopMonitoring();//don't monitor the intro
		}
		
		
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}