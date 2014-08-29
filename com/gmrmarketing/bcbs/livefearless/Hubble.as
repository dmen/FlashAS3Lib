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
		
		//private var pledgeOptions:Array;//array of fields and values for "how would you categorized your pledge" drop down
		private var prizeOptions:Array;//array of fields and values for "please selct your prize" drop down
		
		private var hdr:URLRequestHeader;
		private var hdr2:URLRequestHeader;
		
		
		public function Hubble()
		{		
			token = "";
			
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
			lo.load(req);
		}
		
		
		private function gotToken(e:Event):void
		{
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
			lo.load(req);
			
			
		}
		
		
		private function gotModels(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);	
			
			//pledgeOptions = new Array();
			prizeOptions = new Array();
			
			if (j.Status == 1) {
				
				for (var i:int = 0; i < j.ResponseObject.FieldOptions.length; i++) {
					/*
					if(j.ResponseObject.FieldOptions[i].FieldId == 836){
						pledgeOptions.push([j.ResponseObject.FieldOptions[i].OptionText,j.ResponseObject.FieldOptions[i].FieldOptionId]);
					}
					*/
					if (j.ResponseObject.FieldOptions[i].FieldId == 902) {						
						prizeOptions.push([j.ResponseObject.FieldOptions[i].OptionText,j.ResponseObject.FieldOptions[i].FieldOptionId]);
					}
				}
				
				dispatchEvent(new Event(GOT_TOKEN));
			}
			
		}
		
		/*
		public function getPledgeOptions():Array
		{
			return pledgeOptions;
		}
		*/
		
		public function getPrizeOptions():Array
		{
			return prizeOptions;
		}
		
		
		private function ioError(e:IOErrorEvent):void
		{			
			var t:Timer = new Timer(10000, 1);
			t.addEventListener(TimerEvent.TIMER, getToken, false, 0, true);
			t.start();
		}
		
		
		/**
		 * 
		 * @param	formData Array cur.fname, cur.lname, cur.email, cur.combo, cur.sharephoto, cur.emailoptin, cur.message, cur.prizeCombo
		 * //cur.combo is 0
		 */
		public function submitForm(formData:Array):void
		{
			
			/*var cId:int;
			switch(formData[3]) {
				case "Wellness":
					cId = 2426;
					break;
				case "Nutrition":
					cId = 2427;
					break;
				case "Fitness":
					cId = 2428;
					break;
				case "Healthcare":
					cId = 2429;
					break;
				default: // Other
					cId = 2430;
					break;
			}*/
			
			
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
			
			//var resp:Object = { "AccessToken":token, "MethodData": { "InteractionId":102, "DeviceId":"Flash", "DeviceResponseId":13, "ResponseDate":now, "FieldResponses":[ { "FieldId":677, "Response":formData[0] }, { "FieldId":678, "Response":formData[1] }, { "FieldId":671, "Response":formData[2] }, { "FieldId":679, "OptionId":cId }, { "FieldId":672, "Response":emOpt }, { "FieldId":680, "Response":true }, { "FieldId":681, "Response":phoOpt }, { "FieldId":667, "Response":formData[6] } ], "Latitude":"0", "Longitude":"0" }};			
			var resp:Object = { "AccessToken":token, "MethodData": { "InteractionId":102, "DeviceId":"Flash", "DeviceResponseId":13, "ResponseDate":now, "FieldResponses":[ { "FieldId":677, "Response":formData[0] }, { "FieldId":678, "Response":formData[1] }, { "FieldId":671, "Response":formData[2] }, { "FieldId":672, "Response":emOpt }, { "FieldId":680, "Response":true }, { "FieldId":681, "Response":phoOpt }, { "FieldId":667, "Response":formData[6] }, { "FieldId":902, "Response":formData[7] } ], "Latitude":"0", "Longitude":"0" }};
			/*var resp:Object = { "AccessToken":token, "MethodData": { "InteractionId":102, "DeviceId":"Flash", "DeviceResponseId":13, "ResponseDate":now, "FieldResponses":[ { "FieldId":677, "Response":formData[0] }, { "FieldId":678, "Response":formData[1] }, { "FieldId":671, "Response":formData[2] }, { "FieldId":672, "Response":emOpt }, { "FieldId":680, "Response":true }, { "FieldId":681, "Response":phoOpt }, { "FieldId":667, "Response":formData[5] } ], "Latitude":"0", "Longitude":"0" }};*/
			
			
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
			responseId = j.ResponseObject;
			dispatchEvent(new Event(FORM_POSTED));
		}
		
		private function formError(e:IOErrorEvent):void
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
			}
		}
		
		private function photoError(e:IOErrorEvent):void
		{
			dispatchEvent(new Event(ERROR));
		}
		
		
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