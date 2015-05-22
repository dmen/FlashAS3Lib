package com.gmrmarketing.comcast.taylorswift.photobooth
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.geom.*;
	import flash.printing.PrintJob;
    import flash.printing.PrintJobOptions;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.gmrmarketing.utilities.Validator;
	import com.dynamicflash.util.Base64;
	import flash.utils.ByteArray;
	import com.adobe.images.JPEGEncoder;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Print extends EventDispatcher 
	{
		public static const ADD_ERROR:String = "printJob.addPage_Error";
		public static const SEND_ERROR:String = "printJob.send_Error";
		public static const SHOWING:String = "clipShowing";
		public static const COMPLETE:String = "printComplete";
		public static const COMPLETE_EMAIL:String = "printCompleteSendEmail";
		public static const PROCESS:String = "processComplete";		
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var printImage:BitmapData;//600x1800 for printing
		private var shareImage:BitmapData;//square for sharing
		private var kbd:KeyBoard;		
		
		private var imageString:String;
		private var tim:TimeoutHelper;
		
		
		public function Print()
		{
			clip = new mcPrint();
			
			tim = TimeoutHelper.getInstance();
			
			kbd = new KeyBoard();
			kbd.addEventListener(KeyBoard.KEYFILE_LOADED, initkbd, false, 0, true);
			kbd.loadKeyFile("ts_roundkeys.xml");
		}
		
		
		private function initkbd(e:Event):void
		{
			clip.kbdWhite.addChild(kbd);
			kbd.x = 450;
			kbd.y = 60;
			kbd.setFocusFields([[clip.emailText.email, 0]]);
		}
  
  
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * 
		 * @param	pics Array of 750x750 images
		 */
		public function show(pics:Array):void
		{			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.theText.visible = true;
			clip.btnNo.visible = true;
			clip.btnYes.visible = true;
			
			clip.alpha = 0;
			clip.theText.alpha = 0;
			clip.btnNo.scaleX = clip.btnNo.scaleY = 0;
			clip.btnYes.scaleX = clip.btnYes.scaleY = 0;
			
			clip.kbdWhite.y = 1090;
			clip.emailText.visible = false;
			clip.emailText.email.text = "";
			clip.emailText.notValid.alpha = 0;
			clip.emailText.theCheck.gotoAndStop(1);//unchecked
			clip.emailText.optGlow.alpha = 0;
			
			var pic:BitmapData;
			var m:Matrix = new Matrix();			
			m.scale(.624, .624);//scale 750 to 468
			shareImage = new sharePhoto();//1200x1200 lib image
			pic = new BitmapData(468, 468);
			pic.draw(pics[0], m, null, null, null, true);
			shareImage.copyPixels(pic, pic.rect, new Point(120, 163));
			pic.draw(pics[1], m, null, null, null, true);
			shareImage.copyPixels(pic, pic.rect, new Point(614, 163));
			pic.draw(pics[2], m, null, null, null, true);
			shareImage.copyPixels(pic, pic.rect, new Point(120, 656));			
			
			//600 x 1800 (2"x6") from library
			printImage = new printHolder();
			
			pic = new BitmapData(468, 468);
			
			m = new Matrix();
			m.scale(.624, .624);//scale 750 to 468
			
			//colorTransform to add brightness for printing
			//var co:ColorTransform = new ColorTransform(1.2, 1.2, 1.2, 1) 
			
			//pic 1
			pic.draw(pics[0], m, null, null, null, true);
			printImage.copyPixels(pic, pic.rect, new Point(66, 124));
			//printImage.copyPixels(pic, pic.rect, new Point(670, 180));
			
			//pic 2
			pic.draw(pics[1], m, null, null, null, true);
			printImage.copyPixels(pic, pic.rect, new Point(66, 618));
			//printImage.copyPixels(pic, pic.rect, new Point(670, 682));
			
			//pic 3
			pic.draw(pics[2], m, null, null, null, true);
			printImage.copyPixels(pic, pic.rect, new Point(66, 1115));
			//printImage.copyPixels(pic, pic.rect, new Point(670, 1192));			
			
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		/**
		 * returns an object with email and image keys
		 */
		public function get data():Object
		{			
			return {email:clip.emailText.email.text, image:imageString};
		}
		
		
		private function showing():void
		{
			clip.addEventListener(Event.ENTER_FRAME, updateGlow);
			
			TweenMax.to(clip.theText, .6, { alpha:1 } );
			TweenMax.to(clip.btnNo, .6, { scaleX:1, scaleY:1, delay:.5, ease:Back.easeOut } );
			TweenMax.to(clip.btnYes, .6, { scaleX:1, scaleY:1, delay:.6, ease:Back.easeOut, onComplete:beginPrint } );
			
			clip.btnNo.addEventListener(MouseEvent.MOUSE_DOWN, noClicked, false, 0, true);			
			clip.btnYes.addEventListener(MouseEvent.MOUSE_DOWN, yesClicked, false, 0, true);
			clip.emailText.btnCheck.addEventListener(MouseEvent.MOUSE_DOWN, optInClicked, false, 0, true);
			
			dispatchEvent(new Event(SHOWING));
		}
		
		
		public function hide():void
		{
			clip.removeEventListener(Event.ENTER_FRAME, updateGlow);
			clip.btnNo.removeEventListener(MouseEvent.MOUSE_DOWN, noClicked);			
			clip.btnYes.removeEventListener(MouseEvent.MOUSE_DOWN, yesClicked);
			clip.emailText.btnCheck.removeEventListener(MouseEvent.MOUSE_DOWN, optInClicked);
			kbd.removeEventListener(KeyBoard.SUBMIT, emailSubmitted);
			kbd.removeEventListener(KeyBoard.KBD, resetTim);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function optInClicked(e:MouseEvent):void
		{
			if (clip.emailText.theCheck.currentFrame == 1) {
				clip.emailText.theCheck.gotoAndStop(2);
			}else {
				clip.emailText.theCheck.gotoAndStop(1);
			}
		}
		
		
		private function noClicked(e:MouseEvent):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function yesClicked(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			clip.theText.visible = false;
			clip.btnNo.visible = false;
			clip.btnYes.visible = false;
			
			TweenMax.to(clip.kbdWhite, .6, { y:522, ease:Back.easeOut } );
			kbd.addEventListener(KeyBoard.SUBMIT, emailSubmitted, false, 0, true);
			kbd.addEventListener(KeyBoard.KBD, resetTim, false, 0, true);
			clip.kbdWhite.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelEmail, false, 0, true);
			
			clip.emailText.visible = true;
			clip.emailText.alpha = 0;
			TweenMax.to(clip.emailText, .5, { alpha:1 } );
		}
		
		
		private function resetTim(e:Event):void
		{
			tim.buttonClicked();
		}
		
		
		private function cancelEmail(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			kbd.removeEventListener(KeyBoard.SUBMIT, emailSubmitted);
			kbd.removeEventListener(KeyBoard.KBD, resetTim);
			clip.kbdWhite.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelEmail);
			TweenMax.to(clip.kbdWhite, 1, { y:1090, ease:Back.easeIn, onComplete:showButtons } );
			
			clip.theText.visible = true;
			clip.btnNo.visible = true;
			clip.btnYes.visible = true;
			clip.theText.alpha = 0;
			clip.btnNo.scaleX = clip.btnNo.scaleY = 0;
			clip.btnYes.scaleX = clip.btnYes.scaleY = 0;
			
			clip.emailText.visible = false;			
		}
		
		
		private function showButtons():void
		{
			TweenMax.to(clip.theText, .6, { alpha:1 } );
			TweenMax.to(clip.btnNo, .6, { scaleX:1, scaleY:1, delay:.5, ease:Back.easeOut } );
			TweenMax.to(clip.btnYes, .6, { scaleX:1, scaleY:1, delay:.6, ease:Back.easeOut } );
		}
		
		
		private function emailSubmitted(e:Event):void
		{
			if(clip.emailText.theCheck.currentFrame == 2){
				if (Validator.isValidEmail(clip.emailText.email.text)) {
					dispatchEvent(new Event(COMPLETE_EMAIL));
				}else {
					clip.emailText.notValid.theText.text = "please enter a valid email address";
					clip.emailText.notValid.alpha = 1;
					TweenMax.to(clip.emailText.notValid, 1, { alpha:0, delay:2 } );
				}
			}else {
				clip.emailText.optGlow.alpha = 1;
				TweenMax.to(clip.emailText.optGlow, 1, { alpha:0, delay:1 } );
			}
		}
		
		
		private function beginPrint():void 
		{			
            var printJob:PrintJob = new PrintJob();           
			
			var options:PrintJobOptions = new PrintJobOptions();
            //options.printAsBitmap = true;           
			
			if (printJob.start2(null, false)) {				
				
				var page:Sprite = new Sprite();
				var bmp:Bitmap = new Bitmap(printImage);//printBMD);				
				
				page.addChild(bmp);
				page.width = printJob.pageWidth;
				page.scaleY = page.scaleX;
				//page.rotation = 180;
				
				try {
					printJob.addPage(page, null, options);
					printJob.addPage(page, null, options);
				}
				catch(e:Error) {
					dispatchEvent(new Event(ADD_ERROR));
				}
	 
				try {
					printJob.send();					
				}
				catch (e:Error) {
					dispatchEvent(new Event(SEND_ERROR));   
				}				
		   }
		}
		
		
		private function updateGlow(e:Event):void
		{
			TweenMax.to(clip.xfin, 0, { glowFilter: { color:0x33ccff, alpha:.2 + Math.random()*.8, blurX:5, blurY:5 } } );
			TweenMax.to(clip.year, 0, { glowFilter: { color:0xff9999, alpha:.2 + Math.random()*.8, blurX:5, blurY:5 } } );
		}
		
		
		/**
		 * Three functions process shareImage into imageString to be sent to NowPik
		 */
		public function process():void
		{
			var jpeg:ByteArray = getJpeg(shareImage);
			imageString = getBase64(jpeg);
			dispatchEvent(new Event(PROCESS));
		}
		
		
		private function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		
		private function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPEGEncoder = new JPEGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
		
	}
	
}