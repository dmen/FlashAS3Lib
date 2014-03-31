/**
 * Returns a base64 encoded string from an imput bitmapData object
 * Simple wrapper for JPEG encoder and base64 encoder
 */

package com.gmrmarketing.utilities
{	
	import com.dynamicflash.util.Base64;
	import com.adobe.images.JPGEncoder;
	import flash.events.*;
	import flash.utils.ByteArray;
	import flash.display.*;
	
	
	public class ImageEncoder extends EventDispatcher
	{
		public static const COMPLETE:String = "encodeDone";
		private var enc:String = "";
		
		
		public function encode(bmd:BitmapData, q:int = 86):void
		{
			var ba:ByteArray = getJpeg(bmd, q);
			enc = getBase64(ba);
			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		public function getEncoded():String
		{
			return enc;
		}
		
		
		private function getJpeg(bmpd:BitmapData, q:int = 86):ByteArray
		{			
			var encoder:JPGEncoder = new JPGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
		
		
		private function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
	}
	
}