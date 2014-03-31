package com.gmrmarketing.speed
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
	

	public class CardImage extends EventDispatcher
	{
		private const SERVICE_URL:String = "http://speedcarcards.gmrmarketing.com/PostData.ashx";
		//private const SERVICE_URL:String = "http://staging2.radweblive.com/staging/trugreenubm2011/PostData.ashx";	
		public static const DID_POST:String = "cardWasPosted";
		public static const DID_NOT_POST:String = "cardWasNotPosted";
		
		private var curProgress:Number;
		private var emailLoader:URLLoader;
		
		private var postResponse:String = "";
		
		
		public function CardImage(){}
		
		
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
		 * @param	base 64 encoded main image
		 * @param	base64 encoded thumbnail image
		 * @param	Object of data from form - contains properties:
		 * 
		 * 			fb_uid, firstName, lastName, email, carName, carYear, carMake, carModel, restoreTime
		 */
		public function postImage(encoded:String, thumb:String, data:Object):void
		{
			var request:URLRequest = new URLRequest(SERVICE_URL);
			
			emailLoader = new URLLoader();
			emailLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			var variables:URLVariables = new URLVariables();
			variables.fb_uid = data.fb_uid;
			variables.firstname = data.firstName;
			variables.lastname = data.lastName;
			variables.email = data.email;
			variables.carname = data.carName;
			variables.year = data.carYear;
			variables.make = data.carMake;
			variables.model = data.carModel;
			variables.restoretime = data.restoreTime;
			variables.imagedata = encoded;
			variables.thumbdata = thumb;
			
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
			postResponse = vars.ok;
			
			emailLoader.removeEventListener(Event.COMPLETE, imagePosted);
			emailLoader.removeEventListener(IOErrorEvent.IO_ERROR, imageError);
			emailLoader.removeEventListener(ProgressEvent.PROGRESS, prog);			
			dispatchEvent(new Event(DID_POST));
		}
		
		
		public function getResponse():String
		{
			return postResponse;
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