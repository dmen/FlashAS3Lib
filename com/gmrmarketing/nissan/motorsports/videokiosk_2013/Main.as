package com.gmrmarketing.nissan.motorsports.videokiosk_2013
{
	import com.gmrmarketing.nissan.canada.ridedrive2013.PinEntry;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.display.*;	
	import flash.events.*;
	import flash.ui.Mouse;
	import flash.desktop.NativeApplication; //for quitting
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	public class Main extends MovieClip
	{
		private var userID:String; //id from scanning QR code, or entering manually
		private var intro:Intro;
		private var pin:PinEntry;
		private var vid:Video;
		private var thanks:Thanks;
		private var admin:Admin;
		private var process:ProcessVideo;
		private var queue:Queue;
		
		private var baseContainer:Sprite;
		private var topContainer:Sprite;
		
		private var adminCorner:CornerQuit;
		private var quitCorner:CornerQuit;
		private var tim:TimeoutHelper;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();
			
			baseContainer = new Sprite();
			topContainer = new Sprite();
			
			addChild(baseContainer);
			addChild(topContainer);

			intro = new Intro();
			intro.setContainer(baseContainer);
			
			pin = new PinEntry();
			pin.setContainer(baseContainer);
			
			vid = new Video();
			vid.setContainer(baseContainer);
			
			thanks = new Thanks();
			thanks.setContainer(baseContainer);
			
			admin = new Admin();
			admin.setContainer(topContainer);
			
			quitCorner = new CornerQuit();
			quitCorner.init(topContainer, "ur");
			quitCorner.addEventListener(CornerQuit.CORNER_QUIT, killApp, false, 0, true);
			
			adminCorner = new CornerQuit();
			adminCorner.init(topContainer, "ul");
			adminCorner.addEventListener(CornerQuit.CORNER_QUIT, showAdmin, false, 0, true);
			
			process = new ProcessVideo();
			
			queue = new Queue();
			queue.addEventListener(Queue.DEBUG_MESSAGE, gotDebug, false, 0, true);
			
			
			
			init();
		}
		
		
		private function init(e:Event = null):void
		{
			thanks.removeEventListener(Thanks.COMPLETE, init);
			intro.addEventListener(Intro.QR_SKIPPED, skipQR, false, 0, true);
			intro.addEventListener(Intro.QR_SCANNED, gotQR, false, 0, true);
			intro.addEventListener(Intro.SHOWING, removeThanks, false, 0, true);
			intro.show();
		}
		
		private function removeThanks(e:Event):void
		{
			intro.removeEventListener(Intro.SHOWING, removeThanks);
			thanks.hide();
		}
		
		private function skipQR(e:Event):void
		{
			intro.removeEventListener(Intro.QR_SKIPPED, skipQR);
			intro.removeEventListener(Intro.QR_SCANNED, gotQR);
			
			pin.addEventListener(PinEntry.PIN_CLOSED, pinClosed, false, 0, true);			
			pin.addEventListener(PinEntry.PIN_ENTERED, pinEntered, false, 0, true);			
			pin.show();			
		}
		
		
		/**
		 * callback from pressing close button in the pin entry
		 * shows intro again
		 * @param	e
		 */
		private function pinClosed(e:Event):void
		{
			pin.removeEventListener(PinEntry.PIN_CLOSED, pinClosed);
			pin.hide();
			intro.show();
			intro.addEventListener(Intro.QR_SKIPPED, skipQR, false, 0, true);
			intro.addEventListener(Intro.QR_SCANNED, gotQR, false, 0, true);
		}
		
		
		/**
		 * callback from scanning a qr code in RFID
		 * call intro.getQR() to get ID
		 * @param	e
		 */
		private function gotQR(e:Event):void
		{
			userID = intro.getQR();
			
			intro.removeEventListener(Intro.QR_SKIPPED, skipQR);
			intro.removeEventListener(Intro.QR_SCANNED, gotQR);
			showVideo();
		}
		
		
		/**
		 * callback from entering a 5 digit pin in the keypad
		 * call pin.getPin() to get ID
		 */
		private function pinEntered(e:Event):void
		{
			userID = pin.getPin();
			
			intro.removeEventListener(Intro.QR_SKIPPED, skipQR);
			intro.removeEventListener(Intro.QR_SCANNED, gotQR);
			
			pin.removeEventListener(PinEntry.PIN_CLOSED, pinClosed);			
			pin.removeEventListener(PinEntry.PIN_ENTERED, pinEntered);
			showVideo();
		}
		
		
		/**
		 * called from pinEntered() or gotQR() once the user enters a pin
		 */
		private function showVideo():void
		{
			vid.addEventListener(Video.VID_SHOWING, removeIntro, false, 0, true);
			vid.addEventListener(Video.DONE_RECORDING, showThanks, false, 0, true);
			vid.show();
		}
		
		
		/**
		 * called once the video clip is showing
		 * hides pin and intro clips
		 * 
		 * @param	e VID_SHOWING event
		 */
		private function removeIntro(e:Event):void
		{
			intro.hide();
			pin.hide();
		}		
		
		
		private function showThanks(e:Event):void
		{
			thanks.addEventListener(Thanks.SHOWING, removeVid, false, 0, true);
			thanks.addEventListener(Thanks.COMPLETE, init, false, 0, true);
			thanks.show();
			
			process.addEventListener(ProcessVideo.COMPLETE, processComplete, false, 0, true);
			process.addEventListener(ProcessVideo.ERROR, processError, false, 0, true);
			process.startProcess(userID);
		}
		
		
		private function removeVid(e:Event):void
		{
			thanks.removeEventListener(Thanks.SHOWING, removeVid);
			vid.hide();
		}
		
		
		private function processComplete(e:Event):void
		{		
			process.removeEventListener(ProcessVideo.COMPLETE, processComplete);
			queue.addToQueue(process.getVidName());
		}
		
		
		private function processError(e:Event):void
		{			
		}
		
		
		private function showAdmin(e:Event):void
		{
			admin.show();
		}
		
		
		private function gotDebug(e:Event):void
		{
			if (admin.isShowing()) {
				admin.displayDebug(queue.getDebugMessage());
			}
		}
		
		
		private function killApp(e:Event = null):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}