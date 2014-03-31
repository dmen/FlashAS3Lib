package com.gmrmarketing.holiday2012
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.filters.ColorMatrixFilter;
	import flash.ui.Mouse;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.media.Sound;
	import flash.utils.Timer;
	import flash.desktop.NativeApplication;
	
	import com.gmrmarketing.holiday2012.Intro;
	import com.gmrmarketing.utilities.CamPic;
	import com.gmrmarketing.utilities.CamPicFilters;
	import com.gmrmarketing.holiday2012.Countdown;
	import com.gmrmarketing.holiday2012.WhiteFlash;
	import com.gmrmarketing.holiday2012.Share;
	import com.gmrmarketing.holiday2012.Thanks;
	import com.gmrmarketing.holiday2012.WebServices;	
	import com.gmrmarketing.keyboard.KeyBoard;
	import com.gmrmarketing.utilities.CornerQuit;
	
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.Validator;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var choose:Choose;
		private var camPic:CamPic;
		private var share:Share;
		private var countdown:Countdown; //3-2-1 counter
		private var whiteFlash:WhiteFlash; //white flash
		private var thanks:Thanks; //final thankyou dialog
		
		private var cq:CornerQuit;
		
		private var watermarkOne:BitmapData;
		private var watermarkFour:BitmapData;
		private var watermarkPete:BitmapData;
		
		private var photos:Array; //array of captured bitmapData objects
		
		private var previewData:BitmapData;
		
		private var config:XML;
		private var loader:URLLoader;
		
		private var kbd:KeyBoard;
		private var kbdHolder:MovieClip;
		private var web:WebServices;
		
		private var shutterSound:Sound;
		private var timeoutHelper:TimeoutHelper;
		
		
		public function Main()
		{			
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			intro = new Intro();
			intro.setContainer(this);
			
			choose = new Choose();
			choose.setContainer(this);
			
			share = new Share();
			share.setContainer(this);
			
			countdown = new Countdown();
			countdown.setContainer(this);
			
			whiteFlash = new WhiteFlash();
			whiteFlash.setContainer(this);
			
			thanks = new Thanks();
			thanks.setContainer(this);
			
			shutterSound = new soundShutter();
			
			web = new WebServices();			
			
			watermarkFour = new watermark_four();
			watermarkOne = new watermark_one();
			watermarkPete = new bmpPete();
			
			kbd = new KeyBoard();
			kbd.addEventListener(KeyBoard.KBD, resetTimeout, false, 0, true);
			kbd.loadXML("keyboard.xml");
			
			kbdHolder = new mc_kbdHolder();
			
			camPic = new CamPic();
			camPic.init(674, 870, 0, 0, 0, 0, 30, true);
			
			cq = new CornerQuit();
			cq.init(this, "ullr");
			cq.customLoc(2, new Point(1530, 900));
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			timeoutHelper = TimeoutHelper.getInstance();
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, reset, false, 0, true);
			timeoutHelper.init(120000); //2 min
			timeoutHelper.startMonitoring();
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			loader.load(new URLRequest("config.xml"));
		}
		
		
		private function xmlLoaded(e:Event):void
		{
			config = new XML(e.target.data); //contains image processing data			
			web.setServiceURL(config.webServiceURL);
			web.refreshQueue();
			init();
		}
		
		
		private function init():void
		{		
			photos = new Array();
			intro.addEventListener(Intro.CLICKED, introClicked, false, 0, true);
			intro.show();
			cq.moveToTop();
		}
		
		
		/**
		 * Called when a key on the virtual keyboard is pressed
		 * @param	e
		 */
		private function resetTimeout(e:Event):void
		{
			timeoutHelper.buttonClicked();
		}
		
		
		private function introClicked(e:Event):void
		{			
			timeoutHelper.buttonClicked();
			
			intro.removeEventListener(Intro.CLICKED, introClicked);
			choose.addEventListener(Choose.SHOWING, removeIntro, false, 0, true);
			choose.addEventListener(Choose.CAM_SHOWING, showCamera, false, 0, true);
			choose.addEventListener(Choose.TAKE_PIC, beginTakingPictures, false, 0, true);
			choose.addEventListener(Choose.RETAKE, retakePhotos, false, 0, true);
			choose.addEventListener(Choose.CONTINUE, continuePressed, false, 0, true);
			choose.addEventListener(Choose.TEMPLATE_CHANGED, templateChanged, false, 0, true);
			choose.show();
			cq.moveToTop();
		}
		
		
		private function removeIntro(e:Event):void
		{
			choose.removeEventListener(Choose.SHOWING, removeIntro);
			intro.hide();
		}
		
		
		private function showCamera(e:Event):void
		{
			choose.removeEventListener(Choose.CAM_SHOWING, showCamera);
			camPic.clearFilters();
			camPic.show(choose.getCamContainer());
		}
		
		private function templateChanged(e:Event):void
		{
			var t:int = choose.getTemplateNumber();
			camPic.clearFilters();
			if (t == 2) {				
				camPic.addFilter(CamPicFilters.gray());
			}
		}
		
		
		/**
		 * Called when user presses the take picture button in Choose
		 * @param	e
		 */
		private function beginTakingPictures(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			var numPics = choose.getTemplateNumber() == 1 || choose.getTemplateNumber() == 2 ? 1 : 4;
			
			countdown.show(numPics);
			countdown.start();
			countdown.addEventListener(Countdown.COUNT_FINISHED, grabCapture, false, 0, true);
		}
		
		/**
		 * Called when the 3-2-1 counter is finished
		 * @param	e
		 */
		private function grabCapture(e:Event):void
		{		
			shutterSound.play();
			whiteFlash.show();
			
			photos.push(camPic.getCapture());			
			
			if (photos.length < 4 && (choose.getTemplateNumber() == 3 || choose.getTemplateNumber() == 4)) {
				//take another picture
				countdown.start();
			}else {
				
				//done taking images
				
				//alpha data
				var alphaData:BitmapData = new BitmapData(674, 870, true, 0x33ffffff);
				
				//tints
				var redTint:BitmapData = new BitmapData(674, 870, true, 0xffff0000);
				var yellowTint:BitmapData = new BitmapData(674, 870, true, 0xffffff00);
				var blueTint:BitmapData = new BitmapData(674, 870, true, 0xff00ffff);	
			
				previewData = new BitmapData(674, 870, false, 0x000000);
				
				var grayFilter:ColorMatrixFilter = CamPicFilters.gray();
				var grayBrightnessFilter:ColorMatrixFilter = CamPicFilters.brightness(config.gray.brightness);
				var grayContrastFilter:ColorMatrixFilter = CamPicFilters.contrast(config.gray.contrast);
				var graySaturationFilter:ColorMatrixFilter = CamPicFilters.saturation(config.gray.saturation);
				
				var colorBrightnessFilter:ColorMatrixFilter = CamPicFilters.brightness(config.color.brightness);
				var colorContrastFilter:ColorMatrixFilter = CamPicFilters.contrast(config.color.contrast);
				var colorSaturationFilter:ColorMatrixFilter = CamPicFilters.saturation(config.color.saturation);
				
				//done -- show preview - photos contains bitmapData objects at 674x870
				if (choose.getTemplateNumber() == 3 || choose.getTemplateNumber() == 4) {
					
					//if template 4 make all images grayscale first
					if (choose.getTemplateNumber() == 4) {
						photos[0].applyFilter(photos[0], photos[0].rect, new Point(0, 0), grayFilter);
						photos[1].applyFilter(photos[1], photos[1].rect, new Point(0, 0), grayFilter);
						photos[2].applyFilter(photos[2], photos[2].rect, new Point(0, 0), grayFilter);
						photos[3].applyFilter(photos[3], photos[3].rect, new Point(0, 0), grayFilter);
						
						//amp up the brightness a little
						photos[0].applyFilter(photos[0], photos[0].rect, new Point(0, 0), grayBrightnessFilter);
						photos[1].applyFilter(photos[1], photos[1].rect, new Point(0, 0), grayBrightnessFilter);
						photos[2].applyFilter(photos[2], photos[2].rect, new Point(0, 0), grayBrightnessFilter);
						photos[3].applyFilter(photos[3], photos[3].rect, new Point(0, 0), grayBrightnessFilter);
						
						//apply tints
						photos[1].copyPixels(redTint, redTint.rect, new Point(0, 0), alphaData, new Point(0, 0), true);
						photos[2].copyPixels(yellowTint, yellowTint.rect, new Point(0, 0), alphaData, new Point(0, 0), true);
						photos[3].copyPixels(blueTint, blueTint.rect, new Point(0, 0), alphaData, new Point(0, 0), true);
						
						//amp up the contrast a little
						photos[0].applyFilter(photos[0], photos[0].rect, new Point(0, 0), grayContrastFilter);
						photos[1].applyFilter(photos[1], photos[1].rect, new Point(0, 0), grayContrastFilter);
						photos[2].applyFilter(photos[2], photos[2].rect, new Point(0, 0), grayContrastFilter);
						photos[3].applyFilter(photos[3], photos[3].rect, new Point(0, 0), grayContrastFilter);
						
						//amp up the saturation a little
						photos[0].applyFilter(photos[0], photos[0].rect, new Point(0, 0), graySaturationFilter);
						photos[1].applyFilter(photos[1], photos[1].rect, new Point(0, 0), graySaturationFilter);
						photos[2].applyFilter(photos[2], photos[2].rect, new Point(0, 0), graySaturationFilter);
						photos[3].applyFilter(photos[3], photos[3].rect, new Point(0, 0), graySaturationFilter);
					}else {
						
						//template is three - four color images
						photos[0].applyFilter(photos[0], photos[0].rect, new Point(0, 0), colorBrightnessFilter);
						photos[0].applyFilter(photos[0], photos[0].rect, new Point(0, 0), colorContrastFilter);
						photos[0].applyFilter(photos[0], photos[0].rect, new Point(0, 0), colorSaturationFilter);
						
						photos[1].applyFilter(photos[1], photos[1].rect, new Point(0, 0), colorBrightnessFilter);
						photos[1].applyFilter(photos[1], photos[1].rect, new Point(0, 0), colorContrastFilter);
						photos[1].applyFilter(photos[1], photos[1].rect, new Point(0, 0), colorSaturationFilter);
						
						photos[2].applyFilter(photos[2], photos[2].rect, new Point(0, 0), colorBrightnessFilter);
						photos[2].applyFilter(photos[2], photos[2].rect, new Point(0, 0), colorContrastFilter);
						photos[2].applyFilter(photos[2], photos[2].rect, new Point(0, 0), colorSaturationFilter);
						
						photos[3].applyFilter(photos[3], photos[3].rect, new Point(0, 0), colorBrightnessFilter);
						photos[3].applyFilter(photos[3], photos[3].rect, new Point(0, 0), colorContrastFilter);
						photos[3].applyFilter(photos[3], photos[3].rect, new Point(0, 0), colorSaturationFilter);
					}
					
					//draw four captures into full size image
					var fourData:BitmapData = new BitmapData(1348, 1740, false, 0x000000);
					
					fourData.copyPixels(photos[0], photos[0].rect, new Point(0, 0));
					fourData.copyPixels(photos[1], photos[0].rect, new Point(674, 0));
					fourData.copyPixels(photos[2], photos[0].rect, new Point(0, 870));
					fourData.copyPixels(photos[3], photos[0].rect, new Point(674, 870));
					
					var m:Matrix = new Matrix();
					m.scale(.5, .5);
					
					//draw full size four into preview
					previewData.draw(fourData, m);					
					previewData.draw(watermarkFour, null, null, null, null, true);
					
					
				}else {
					//draw single capture into preview
					
					//apply grayscale filters if template 2
					if (choose.getTemplateNumber() == 2) {						
						photos[0].applyFilter(photos[0], photos[0].rect, new Point(0, 0), grayFilter);
						photos[0].applyFilter(photos[0], photos[0].rect, new Point(0, 0), grayBrightnessFilter);
						photos[0].applyFilter(photos[0], photos[0].rect, new Point(0, 0), grayContrastFilter);
					}else {
						//template 1 - color image
						photos[0].applyFilter(photos[0], photos[0].rect, new Point(0, 0), colorBrightnessFilter);
						photos[0].applyFilter(photos[0], photos[0].rect, new Point(0, 0), colorContrastFilter);
						photos[0].applyFilter(photos[0], photos[0].rect, new Point(0, 0), colorSaturationFilter);
					}
					
					previewData.draw(photos[0]);
					if (choose.getPete()) {
						if (choose.getTemplateNumber() == 2) {
							var p:Bitmap = new Bitmap(watermarkPete);
							p.filters = [CamPicFilters.gray()];
							previewData.draw(p, null, null, null, null, true);
						}else{
							previewData.draw(watermarkPete, null, null, null, null, true);
						}
					}else {
						previewData.draw(watermarkOne, null, null, null, null, true);
					}
				}
				
				var preview:Bitmap = new Bitmap(previewData);				
				
				choose.showPreview(preview);
				countdown.hide();
				
				var a:Timer = new Timer(500, 1);
				a.addEventListener(TimerEvent.TIMER, processImage, false, 0, true);
				a.start();
			}
		} //function
		
		
		/**
		 * Called if user presses Retake in Choose
		 * @param	e
		 */
		private function retakePhotos(e:Event):void
		{
			timeoutHelper.buttonClicked();			
			photos = new Array();
		}
		
		
		/**
		 * Called once user presses Continue in Choose
		 * @param	e
		 */
		private function continuePressed(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			photos = new Array();
			//final image in previewData
			share.addEventListener(Share.SHOWING, removeChoose, false, 0, true);
			share.addEventListener(Share.CANCEL, shareCanceled, false, 0, true);
			share.addEventListener(Share.EMAIL, emailClicked, false, 0, true);
			share.show(previewData);
			cq.moveToTop();
		}
		
		
		private function removeChoose(e:Event):void
		{
			share.removeEventListener(Share.SHOWING, removeChoose);
			camPic.hide();
			choose.hide();
			choose.removeEventListener(Choose.TEMPLATE_CHANGED, templateChanged);
			choose.removeEventListener(Choose.SHOWING, removeIntro);
			choose.removeEventListener(Choose.CAM_SHOWING, showCamera);
			choose.removeEventListener(Choose.TAKE_PIC, beginTakingPictures);
			choose.removeEventListener(Choose.RETAKE, retakePhotos);
			choose.removeEventListener(Choose.CONTINUE, continuePressed);
		}
		
		
		/**
		 * user canceled sharing
		 * reset app
		 * @param	e
		 */
		private function shareCanceled(e:Event):void
		{			
			timeoutHelper.buttonClicked();
			share.removeEventListener(Share.CANCEL, shareCanceled);
			share.removeEventListener(Share.EMAIL, emailClicked);
			share.hide();
			thanks.removeEventListener(Thanks.DONE, reset);
			TweenMax.killAll();
			init();
		}
		
		
		/**
		 * Called when the email button is clicked
		 * shows the holder and keyboard
		 * @param	e
		 */
		private function emailClicked(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			share.removeEventListener(Share.EMAIL, emailClicked);
			
			kbdHolder.x = 344;
			kbdHolder.y = 300;
			addChild(kbdHolder);
			kbdHolder.theText.text = "";
			
			kbd.x = 372;
			kbd.y = 600;
			kbd.alpha = 0;
			addChild(kbd);
			kbd.enableKeyboard();
			kbd.setFocusFields([kbdHolder.theText]);
			kbd.addEventListener(KeyBoard.SUBMIT, submitClicked, false, 0, true);			
			
			TweenMax.to(kbd, 1, { alpha:1, y:428} );
		}
		
		
		/**
		 * Sends the captured image to WebServices to save on the desktop and
		 * get ready for emailing
		 * Called from grabCapture after 500ms to allow the white
		 * flash to show
		 * @param	e
		 */
		private function processImage(e:TimerEvent):void
		{
			web.processImage(previewData);
		}
		
		
		/**
		 * Called when the Send button on the keyboard is clicked
		 * @param	e
		 */
		private function submitClicked(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			if(Validator.isValidEmail(kbdHolder.theText.text)){
				kbd.disableKeyboard();//so submit can't be pressed twice
				web.queueImage(kbdHolder.theText.text);
				thanks.addEventListener(Thanks.DONE, reset, false, 0, true);
				thanks.show();
			}else {
				//invalid email
				kbd.disableKeyboard();
				kbdHolder.theText.y = -1000;
				kbdHolder.valid.alpha = 1;
				TweenMax.to(kbdHolder.valid, .5, { alpha:0, delay:1.5, onComplete:restoreEmail } );
			}
		}
		
		
		private function restoreEmail():void
		{
			kbdHolder.valid.alpha = 0;
			kbdHolder.theText.y = 44;
			kbdHolder.stage.focus = kbdHolder.theText;
			kbd.enableKeyboard();
		}
		
		
		private function reset(e:Event):void
		{
			thanks.removeEventListener(Thanks.DONE, reset);
			
			choose.hide();
			camPic.hide();
			
			share.removeEventListener(Share.CANCEL, shareCanceled);
			share.removeEventListener(Share.EMAIL, emailClicked);
			share.hide();
			
			init();
		}
		
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}