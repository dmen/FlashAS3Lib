//used by Queue

package com.gmrmarketing.comcast.taylorswift.photobooth
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.LoggerAIR;
	import com.greensock.TweenMax;
	
	public class Hubble extends EventDispatcher
	{		
		public static const GOT_TOKEN:String = "gotToken";
		public static const FORM_POSTED:String = "formPosted";
		public static const ERROR:String = "errorReceived";
		public static const COMPLETE:String = "followupsProcessed";
		
		private const BASE_URL:String = "http://api.nowpik.com/api/";
		
		private var token:String; //GUID - token returned from call to validateuser
		private var responseId:int;
		
		private var hdr:URLRequestHeader;
		private var hdr2:URLRequestHeader;
		
		private var busy:Boolean; //true when submitting data
		private var thePhoto:String;		
		
		
		public function Hubble()
		{
			token = "";
			busy = false;	
			hdr = new URLRequestHeader("Content-type", "application/json");
			hdr2 = new URLRequestHeader("Accept", "application/json");
		}

		
		/**
		 * Called from Queue constructor after instantiating Hubble
		 * @param	e
		 */
		public function getToken(e:TimerEvent = null):void
		{		
			busy = true;			
			
			var js:String = JSON.stringify({"userName":"gmrdigital", "password":"d1gital"});
			var req:URLRequest = new URLRequest(BASE_URL + "authorize/validateuser");
			
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, gotToken, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, tokenError, false, 0, true);
			lo.load(req);
		}
		
		
		public function hasToken():Boolean
		{
			return token == "" ? false : true;
		}
		
		
		public function isBusy():Boolean
		{
			return  busy;
		}
		
		
		/**
		 * Callback for calling validateUser
		 * @param	e
		 */
		private function gotToken(e:Event = null):void
		{			
			var j:Object = JSON.parse(e.currentTarget.data);
			if(j.Status == 1){
				token = j.ResponseObject;
				busy = false;
				dispatchEvent(new Event(GOT_TOKEN));
			}else {
				tokenError();
			}
		}
		
		
		/**
		 * Error callback if getting the token returns an error or status != 1 within gotToken() calls modelError()
		 * @param	e
		 */
		private function tokenError(e:IOErrorEvent = null):void
		{
			token = "";
			TweenMax.delayedCall(10, getToken);
		}
		
		
		/**
		 * Called from Queue.uploadNext()
		 * @param	formData Array email, image		
		 */
		public function submit(formData:Array):void
		{	
			if (hasToken()) {
				
				thePhoto = formData[1]; //used in submitPhoto
				
				busy = true;//true when submitting the user object
					
				//timestamp
				var a:Date = new Date();//now
				var m:String = String(a.month + 1);
				if (m.length < 2) {
					m = "0" + m;
				}
				var d:String = String(a.date);
				if (d.length < 2) {
					d = "0" + d;
				}
				var hor:String = String(a.hours);
				if (hor.length < 2) {
					hor = "0" + hor;
				}
				var min:String = String(a.minutes);
				if (min.length < 2) {
					min = "0" + min;
				}
				var sec:String = String(a.seconds);
				if (sec.length < 2) {
					sec = "0" + sec;
				}
				var ms:String = String( a.milliseconds);
				while (ms.length < 3) {
					ms = "0" + ms;
				}
				var now:String = a.fullYear + "-" +m + "-" +d + "T" + hor + ":" + min + ":" + sec + "." + ms + "Z";
				
				var resp:Object = { "AccessToken":token, "MethodData": { "InteractionId":195, "DeviceId":"Flash", "DeviceResponseId":13, "ResponseDate":now, "FieldResponses":[ { "FieldId":1366, "Response":formData[0] }], "Latitude":"0", "Longitude":"0" }};
				
				var js:String = JSON.stringify(resp);
				var req:URLRequest = new URLRequest(BASE_URL + "interaction/interactionresponse");
				req.method = URLRequestMethod.POST;
				req.data = js;
				req.requestHeaders.push(hdr);
				req.requestHeaders.push(hdr2);
				
				var lo:URLLoader = new URLLoader();
				lo.addEventListener(Event.COMPLETE, formPosted, false, 0, true);
				lo.addEventListener(IOErrorEvent.IO_ERROR, formError, false, 0, true);
				lo.load(req);	
			}
		}
		
		
		private function formPosted(e:Event):void
		{
			
			var j:Object = JSON.parse(e.currentTarget.data);			
			responseId = j.ResponseObject;//used in submitPhoto() and processFollowups()
			if (j.Status == 1) {
				submitPhoto();
			}else {
				formError();
			}
		}
		
		
		private function formError(e:IOErrorEvent = null):void
		{
			busy = false;
			dispatchEvent(new Event(ERROR));
		}
		
		
		/**
		 * Called from formPosted() is response.Status == 1
		 * thePhoto was set in submit()
		 */
		private function submitPhoto():void
		{
			var resp:Object = { "AccessToken":token, "MethodData": { "InteractionResponseId":responseId, "FieldId":1367, "Response":thePhoto }};			
			var js:String = JSON.stringify(resp);
			
			var req:URLRequest = new URLRequest(BASE_URL + "interaction/interactionfieldresponse");
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, photoPosted, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, photoError, false, 0, true);
			lo.load(req);
		}
		
		
		private function photoPosted(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);
			
			if (j.Status == 1) {
				processFollowups();
			}else {
				photoError();
			}
		}
		
		
		private function photoError(e:IOErrorEvent = null):void
		{
			 busy = false;
			dispatchEvent(new Event(ERROR));
		}
		
		
		/**
		 * called from photoPosted()
		 * responseID is set in formPosted if Status response == 1
		 */
		private function processFollowups():void
		{	
			var resp:Object = { "AccessToken":token, "MethodData": responseId };			
			var js:String = JSON.stringify(resp);
			
			var req:URLRequest = new URLRequest(BASE_URL + "interaction/processfollowups");
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, followupsProcessed, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, followupError, false, 0, true);
			lo.load(req);
		}
		
		
		private function followupsProcessed(e:Event):void
		{
			
			var j:Object = JSON.parse(e.currentTarget.data);
			busy = false;
			if (j.Status == 1) {
				dispatchEvent(new Event(COMPLETE));
			}else {
				followupError();
			}
		}
		
		
		private function followupError(e:IOErrorEvent = null):void
		{
			busy = false;
			dispatchEvent(new Event(ERROR));
		}
	}
	
}