package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.*;
	import flash.events.*;
	import com.gmrmarketing.utilities.CamPic;
	import com.greensock.TweenMax;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import com.dynamicflash.util.Base64;
	import flash.utils.ByteArray;
	import com.adobe.images.JPEGEncoder;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TakePhoto extends EventDispatcher
	{
		public static const SHOWING:String = "clipShowing";
		public static const EDIT:String = "editText";
		public static const TAKE_PHOTO:String = "takePhoto";
		public static const FINISHED:String = "goodPhoto";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var cam:CamPic;
		private var currPhoto:BitmapData;
		private var displayPhoto:Bitmap;
		private var imageString:String;
		
		private var tookPhoto:Boolean; //true in takePic()
		
		public function TakePhoto()
		{
			tookPhoto = false;
			clip = new mcTakePhoto();
			cam = new CamPic();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(message:String, name:String, wasEditing:Boolean = false):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.btnTake.gotoAndStop(1); //shows take photo - frame 2 is retake			
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, takePic, false, 0, true);
			clip.btnContinue.visible = false;
				
			if(!wasEditing){
				if(displayPhoto){
					if (clip.contains(displayPhoto)) {
						clip.removeChild(displayPhoto);
					}
				}
				
			}else {
				//was editing
				if(tookPhoto){
					clip.btnTake.gotoAndStop(2); //show retake photo					
					clip.btnContinue.visible = true;
					clip.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, finished, false, 0, true);
				}
			}
			
			clip.theText.text = message;//side bar on left
			clip.theText.y = 716 + ((166 - clip.theText.textHeight) * .5);
			
			clip.theText2.autoSize = TextFieldAutoSize.LEFT;
			clip.theText2.text = message;//main text over photo
			
			var f:TextFormat = new TextFormat();
			if (clip.theText2.numLines > 1) {				
				f.leading = -16;
				clip.theText2.setTextFormat(f);
			}else {
				f.leading = 0;
				clip.theText2.setTextFormat(f);
			}
			clip.theText2.y = 670 + ((140 - clip.theText2.textHeight) * .5);
			
			clip.theName.text = name;
			clip.theName.y = clip.theText2.y + clip.theText2.textHeight - 4;
			
			cam.init(1920, 1080, 0, 0, 1717, 964, 30); //set camera and capture res to 1920x1080 and display at 1717x964 (24 fps)	
			cam.show(clip.camImage);//black box behind bg image
			
			clip.btnEdit.addEventListener(MouseEvent.MOUSE_DOWN, editText, false, 0, true);			
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, delay:.5, onComplete:showing } );
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			clip.btnEdit.removeEventListener(MouseEvent.MOUSE_DOWN, editText);
			
			cam.dispose();			
		}
		
		
		/**
		 * called from main - snapshots the current camPic image
		 * and displays it
		 */
		public function showPhoto():void
		{	
			var camIm:BitmapData = new BitmapData(1717, 964);
			camIm.draw(clip.camImage);
			
			currPhoto = new BitmapData(822, 960);//same size as overlay clip
			currPhoto.copyPixels(camIm, new Rectangle(482, 2, 822, 960), new Point(0, 0));
			
			displayPhoto = new Bitmap(currPhoto);
			displayPhoto.x = 728;//position of overlay clip on stage
			displayPhoto.y = 50;
			clip.addChildAt(displayPhoto, 1); //put right in front of camPic
			
			clip.btnTake.gotoAndStop(2); //show retake photo
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, takePic, false, 0, true);
			clip.btnContinue.visible = true;
			clip.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, finished, false, 0, true);
			clip.btnEdit.addEventListener(MouseEvent.MOUSE_DOWN, editText, false, 0, true);
		}
		
		
		public function getPhotoString():String
		{
			clip.btnTake.visible = false;
			var bmpd:BitmapData = new BitmapData(1920, 1080);
			bmpd.draw(clip);
			var pho:BitmapData = new BitmapData(822, 960);
			pho.copyPixels(bmpd, new Rectangle(728, 50, 822, 960), new Point(0, 0));
			clip.btnTake.visible = true;
			
			var jpeg:ByteArray = getJpeg(pho);
			imageString = getBase64(jpeg);
			return imageString;
		}		
		
		
		private function editText(e:MouseEvent):void
		{
			dispatchEvent(new Event(EDIT));
		}
		
		
		/**
		 * clled when take photo button is pressed
		 * @param	e
		 */
		private function takePic(e:MouseEvent):void
		{
			tookPhoto = true;
			if(displayPhoto){
				if (clip.contains(displayPhoto)) {
					clip.removeChild(displayPhoto);
				}
			}
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, takePic);//aded back in showPhoto()
			clip.btnEdit.removeEventListener(MouseEvent.MOUSE_DOWN, editText);
			dispatchEvent(new Event(TAKE_PHOTO));//main will now call showPhoto() after countdown
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		private function finished(e:MouseEvent):void
		{
			clip.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, finished);
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