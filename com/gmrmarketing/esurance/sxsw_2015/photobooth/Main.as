package com.gmrmarketing.esurance.sxsw_2015.photobooth
{
	import flash.display.*;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.ui.Mouse;
	import com.greensock.TweenMax;
	
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var takePhoto:TakePhoto;		
		private var queue:Queue;		
	
		private var mainContainer:Sprite;
		private var topContainer:Sprite;
		
		private var timeoutHelper:TimeoutHelper;
		private var cq:CornerQuit; //quit - upper right
		private var cb:CornerQuit; //back to intro - upper left
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			mainContainer = new Sprite();
			topContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(topContainer);
			
			takePhoto = new TakePhoto();
			takePhoto.container = mainContainer;
			
			cq = new CornerQuit();
			cq.init(topContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			cb = new CornerQuit();
			cb.init(topContainer, "ur");
			cb.addEventListener(CornerQuit.CORNER_QUIT, doReset2, false, 0, true);			
			
			timeoutHelper = TimeoutHelper.getInstance();
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, doReset2, false, 0, true);
			timeoutHelper.init(120000);//2 min		
			
			queue = new Queue();			
			
			intro = new Intro();
			intro.container = mainContainer;
			intro.addEventListener(Intro.RFID, showTakePhoto, false, 0, true);
			intro.show();
		}
		
		
		private function showTakePhoto(e:Event):void
		{
			timeoutHelper.buttonClicked();
			intro.removeEventListener(Intro.RFID, showTakePhoto);
			
			takePhoto.addEventListener(TakePhoto.FINISHED, doReset, false, 0, true);
			takePhoto.addEventListener(TakePhoto.SHOWING, removeIntro, false, 0, true);			
			takePhoto.show();
		}
		
		
		private function removeIntro(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOWING, removeIntro);
			intro.hide();
		}
		
		
		/**
		 * called when photo is doen
		 * @param	e
		 */
		private function doReset(e:Event):void
		{
			queue.add( { rfid:intro.getRFID(), image:takePhoto.getPhotoString() } );
			
			takePhoto.hide();
			intro.addEventListener(Intro.RFID, showTakePhoto, false, 0, true);
			timeoutHelper.stopMonitoring(); //don't monitor the intro screen
			intro.show();
		}
		
		//called from 4 taps ur
		private function doReset2(e:Event):void
		{
			//queue.add( { rfid:intro.getRFID(), image:takePhoto.getPhotoString() } );
			
			takePhoto.hide();
			intro.addEventListener(Intro.RFID, showTakePhoto, false, 0, true);
			timeoutHelper.stopMonitoring(); //don't monitor the intro screen
			intro.show();
		}
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}	
	}	
}