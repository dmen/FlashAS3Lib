package com.gmrmarketing.holiday2016.photostrip
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
			
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
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
			takePhoto.addEventListener(TakePhoto.PRINT, showThanks);
			intro.removeEventListener(Intro.COMPLETE, introComplete);
			
			tim.startMonitoring();
		}
		
		
		private function hideIntro(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOWING, hideIntro);;
			intro.hide();
		}
		
		private function cancelPhoto(e:Event = null):void
		{
			takePhoto.removeEventListener(TakePhoto.CANCEL, cancelPhoto);
			takePhoto.removeEventListener(TakePhoto.PRINT, showThanks);
			takePhoto.hide();
			init();
		}
		
		private function hideTakePhoto(e:Event):void
		{
			takePhoto.hide();
		}
		
		
		private function showThanks(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.CANCEL, cancelPhoto);
			takePhoto.removeEventListener(TakePhoto.PRINT, showThanks);
			
			var pics:Array = takePhoto.getPhotos();
			thanks.addEventListener(Thanks.SHOWING, hideTakePhoto);
			thanks.show(pics);
			
			TweenMax.delayedCall(1, processImage);
		}
		
		private function processImage():void
		{
			thanks.addEventListener(Thanks.PROCESS, processComplete);
			thanks.process();//get imageString from bmd
		}		
		
		private function processComplete(e:Event):void
		{			
			thanks.removeEventListener(Thanks.PROCESS, processComplete);
			thanks.addEventListener(Thanks.COMPLETE, thanksComplete);
			queue.add(thanks.data);
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
			takePhoto.removeEventListener(TakePhoto.PRINT, showThanks);

			thanks.removeEventListener(Thanks.SHOWING, hideTakePhoto);
			thanks.removeEventListener(Thanks.COMPLETE, thanksComplete);			
			
			takePhoto.hide();
			thanks.hide();
			
			init();
		}
	}
}