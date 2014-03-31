package com.gmrmarketing.fx.ahs
{
	import com.dynamicflash.util.Base64;
	import com.adobe.images.JPGEncoder;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.events.IOErrorEvent;
	

	public class ImageSave extends EventDispatcher
	{
		//private const SERVICE_URL:String = "http://fxhorrorshow.gmrstage.com/Scare/PostPhoto";
		
		public static const DID_POST:String = "cardWasPosted";
		public static const DID_NOT_POST:String = "cardWasNotPosted";
		
		private var curProgress:Number;
		private var emailLoader:URLLoader;
		
		private var postResponse:String = "";
		private var serviceURL:String = "";
		
		
		//CONSTRUCTOR
		public function ImageSave(){}
		
		
		public function setPostURL(url:String):void
		{
			serviceURL = url;
		}
		
		/**
		 * Returns a ByteArray from the jpegEncoder of the passed in bitmapData object
		 * @param	bmpd
		 * @param	q - JPEG Quality
		 * @return
		 */
		public function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPGEncoder = new JPGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
		
		
		/**
		 * Used to encode the jpeg byteArray to a string for sending to the server
		 * or saving to disk if send fails
		 * 
		 * @param	ba
		 * @return
		 */
		public function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		
		/**
		 * Posts to the service
		 * @param	encoded - base 64 encoded main image		
		 */
		public function postImage(encoded:String):void
		{
			var request:URLRequest = new URLRequest(serviceURL);
			
			emailLoader = new URLLoader();
			emailLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			var variables:URLVariables = new URLVariables();		
			variables.imageBuffer = encoded;			
			
			request.data = variables;
			request.method = URLRequestMethod.POST;
			
			emailLoader.addEventListener(Event.COMPLETE, imagePosted, false, 0, true);
			emailLoader.addEventListener(IOErrorEvent.IO_ERROR, imageError, false, 0, true);
			emailLoader.addEventListener(ProgressEvent.PROGRESS, prog, false, 0, true);			
			
			emailLoader.load(request);		
		}
		
		
		private function imagePosted(e:Event):void
		{
			var vars:URLVariables = new URLVariables(e.target.data);
			postResponse = vars.success;
			
			emailLoader.removeEventListener(Event.COMPLETE, imagePosted);
			emailLoader.removeEventListener(IOErrorEvent.IO_ERROR, imageError);
			emailLoader.removeEventListener(ProgressEvent.PROGRESS, prog);			
			dispatchEvent(new Event(DID_POST));
		}
		
		
		/**
		 * Gets the Facebook post location
		 * @return
		 */
		public function getResponse():String
		{
			var i:int = serviceURL.lastIndexOf("/");
			var b:String = serviceURL.substring(0, i);
			return b + "?id=" + postResponse;
		}
		
		
		private function imageError(e:IOErrorEvent):void
		{
			emailLoader.removeEventListener(Event.COMPLETE, imagePosted);
			emailLoader.removeEventListener(IOErrorEvent.IO_ERROR, imageError);
			emailLoader.removeEventListener(ProgressEvent.PROGRESS, prog);
			postResponse = "";
			dispatchEvent(new Event(DID_NOT_POST));
		}
		
		
		private function prog(e:ProgressEvent):void
		{
			curProgress = e.bytesLoaded / e.bytesTotal;			
		}
		
		
		public function getProgress():Number
		{
			return curProgress;
		}
	}	
}