package com.sagecollective.corona.atp
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.events.*;
	import com.sagecollective.corona.atp.CamPic;
	import com.sagecollective.utilities.TimeoutHelper;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.utils.Timer;
	import flash.filters.DropShadowFilter;
	import flash.media.Sound;
	
	
	public class Instructions extends EventDispatcher
	{
		public static const ITEMS_REMOVED:String = "instructionsContainerCleared";
		public static const RESET:String = "reset";
		public static const PRINT_CARD:String = "cardReadyToPrint";
		public static const SHARE_FACEBOOK:String = "shareOnFacebook";
		public static const SHARE_EMAIL:String = "shareOnEmail";
		public static const HIDE_DIALOG:String = "hideTheDialog";
		public static const SHARE_AGREE:String = "didntAgreeToShare";
		
		private var container:DisplayObjectContainer;
		private var instructionsSign:MovieClip;
		private var signShadow:MovieClip;
		
		private var previewSign:MovieClip;
		private var socialSign:MovieClip;
		private var thanksSign:MovieClip;
		
		private var theCamera:CamPic;
		private var theCapture:Bitmap;
		private var previewPic:Bitmap;
		
		private var thatch:MovieClip;
		
		private var templates:TemplateOptions;
		
		private var overlay:Bitmap;
		private var overlayNum:int; //set in templatePicked
		
		private var limeCount:MovieClip;
		private var limeTimer:Timer;
		private var limeCounter:int;
		private var limeBeep:Sound;
		private var shutter:Sound;
		
		private var whiteFlash:MovieClip;
		private var flashTimer:Timer;
		
		private var btnRetake:MovieClip;
		private var btnContinue:MovieClip;
		
		private var btnShadow:DropShadowFilter;
		
		private var theStamp:BitmapData; //passed in from Main in init()
		
		private var timeoutHelper:TimeoutHelper;
		
		
		public function Instructions($container:DisplayObjectContainer)
		{
			container = $container;
			btnShadow = new DropShadowFilter(0, 0, 0, .8, 5, 5, 1, 2);
			
			limeBeep = new lime_beep(); //lib clips
			shutter = new the_shutter();
			
			timeoutHelper = TimeoutHelper.getInstance();
			
			//lib clips
			instructionsSign = new sign_instructions();
			signShadow = new sign_instructions_shadow();
			previewSign = new sign_camera();
			socialSign = new sign_social();
			thanksSign = new sign_thanks();
			templates = new TemplateOptions(container);
			thatch = new theThatch();
			
			btnRetake = new btn_arrow_retake();
			btnRetake.filters = [btnShadow];
			btnContinue = new btn_arrow_continue();
			btnContinue.filters = [btnShadow];
			
			whiteFlash = new white();
			flashTimer = new Timer(20, 1);			
			
			limeCount = new lime_count();
			limeTimer = new Timer(1000);
			
			theCamera = new CamPic();
			theCamera.init(1350, 900, 0,0, 892, 494,24); //capture at 1350x900 - preview at 892x494				
		}
		
		
		public function init($theStamp:BitmapData):void
		{
			theStamp = $theStamp;			
			
			thatch.height = 242;
			thatch.x = 0;
			thatch.y = -242;
			
			instructionsSign.x = 506;
			instructionsSign.y = 0 - instructionsSign.height;
			
			previewSign.x = 506;
			previewSign.y = 0 - previewSign.height;
			
			socialSign.x = 506;
			socialSign.y = 0 - socialSign.height;
			
			thanksSign.x = 506;
			thanksSign.y = 0 - thanksSign.height;
			
			signShadow.x = 1013;
			signShadow.y = 924;
			signShadow.scaleX = 0;
			/*
			btnRetake.x = 707;
			btnRetake.y = 745;
			
			btnContinue.x = 1027;
			btnContinue.y = 745;
			*/
			btnRetake.x = 233;
			btnRetake.y = 833;
			
			btnContinue.x = 526;
			btnContinue.y = 833;
			
			instructionsSign.addEventListener(Event.ADDED_TO_STAGE, addInstructions);
			
			container.addChild(thatch);
			container.addChild(instructionsSign);
			container.addChild(signShadow);
		}		
		
		
		private function addInstructions(e:Event = null):void
		{
			instructionsSign.removeEventListener(Event.ADDED_TO_STAGE, addInstructions);			
			TweenMax.to(thatch, .5, { y:0, ease:Linear.easeNone, onComplete:addInstructionsSign } );			
		}
		
		
		private function addInstructionsSign():void
		{
			TweenMax.to(instructionsSign, .75, { y: -90, ease:Bounce.easeOut } );
			TweenMax.to(signShadow, .75, { scaleX:1, ease:Bounce.easeOut } );
			
			instructionsSign.btnGo.addEventListener(MouseEvent.MOUSE_DOWN, removeInstructionItems, false, 0, true);
		}
		
		
		/**
		 * Clears the screen
		 * Calls dispatchReset or dispatchRemove depending on the value of reset
		 * @param	reset
		 */
		public function removeItems(reset:Boolean = false):void
		{
			stopLimeTimer();
			
			TweenMax.to(thatch, .5, { y: -242, ease:Linear.easeNone } );
			
			socialSign.btnDone.removeEventListener(MouseEvent.MOUSE_DOWN, showThanks);
			socialSign.btnFB.removeEventListener(MouseEvent.MOUSE_DOWN, shareOnFB);
			socialSign.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, shareEmail);
			socialSign.btnCheck.removeEventListener(MouseEvent.MOUSE_DOWN, toggleCheck);
			
			templates.hide();			
			templates.removeEventListener(TemplateOptions.TEMPLATES_REMOVED, beginCountDown);			
			templates.removeEventListener(TemplateOptions.TEMPLATE_PICKED, templatePicked);
			templates.removeEventListener(TemplateOptions.TAKE_PHOTO, takePhotoPicked);
			
			flashTimer.removeEventListener(TimerEvent.TIMER, doCapture);
			flashTimer.stop();
			
			if (overlay) {
				if (previewSign.vidHolder.contains(overlay)) {
					previewSign.vidHolder.removeChild(overlay);
				}				
			}
			
			if(previewPic){
				if(previewSign.vidHolder.contains(previewPic)){
					previewSign.vidHolder.removeChild(previewPic);
				}
			}
			
			if (container.contains(instructionsSign)) {
					TweenMax.to(instructionsSign, .75, { y:0 - instructionsSign.height, ease:Back.easeIn } );
			}
			
			if (container.contains(socialSign)) {
					socialSign.alpha = 1;
					TweenMax.to(socialSign, .75, { y:0 - socialSign.height, ease:Back.easeIn } );
			}
			
			if (container.contains(thanksSign)) {
					TweenMax.to(thanksSign, .75, { y:0 - thanksSign.height, ease:Back.easeIn } );
			}
			
			if (container.contains(previewSign)) {
				TweenMax.to(previewSign, .75, { y:0 - previewSign.height, ease:Back.easeIn } );
				if(overlay){
					if (previewSign.vidHolder.contains(overlay)) {
						previewSign.vidHolder.removeChild(overlay);
					}
				}
			}
			
			if (reset) {
				TweenMax.to(signShadow, .75, { scaleX:0, ease:Back.easeIn, onComplete:dispatchReset } );
			}else {
				TweenMax.to(signShadow, .75, { scaleX:0, ease:Back.easeIn, onComplete:dispatchRemove } );
			}
		}
		
		
		/**
		 * Called by clicking the go button on the instructions sign
		 * Removes the instructions sign and then calls addCameraPreview
		 * @param	e MOUSE_DOWN MouseEvent
		 */
		private function removeInstructionItems(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			TweenMax.to(instructionsSign, .75, { y:0 - instructionsSign.height, ease:Back.easeIn } );
			TweenMax.to(signShadow, .75, { scaleX:0, ease:Back.easeIn, onComplete:addCameraPreview } );			
		}
		
		
		/**
		 * Called once the instructions sign is removed
		 * Shows the camera preview
		 */
		private function addCameraPreview():void
		{
			theCamera.show(previewSign.vidHolder);
			
			if(previewSign.contains(btnRetake)){
				previewSign.removeChild(btnRetake);
				previewSign.removeChild(btnContinue);
			}
			
			container.addChild(previewSign);
			TweenMax.to(previewSign, 1, { y: -90, ease:Bounce.easeOut, onComplete:addTemplatePickers } );
			TweenMax.to(signShadow, 1, { scaleX:1, ease:Bounce.easeOut } );
		}
		
		
		/**
		 * Shows the three template options below the camera preview
		 */
		private function addTemplatePickers():void
		{
			if(container.contains(instructionsSign)){
				container.removeChild(instructionsSign);
			}
			templates.show();
			templates.addEventListener(TemplateOptions.TEMPLATE_PICKED, templatePicked, false, 0, true);
			templates.addEventListener(TemplateOptions.TAKE_PHOTO, takePhotoPicked, false, 0, true);
		}
		
		
		/**
		 * Called by clicking one of the template signs in TemplateOptions
		 * @param	e TEMPLATE_PICKED Event
		 */
		private function templatePicked(e:Event):void
		{		
			timeoutHelper.buttonClicked();
			if (overlay) {
				if (previewSign.vidHolder.contains(overlay)) {
					previewSign.vidHolder.removeChild(overlay);
				}				
			}
			var template:BitmapData;
			var stampPoint:Point;//position of the stamp in the template
			switch(templates.getTemplate()) {
				case 1:
					template = new template_overlay_1();
					stampPoint = new Point(1188, 744);
					overlayNum = 1;
					break;
				case 2:
					template = new template_overlay_2();
					stampPoint = new Point(1160, 708);
					overlayNum = 2;
					break;
				case 3:
					template = new template_overlay_3();
					stampPoint = new Point(1150, 704);
					overlayNum = 3;
					break;
			}
			template.copyPixels(theStamp, new Rectangle(0, 0, theStamp.width, theStamp.height), stampPoint, null, null, true);
			
			overlay = new Bitmap(template);
			overlay.width = 892;
			overlay.height = 494;
			overlay.alpha = 0;
			previewSign.vidHolder.addChild(overlay);
			TweenMax.to(overlay, .5, { alpha:1 } );
		}
		
		
		/**
		 * Called from pressing take photo on a template sign
		 * @param	e
		 */
		private function takePhotoPicked(e:Event):void
		{			
			timeoutHelper.buttonClicked();
			templates.addEventListener(TemplateOptions.TEMPLATES_REMOVED, beginCountDown, false, 0, true);
			templates.hide();
		}
		
		
		/**
		 * Called once the template signs are removed 
		 * Adds the lime count
		 * @param	e TEMPLATES_REMOVED Event
		 */
		private function beginCountDown(e:Event):void
		{
			templates.removeEventListener(TemplateOptions.TEMPLATES_REMOVED, beginCountDown);			
			templates.removeEventListener(TemplateOptions.TEMPLATE_PICKED, templatePicked);
			templates.removeEventListener(TemplateOptions.TAKE_PHOTO, takePhotoPicked);
			
			limeCount.x = 643;
			limeCount.y = 1100;
			
			limeCount.l1.alpha = 1;
			limeCount.n1.alpha = 1;
			limeCount.s1.alpha = .3;
			limeCount.l2.alpha = 1;
			limeCount.n2.alpha = 1;
			limeCount.s2.alpha = .3;
			limeCount.l3.alpha = 1;
			limeCount.n3.alpha = 1;
			limeCount.s3.alpha = .3;
			
			container.addChild(limeCount);			
			
			TweenMax.to(limeCount, .75, { y:830, ease:Bounce.easeOut, onComplete:startLimeTimer } );
		}
		
		
		private function startLimeTimer():void
		{
			limeCounter = 4;
			limeTimer.addEventListener(TimerEvent.TIMER, updateLimeCount, false, 0, true);
			limeTimer.start();
		}
		
		
		private function stopLimeTimer():void
		{
			limeTimer.removeEventListener(TimerEvent.TIMER, updateLimeCount);
			limeTimer.stop();
		}
		
		
		private function updateLimeCount(e:TimerEvent):void
		{
			limeCounter--;
			if (limeCounter == 0) {
				stopLimeTimer();
				flashTimer.addEventListener(TimerEvent.TIMER, doCapture, false, 0, true);
				takePic();
			}else {
				limeBeep.play();
				TweenMax.to(limeCount["l" + limeCounter], .3, { alpha:0 } );
				TweenMax.to(limeCount["s" + limeCounter], .3, { alpha:0 } );
				TweenMax.to(limeCount["n" + limeCounter], .3, { alpha:0 } );
			}
		}
		
		
		private function takePic():void
		{
			whiteFlash.alpha = 1;
			container.addChild(whiteFlash);
			TweenMax.to(whiteFlash, 1, { alpha:0, onComplete:killWhite } );
			shutter.play();
			flashTimer.start(); //calls doCapture() in 20ms
		}
		
		
		private function killWhite():void
		{
			if(container.contains(whiteFlash)){
				container.removeChild(whiteFlash);
			}
		}
		
		
		/**
		 * Called by Main.printCard()
		 * and Main.showEmail()
		 * 
		 * Combines the camera captured image, the template and the stamp
		 * 
		 * @param theStamp - the 120x120 bitmap data stamp from the library
		 * 
		 * @return Bitmap of the composed card
		 */
		public function getCard():Bitmap
		{
			var bmp:BitmapData = new BitmapData(theCapture.width, theCapture.height, false, 0xffffff);
			bmp.draw(theCapture);
			
			var stampPoint:Point;//position of the stamp in the template
			
			var template:BitmapData;
			switch(overlayNum) {
				case 1:
					template = new template_overlay_1();//bitmap lib clip
					stampPoint = new Point(1188, 744);
					break;
				case 2:
					template = new template_overlay_2();
					stampPoint = new Point(1160, 708);
					break;
				case 3:
					template = new template_overlay_3();
					stampPoint = new Point(1150, 704);
					break;
			}
			
			bmp.draw(template);
			
			//add stamp to card
			bmp.copyPixels(theStamp, new Rectangle(0, 0, theStamp.width, theStamp.height), stampPoint, null, null, true);			
			
			return new Bitmap(bmp);
		}
		
		
		/**
		 * Called by timer from takePic
		 * gets the camera image when the white flash is displayed
		 * @param	e
		 */
		private function doCapture(e:TimerEvent):void
		{			
			theCapture = new Bitmap(theCamera.getCapture());
			previewPic = new Bitmap(theCamera.getDisplay());
			
			//add behind the template
			previewSign.vidHolder.addChildAt(previewPic, previewSign.vidHolder.numChildren - 1);
			
			btnRetake.alpha = 0;
			btnContinue.alpha = 0;
			
			previewSign.addChild(btnRetake);
			previewSign.addChild(btnContinue);
			
			TweenMax.to(btnRetake, .5, { alpha:1 } );
			TweenMax.to(btnContinue, .5, { alpha:1 } );
			
			btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retake, false, 0, true);
			btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, hideCam, false, 0, true);
		}
		
		
		private function retake(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, retake);
			previewSign.removeChild(btnRetake);
			previewSign.removeChild(btnContinue);
			previewSign.vidHolder.removeChild(previewPic);
			if (overlay) {
				if (previewSign.vidHolder.contains(overlay)) {
					previewSign.vidHolder.removeChild(overlay);
				}				
			}
			addTemplatePickers();
		}
		
		
		
		/**
		 * Called by clicking continue button after taking photo
		 * ie after user has accepted the photo they took
		 * turns off the camera before swapping the signs
		 * @param	e
		 */
		private function hideCam(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			theCamera.dispose();
			
			//300ms to allow camera to turn off before animating signs
			var a:Timer = new Timer(300, 1);
			a.addEventListener(TimerEvent.TIMER, showSocialSign, false, 0, true);
			a.start();
		}
		
		
		
		/**
		 * Dispatches a print_card - calls Main.prinCard()
		 * @param	e
		 */
		private function showSocialSign(e:TimerEvent):void
		{
			dispatchEvent(new Event(PRINT_CARD));
			
			container.addChild(socialSign);
			TweenMax.to(previewSign, .75, { y:0 - previewSign.height, ease:Back.easeIn, onComplete:removePreview } );
			TweenMax.to(signShadow, .75, { scaleX:0, ease:Back.easeIn } );	
			TweenMax.to(socialSign, .75, { y: -90, ease:Bounce.easeOut, delay:.75 } );
			TweenMax.to(signShadow, .75, { scaleX:1, ease:Back.easeOut, delay:.75 } );
			
			socialSign.theCheck.alpha = 0;
			
			socialSign.btnDone.addEventListener(MouseEvent.MOUSE_DOWN, showThanks, false, 0, true);
			socialSign.btnFB.addEventListener(MouseEvent.MOUSE_DOWN, shareOnFB, false, 0, true);
			socialSign.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, shareEmail, false, 0, true);
			socialSign.btnCheck.addEventListener(MouseEvent.MOUSE_DOWN, toggleCheck, false, 0, true);
		}
		
		
		private function toggleCheck(e:MouseEvent):void
		{
			if (socialSign.theCheck.alpha == 0) {
				socialSign.theCheck.alpha = 1;
			}else {
				socialSign.theCheck.alpha = 0;
			}
		}
		
		
		/**
		 * Called by main if facebook login fails, the listener is removed in shareOnFB() when the
		 * button is clicked, to prevent it from being clicked twice as the dialog may take a moment
		 * to appear.
		 */
		public function enableFBButton():void
		{
			socialSign.btnFB.addEventListener(MouseEvent.MOUSE_DOWN, shareOnFB, false, 0, true);
		}
		private function removePreview():void
		{
			if(container.contains(previewSign)){
				container.removeChild(previewSign);
			}			
		}
		
		
		private function showThanks(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			dispatchEvent(new Event(HIDE_DIALOG));
			
			container.addChild(thanksSign);
			TweenMax.to(socialSign, .75, { y:0 - socialSign.height, ease:Back.easeIn, onComplete:removeSocial } );
			TweenMax.to(signShadow, .75, { scaleX:0, ease:Back.easeIn } );	
			TweenMax.to(thanksSign, .75, { y: -90, ease:Bounce.easeOut, delay:.75, onComplete:removeThanks } );
			TweenMax.to(signShadow, .75, { scaleX:1, ease:Back.easeOut, delay:.75 } );
		}
		
		
		//called from Main when an app timeout appears and the camera image is being
		//turns off the camera
		public function disposeCam():void
		{
			theCamera.dispose();
		}
		
		
		private function removeThanks():void
		{
			TweenMax.to(thanksSign, .75, { y:0 - thanksSign.height, ease:Back.easeIn, delay:2, onComplete:removeItems, onCompleteParams:[true] } );
			TweenMax.to(signShadow, .75, { scaleX:0, delay:2, ease:Back.easeIn } );	
		}
		
		
		private function removeSocial():void
		{
			if(container.contains(socialSign)){
				container.removeChild(socialSign);
			}
		}
		
		
		private function shareOnFB(e:MouseEvent):void
		{
			if(socialSign.theCheck.alpha == 1){
				timeoutHelper.buttonClicked();
				socialSign.btnFB.removeEventListener(MouseEvent.MOUSE_DOWN, shareOnFB);
				dispatchEvent(new Event(SHARE_FACEBOOK));//calls Main.facebookLogin()
			}else {
				dispatchEvent(new Event(SHARE_AGREE));//calls Main.shareError()
			}
		}
		
		
		private function shareEmail(e:MouseEvent):void
		{
			//socialSign.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, shareEmail);
			if(socialSign.theCheck.alpha == 1){
				dispatchEvent(new Event(SHARE_EMAIL));//picked up by Main - calls Main.showEmail()
			}else {
				dispatchEvent(new Event(SHARE_AGREE));//calls Main.shareError()
			}
		}
		
		/**
		 * Hides the social sign when the email dialog is showing
		 */
		public function hideSocial():void
		{
			socialSign.alpha = 0;
		}
		public function showSocial():void
		{
			socialSign.alpha = 1;
		}
		
		
		/**
		 * ITEMS_REMOVED Event tells Main that items are removed from the
		 * screen and the app can continue to the next screen
		 */
		private function dispatchRemove():void
		{
			dispatchEvent(new Event(ITEMS_REMOVED));
		}
		
		
		/**
		 * RESET Event tells Main that items are removed from the screen
		 * and that the app should reset to the beginning
		 */
		private function dispatchReset():void
		{
			dispatchEvent(new Event(RESET));
		}
	}
	
}