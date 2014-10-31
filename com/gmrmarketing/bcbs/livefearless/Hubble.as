//used by Queue

package com.gmrmarketing.bcbs.livefearless
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.LoggerAIR;
	
	public class Hubble extends EventDispatcher
	{
		public static const GOT_MODELS:String = "modelDataReceived";
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
		
		private var working:Boolean; //true when submitting data
		private var thePhoto:String;		
		
		private var log:Logger;
		
		
		public function Hubble()
		{		
			log = new Logger();
			log.setLogger(new LoggerAIR());//creates kiosklog.txt on the desktop
			log.log("Hubble Constructor");
			
			token = "";
			pledgeOptions = new Array();
			prizeOptions = new Array();
			working = false;
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
			log.log("Hubble.getToken()");
			var js:String = JSON.stringify({"userName":"BCBS", "password":"fearless!"});
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
		
		public function isWorking():Boolean
		{
			return working;
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
				getModels();
				
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
			modelError();
		}
		
		
		/**
		 * Gets the interaction models
		 * called from gotToken()
		 */
		private function getModels(e:TimerEvent = null):void
		{
			log.log("Hubble.getModels()");
			//Need to get the interactionModel in order to parse out the drop down fields
			var js:String = JSON.stringify({"AccessToken":token});
			var req:URLRequest = new URLRequest(BASE_URL + "interaction/interactionmodels");
	
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
	
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, gotModels, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, modelError, false, 0, true);
			lo.load(req);
		}
		
		
		/**
		 * Callback from getModels()
		 * parses the JSON into the arrays
		 * resets the shared object with the new data
		 * @param	e
		 */
		private function gotModels(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);	
			
			pledgeOptions = new Array();
			prizeOptions = new Array();
			
			if (j.Status == 1) {
				log.log("Hubble.gotModels() - Status = 1");
				for (var i:int = 0; i < j.ResponseObject.FieldOptions.length; i++) {
					
					if(j.ResponseObject.FieldOptions[i].FieldId == 836 && j.ResponseObject.FieldOptions[i].ActiveStatusType == 1){
						pledgeOptions.push([j.ResponseObject.FieldOptions[i].OptionText, j.ResponseObject.FieldOptions[i].FieldOptionId]);						
					}
					
					if (j.ResponseObject.FieldOptions[i].FieldId == 902 && j.ResponseObject.FieldOptions[i].ActiveStatusType == 1) {
						prizeOptions.push([j.ResponseObject.FieldOptions[i].OptionText,j.ResponseObject.FieldOptions[i].FieldOptionId]);
					}
				}				
				
				so.data.pledgeOptions = pledgeOptions.concat();
				so.data.prizeOptions = prizeOptions.concat();
				
				so.flush();
				
				dispatchEvent(new Event(GOT_MODELS));
				
			}else {
				//Status != 1
				modelError();//check local cache
			}
		}
		
		
		/**
		 * Error callback for interactionModels call in gotToken()
		 * Called from tokenError()
		 * called from gotModels() if status != 1
		 * dispatches GOT_TOKEN like gotModels() if there is data in the local shared object
		 * @param	
		 */
		private function modelError(e:IOErrorEvent = null):void
		{	
			log.log("Hubble.modelError()");
			if (so.data.pledgeOptions != null) {
				log.log("Hubble.modelError() - using local cache data");
				pledgeOptions = so.data.pledgeOptions;
				prizeOptions = so.data.prizeOptions;
				dispatchEvent(new Event(GOT_MODELS));//token could still be "" if called from tokenError()
			}else {
				log.log("Hubble.modelError() - no local cache");
				var t:Timer = new Timer(5000, 1);
				if (token == "") {
					//can't call getModels again with a blank token
					t.addEventListener(TimerEvent.TIMER, getToken, false, 0, true);
				}else {
					//got the token - call getModels again since there's nothing in local cache
					t.addEventListener(TimerEvent.TIMER, getModels, false, 0, true);
				}
				
				t.start();
			}
		}
		
		
		public function getPledgeOptions():Array
		{
			if(pledgeOptions.length > 0){
				return pledgeOptions;
			}else {
				return new Array([["",0]]);
			}
		}
		
		
		public function getPrizeOptions():Array
		{
			if (prizeOptions.length > 0) {
				return prizeOptions;
			}else {
				return new Array([["",0]]);
			}			
		}
		
		
		/**
		 * Called from Queue.uploadNext()
		 * @param	formData Array fname, lname, email, pledgeCombo, sharephoto, emailoptin, message, prizeCombo, image	
		 */
		public function submit(formData:Array):void
		{	
			if (hasToken()) {
				
				thePhoto = formData[8]; //used in submitPhoto
				
				working = true;//true while hubble is submitting the user object
				
				var phoOpt:Boolean = formData[4] == "true" ? true : false;
				var	emOpt:Boolean = formData[5] == "true" ? true : false;			
					
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
				
				var resp:Object = { "AccessToken":token, "MethodData": { "InteractionId":102, "DeviceId":"Flash", "DeviceResponseId":13, "ResponseDate":now, "FieldResponses":[ { "FieldId":677, "Response":formData[0] }, { "FieldId":678, "Response":formData[1] }, { "FieldId":671, "Response":formData[2] }, { "FieldId":672, "Response":emOpt }, { "FieldId":680, "Response":true }, { "FieldId":681, "Response":phoOpt }, { "FieldId":667, "Response":formData[6] }, { "FieldId":902, "OptionId":parseInt(formData[7]) }, { "FieldId":836, "OptionId":parseInt(formData[3]) }], "Latitude":"0", "Longitude":"0" }};
				
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
			working = false;
			dispatchEvent(new Event(ERROR));
		}
		
		
		/**
		 * Called from formPosted() is response.Status == 1
		 * thePhoto was set in submit()
		 */
		private function submitPhoto():void
		{			
			log.log("Hubble.submitPhoto() - responseID:" + responseId);
			var resp:Object = { "AccessToken":token, "MethodData": { "InteractionResponseId":responseId, "FieldId":668, "Response":thePhoto }};			
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
			working = false;
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
			working = false;
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
			working = false;
			dispatchEvent(new Event(ERROR));
		}
	}
	
}