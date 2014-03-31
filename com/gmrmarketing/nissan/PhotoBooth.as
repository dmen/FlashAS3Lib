package com.gmrmarketing.nissan
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import com.gmrmarketing.nissan.BaseButton;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	import com.gmrmarketing.bicycle.SWFKitFiles;
	import com.dynamicflash.util.Base64;
	import com.adobe.images.JPGEncoder;
	import flash.utils.ByteArray;
	
	

	public class PhotoBooth extends MovieClip
	{
		private var cam:Camera;
		private var theVideo:Video;
		private var camWidth:int;
		private var camHeight:int;
		private var blank:BitmapData;
		private var cap:Bitmap;
		
		private var takePic:BaseButton;
		private var retake:BaseButton;
		private var submit:BaseButton;
		
		//private var pressTake:pressTakePhoto; //lib clip
		private var getReady:getReadyText; //lib clip
		
		private var countDown:countdown; //lib clip
				
		private var whiteFlash:Shape;
		
		private var picX:int = 106;
		private var picY:int = 137;
		
		private var swfKit:SWFKitFiles;		
		
		private var thanks:thankYou; //lib clip
		
		private var restartTimer:Timer;
		
		
		
		public function PhotoBooth()
		{			
			swfKit = new SWFKitFiles();
			
			whiteFlash = new Shape();
			whiteFlash.graphics.beginFill(0xFFFFFF);
			whiteFlash.graphics.drawRect(0, 0, 500, 600);
			whiteFlash.x = picX;
			whiteFlash.y = picY;
			
			restartTimer = new Timer(45000, 1);
			restartTimer.addEventListener(TimerEvent.TIMER, retakePressed, false, 0, true);
			
			cam = Camera.getCamera();				
			
			if (!cam) {
				trace("No camera present!");					
			}else {
				init();
			}
		}
		
		
		
		private function init():void
		{
			cam.setMode(500, 600, 30);
			cam.setQuality(0, 100);
			
			camWidth = cam.width;
			camHeight = cam.height;
			
			blank = new BitmapData(camWidth, camHeight);
			cap = new Bitmap(blank);
				
			theVideo = new Video(camWidth, camHeight);
			theVideo.attachCamera(cam);
			
			theVideo.x = picX;
			theVideo.y = picY;
			
			//pressTake = new pressTakePhoto();
			//pressTake.x = 638;
			//pressTake.y = 417;
			
			countDown = new countdown();
			countDown.x = 638;
			countDown.y = 446;
			
			getReady = new getReadyText();
			getReady.x = 638;
			getReady.y = 513;
			
			takePic = new BaseButton("take photo");			
			takePic.x = 647;
			takePic.y = 350;
			
			retake = new BaseButton("retake");			
			retake.x = 647;
			retake.y = 350;
			
			submit = new BaseButton("save");			
			submit.x = 647;
			submit.y = 430;
			
			thanks = new thankYou();
			thanks.x = 643;
			thanks.y = 508;			
			
			begin();
		}
		
		
		
		/**
		 * Called from constructor - adds the take pic button and the camera video to the stage
		 * called from retakePressed()
		 */
		private function begin():void
		{
			//addChild(pressTake);
			addChild(takePic);
			takePic.addEventListener(MouseEvent.CLICK, beginCapture, false, 0, true);
			
			addChild(countDown);
			addChild(theVideo);
		}
		
		
		/**
		 * Called when the take picture button is pressed
		 * @param	e
		 */
		private function beginCapture(e:MouseEvent):void
		{
			//removeChild(pressTake);
			//removeChild(takePic);
			takePic.removeEventListener(MouseEvent.CLICK, beginCapture);
			
			takePic.yellow.alpha = 1;
			TweenMax.to(takePic.yellow, .25, { alpha:0 } );
			
			//addChild(countDown);			
			
			addChild(getReady);
			
			TweenMax.to(countDown.three, 0, { tint:0xFCEF16 } );
			TweenMax.to(countDown.textThree, 0, { tint:0x000000 } );			
			TweenMax.to(countDown.three, 1, { tint:0x022236, delay:.5 } );
			TweenMax.to(countDown.textThree, 1, { tint:0x81919B, delay:.5, onComplete:countTwo } );
		}
		
		
		
		private function countTwo():void
		{
			TweenMax.to(countDown.two, 0, { tint:0xFCEF16 } );
			TweenMax.to(countDown.textTwo, 0, { tint:0x000000 } );			
			TweenMax.to(countDown.two, 1, { tint:0x022236, delay:.5 } );
			TweenMax.to(countDown.textTwo, 1, { tint:0x81919B, delay:.5, onComplete:countOne } );
		}
		
		
		
		private function countOne():void
		{
			TweenMax.to(countDown.one, 0, { tint:0xFCEF16 } );
			TweenMax.to(countDown.textOne, 0, { tint:0x000000 } );			
			TweenMax.to(countDown.one, 1, { tint:0x022236, delay:.5 } );
			TweenMax.to(countDown.textOne, 1, { tint:0x81919B, delay:.5, onComplete:capture } );
		}		
		
		
		
		private function capture():void
		{			
			blank.draw(theVideo);
			
			addChild(cap);
			cap.x = picX;
			cap.y = picY;
			
			addChild(whiteFlash);
			whiteFlash.alpha = 1;
			headlight.alpha = 1; //clip already on stage
			
			TweenMax.to(headlight, 1, { alpha:0} );
			TweenMax.to(whiteFlash, 1, { alpha:0, onComplete:showCapture } );
		}
		
		
		
		private function showCapture():void
		{
			removeChild(getReady);
			removeChild(takePic);
			removeChild(countDown);
			removeChild(whiteFlash);
			removeChild(theVideo);
			
			addChild(retake);
			addChild(submit);
			submit.addEventListener(MouseEvent.CLICK, submitPressed, false, 0, true);
			retake.addEventListener(MouseEvent.CLICK, retakePressed, false, 0, true);
			
			//wait 45 seconds and then call retakePressed if the user walks away
			restartTimer.start();
		}
		
		
		
		private function retakePressed(e:* = null):void
		{
			restartTimer.reset();
			
			removeChild(retake);
			removeChild(submit);
			submit.removeEventListener(MouseEvent.CLICK, submitPressed);
			retake.removeEventListener(MouseEvent.CLICK, retakePressed);
			removeChild(cap);
			if (contains(thanks)) {
				removeChild(thanks);
			}
			begin();
		}
		
		
		
		/**
		 * Called when the submit button is pressed
		 * Sends the base64 encoded string to swfKit for saving into the images folder
		 * 
		 * @param	e
		 */
		private function submitPressed(e:MouseEvent):void
		{			
			restartTimer.reset();
			
			submit.removeEventListener(MouseEvent.CLICK, submitPressed);
			retake.removeEventListener(MouseEvent.CLICK, retakePressed);
			
			submit.yellow.alpha = 1;
			TweenMax.to(submit.yellow, .25, { alpha:0, onComplete:submitIt } );
		}	
		
		
		private function submitIt():void
		{
			var currentCount:String = String(swfKit.getFiles().length);
			if (currentCount.length < 2) { currentCount = "0" + currentCount; }
			
			var bs:String = getJpeg(blank, 84);
			swfKit.saveFile(bs, "leaf.jpg");
			
			addChild(thanks);
			thanks.alpha = 1;
			TweenMax.to(thanks, 3, { alpha:0, delay:3, onComplete:retakePressed } );
		}
		
		
		
		/**
		 * Returns a base64 encoded String of the encoded jpeg
		 * @param	bmpd
		 * @param	q - JPEG Quality
		 * @return
		 */
		public function getJpeg(bmpd:BitmapData, q:int = 80):String
		{			
			var encoder:JPGEncoder = new JPGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return Base64.encodeByteArray(ba);
		}
		

	}
	
}