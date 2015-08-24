//used by Queue

package com.gmrmarketing.testing
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.LoggerAIR;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.Strings;//for timestamp
	
	
	public class Hubble extends EventDispatcher
	{		
		public static const GOT_TOKEN:String = "gotToken";
		public static const FORM_POSTED:String = "formPosted";
		public static const FORM_ERROR:String = "formErrorReceived";
		public static const PHOTO_ERROR:String = "photoErrorReceived";
		public static const FOLLOWUP_ERROR:String = "followUpErrorReceived";
		public static const PRINTAPI_ERROR:String = "printAPIErrorReceived";
		public static const COMPLETE:String = "followupsProcessed";
		
		private const BASE_URL:String = "http://api.nowpik.com/api/";
		
		private var token:String; //GUID - token returned from call to validateuser
		private var responseId:int;//set in submit if the form data is already posted, or formPosted normally
		
		private var hdr:URLRequestHeader;
		private var hdr2:URLRequestHeader;
		
		private var busy:Boolean; //true when submitting data
		private var thePhoto:String;
		private var didPrint:Boolean;//set in submit - calls printAPI if true
		private var myGUID:String;
		
		
		
		public function Hubble(guid:String)
		{
			myGUID = guid;//unique machine identifier - used as deviceId when submitting form data
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
		 * @param	formData Object with keys:
			 email, phone, opt1, opt2, opt3, opt4, opt5, gif, deviceResponseID, responseID, followupError, print
		 */
		public function submit(formData:Object):void
		{	
			if (hasToken()) {
				
				thePhoto = formData.gif; //used in submitPhoto - encoded to B64 string
				didPrint = formData.print;//boolean
				
				busy = true;//true when submitting data
				
				if (formData.responseID != -1) {
					
					if (formData.printAPIError) {
						responseId = formData.responseID;
						callPrintAPI();
					}else if (formData.followupError) {						
						responseId = formData.responseID;
						processFollowups();
					}else{
						//form data already posted but posting photo or followup got an error...just post photo again
						responseId = formData.responseID;
						submitPhoto();
					}
					
				}else{
					//responseID = -1 form data has not been sent yet
					
					var resp:Object = { "AccessToken":token, "MethodData": { "InteractionId":230, "DeviceId":myGUID, "DeviceResponseId":formData.deviceResponseID, "ResponseDate":Strings.hubbleTimestamp(), "FieldResponses":[ { "FieldId":1667, "Response":formData.email }, { "FieldId":1668, "Response":formData.phone },{ "FieldId":1670, "Response":formData.opt1 }, { "FieldId":1673, "Response":formData.opt2 }, { "FieldId":1674, "Response":formData.opt3 }, { "FieldId":1675, "Response":formData.opt4 }, { "FieldId":1676, "Response":formData.opt5 }, { "FieldId":1682, "Response":true }], "Latitude":"0", "Longitude":"0" }};
					
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
		
		/**
		 * Called from Queue.hubblePhotoError() if posting the photo or followup generates an error
		 * if so the responseID is injected into the user object so that subsequent attempts will use
		 * the proper record as the form data is already posted into the database
		 */
		public function get responseID():int
		{
			return responseId;
		}
		
		private function formError(e:IOErrorEvent = null):void
		{
			busy = false;
			dispatchEvent(new Event(FORM_ERROR));
		}
		
		
		/**
		 * Called from formPosted() if response.Status == 1
		 * thePhoto was set in submit()
		 */
		private function submitPhoto():void
		{			
			var resp:Object = { "AccessToken":token, "MethodData": { "InteractionResponseId":responseId, "FieldId":1666, "Response":thePhoto }};			
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
		
		
		/**
		 * calls hubblePhotoError() in Queue
		 */
		private function photoError(e:IOErrorEvent = null):void
		{
			busy = false;
			dispatchEvent(new Event(PHOTO_ERROR));
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
				if (didPrint) {
					callPrintAPI();
				}else{
					dispatchEvent(new Event(COMPLETE));
				}				
			}else {
				followupError();
			}
		}
		
		
		private function callPrintAPI():void
		{	
			var ts:String = Strings.hubbleTimestamp();
			
			var resp:Object = { "AccessToken":token, "MethodData": { "InteractionId":230, "Label":"photoPrinted", "Value":"1", "Timestamp":ts, "DeviceResponseId":myGUID }};		
			var js:String = JSON.stringify(resp);
			
			var req:URLRequest = new URLRequest(BASE_URL + "interaction/CreateActivity");
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, printProcessed, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, printAPIError, false, 0, true);
			lo.load(req);			
		}
		
		
		private function printProcessed(e:Event):void
		{
			
			var j:Object = JSON.parse(e.currentTarget.data);
			busy = false;
			if (j.Status == 1) {				
				dispatchEvent(new Event(COMPLETE));
			}else {
				followupError();
			}
		}
		
		
		/**
		 * calls hubblePhotoError() in Queue.as
		 */
		private function followupError(e:IOErrorEvent = null):void
		{
			busy = false;
			dispatchEvent(new Event(FOLLOWUP_ERROR));
		}
		
		
		private function printAPIError():void
		{
			busy = false;
			dispatchEvent(new Event(PRINTAPI_ERROR));
		}
	}
	
}