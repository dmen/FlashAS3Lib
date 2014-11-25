package com.gmrmarketing.humana.rrbighead
{
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.gmrmarketing.nissan.rodale2013.Print;
	import flash.net.SharedObject;
	import flash.desktop.NativeApplication;
	//for saving images to the local filesystem
	import flash.utils.ByteArray;
	import flash.filesystem.*; 
	import com.adobe.images.JPEGEncoder;
	
	
	public class Main extends MovieClip 
	{
		private var tim:TimeoutHelper;
		
		private var intro:Intro;
		private var take:TakePhoto;
		private var confirm:Confirm; //overlay screen
		private var print:Print;
		private var thanks:ThankYou;
		private var dialog:Dialog;
		
		private var so:SharedObject; //stores the print count
		private var numPrints:int;
		
		private var mainContainer:Sprite;
		private var cornerContainer:Sprite;
		private var cq:CornerQuit;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			so = SharedObject.getLocal("rrbh_pc", "/");
			numPrints = so.data.prints;
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, resetApp, false, 0, true);
			tim.init(120000); //2 minutes --startMonitoring() called from takePhoto
			
			mainContainer = new Sprite();
			cornerContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(cornerContainer);
			
			intro = new Intro();
			intro.container = mainContainer;
			
			take = new TakePhoto();
			take.container = mainContainer;
			
			confirm = new Confirm();
			confirm.container = mainContainer;
			
			thanks = new ThankYou();
			thanks.container = mainContainer;
			
			dialog = new Dialog();
			dialog.container = mainContainer;			
			
			print = new Print();
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApp, false, 0, true);
			
			init();
		}
		
		
		private function init():void
		{
			tim.buttonClicked();
			thanks.hide();
			intro.addEventListener(Intro.BEGIN, introComplete);
			intro.showCount(numPrints);
			intro.show();
		}
		
		
		/**
		 * Called once start button on intro screen is pressed
		 * @param	e
		 */
		private function introComplete(e:Event):void
		{
			tim.buttonClicked();
			intro.removeEventListener(Intro.BEGIN, introComplete);
			take.addEventListener(TakePhoto.PIC_TAKEN, picTaken, false, 0, true);
			take.addEventListener(TakePhoto.TAKE_SHOWING, removeIntro, false, 0, true);
			take.show();
		}
		
		
		/**
		 * Called when take photo screen has finished it's intro and is fully showing
		 * removes the previous intro screen
		 * @param	e
		 */
		private function removeIntro(e:Event):void
		{
			take.removeEventListener(TakePhoto.TAKE_SHOWING, removeIntro);
			intro.hide();
		}
		
		
		/**
		 * Called once image is taken
		 * Shows the confirmation / overlay screen
		 * @param	e
		 */
		private function picTaken(e:Event):void
		{			
			take.removeEventListener(TakePhoto.PIC_TAKEN, picTaken);
			
			confirm.addEventListener(Confirm.RETAKE, retake, false, 0, true);
			confirm.addEventListener(Confirm.PRINT, beginPrint, false, 0, true);
			confirm.addEventListener(Confirm.CONFIRM_SHOWING, removeTakePhoto, false, 0, true);
			confirm.show(take.getPic());//1405 x 800
		}
		
		
		/**
		 * Called once confirm/overlay screen is fully showing
		 * removes the previous take photo screen
		 * @param	e
		 */
		private function removeTakePhoto(e:Event):void
		{
			confirm.removeEventListener(Confirm.CONFIRM_SHOWING, removeTakePhoto);
			take.hide();
		}
		
		
		/**
		 * Called if user presses retake in the confirm/overlay screen
		 * @param	e
		 */
		private function retake(e:Event):void
		{
			confirm.removeEventListener(Confirm.RETAKE, retake);
			confirm.removeEventListener(Confirm.PRINT, beginPrint);
			confirm.removeEventListener(Confirm.CONFIRM_SHOWING, removeTakePhoto);
			confirm.hide();
			
			take.addEventListener(TakePhoto.PIC_TAKEN, picTaken, false, 0, true);
			take.show();
		}
		
		
		/**
		 * Called when Print button is pressed in cofirm/overlay screen
		 * @param	e
		 */
		private function beginPrint(e:Event):void
		{
			tim.buttonClicked();
			
			//take.killCam(); //turns off the camera
			
			thanks.addEventListener(ThankYou.SHOWING, removeConfirm, false, 0, true);
			thanks.addEventListener(ThankYou.COMPLETE, resetApp, false, 0, true);			
			thanks.show(confirm.getPic());//800x800 bmd			
						
			print.addEventListener(Print.ADD_ERROR, printError, false, 0, true);//removed in resetApp()
			print.addEventListener(Print.SEND_ERROR, printError, false, 0, true);
			print.beginPrint(confirm.getPic());//800x800
			
			//save full image to local HD
			writeImage(confirm.getPic(false)); //false to not include white cirle
			
			numPrints++;
			so.data.prints = numPrints;			
			so.flush();
		}
		
		
		private function removeConfirm(e:Event):void
		{
			thanks.removeEventListener(ThankYou.SHOWING, removeConfirm);
			confirm.hide();
		}
		
		
		private function printError(e:Event):void
		{
			dialog.show("An error occurred.\nPlease check the printer");
		}
			
		/**
		 * Called if tim times out
		 * @param	e
		 */
		private function resetApp(e:Event = null):void
		{
			thanks.removeEventListener(ThankYou.COMPLETE, resetApp);
			print.removeEventListener(Print.ADD_ERROR, printError);
			print.removeEventListener(Print.SEND_ERROR, printError);
			init();//shows intro
		}
		
		
		/**
		 * called from cornerQuit after four taps at upper left
		 * @param	e
		 */
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		/**
		 * 
		 * @param	bmpd
		 */
		private function writeImage(bmpd:BitmapData):void
		{
			var encoder:JPEGEncoder = new JPEGEncoder(82);
			var ba:ByteArray = encoder.encode(bmpd);
			
			var a:Date = new Date();
			var fileName:String = "humana_bh_rr_" + String(a.valueOf()) + ".jpg";			
			
			try{
				var file:File = File.documentsDirectory.resolvePath( fileName );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.APPEND );
				stream.writeBytes (ba, 0, ba.length );
				stream.close();
				file = null;
				stream = null;
			}catch (e:Error) {
				
			}
		}		
	}
	
}