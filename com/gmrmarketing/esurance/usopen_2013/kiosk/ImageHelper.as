package com.gmrmarketing.esurance.usopen_2013.kiosk
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.gmrmarketing.utilities.ImageEncoder;
	
	
	public class ImageHelper extends EventDispatcher
	{
		public static const SERVER_UPLOAD_ERROR:String = "serverUploadError";
		public static const SERVER_UPLOAD_COMPLETE:String = "serverUploadComplete";
		public static const FB_POST_GOOD:String = "postedToWall";
		public static const DONE_ENCODING:String = "finishedEncoding";
		
		private var encoder:ImageEncoder;
		private var imageURL:String;
		
		
		public function ImageHelper()
		{
			encoder = new ImageEncoder();
			encoder.addEventListener(ImageEncoder.COMPLETE, doneEncoding, false, 0, true);
		}
		
		
		public function encode(bmd:BitmapData):void
		{
			encoder.encode(bmd);
		}
		
		
		/**
		 * called by listener on the encoder once encoding is complete		 * 
		 * @param	e
		 */
		private function doneEncoding(e:Event):void
		{
			dispatchEvent(new Event(DONE_ENCODING));
		}
		
		
		/**
		 * posts the encoded image to the web service and gets the image url back
		 */
		public function postEncoded(rfid:String = null, type:String = null):void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
			var hdr2:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			
			var b64:String = encoder.getEncoded();
			
			var js:String;
			if (type == null) {
				//store image from FYN
				js = JSON.stringify( { ImageData:b64 } );
			}else {
				//store image from MyPik template				
				js = JSON.stringify( { ImageData:b64, rfid:rfid, imageType:type } );
			}
			
			var req:URLRequest = new URLRequest("http://esuranceusopen2013.thesocialtab.net/api/Image");
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			req.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, imageError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, imagePosted, false, 0, true);
			lo.load(req);
		}
		
		
		private function imageError(e:IOErrorEvent):void
		{
			dispatchEvent(new Event(SERVER_UPLOAD_ERROR));
		}
		
		
		private function imagePosted(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);
			imageURL = j.ImageUrl;			
			dispatchEvent(new Event(SERVER_UPLOAD_COMPLETE));
		}
		
		
		
		public function fynFBPost(authToken:String):void
		{	
			var url:String = "https://graph.facebook.com/me/photos?access_token=" + authToken;			

			var req:URLRequest = new URLRequest(url);

			var vars:URLVariables = new URLVariables();
			vars.message = "Just got my name framed at the US Open. Now that’s an #Advantage. Thanks Esurance!";
			vars.access_token = authToken;
			vars.url = imageURL;

			req.data = vars;
			req.method = URLRequestMethod.POST;

			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, imageError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, fbPostGood, false, 0, true);
			lo.load(req);
		}
		
		
		private function fbPostGood(e:Event):void
		{
			dispatchEvent(new Event(FB_POST_GOOD));
		}
		
		
		public function myPikFBPost(authToken:String):void
		{	
			var url:String = "https://graph.facebook.com/me/photos?access_token=" + authToken;			

			var req:URLRequest = new URLRequest(url);

			var vars:URLVariables = new URLVariables();
			vars.message = "Just got my picture with the Bryan Brothers at the US Open! Now that's an #Advantage. Thanks Esurance!";
			vars.access_token = authToken;
			vars.url = imageURL;
			
			req.data = vars;
			req.method = URLRequestMethod.POST;

			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, imageError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, fbPostGood, false, 0, true);
			lo.load(req);
		}
		
	}
	
}