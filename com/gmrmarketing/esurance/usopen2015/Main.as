package com.gmrmarketing.esurance.usopen2015
{
	import com.gmrmarketing.utilities.SharedObjectWrapper;
	import flash.display.*;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.net.SharedObject;
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
		
		private var print:Print;
		private var config:SharedObject;//for getting isKidsDay boolean
		
		private var kidsDialog:MovieClip;//lib clip
		
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			kidsDialog = new mcKidsDialog();
			
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
			cb.addEventListener(CornerQuit.CORNER_QUIT, showKidsDialog, false, 0, true);			
			
			timeoutHelper = TimeoutHelper.getInstance();
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, doReset2, false, 0, true);
			timeoutHelper.init(120000);//2 min		
			
			queue = new Queue();
			
			print = new Print();
			
			config = SharedObject.getLocal("esurance_uso");
			if (config.data.isKidsDay == undefined) {
				config.data.isKidsDay = false;
				config.flush();
			}
		
			intro = new Intro();
			intro.container = mainContainer;
			intro.addEventListener(Intro.RFID, showTakePhoto, false, 0, true);
			intro.show(config.data.isKidsDay);			
		}
		
		
		private function showTakePhoto(e:Event):void
		{
			timeoutHelper.buttonClicked();
			intro.removeEventListener(Intro.RFID, showTakePhoto);
			
			takePhoto.addEventListener(TakePhoto.FINISHED, doReset, false, 0, true);
			takePhoto.addEventListener(TakePhoto.SHOWING, removeIntro, false, 0, true);			
			takePhoto.show(config.data.isKidsDay);
		}
		
		
		private function removeIntro(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOWING, removeIntro);
			intro.hide();
		}
		
		
		//called from four taps at upper right
		private function showKidsDialog(e:Event):void
		{
			addChild(kidsDialog);
			kidsDialog.x = 1214;
			kidsDialog.y = 0;
			kidsDialog.theX.visible = config.data.isKidsDay;
			kidsDialog.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeKids, false, 0, true);
			kidsDialog.btnKids.addEventListener(MouseEvent.MOUSE_DOWN, toggleKids, false, 0, true);
		}
		private function closeKids(e:MouseEvent):void
		{
			removeChild(kidsDialog);
			kidsDialog.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeKids);
			kidsDialog.btnKids.removeEventListener(MouseEvent.MOUSE_DOWN, toggleKids);
		}
		private function toggleKids(e:MouseEvent):void
		{
			if (config.data.isKidsDay) {
				kidsDialog.theX.visible = false;
				config.data.isKidsDay = false;
			}else {
				kidsDialog.theX.visible = true;
				config.data.isKidsDay = true;
			}
			config.flush();
		}
		
		
		/**
		 * called when photo is done
		 * @param	e
		 */
		private function doReset(e:Event):void
		{
			if (!config.data.isKidsDay) {
				var o:Object = intro.getData(); //Object with email, rfid keys
				o.image = takePhoto.getPhotoString();
				queue.add(o);
			}else {
				//kids day - call print api only
				queue.callPrintOnly("kidsDay");
			}
			
			print.doPrint(takePhoto.getPrintPhoto());//1200x1800
			
			takePhoto.hide();
			intro.addEventListener(Intro.RFID, showTakePhoto, false, 0, true);
			timeoutHelper.stopMonitoring(); //don't monitor the intro screen
			intro.show(config.data.isKidsDay);
		}
		
		
		//called from timeoutHelper timeout
		private function doReset2(e:Event):void
		{			
			takePhoto.hide();
			intro.addEventListener(Intro.RFID, showTakePhoto, false, 0, true);
			timeoutHelper.stopMonitoring(); //don't monitor the intro screen
			intro.show(config.data.isKidsDay);
		}
		
		
		//called from four taps at upper left
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}	
	}	
}