package com.gmrmarketing.esurance.usopen2015
{
	import flash.display.*;
	import flash.events.*;
	import com.gmrmarketing.utilities.CamPic;
	import com.greensock.TweenMax;
	import flash.geom.*;
	import com.dynamicflash.util.Base64;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import com.adobe.images.JPEGEncoder;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TakePhoto extends EventDispatcher
	{
		public static const SHOWING:String = "clipShowing";
		public static const FINISHED:String = "goodPhoto";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var cam:CamPic;
		private var currPhoto:BitmapData;
		private var displayPhoto:Bitmap;
		private var imageString:String;
		private var whiteFlash:WhiteFlash;
		private var countDown:Countdown;
		
		private var overlayData:BitmapData;
		private var overlay:Bitmap;
		private var overlayShowing:int;//0 1 or 2
		private var isKids:Boolean;
		
		
		public function TakePhoto()
		{
			clip = new mcTakePhoto();
			cam = new CamPic();
			
			whiteFlash = new WhiteFlash(1600, 900);
			whiteFlash.container = clip;
			
			overlay = new Bitmap();
			overlay.x = 545;
			overlay.y = 53;
			
			countDown = new Countdown();
			countDown.container = clip;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(isKidsDay:Boolean = false, fromMain:Boolean = true):void
		{
			isKids = isKidsDay;
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			if (displayPhoto) {
				if (clip.contains(displayPhoto)) {
					clip.removeChild(displayPhoto);
				}
			}
			
			if (clip.contains(overlay)) {
				clip.removeChild(overlay);
			}
			overlayShowing = 0;
			
			clip.theText.visible = true;
			clip.theText.alpha = 1;
			if (isKidsDay) {
				clip.theText.title.text = "\n\npose";
				clip.theText.sub1.text = "When you're ready press\nTAKE PICTURE and we'll\nstart a countdown.";
				clip.theText.sub2.text = "";
				
				clip.t1.visible = false;
				clip.t2.visible = false;
			}else {
				clip.theText.title.text = "pick your\ntheme\n& pose";
				clip.theText.sub1.text = "Choose one of the\noverlays below and show\nus your best pose.";
				clip.theText.sub2.text = "When you're ready press\nTAKE PICTURE and we'll\nstart a countdown.";
				
				//theme button(s)
				clip.t2.theText.text = "option\n2";
				clip.t1.visible = true;
				clip.t2.visible = true;
				clip.t1.addEventListener(MouseEvent.MOUSE_DOWN, overlayOneClick, false, 0, true);
				clip.t2.addEventListener(MouseEvent.MOUSE_DOWN, overlayTwoClick, false, 0, true);
			}
			
			clip.thanks.visible = false;
			clip.btnRetake.visible = false;
			clip.btnLoveIt.visible = false;
			
			clip.btnTake.visible = true;				
			clip.btnTake.alpha = 1;				
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, takePic, false, 0, true);
			
			//set camera and capture res to 1920x1080 and display at 1313x739
			cam.init(1920, 1080, 0, 0, 1313, 739, 30);
			cam.show(clip.camImage);//black box behind bg image	- 1313x739
			//clip.camImage.alpha = 0;
			
			if (fromMain) {
				//called from Main instead of retake button - fade in
				clip.alpha = 0;
				TweenMax.to(clip, .5, { alpha:1, onComplete:showing } );
				//TweenMax.to(clip.camImage, .25, { alpha:1, delay:.5 } );
			}else {
				//clip.camImage.alpha = 1;
			}
		}
		
		
		private function overlayOneClick(e:MouseEvent):void
		{
			overlayData = new overlayOne();//lib
			overlay.bitmapData = overlayData;
			if (overlayShowing == 0 || overlayShowing == 2) {
				overlayShowing = 1;
				if (!clip.contains(overlay)) {
					clip.addChild(overlay);
				}
			}else {
				if (clip.contains(overlay)) {
					clip.removeChild(overlay);
				}
				overlayShowing = 0;
			}
		}
		
		private function overlayTwoClick(e:MouseEvent):void
		{
			overlayData = new overlayTwo();//lib
			overlay.bitmapData = overlayData;
			if (overlayShowing == 0 || overlayShowing == 1) {
				overlayShowing = 2;
				if (!clip.contains(overlay)) {
					clip.addChild(overlay);
				}
			}else {
				if (clip.contains(overlay)) {
					clip.removeChild(overlay);
				}
				overlayShowing = 0;
			}
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		public function hide():void
		{
			trace("takePhoto.hide()");
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}			
			cam.dispose();			
		}
		
		
		private function takePic(e:MouseEvent):void
		{
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, takePic);//aded back in showPhoto()
			TweenMax.to(clip.btnTake, .25, { alpha:0 } );
			TweenMax.to(clip.theText, .25, { alpha:0 } );
			countDown.addEventListener(Countdown.COUNT_COMPLETE, showFlash, false, 0, true);
			countDown.show();
		}
		
		
		private function showFlash(e:Event):void
		{			
			countDown.hide();
			whiteFlash.show();
			TweenMax.delayedCall(.2, showPhoto);
		}		
		
		
		private function showPhoto():void
		{	
			var camIm:BitmapData = cam.getDisplay();//1313x739
			
			var displayIm:BitmapData = new BitmapData(501, 735);
			displayIm.copyPixels(camIm, new Rectangle(406, 2, 501, 735), new Point(0, 0));
			//displayIm.copyPixels(overlay, new Rectangle(0, 0, 900, 615), new Point(0, 0), null, null, true);
			
			displayPhoto = new Bitmap(displayIm);
			displayPhoto.x = 545;
			displayPhoto.y = 53;
			clip.addChildAt(displayPhoto, 1); //put right in front of camImage
			
			clip.btnTake.visible = false;
			clip.btnRetake.visible = true;
			clip.btnLoveIt.visible = true;
			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, showInternal, false, 0, true);
			clip.btnLoveIt.addEventListener(MouseEvent.MOUSE_DOWN, showThanks, false, 0, true);
		}
		//just for calling show() from retake button
		private function showInternal(e:MouseEvent):void
		{
			show(isKids, false);
		}
		
		/**
		 * returns a 1200x1800 BitmapData for printing 4x6
		 * @return
		 */
		public function getPrintPhoto():BitmapData
		{
			var b:BitmapData = new BitmapData(501, 735);
			b.copyPixels(displayPhoto.bitmapData, new Rectangle(0, 0, 501, 735), new Point(0, 0));
			if (overlayShowing != 0) {
				b.copyPixels(overlayData, new Rectangle(0, 0, overlayData.width, overlayData.height), new Point(0, 0), null, null, true);
			}
			
			var m:Matrix = new Matrix();			
			m.scale(2.3952, 2.3952);//scale 501x735 to 1200x1800
			
			var printImage:BitmapData = new BitmapData(1200, 1800);			
			printImage.draw(b, m, null, null, null, true);		
			
			return printImage;
		}
		
		
		public function getPhotoString():String
		{	
			return imageString;
		}
		
		
		private function showThanks(e:MouseEvent):void
		{
			clip.btnLoveIt.removeEventListener(MouseEvent.MOUSE_DOWN, showThanks);
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, showInternal);
			
			clip.t1.removeEventListener(MouseEvent.MOUSE_DOWN, overlayOneClick);
			clip.t2.removeEventListener(MouseEvent.MOUSE_DOWN, overlayTwoClick);
			clip.t1.visible = false;
			clip.t2.visible = false;
			
			clip.thanks.visible = true;
			clip.thanks.alpha = 0;
			if (isKids) {
				clip.thanks.theText.text = "Thanks for walking the Esurance Indigo Carpet.\n\nEnjoy the rest of your US Open experience.";
			}else {
				clip.thanks.theText.text = "Thanks for walking the Esurance Indigo Carpet. You'll receive an email with your personalized photo soon. Enjoy the rest of your US Open experience.";
			}
			clip.btnRetake.visible = false;
			clip.btnLoveIt.visible = false;
			
			TweenMax.to(clip.thanks, .5, { alpha:1 } );
			
			TweenMax.delayedCall(.75, process);		
			TweenMax.delayedCall(8, finished);
		}
		
		
		private function process():void
		{
			var b:BitmapData = new BitmapData(501, 735);
			b.copyPixels(displayPhoto.bitmapData, new Rectangle(0, 0, 501, 735), new Point(0, 0));
			if (overlayShowing != 0) {
				b.copyPixels(overlayData, new Rectangle(0, 0, overlayData.width, overlayData.height), new Point(0, 0), null, null, true);
			}
			
			var jpeg:ByteArray = getJpeg(b);
			imageString = getBase64(jpeg);
			
			trace("process complete");
		}
		
		
		private function finished():void
		{
			trace("take dispatching FINISHED");
			dispatchEvent(new Event(FINISHED));
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