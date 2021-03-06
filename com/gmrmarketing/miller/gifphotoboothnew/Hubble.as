﻿//used by Queue

package com.gmrmarketing.miller.gifphotoboothnew
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.LoggerAIR;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Hubble extends EventDispatcher
	{		
		public static const GOT_TOKEN:String = "gotToken";
		public static const FORM_POSTED:String = "formPosted";
		public static const FORM_ERROR:String = "formErrorReceived";
		public static const PHOTO_ERROR:String = "photoErrorReceived";
		public static const FOLLOWUP_ERROR:String = "followUpErrorReceived";
		public static const COMPLETE:String = "followupsProcessed";
		
		private const BASE_URL:String = "http://api.nowpik.com/api/";
		
		private var token:String; //GUID - token returned from call to validateuser
		private var responseId:int;//set in submit if the form data is already posted, or formPosted normally
		
		private var hdr:URLRequestHeader;
		private var hdr2:URLRequestHeader;
		
		private var busy:Boolean; //true when submitting data
		private var thePhoto:String;		
		private var myGUID:String;
		
		private var log:Logger;
		private var loggerID:int;
		
		
		public function Hubble(guid:String)
		{
			myGUID = guid;//unique machine identifier - used as deviceId when submitting form data
			token = "";
			busy = false;	
			
			log = Logger.getInstance();//will make kiosklog.txt log on the desktop
			
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
		 * @param	curUpload.dob, curUpload.email, curUpload.phone, gifString, curUpload.opt1, curUpload.opt2, curUpload.opt3, curUpload.opt4, curUpload.opt5, curUpload.deviceResponseID,  curUpload.responseID, curUpload.followUpError
		 */
		public function submit(formData:Array):void
		{	
			if (hasToken()) {
				log.log("Hubble.submit" + " | " + formData[1] + " | " + formData[2] + " | deviceResponseID: " + formData[9]);
				loggerID = formData[9];
				
				thePhoto = formData[3]; //used in submitPhoto - encoded to B64 string
				
				busy = true;//true when submitting data
				
				if (formData[10] != -1) {
					
					//previous hubble responseID - means form data was posted but there was an error posting photo or followup
					if (formData[11] == true) {
						//previous followup error
						log.log("Hubble.submit - only process followups, response ID" + formData[10]);
						responseId = formData[10];
						processFollowups();
					}else {
						log.log("Hubble.submit = photo only, responseID: " + formData[10]);
						//form data already posted but posting photo or followup got an error...just post photo again
						responseId = formData[10];
						submitPhoto();
					}
					
				}else{
				
					//no prior hubble responseID - New full form post
					
					var resp:Object = { "AccessToken":token, "MethodData": { "InteractionId":247, "DeviceId":myGUID, "DeviceResponseId":formData[9], "ResponseDate":Utility.hubbleTimeStamp, "FieldResponses":[ { "FieldId":1861, "Response":formData[0] }, { "FieldId":1863, "Response":formData[1] },{ "FieldId":1869, "Response":formData[2] }, { "FieldId":1864, "Response":formData[4] }, { "FieldId":1870, "Response":true }, { "FieldId":1865, "Response":formData[5] }, { "FieldId":1866, "Response":formData[6] }, { "FieldId":1867, "Response":formData[7] }, { "FieldId":1868, "Response":formData[8] }], "Latitude":"0", "Longitude":"0" }};
					
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
		
		
		/**
		 * Callback from posting the full form
		 * sets the responseID from Hubble
		 * @param	e
		 */
		private function formPosted(e:Event):void
		{			
			var j:Object = JSON.parse(e.currentTarget.data);			
			responseId = j.ResponseObject;//used in submitPhoto() and processFollowups()
			if (j.Status == 1) {				
				submitPhoto();
			}else {
				log.log("Hubble.formPosted() - status error: " + String(j.Status));
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
			log.log("Hubble.formError() " + e.toString());
			busy = false;
			dispatchEvent(new Event(FORM_ERROR));
		}
		
		
		/**
		 * Called from formPosted() if response.Status == 1
		 * thePhoto was set in submit()
		 */
		private function submitPhoto():void
		{			
			var resp:Object = { "AccessToken":token, "MethodData": { "InteractionResponseId":responseId, "FieldId":1862, "Response":thePhoto }};			
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
				log.log("Hubble.photoPosted() - status error: " + String(j.Status));
				photoError();
			}
		}
		
		
		/**
		 * calls hubblePhotoError() in Queue
		 */
		private function photoError(e:IOErrorEvent = null):void
		{
			log.log("Hubble.photoError()" + e.toString());
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
				log.log("Hubble.followupsProcessed - COMPLETE - deviceResponseId: " + String(loggerID));
				dispatchEvent(new Event(COMPLETE));
				//callPrintAPI();
			}else {
				log.log("Hubble.followupsProcessed - status error: " + String(j.Status));
				followupError();
			}
		}
		
		/*
		private function callPrintAPI():void
		{
			var resp:Object = { "AccessToken":"2d125c5e-edb2-48ad-8a8e-07d9762091e7", "MethodData": { "InteractionId":202, "Label":"photoPrinted", "Value":"2", "Timestamp":Utility.hubbleTimeStamp, "DeviceResponseId":"sldkfjsdf" }};		
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
		
		
		/**
		 * calls hubblePhotoError() in Queue.as
		 */
		private function followupError(e:IOErrorEvent = null):void
		{
			log.log("Hubble.followupError()" + e.toString());
			busy = false;
			dispatchEvent(new Event(FOLLOWUP_ERROR));
		}
	}
	
}