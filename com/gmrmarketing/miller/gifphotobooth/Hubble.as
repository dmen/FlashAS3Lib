//used by Queue

package com.gmrmarketing.miller.gifphotobooth
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
		 * @param	curUpload.dob, curUpload.email, curUpload.phone, gString, curUpload.opt1, curUpload.opt2, curUpload.opt3, curUpload.opt4, curUpload.opt4	
		 */
		public function submit(formData:Array):void
		{	
			if (hasToken()) {
				
				thePhoto = formData[3]; //used in submitPhoto
				
				busy = true;//true when submitting the user object
				
				var resp:Object = { "AccessToken":token, "MethodData": { "InteractionId":209, "DeviceId":"Flash", "DeviceResponseId":13, "ResponseDate":Strings.hubbleTimestamp(), "FieldResponses":[ { "FieldId":1484, "Response":formData[0] }, { "FieldId":1485, "Response":formData[1] },{ "FieldId":1486, "Response":formData[2] }, { "FieldId":1488, "Response":formData[4] }, { "FieldId":1489, "Response":true }, { "FieldId":1490, "Response":formData[5] }, { "FieldId":1491, "Response":formData[6] }, { "FieldId":1504, "Response":formData[7] }, { "FieldId":1505, "Response":formData[8] }], "Latitude":"0", "Longitude":"0" }};
				
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
			var resp:Object = { "AccessToken":token, "MethodData": { "InteractionResponseId":responseId, "FieldId":1487, "Response":thePhoto }};			
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
				//callPrintAPI();
			}else {
				followupError();
			}
		}
		
		/*
		private function callPrintAPI():void
		{	
			var ts:String = Strings.timestamp();
			
			var resp:Object = { "AccessToken":"2d125c5e-edb2-48ad-8a8e-07d9762091e7", "MethodData": { "InteractionId":202, "Label":"photoPrinted", "Value":"2", "Timestamp":ts, "DeviceResponseId":"sldkfjsdf" }};		
			var js:String = JSON.stringify(resp);
			
			var req:URLRequest = new URLRequest(BASE_URL + "interaction/CreateActivity");
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, printProcessed, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, followupError, false, 0, true);
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
		*/
		
		private function followupError(e:IOErrorEvent = null):void
		{
			busy = false;
			dispatchEvent(new Event(ERROR));
		}
	}
	
}