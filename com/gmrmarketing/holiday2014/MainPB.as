package com.gmrmarketing.holiday2014
{
	import com.gmrmarketing.sap.levisstadium.avatar.testing.BGDisplay;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.display.*;
	import com.gmrmarketing.holiday2014.ColorEmitter;
	import com.gmrmarketing.holiday2014.SpotEmitter;
	import flash.events.Event;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.dmennenoh.keyboard.KeyBoard
	import flash.events.KeyboardEvent;
	import com.gmrmarketing.utilities.Validator;
	import flash.geom.Point;
	import flash.geom.Rectangle;	
	import com.dynamicflash.util.Base64;
	import flash.utils.ByteArray;
	import com.adobe.images.JPEGEncoder;
	import flash.desktop.NativeApplication;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.ui.Mouse; 

	public class MainPB extends MovieClip
	{
		//background 
		private var bgContainer:Sprite;
		private var colorEmitter:ColorEmitter;
		private var spotEmitter:SpotEmitter;
		
		private var fgContainer:Sprite;
		
		private var intro:Intro;
		private var take:Take;
		private var countDown:CountDown;
		private var whiteFlash:WhiteFlash;
		private var retake:RetakeEmail; //retake cancel email buttons
		private var thePic:Bitmap;
		private var overlay:Bitmap;
		private var thanks:Thanks;
		private var look:Look;
		
		private var keyboard:KeyBoard;
		private var kbdBG:MovieClip;
		
		private var thePics:Array;
		
		private var queue:Queue;		
		
		private var cc:CornerQuit;
		private var ccContainer:Sprite;
		
		private var heffCorner:CornerQuit;
		private var heffContainer:Sprite;
		
		private var flash:Sound;
		private var vol:SoundTransform;
		private var chan:SoundChannel;
		
		private var tim:TimeoutHelper;		
		
		
		
		public function MainPB()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();

			bgContainer = new Sprite();
			addChild(bgContainer);			
			
			colorEmitter = new ColorEmitter(bgContainer);
			spotEmitter = new SpotEmitter(bgContainer);
			
			fgContainer = new Sprite();
			addChild(fgContainer);
			
			ccContainer = new Sprite();
			addChild(ccContainer);
			
			heffContainer = new Sprite();
			addChild(heffContainer);
			
			intro = new Intro();
			intro.container = fgContainer;
			
			take = new Take();
			take.container = fgContainer;
			
			countDown = new CountDown();
			countDown.container = fgContainer;
			
			whiteFlash = new WhiteFlash();
			whiteFlash.container = fgContainer;			
			
			retake = new RetakeEmail();
			retake.container = fgContainer;
			
			overlay = new Bitmap(new overlayBMD());//lib
			overlay.x = 531;
			overlay.y = 51;
			
			thanks = new Thanks();
			thanks.container = fgContainer;
			
			look = new Look();
			look.container = fgContainer;
			
			keyboard = new KeyBoard();
			//keyboard.addEventListener(KeyBoard.KEYFILE_LOADED, init, false, 0, true);
			keyboard.loadKeyFile("kbd.xml");
			keyboard.x = 64;
			keyboard.y = 630;
			
			kbdBG = new mcKbdBar();//lib - contains email field
			kbdBG.x = 0;
			kbdBG.y = 615;
			
			thePic = new Bitmap();
			thePic.x = 565;//same as camMask in take
			thePic.y = 87;
			
			queue = new Queue();
			
			cc = new CornerQuit();
			cc.init(ccContainer, "ul");
			cc.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			heffCorner = new CornerQuit();
			heffCorner.init(heffContainer, "ur");
			heffCorner.customLoc(1, new Point(1318, 10));
			heffCorner.addEventListener(CornerQuit.CORNER_QUIT, swapHeff, false, 0, true);
			
			flash = new soundShutter();
			vol = new SoundTransform(.4);
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, doCancel, false, 0, true);
			tim.init(180000);//3min				
			
			init();
		}
		
		
		private function swapHeff(e:Event):void
		{
			take.heff();
		}
		
		
		private function init(e:Event = null):void
		{
			tim.stopMonitoring();
			thanks.removeEventListener(Thanks.COMPLETE, init);
			intro.show();
			intro.addEventListener(Intro.COMPLETE, hideIntro);
		}
		
		
		private function hideIntro(e:Event):void
		{
			intro.removeEventListener(Intro.COMPLETE, hideIntro);
			intro.hide();
			
			tim.startMonitoring();
			
			take.show();
			take.addEventListener(Take.TAKE, startCount, false, 0, true);
		}
		
		
		/**
		 * Called when user presses the take photo button
		 * @param	e
		 */
		private function startCount(e:Event):void
		{
			take.removeEventListener(Take.TAKE, startCount);
			tim.buttonClicked();
			look.show();
			countDown.addEventListener(CountDown.COMPLETE, takePhoto, false, 0, true);
			countDown.show();//starts counting
		}
		
		
		/**
		 * Called when COMPLETE is received from countDown
		 * @param	e
		 */
		private function takePhoto(e:Event):void
		{
			countDown.hide();			
			
			retake.show(); //show the retake cancel email buttons
			retake.addEventListener(RetakeEmail.RETAKE, doRetake, false, 0, true);
			retake.addEventListener(RetakeEmail.CANCEL, doCancel, false, 0, true);
			retake.addEventListener(RetakeEmail.EMAIL, doEmail, false, 0, true);
			
			take.addEventListener(Take.BWPRESED, showPic, false, 0, true);
			take.addEventListener(Take.COLORPRESSED, showPic, false, 0, true);
			
			thePics = take.getPic();//color,bw
			showPic();
			
			chan = flash.play();
			chan.soundTransform = vol;
			
			whiteFlash.show();//shows white and fades out over 1 sec
		}
		
		private function showHeff():void
		{
			
		}
		
		private function showPic(e:Event = null):void
		{	
			tim.buttonClicked();
			
			if(take.isColor()){
				thePic.bitmapData = thePics[0];
			}else{
				thePic.bitmapData = thePics[1];
			}
			
			thePic.alpha = 1;
			
			if (!fgContainer.contains(thePic)) {
				fgContainer.addChild(thePic);
			}
			
			//add the overlay
			if (!fgContainer.contains(overlay)) {
				fgContainer.addChild(overlay);				
			}			
		}
		
		
		private function doRetake(e:Event):void
		{
			tim.buttonClicked();
			
			retake.removeEventListener(RetakeEmail.RETAKE, doRetake);
			retake.removeEventListener(RetakeEmail.CANCEL, doCancel);
			retake.removeEventListener(RetakeEmail.EMAIL, doEmail);
			retake.removeEventListener(RetakeEmail.EMAIL, checkEmail);
			retake.hide();
			
			take.removeEventListener(Take.BWPRESED, showPic);
			take.removeEventListener(Take.COLORPRESSED, showPic);	
			
			if (fgContainer.contains(thePic)) {
				fgContainer.removeChild(thePic);
			}
			if (fgContainer.contains(overlay)) {
				fgContainer.removeChild(overlay);
			}
			if (contains(kbdBG)) {
				removeChild(kbdBG);
			}
			if (contains(keyboard)) {
				removeChild(keyboard);
			}
			
			keyboard.removeEventListener(KeyBoard.SUBMIT, checkEmail);
			
			take.show();//two lines from hideIntro()
			take.addEventListener(Take.TAKE, startCount, false, 0, true);			
		}
		
		
		private function doCancel(e:Event):void
		{			
			retake.removeEventListener(RetakeEmail.RETAKE, doRetake);
			retake.removeEventListener(RetakeEmail.CANCEL, doCancel);
			retake.removeEventListener(RetakeEmail.EMAIL, doEmail);
			retake.removeEventListener(RetakeEmail.EMAIL, checkEmail);
			retake.hide();
			
			take.removeEventListener(Take.BWPRESED, showPic);
			take.removeEventListener(Take.COLORPRESSED, showPic);	
			
			if (fgContainer.contains(thePic)) {
				fgContainer.removeChild(thePic);
			}
			if (fgContainer.contains(overlay)) {
				fgContainer.removeChild(overlay);
			}
			if (contains(kbdBG)) {
				removeChild(kbdBG);
			}
			if (contains(keyboard)) {
				removeChild(keyboard);
			}
			
			keyboard.removeEventListener(KeyBoard.SUBMIT, checkEmail);
			
			take.hide();
			take.picColor();
			init();
		}
		
		
		private function doEmail(e:Event):void
		{
			tim.buttonClicked();
			retake.removeEventListener(RetakeEmail.EMAIL, doEmail);
			retake.addEventListener(RetakeEmail.EMAIL, checkEmail, false, 0, true);
			
			addChild(kbdBG);
			addChild(keyboard);
			
			kbdBG.x = 0;
			kbdBG.y = 1080;						
			keyboard.x = 64;
			keyboard.y = 1080;
			
			TweenMax.to(kbdBG, .5, { y:615, ease:Back.easeOut } );
			TweenMax.to(keyboard, .5, { y:630, ease:Back.easeOut } );
			
			kbdBG.theError.alpha = 0;
			kbdBG.theText.text = "";
			keyboard.setFocusFields([kbdBG.theText]);
			keyboard.addEventListener(KeyBoard.SUBMIT, checkEmail, false, 0, true);
			keyboard.addEventListener(KeyBoard.KBD, resetTim, false, 0, true);
		}
		
		//called whenever a key on the onscreen keyboard is pressed
		private function resetTim(e:Event):void
		{
			tim.buttonClicked();
		}
		
		
		private function checkEmail(e:Event):void
		{			
			if (!Validator.isValidEmail(kbdBG.theText.text)) {
				TweenMax.to(kbdBG.theError, .5, { alpha:1 } );
				TweenMax.to(kbdBG.theError, .5, { alpha:0, delay:2 } );
			}else {
				
				keyboard.removeEventListener(KeyBoard.KBD, resetTim);
				keyboard.removeEventListener(KeyBoard.SUBMIT, checkEmail);
				retake.removeEventListener(RetakeEmail.EMAIL, checkEmail);
				doThanks();
			}
		}
		
		
		private function doThanks():void
		{
			tim.buttonClicked();
			
			take.removeEventListener(Take.BWPRESED, showPic);
			take.removeEventListener(Take.COLORPRESSED, showPic);			
			
			if (fgContainer.contains(thePic)) {
				fgContainer.removeChild(thePic);
			}
			if (fgContainer.contains(overlay)) {
				fgContainer.removeChild(overlay);
			}
			if (contains(kbdBG)) {
				removeChild(kbdBG);
			}
			if (contains(keyboard)) {
				removeChild(keyboard);
			}
			
			TweenMax.delayedCall(2, saveImage);
			
			retake.hide();
			take.hide();
			take.picColor();//resets outline to color pete
			thanks.show();
			thanks.addEventListener(Thanks.COMPLETE, init, false, 0, true);
		}
		
		
		private function saveImage():void
		{
			var im:BitmapData = new BitmapData(880, 880);//size of overlay
			im.copyPixels(thePic.bitmapData, new Rectangle(0, 0, 811, 811), new Point(35, 35));
			im.copyPixels(overlay.bitmapData, new Rectangle(0, 0, 880, 880), new Point(), null, null, true);
			
			var ims:String = getBase64(im);
			queue.add( { email:kbdBG.theText.text, image:ims } );
		}
		
		
		private function getBase64(bmpd:BitmapData):String
		{
			var encoder:JPEGEncoder = new JPEGEncoder(84);
			var ba:ByteArray = encoder.encode(bmpd);
			
			return Base64.encodeByteArray(ba);
		}
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}