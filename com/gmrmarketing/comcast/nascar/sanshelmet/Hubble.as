//used by Queue

package com.gmrmarketing.comcast.nascar.sanshelmet
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
		
		private var pledgeOptions:Array;//array of fields and values for "how would you categorized your pledge" drop down
		private var prizeOptions:Array;//array of fields and values for "please select your prize" drop down		
		
		private var hdr:URLRequestHeader;
		private var hdr2:URLRequestHeader;
		private var so:SharedObject;
		
		private var busy:Boolean; //true when submitting data
		private var thePhoto:String;		
		
		private var log:Logger;
		
		
		public function Hubble()
		{		
			log = Logger.getInstance();
			//don't need to setLogger because queue already did it
			log.log("Hubble Constructor");
			
			token = "";
			pledgeOptions = new Array();
			prizeOptions = new Array();
			busy = false;
			so = SharedObject.getLocal("bcbsData");			
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
			
			log.log("Hubble.getToken()");
			var js:String = JSON.stringify({"userName":"xfinityavatar", "password":"avatar"});
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
				log.log("Hubble.gotToken() - Status = 1");
				token = j.ResponseObject;
				busy = false;
				dispatchEvent(new Event(GOT_TOKEN));
			}else {
				tokenError();
			}
		}
		
		
		/**
		 * Error callback if getting the token returns an error or status != 1 within gotToken()
		 * calls modelError() which will populate the options arrays with local cache if available
		 * if not available, getToken() will be called again to restart the process
		 * since the app has to have the options arrays
		 * @param	e
		 */
		private function tokenError(e:IOErrorEvent = null):void
		{
			log.log("Hubble.tokenError()");
			token = "";
			TweenMax.delayedCall(10, getToken);
		}
		
		
		/**
		 * Called from Queue.uploadNext()
		 * @param	formData Array rfid, image	
		 * 
		 * update 11/21/14 - prizeCombo is -1
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
				
				log.log("Hubble.submit() " + formData[0] + " " + formData[1] + " " + formData[2] + "now: " + now);
				
				var resp:Object = { "AccessToken":token, "MethodData": { "InteractionId":173, "DeviceId":"Flash", "DeviceResponseId":13, "ResponseDate":now, "FieldResponses":[ { "FieldId":1148, "Response":formData[0] }], "Latitude":"0", "Longitude":"0" }};
				
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
				log.log("Hubble.formPosted() - Status = 1 - responseID:" + responseId);
				submitPhoto();
			}else {
				log.log("Hubble.formPosted() - Status != 1");
				formError();
			}
		}
		
		
		private function formError(e:IOErrorEvent = null):void
		{
			log.log("Hubble.formError()");
			busy = false;
			dispatchEvent(new Event(ERROR));
		}
		
		
		/**
		 * Called from formPosted() is response.Status == 1
		 * thePhoto was set in submit()
		 */
		private function submitPhoto():void
		{			
			log.log("Hubble.submitPhoto() - responseID:" + responseId);
			var resp:Object = { "AccessToken":token, "MethodData": { "InteractionResponseId":responseId, "FieldId":1147, "Response":thePhoto }};			
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
				log.log("Hubble.photoPosted - Status = 1");
				processFollowups();
			}else {
				photoError();
			}
		}
		
		
		private function photoError(e:IOErrorEvent = null):void
		{
			log.log("Hubble.photoError()");
			 busy = false;
			dispatchEvent(new Event(ERROR));
		}
		
		
		/**
		 * called from photoPosted()
		 * responseID is set in formPosted if Status response == 1
		 */
		private function processFollowups():void
		{	
			log.log("Hubble.processFollowups() - responseID: " + responseId);
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
				log.log("Hubble.followupsProcessed() - Status = 1");
				dispatchEvent(new Event(COMPLETE));
			}else {
				followupError();
			}
		}
		
		
		private function followupError(e:IOErrorEvent = null):void
		{
			log.log("Hubble.followupError()");
			busy = false;
			dispatchEvent(new Event(ERROR));
		}
	}
	
}