package com.gmrmarketing.miller.sxsw
{
	import flash.display.BitmapData;
	import flash.events.*;
	import com.dynamicflash.util.Base64;
	import flash.utils.ByteArray;
	import com.adobe.images.JPEGEncoder;
	import flash.net.URLVariables;
	import flash.net.URLLoader;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	public class WebServices extends EventDispatcher
	{
		public static const IMAGE_SAVED:String = "imageWasSaved";
		public static const IMAGE_SAVE_ERROR:String = "imageWasNotSaved";
		public static const EMAIL_SENT:String = "emailWasSent";
		public static const EMAIL_ERROR:String = "emailWasNotSent";
		public static const SPIN_SAVED:String = "spinWasSaved";
		public static const SPIN_ERROR:String = "spinWasNotSaved";
		
		private var imageString:String;	
		private var savedID:String; //id of the saved image - returned from web service - set in saveDone()
		
		
		public function WebServices()
		{
			savedID = "false";
		}
		
		
		/**
		 * Called by Main.beginSave()
		 * and Main.beginSpin()
		 * 
		 * @param	img
		 */
		public function savePoster(img:BitmapData):void
		{
			var jpeg:ByteArray = getJpeg(img);			
			imageString = getBase64(jpeg);
			
			var request:URLRequest = new URLRequest("https://millersxsw.thesocialtab.net/Home/SubmitPhoto");
				
			var vars:URLVariables = new URLVariables();
			vars.imageBuffer = imageString;
			vars.dob = "";			
			
			request.data = vars;			
			request.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, saveError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, saveDone, false, 0, true);
			
			try{
				lo.load(request);
			}catch (e:Error) {
				dispatchEvent(new Event(IMAGE_SAVE_ERROR));
			}
		}
		

		private function saveDone(e:Event):void
		{			
			var vars:URLVariables = new URLVariables(e.target.data);			
			savedID = vars.success;			
			if(savedID != "false"){
				dispatchEvent(new Event(IMAGE_SAVED));
			}else {
				dispatchEvent(new Event(IMAGE_SAVE_ERROR));
			}
		}
		
		public function getImageID():String
		{
			return savedID;
		}
		
		
		private function saveError(e:IOErrorEvent):void
		{			
			dispatchEvent(new Event(IMAGE_SAVE_ERROR));
		}
		
		
		public function spinSubmit(name:String = "", email:String = "", phone:String = ""):void
		{
			var request:URLRequest = new URLRequest("https://millersxsw.thesocialtab.net/Home/SubmitSpin");
				
			var vars:URLVariables = new URLVariables();
			vars.posterId = savedID;
			vars.name = name;
			vars.email = email;
			vars.phone = phone;
			
			request.data = vars;			
			request.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, spinError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, spinDone, false, 0, true);
			
			try{
				lo.load(request);
			}catch (e:Error) {
				dispatchEvent(new Event(SPIN_ERROR));
			}
		}
		
		private function spinDone(e:Event):void
		{
			var vars:URLVariables = new URLVariables(e.target.data);
			if (vars.success == "true") {
				dispatchEvent(new Event(SPIN_SAVED));
			}else {
				dispatchEvent(new Event(SPIN_ERROR));
			}
		}
		
		private function spinError(e:IOErrorEvent):void
		{			
			dispatchEvent(new Event(SPIN_ERROR));
		}
		
		
		
		
		public function emailSubmit(from:String, to:String):void
		{
			var request:URLRequest = new URLRequest("https://millersxsw.thesocialtab.net/Home/EmailToFriend");
				
			var vars:URLVariables = new URLVariables();
			vars.posterId = savedID;
			vars.fromemail = from;
			vars.toemail = to;
			vars.body = "";
			
			request.data = vars;			
			request.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, emailError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, emailDone, false, 0, true);
			
			lo.load(request);
		}
		
		private function emailDone(e:Event):void
		{
			var vars:URLVariables = new URLVariables(e.target.data);
			if(vars.success == "true"){
				dispatchEvent(new Event(EMAIL_SENT));
			}else {
				dispatchEvent(new Event(EMAIL_ERROR));
			}
		}
		
		private function emailError(e:IOErrorEvent):void
		{
			savedID = "false";
			dispatchEvent(new Event(EMAIL_ERROR));
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