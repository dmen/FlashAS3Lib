package com.gmrmarketing.nissan.rodale2013
{
	import flash.display.*;
	import flash.events.Event;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication; //for quitting
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.net.SharedObject;	
	
	//for saving images to the local filesystem
	import flash.utils.ByteArray;
	import flash.filesystem.*; 
	import com.adobe.images.JPEGEncoder;
	
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var take:TakePhoto;
		private var confirm:Confirm;
		private var print:Print;
		private var dialog:Dialog;
		private var baseContainer:Sprite;
		private var quitContainer:Sprite;
		private var cq:CornerQuit;
		private var introShowing:Boolean;
		private var tim:TimeoutHelper;
		
		private var so:SharedObject;
		private var numPrints:int;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			so = SharedObject.getLocal("nissanData", "/");
			
			baseContainer = new Sprite();
			addChild(baseContainer);
			quitContainer = new Sprite();
			addChild(quitContainer);

			intro = new Intro();
			intro.setContainer(baseContainer);
			
			take = new TakePhoto();
			take.setContainer(baseContainer);
			
			confirm = new Confirm();
			confirm.setContainer(baseContainer);
			
			print = new Print();
			
			dialog = new Dialog();
			dialog.addEventListener(Dialog.COMPLETE, printComplete);
			dialog.setContainer(quitContainer);
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, killApp, false, 0, true);
			tim.init(120000); //2 minutes --startMonitoring() called from takePhoto			
			
			cq = new CornerQuit();
			cq.init(quitContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, killApp, false, 0, true);
			
			numPrints = so.data.prints;
			
			init();
		}
		
		private function init(e:Event = null):void
		{
			dialog.removeEventListener(Dialog.THANKS_DONE, init);
			take.hide();
			confirm.hide();
			introShowing = true;
			tim.stopMonitoring();
			intro.show();
			intro.addEventListener(Intro.INTRO_BEGIN, takePhoto, false, 0, true);			
		}
		
		
		private function takePhoto(e:Event):void
		{
			intro.removeEventListener(Intro.INTRO_BEGIN, takePhoto);
			introShowing = false;
			tim.startMonitoring();
			take.addEventListener(TakePhoto.TAKE_SHOWING, removeIntro, false, 0, true);
			take.addEventListener(TakePhoto.PIC_TAKEN, picTaken, false, 0, true);
			take.show();			
		}
		
		
		private function removeIntro(e:Event):void
		{
			take.removeEventListener(TakePhoto.TAKE_SHOWING, removeIntro);
			intro.hide();
		}
		
		
		private function picTaken(e:Event):void
		{
			confirm.show(take.getPic());//display size image
			confirm.addEventListener(Confirm.RETAKE, retake, false, 0, true);
			confirm.addEventListener(Confirm.CONTINUE, beginPrint, false, 0, true);
			take.hide();
		}
		
		private function retake(e:Event):void
		{
			confirm.hide();
			take.show();
		}
		
		
		private function beginPrint(e:Event):void
		{			
			tim.stopMonitoring();
			
			dialog.show("Now Printing...\nPlease Wait...");
			
			print.addEventListener(Print.ADD_ERROR, printError, false, 0, true);
			print.addEventListener(Print.SEND_ERROR, printError, false, 0, true);			
			print.beginPrint(confirm.getPic());//with white
			
			writeImage(confirm.getPic(false)); //without the white circle
			
			numPrints++;
			so.data.prints = numPrints;
			intro.numPrints(numPrints);
			so.flush();
		}
		
		
		private function printError(e:Event):void
		{
			dialog.show("An error occurred.\nPlease check the printer");
		}
		
		
		/**
		 * Called by tapping on the print dialog, or letting it expire
		 * @param	e
		 */
		private function printComplete(e:Event):void
		{
			print.removeEventListener(Print.ADD_ERROR, printError);
			print.removeEventListener(Print.SEND_ERROR, printError);
			
			dialog.addEventListener(Dialog.THANKS_DONE, init, false, 0, true);
			dialog.thanks();
		}
		
		
		private function killApp(e:Event):void
		{
			if(introShowing){
				NativeApplication.nativeApplication.exit();
			}else {
				take.hide();
				confirm.hide();
				init();
			}
		}		
		
		
		private function writeImage(bmpd:BitmapData):void
		{
			var encoder:JPEGEncoder = new JPEGEncoder(82);
			var ba:ByteArray = encoder.encode(bmpd);
			
			var a:Date = new Date();
			var fileName:String = "bighead_" + String(a.valueOf()) + ".jpg";			
			
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