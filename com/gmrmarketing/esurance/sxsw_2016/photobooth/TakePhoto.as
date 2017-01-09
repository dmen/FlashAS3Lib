
package com.gmrmarketing.esurance.sxsw_2016.photobooth
{
	import com.gmrmarketing.htc.movies.Overlay;
	import com.gmrmarketing.nissan.motorsports.videokiosk_2013.Video;
	import flash.display.*;
	import flash.events.*;
	import com.gmrmarketing.utilities.CamPic;
	import com.greensock.TweenMax;
	import flash.geom.*;
	import flash.media.*;
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
		private var cam:Camera;
		private var vid:Video;
		private var tim:TimeoutHelper;
		private var currPhoto:BitmapData;
		private var displayPhoto:Bitmap;
		private var imageString:String;
		private var whiteFlash:WhiteFlash;
		private var countDown:Countdown;
		
		private var over:BitmapData; //overlay
		
		public function TakePhoto()
		{
			clip = new mcTakePhoto();
			
			cam = Camera.getCamera();
			cam.setMode(960, 720, 30);
			vid = new Video(960, 720);
			
			whiteFlash = new WhiteFlash(1600, 900);
			whiteFlash.container = clip;
			
			over = new overlay();//960x620
			
			tim = TimeoutHelper.getInstance();
			
			countDown = new Countdown();
			countDown.container = clip;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(e:MouseEvent = null):void
		{
			tim.buttonClicked();
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			if (displayPhoto) {
				if (myContainer.contains(displayPhoto)) {
					myContainer.removeChild(displayPhoto);
				}
			}
			
			clip.theText.visible = true;
			clip.theText.alpha = 1;
			clip.thanks.visible = false;
			clip.btnRetake.visible = false;
			clip.btnLoveIt.visible = false;
			
			clip.btnTake.visible = true;				
			clip.btnTake.alpha = 1;				
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, takePic, false, 0, true);
			
			vid.attachCamera(cam);
			clip.addChildAt(vid, 0);
			vid.x = 545;
			vid.y = 90;
			
			if (e == null) {
				//called from Main instead of retake button
				clip.alpha = 0;
				TweenMax.to(clip, 1, { alpha:1, delay:.5, onComplete:showing } );
			}
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}			
		}
		
		
		private function takePic(e:MouseEvent):void
		{
			tim.buttonClicked();
			
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
			var temp:BitmapData = new BitmapData(960, 720);
			temp.draw(vid,null,null,null,null,true);//camera image
			
			currPhoto = new BitmapData(960, 620);
			currPhoto.copyPixels(temp, new Rectangle(0, 50, 960, 620), new Point(0, 0));
			currPhoto.copyPixels(over, new Rectangle(0, 0, 960, 620), new Point(0, 0), null, null, true);
			
			displayPhoto = new Bitmap(currPhoto);
			displayPhoto.x = 545;
			displayPhoto.y = 140;
			myContainer.addChild(displayPhoto);
			
			clip.btnTake.visible = false;
			clip.btnRetake.visible = true;
			clip.btnLoveIt.visible = true;
			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, show, false, 0, true);
			clip.btnLoveIt.addEventListener(MouseEvent.MOUSE_DOWN, showThanks, false, 0, true);
		}
		
		
		public function getPhotoString():String
		{	
			return imageString;
		}
		
		
		private function showThanks(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			clip.btnLoveIt.removeEventListener(MouseEvent.MOUSE_DOWN, showThanks);
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, show);
			clip.thanks.visible = true;
			clip.thanks.alpha = 0;
			clip.btnRetake.visible = false;
			clip.btnLoveIt.visible = false;
			
			TweenMax.to(clip.thanks, .5, { alpha:1 } );
			
			TweenMax.delayedCall(.75, process);		
			TweenMax.delayedCall(8, finished);
		}
		
		private function process():void
		{
			var jpeg:ByteArray = getJpeg(displayPhoto.bitmapData);
			imageString = getBase64(jpeg);
		}
		
		private function finished():void
		{
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