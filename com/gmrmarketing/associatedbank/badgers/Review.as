package com.gmrmarketing.associatedbank.badgers
{
	import com.greensock.TweenMax;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import com.dynamicflash.util.Base64;
	import com.adobe.images.JPEGEncoder;
	
	public class Review extends EventDispatcher
	{
		public static const RETAKE:String = "retakePhoto";
		public static const SAVE:String = "savePhoto";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var bmd:BitmapData;
		private var bmp:Bitmap;
		private var imageString:String;
		
		
		
		public function Review()
		{
			clip = new mcReview();			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
				
		
		public function get pic():String
		{
			return imageString;
		}
		
		
		public function get picData():BitmapData
		{
			return bmd;
		}
		
		
		public function get numPrints():int
		{
			return parseInt(clip.numPrints.text);
		}		
	
		
		/**
		 * 
		 * @param	frames Array of four 1280x720 BitmapData's
		 */
		public function show(frames:Array):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			bmd = new frame();// full size 1723 x 1124 bitmap in library
			
			var im:BitmapData = new BitmapData(780, 439);
			var sc:Matrix = new Matrix();
			sc.scale(.609375, .609375);//scales 1280x720 to 780x439
			var points:Array = [new Point(60, 70), new Point(884, 70), new Point(60, 512), new Point(884, 512)];
			
			for (var i:int = 0; i < 4; i++){
				im.draw(frames[i], sc, null, null, null, true);			
				bmd.copyPixels(im, new Rectangle(0, 19, 780, 400), points[i]);
			}
			
			var resized:BitmapData = new BitmapData(1152, 751);//for display in review
			sc = new Matrix();
			sc.scale(.6686013, .6686013);
			resized.draw(bmd, sc, null, null, null, true);
			
			bmp = new Bitmap(resized, "auto", true);
			
			clip.addChild(bmp);
			bmp.x = 384;
			bmp.y = 140;
			
			clip.numPrints.restrict = "0-9";
			clip.numPrints.text = "1";
			clip.numPrints.addEventListener(Event.CHANGE, limitToTen, false, 0, true);
			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retakePhoto, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, savePhoto, false, 0, true);
			
			TweenMax.delayedCall(.25, makeString);
		}
		
		private function makeString():void
		{
			var jpeg:ByteArray = getJpeg(bmd);
			imageString = getBase64(jpeg);
		}
		
		private function limitToTen(e:Event):void
		{
			if (parseInt(clip.numPrints.text) > 10) {
				clip.numPrints.text = "10";
			}
		}
		
		public function hide():void
		{
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, retakePhoto);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, savePhoto);			
			clip.numPrints.removeEventListener(Event.CHANGE, limitToTen);
			
			if(myContainer){
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}				
			}
			if (bmp) {
				if (clip.contains(bmp)) {
					clip.removeChild(bmp);
				}
			}
		}		
	
		
		private function retakePhoto(e:MouseEvent):void
		{
			dispatchEvent(new Event(RETAKE));
		}
		
		
		private function savePhoto(e:MouseEvent):void
		{	
			
			dispatchEvent(new Event(SAVE));
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