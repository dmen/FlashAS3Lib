package com.gmrmarketing.comcast.taylorswift.photobooth
{
	import com.greensock.TweenMax;
	import flash.display.*;
	import flash.events.Event;
	import flash.ui.*;	
	import com.gmrmarketing.particles.Dust;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var takePhoto:TakePhoto;
		private var print:Print;
		private var thanks:Thanks;
		private var mainContainer:Sprite;
		private var dustContainer:Sprite;
		private var queue:Queue;
		private var cq:CornerQuit;
		private var tim:TimeoutHelper;
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, doReset, false, 0, true);
			tim.init(60000);//1min			
			
			queue = new Queue();
			
			mainContainer = new Sprite();
			dustContainer = new Sprite();
			addChild(mainContainer);
			addChild(dustContainer);
			
			intro = new Intro();
			intro.container = mainContainer;
			
			takePhoto = new TakePhoto();
			takePhoto.container = mainContainer;
			
			print = new Print();
			print.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
			for(var i:int = 0; i < 150; i++){
				var d:Dust = new Dust();
				d.x = Math.random() * 1920;
				d.y = Math.random() * 1080;
				dustContainer.addChild(d);
			}
			
			cq = new CornerQuit();
			cq.init(dustContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApp, false, 0, true);
			
			init();
		}
		
		
		private function init():void
		{
			tim.stopMonitoring();
			intro.addEventListener(Intro.COMPLETE, introComplete);
			intro.show();
		}
		
		
		private function introComplete(e:Event):void
		{
			takePhoto.show();
			takePhoto.addEventListener(TakePhoto.SHOWING, hideIntro);
			takePhoto.addEventListener(TakePhoto.CANCEL, cancelPhoto);
			takePhoto.addEventListener(TakePhoto.PRINT, printPhoto);// showThanks);// printPhoto);
			
			tim.startMonitoring();
		}
		
		
		private function hideIntro(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOWING, hideIntro);
			intro.hide();
		}
		
		
		private function cancelPhoto(e:Event = null):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOWING, hideIntro);
			takePhoto.removeEventListener(TakePhoto.CANCEL, cancelPhoto);
			takePhoto.removeEventListener(TakePhoto.PRINT, printPhoto);// showThanks);// printPhoto);
			takePhoto.hide();
			init();
		}
		
		
		private function printPhoto(e:Event):void
		{
			var pics:Array = takePhoto.getPhotos();//three 750x750 BMD's
			
			print.addEventListener(Print.SHOWING, hideTakePhoto);
			print.addEventListener(Print.COMPLETE_EMAIL, showThanksEmail);
			print.addEventListener(Print.COMPLETE, showThanks);
			print.show(pics);
		}		
		
		
		private function hideTakePhoto(e:Event):void
		{
			print.removeEventListener(Print.SHOWING, hideTakePhoto);
			thanks.removeEventListener(Thanks.SHOWING, hideTakePhoto);
			takePhoto.hide();
		}
		
		
		private function showThanks(e:Event):void
		{
			var pics:Array = takePhoto.getPhotos();//three 750x750 BMD's
			
			print.removeEventListener(Print.COMPLETE, showThanks);
			print.removeEventListener(Print.COMPLETE_EMAIL, showThanksEmail);
			
			thanks.addEventListener(Thanks.SHOWING, hidePrint);
			//thanks.addEventListener(Thanks.SHOWING, hideTakePhoto);
			thanks.addEventListener(Thanks.COMPLETE, thanksComplete);	
			thanks.show(false);
		}
		
		
		private function showThanksEmail(e:Event):void
		{
			print.removeEventListener(Print.COMPLETE, showThanks);
			print.removeEventListener(Print.COMPLETE_EMAIL, showThanksEmail);						
			
			thanks.addEventListener(Thanks.SHOWING, hidePrint);
			thanks.show(true);
			
			TweenMax.delayedCall(1, processImage);//allow thanks to show
		}
		
		private function processImage():void
		{
			print.addEventListener(Print.PROCESS, processComplete);
			print.process();//get imageString from bmd
		}		
		private function processComplete(e:Event):void
		{			
			print.removeEventListener(Print.PROCESS, processComplete);
			thanks.addEventListener(Thanks.COMPLETE, thanksComplete);
			queue.add(print.data);
		}
		
		
		private function hidePrint(e:Event):void
		{
			thanks.removeEventListener(Thanks.SHOWING, hidePrint);
			print.hide();
		}
		
		
		private function thanksComplete(e:Event):void
		{
			thanks.removeEventListener(Thanks.COMPLETE, thanksComplete);	
			intro.addEventListener(Intro.SHOWING, hideThanks);
			init();
		}
		
		
		private function hideThanks(e:Event):void
		{
			intro.removeEventListener(Intro.SHOWING, hideThanks);
			thanks.hide();
		}
		
		
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		/**
		 * Called by TimeOutHelper if the app times out
		 * @param	e
		 */
		private function doReset(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOWING, hideIntro);
			takePhoto.removeEventListener(TakePhoto.CANCEL, cancelPhoto);
			takePhoto.removeEventListener(TakePhoto.PRINT, showThanks);// printPhoto);
			/*
			print.removeEventListener(Print.SHOWING, hideTakePhoto);
			print.removeEventListener(Print.COMPLETE, showThanks);
			print.removeEventListener(Print.COMPLETE_EMAIL, showThanksEmail);
			print.removeEventListener(Print.PROCESS, processComplete);
			*/
			thanks.removeEventListener(Thanks.SHOWING, hideTakePhoto);// hidePrint);
			thanks.removeEventListener(Thanks.COMPLETE, thanksComplete);			
			
			takePhoto.hide();
			//print.hide();
			thanks.hide();
			
			init();
		}
		
		
	}
	
}