//used by Queue

package com.gmrmarketing.bcbs.livefearless
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	
	public class Hubble extends EventDispatcher
	{
		public static const GOT_TOKEN:String = "tokenReceived";
		public static const FORM_POSTED:String = "formPosted";
		public static const ERROR:String = "errorReceived";
		public static const COMPLETE:String = "followupsProcessed";
		
		private const BASE_URL:String = "http://api.nowpik.com/api/";
		
		private var token:String; //GUID
		private var responseId:int;
		
		private var pledgeOptions:Array;//array of fields and values for "how would you categorized your pledge" drop down
		private var prizeOptions:Array;//array of fields and values for "please select your prize" drop down
		private var interestOptions:Array;//array of fields and values for I am interested in" drop down
		
		private var hdr:URLRequestHeader;
		private var hdr2:URLRequestHeader;
		private var so:SharedObject;
		
		
		public function Hubble()
		{		
			token = "";
			so = SharedObject.getLocal("bcbsData");
			
			trace("============================");
			trace("     In Local Storage:");
			trace("============================");
			trace(so.data.prizeOptions);
			trace("----");
			trace(so.data.pledgeOptions);
			trace("============================");
			
			hdr = new URLRequestHeader("Content-type", "application/json");
			hdr2 = new URLRequestHeader("Accept", "application/json");
			
			getToken();			
		}

		
		public function getToken(e:TimerEvent = null):void
		{			
			var js:String = JSON.stringify({"userName":"BCBS", "password":"fearless!"});
			var req:URLRequest = new URLRequest(BASE_URL + "authorize/validateuser");
			
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, gotToken, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, ioError, false, 0, true);
			lo.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			lo.load(req);
		}
		
		
		private function gotToken(e:Event = null):void
		{
			trace("gotToken");
			var j:Object = JSON.parse(e.currentTarget.data);			
			token = j.ResponseObject;
			
			//Need to get the interactionModel in order to parse out the drop down fields
			var js:String = JSON.stringify({"AccessToken":token});
			var req:URLRequest = new URLRequest(BASE_URL + "interaction/interactionmodels");
	
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
	
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, gotModels, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, ioError, false, 0, true);
			lo.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			lo.load(req);
		}
		
		
		private function gotModels(e:Event):void
		{			
			trace("gotModels");
			var j:Object = JSON.parse(e.currentTarget.data);	
			
			pledgeOptions = new Array();
			prizeOptions = new Array();
			interestOptions = new Array();
			
			if (j.Status == 1) {
				//trace("gotModels:",j.ResponseObject.FieldOptions.length);
				for (var i:int = 0; i < j.ResponseObject.FieldOptions.length; i++) {
					
					if(j.ResponseObject.FieldOptions[i].FieldId == 836 && j.ResponseObject.FieldOptions[i].ActiveStatusType == 1){
						pledgeOptions.push([j.ResponseObject.FieldOptions[i].OptionText, j.ResponseObject.FieldOptions[i].FieldOptionId]);						
					}
					
					if (j.ResponseObject.FieldOptions[i].FieldId == 902 && j.ResponseObject.FieldOptions[i].ActiveStatusType == 1) {
						//trace("opt 902 found", j.ResponseObject.FieldOptions[i].OptionText, j.ResponseObject.FieldOptions[i].FieldOptionId);
						prizeOptions.push([j.ResponseObject.FieldOptions[i].OptionText,j.ResponseObject.FieldOptions[i].FieldOptionId]);
					}
					/*
					if (j.ResponseObject.FieldOptions[i].FieldId == 676) {
						//trace("opt 902 found", j.ResponseObject.FieldOptions[i].OptionText, j.ResponseObject.FieldOptions[i].FieldOptionId);
						interestOptions.push([j.ResponseObject.FieldOptions[i].OptionText,j.ResponseObject.FieldOptions[i].FieldOptionId]);
					}
					*/
				}				
				
				so.data.pledgeOptions = pledgeOptions.concat();
				so.data.prizeOptions = prizeOptions.concat();
				
				trace("============================");
				trace("        Got Models");
				trace("============================");
				trace(prizeOptions);
				trace("-------------");
				trace(pledgeOptions);
				trace("============================");
				trace("replacing local storage");
				
				so.flush();
				
				dispatchEvent(new Event(GOT_TOKEN));
			}
			
		}
		
		
		public function getPledgeOptions():Array
		{
			return pledgeOptions;
		}
		
		
		public function getPrizeOptions():Array
		{
			return prizeOptions;
		}
		
		public function getInterestOptions():Array
		{
			return interestOptions;
		}
		
		private function httpStatusHandler(e:HTTPStatusEvent):void
		{			
			if (e.status != 200) {
				var t:Timer = new Timer(1000, 1);
				if(token == ""){
					t.addEventListener(TimerEvent.TIMER, getToken, false, 0, true);
				}else {
					t.addEventListener(TimerEvent.TIMER, gotToken, false, 0, true);//gets models if we already have the token
				}
				t.start();
			}
		}
		private function ioError(e:IOErrorEvent):void
		{	
			if (so.data.pledgeOptions != null) {
				pledgeOptions = so.data.pledgeOptions;
				prizeOptions = so.data.prizeOptions;
				dispatchEvent(new Event(GOT_TOKEN));
			}else {
				var t:Timer = new Timer(1000, 1);
				t.addEventListener(TimerEvent.TIMER, getToken, false, 0, true);
				t.start();
			}
		}
		
		
		/**
		 * Called from Queue.uploadNext()
		 * @param	formData Array cur.fname, cur.lname, cur.email, cur.pledgeCombo, cur.sharephoto, cur.emailoptin, cur.message, cur.prizeCombo	
		 */
		public function submitForm(formData:Array):void
		{	
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
		
		
		private function formPosted(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);			
			responseId = j.ResponseObject;//used in submitPhoto() and processFollowups()
			if(j.Status == 1){
				dispatchEvent(new Event(FORM_POSTED));
			}else {
				formError();
			}
		}
		
		private function formError(e:IOErrorEvent = null):void
		{
			dispatchEvent(new Event(ERROR));
		}
		
		public function submitPhoto(photo:String):void
		{
			var resp:Object = { "AccessToken":token, "MethodData": { "InteractionResponseId":responseId, "FieldId":668, "Response":photo }};			
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
			
			if (j.Status == 1) {
				dispatchEvent(new Event(COMPLETE));
			}
		}
		
		private function followupError(e:IOErrorEvent):void
		{
			dispatchEvent(new Event(ERROR));
		}
	}
	
}