package com.gmrmarketing.miller.sxsw
{
	import adobe.utils.CustomActions;
	import com.sagecollective.utilities.TimeoutHelper;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.CamPic;
	import com.gmrmarketing.utilities.CamPicFilters;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Matrix;
	import com.greensock.TweenMax;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;	
	
	
	public class Preview extends EventDispatcher
	{
		public static const PREVIEW_ADDED:String = "previewAdded";
		public static const PHOTO_TAKEN:String = "photoTaken";
		
		private var timeoutHelper:TimeoutHelper;
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var theCamera:CamPic;
		private var camHolder:Sprite;
		private var theCapture:Bitmap;//full size camera pic - set in takePic()
		private var theOriginal:BitmapData;//camera size cam pic without filters - set in takePic();
		
		private var templateHolder:Sprite;
		private var currentTemplateImage:BitmapData;
		private var currentTemplateNumber:int;
		
		private var countdownTimer:Timer;
		private var countdownCounter:int;
		private var shutter:Sound;
		private var countBeep:Sound;
		
		
		public function Preview()
		{
			timeoutHelper = TimeoutHelper.getInstance();			
			clip = new preview(); //lib clip
			
			countdownTimer = new Timer(1000);
			
			shutter = new soundShutter(); //lib
			countBeep = new soundBeep();
			
			theCamera = new CamPic();
			theCamera.init(409, 530, 818, 1059, 684, 886, 24); //capture at 818x1059 - preview at 684x886
			
			camHolder = new Sprite();
			camHolder.x = 531;
			camHolder.y = 57;
			
			templateHolder = new Sprite();
			templateHolder.x = 531;
			templateHolder.y = 57;
			
			clip.addChildAt(templateHolder, 1);
			clip.addChildAt(camHolder, 1);
		}
		
		
		public function show($container:DisplayObjectContainer):void
		{
			container = $container;
			clip.alpha = 0;
			container.addChild(clip);
			
			theCamera.show(camHolder);
			
			clip.t1.addEventListener(MouseEvent.MOUSE_DOWN, changeTemplate, false, 0, true);
			clip.t2.addEventListener(MouseEvent.MOUSE_DOWN, changeTemplate, false, 0, true);
			clip.t3.addEventListener(MouseEvent.MOUSE_DOWN, changeTemplate, false, 0, true);
			
			//clip.ti1.theText.text = "VIP AFTERPARTY - " + dateString(1);
			//clip.ti2.theText.text = "VIP AFTERPARTY " + dateString(2);
			clip.ti1.theText.text = dateString(1);
			clip.ti2.theText.text = dateString(2);
			clip.ti3.theText.text = dateString(3);
			
			doRetake();
			changeTemplate(); //show default template 2
			
			TweenMax.to(clip, 1, { alpha:1, onComplete:clipAdded } );
		}
		
		
		public function fade():void
		{
			TweenMax.to(clip, 1, { alpha:0 } );
		}
		
		
		public function hide():void
		{
			theCamera.dispose();
			clip.t1.removeEventListener(MouseEvent.MOUSE_DOWN, changeTemplate);
			clip.t2.removeEventListener(MouseEvent.MOUSE_DOWN, changeTemplate);
			clip.t3.removeEventListener(MouseEvent.MOUSE_DOWN, changeTemplate);
			if (container) {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}
			
		}
		
		
		/**
		 * Returns the full-size poster 818 x 1059
		 * 
		 * @return
		 */
		public function getPoster():BitmapData
		{
			//final cam image in theCapture
			var finalImage:BitmapData = new BitmapData(818, 1059, true, 0x00000000);
			finalImage.copyPixels(theCapture.bitmapData, theCapture.bitmapData.rect, new Point(0, 0));
			finalImage.copyPixels(currentTemplateImage, currentTemplateImage.rect, new Point(0, 0), currentTemplateImage, new Point(0,0), true);
			var title:MovieClip;
			switch(currentTemplateNumber) {
				case 1:
					title = new title1();
					//title.theText.text = "VIP AFTERPARTY - " + dateString(1);
					title.theText.text = dateString(1);
					break;
				case 2:
					title = new title2();
					//title.theText.text = "VIP AFTERPARTY " + dateString(2);
					title.theText.text = dateString(2);
					break;
				case 3:
					title = new title3();
					title.theText.text = dateString(3);
					break;
			}
			
			finalImage.draw(title, null, null, null, null, true);			
			
			return finalImage;
		}
		
		
		
		/**
		 * Returns the camera sized (409x530) bitmap data of the captured
		 * camera image with no filters applied
		 * 
		 * theOriginal is set in takePic()
		 * 
		 * @return BitmapData
		 */
		public function getOriginal():BitmapData
		{
			return theOriginal;
		}
		
		
		
		private function dateString(tempNumber:int):String
		{
			var d:Date = new Date();
			var months:Array = new Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
			//t1: July 12, 2012
			//t2: 7 - 10 - 12
			//t3: July 12, 2012
			
			var r:String;
			if (tempNumber == 2) {
				var y:String = String(d.getFullYear());				
				r = String(d.getMonth() + 1) + " - " + String(d.getDate()) + " - " + y.substr(2);
				return r.toUpperCase();
			}else {
				//t1 or t3
				r = months[d.getMonth()] + " " + String(d.getDate()) + ", " + String(d.getFullYear());
				return r.toUpperCase();
			}
			
		}
		
		private function clipAdded():void
		{
			dispatchEvent(new Event(PREVIEW_ADDED));			
		}
		
		
		/**
		 * Called by clicking a template selector image
		 * Called from show() to set the default
		 * @param	e
		 */
		private function changeTemplate(e:MouseEvent = null):void
		{
			timeoutHelper.buttonClicked();
			
			var n:String;
			if (e == null) {
				n = "t2";
			}else {
				n = MovieClip(e.currentTarget).name; //t1 - t3
			}
			
			switch(n) {
				case "t1":
					//grayscale
					theCamera.clearFilters();
					theCamera.addFilter(CamPicFilters.gray());					
					addTemplate(1);
					break;
				case "t2":
					//circle
					theCamera.clearFilters();					
					addTemplate(2);
					break;
				case "t3":
					//saturated
					theCamera.clearFilters();
					theCamera.addFilter(CamPicFilters.saturation(30));
					theCamera.addFilter(CamPicFilters.contrast(30));
					theCamera.addFilter(CamPicFilters.brightness(30));
					theCamera.addFilter(CamPicFilters.blur());				
					addTemplate(3);
					break;
			}
		}
		
		
		private function addTemplate(templateNumber:int):void
		{
			currentTemplateNumber = templateNumber;
			
			while (templateHolder.numChildren > 0) {
				templateHolder.removeChildAt(0);
			}
			
			var templateTitle:MovieClip;			
			
			var tempData:BitmapData;
			var fullData:BitmapData;
			
			switch(templateNumber) {
				case 1:
					tempData = new t1_preview();
					fullData = new t1_full();
					templateTitle = new title1();
					//templateTitle.theText.text = "VIP AFTERPARTY - " + dateString(1);
					templateTitle.theText.text = dateString(1);
					break;
				case 2:
					tempData = new t2_preview();
					fullData = new t2_full();
					templateTitle = new title2();
					//templateTitle.theText.text = "VIP AFTERPARTY " + dateString(2);
					templateTitle.theText.text = dateString(2);
					break;
				case 3:
					tempData = new t3_preview();
					fullData = new t3_full();
					templateTitle = new title3();
					templateTitle.theText.text = dateString(3);
					break;
			}
			
			currentTemplateImage = fullData;
			
			var temp:Bitmap = new Bitmap(tempData, "auto", true);
			templateHolder.addChild(temp);
			
			templateTitle.scaleX = templateTitle.scaleY = .8333333;
			templateHolder.addChild(templateTitle);
		}
		
		
		/**
		 * Called when Take Pic is pressed
		 * @param	e
		 */
		private function beginCountdown(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			clip.btnTakePic.removeEventListener(MouseEvent.MOUSE_DOWN, beginCountdown);
			
			TweenMax.to(clip.btnTakePic, .5, { y:1150 } );//animate off screen
			//animate countdown circles onto screen
			TweenMax.to(clip.c3, .5, { y:962, alpha:1 } );
			TweenMax.to(clip.c2, .5, { y:962, alpha:1, delay:.2 } );
			TweenMax.to(clip.c1, .5, { y:962, alpha:1, delay:.4 } );
			
			countdownCounter = 4;
			countdownTimer.addEventListener(TimerEvent.TIMER, updateCountdown, false, 0, true);
			countdownTimer.start();
		}
		
		
		private function stopCountdown():void
		{
			countdownTimer.removeEventListener(TimerEvent.TIMER, updateCountdown);
			countdownTimer.stop();
		}
		
		
		private function updateCountdown(e:TimerEvent):void
		{
			countdownCounter--;
			if (countdownCounter == 0) {				
				stopCountdown();
				takePic();
			}else {
				countBeep.play();
				TweenMax.to(clip["c" + countdownCounter], .3, { alpha:.3 } );
			}
		}
		
		/**
		 * Called from updateCountdown() when the countdown reaches 0
		 */
		private function takePic():void
		{
			shutter.play();
			
			clip.whiteFlash.alpha = 1;			
			TweenMax.to(clip.whiteFlash, 1, { alpha:0 } );
			
			theCapture = new Bitmap(theCamera.getCapture());//fullsize
			theOriginal = theCamera.getCamera(false); //cam size with no filters
			
			theCamera.pause();
			
			//hide countdown numbers
			TweenMax.to(clip.c3, .5, { y:1150 } );
			TweenMax.to(clip.c2, .5, { y:1150 } );
			TweenMax.to(clip.c1, .5, { y:1150 } );
			
			//show retake and continue
			TweenMax.to(clip.btnRetake, .5, { y:907 } );
			TweenMax.to(clip.btnContinue, .5, { y:907 } );			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, doRetake, false, 0, true);
			clip.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, picTaken, false, 0, true);
		}
		
		
		private function doRetake(e:MouseEvent = null):void
		{
			timeoutHelper.buttonClicked();
			
			//hide count down
			clip.c1.y = 1150;
			clip.c2.y = 1150;
			clip.c3.y = 1150;
			clip.whiteFlash.alpha = 0;			
			
			TweenMax.to(clip.btnTakePic, .5, { y:894 } );
			TweenMax.to(clip.btnRetake, .5, { y:1150 } );
			TweenMax.to(clip.btnContinue, .5, { y:1150 } );		
			
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, doRetake);
			clip.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, picTaken);
			
			clip.btnTakePic.addEventListener(MouseEvent.MOUSE_DOWN, beginCountdown, false, 0, true);
			
			theCamera.resume();
		}
		
		
		private function picTaken(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();			
			dispatchEvent(new Event(PHOTO_TAKEN));
		}
	}
	
}