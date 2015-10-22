/**
 * Generic Hubble Service
 * Version 1 - 9/22/2015
 * 10/14/2015 - added parameters to HubbleService constructor to allow passing userName and password
 * 10/16		Changed .gif to .image when passing the data object to send
 * 				added a second image2 to allow sending multiple images
 * 
 * Implements IQueueService - used as a service for Queue.as
 * 
 * Properties of the data object sent to send():	
 * image - 			Base64 encoded String - used by the submitPhoto() method
 * photoFieldID - 	NowPik field ID that image will be sent to
 * image2 - 		Base64 encoded String - if present submitPhoto2() is called
 * photoFieldID2 - 	NowPik field ID that image2 will be sent to
 * printed -		If true the Print API will be called
 * 
 * Properties injected by the Class:
 * responseID - injected into the object - recordID returned from the service in formPosted() - used for error processing
 * error codes
 * 		-1 if photo error occurs
 * 		-4 if photo error 2 occurs
 * 		-2 if followup error occurs
 * 		-3 if printAPI call error occurs
 */
package com.gmrmarketing.utilities.queue
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.queue.AutoIncrement;
	import com.gmrmarketing.utilities.queue.IQueueService;
	
	
	public class HubbleService extends EventDispatcher implements IQueueService
	{	
		private const BASE_URL:String = "http://api.nowpik.com/api/";

		private var token:String; //GUID - token returned from call to validateuser
		private var responseId:int;//set in submit if the form data is already posted, or formPosted normally
		
		private var hdr:URLRequestHeader;//headers for sending and receiving JSON
		private var hdr2:URLRequestHeader;
		
		private var isBusy:Boolean; //true when submitting data
		private var autoInc:AutoIncrement;//used for unique machine ID (GUID) and auto inc integer for deviceResponseID in send()
		private var upload:Object;//current object being uploaded
		private var interactionID:int; //Hubble ID - set in send()
		private var photoFieldID:int;//for sending in submitPhoto() set in send()
		private var photoFieldID2:int;//for sending in submitPhoto2() set in send()
		private var error:String;//last error - retrieved in lastError()
		
		private var auth:Object;//contains user and pwd keys - set in Constructor - used in getToken()
		
		
		/**
		 * 10/14/2015 - added parameters to HubbleService constructor to allow passing userName and password
		 * 
		 * Change username and password if you need a token specific to the interaction
		 * ie - if you'll be calling InteractionDefinitions
		 * 
		 * @param	user User name if different from default gmrdigital
		 * @param	pwd Password if different from default d1gital
		 */
		public function HubbleService(user:String = "gmrdigital", pwd:String = "d1gital")
		{
			auth = { user:user, pwd:pwd };
			
			autoInc = new AutoIncrement();
			
			token = "";
			isBusy = false;				
			error = "HubbleService Started";
			
			hdr = new URLRequestHeader("Content-type", "application/json");
			hdr2 = new URLRequestHeader("Accept", "application/json");
			
			getToken();
		}
		
		
		public function get ready():Boolean
		{
			return token != "";
		}
		
		
		public function get errorEvent():String
		{
			return "serviceError";
		}
		
		
		public function get completeEvent():String
		{
			return "serviceComplete";
		}
		
		
		/**
		 * called by constructor or every five seconds if an error occurs getting the token
		 */
		public function getToken():void
		{		
			isBusy = true;			
			
			var js:String = JSON.stringify({"userName":auth.user, "password":auth.pwd});
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
	
		
		public function get busy():Boolean
		{
			return  isBusy;
		}
		
		
		public function get authData():Object
		{
			return {"AccessToken":token};
		}
		
		
		private function gotToken(e:Event = null):void
		{			
			var j:Object = JSON.parse(e.currentTarget.data);
			if(j.Status == 1){
				token = j.ResponseObject;
				isBusy = false;
			}else {
				tokenError();
			}
		}
		
		
		
		/**
		 * If a token error occurs call getToken() again in 5 seconds
		 * 
		 * @param	e
		 */
		private function tokenError(e:IOErrorEvent = null):void
		{
			error = "HubbleService.tokenError";
			token = "";
			var a:Timer = new Timer(5000, 1);
			a.addEventListener(TimerEvent.TIMER, delayedToken, false, 0, true);
			a.start();
		}
		
		
		private function delayedToken(e:TimerEvent):void
		{
			getToken();
		}
		
		
		/**
		 * Sends the data object to Hubble
		 * responseID is the ID given to the record by the server - set to -1 the first time the record is sent
		 * set to the response ID from the server in formPosted is the status = 1
		 * DeviceResponseId is the unique record number from this machine
		 * 
		 * @param	data - has data, resp and photoFieldID properties
		 * data is the original data object as passed to Queue
		 * resp is the unique response object created in the overridden version of this send() in the extender
		 * 
		 */
		public function send(data:Object):void
		{	
			upload = data.data;//original data object sent to the service extender
			
			data.resp.AccessToken = token;
			data.resp.MethodData.DeviceId = autoInc.guid;
			data.resp.MethodData.DeviceResponseId = autoInc.nextNum;
			data.resp.MethodData.ResponseDate = Utility.hubbleTimeStamp;
			data.resp.MethodData.Latitude = "0";
			data.resp.MethodData.Longitude = "0";
			
			interactionID = data.resp.MethodData.InteractionId;//The main interactionID - used in callPrintAPI()
			photoFieldID = data.photoFieldID;//used in submitPhoto()
			photoFieldID2 = data.photoFieldID2;//used in submitPhoto2() if defined -- will be 0 if photoFieldID2 is undefined in the object
			//trace("HS.send()", upload.error, token, upload.responseID);
			if (upload.responseID == undefined || upload.responseID == 0) {
				//first time trying to send
				upload.responseID = -1;
			}			
			
			if (token != "") {
				
				isBusy = true;
				
				//responseID is returned from NowPik after the form data (initial reponse object) is posted
				if (upload.responseID == -1) {
					
					var js:String = JSON.stringify(data.resp);//the response object built in overridden send()
					var req:URLRequest = new URLRequest(BASE_URL + "interaction/interactionresponse");
					req.method = URLRequestMethod.POST;
					req.data = js;
					req.requestHeaders.push(hdr);
					req.requestHeaders.push(hdr2);
					
					var lo:URLLoader = new URLLoader();
					lo.addEventListener(Event.COMPLETE, formPosted, false, 0, true);
					lo.addEventListener(IOErrorEvent.IO_ERROR, formError, false, 0, true);
					lo.load(req);
					
				}else{					
					
					if (upload.error == -1) {
						submitPhoto();
					}else if (upload.error == -4) {
						submitPhoto2();
					}else if (upload.error == -2) {	
						processFollowups();
					}else {		
						//upload.error == -3
						callPrintAPI();
					}
					
				}
			}
		}
		
		
		/**
		 * Called by Queue if an error occurs. Queue gets the data
		 * and adds it back to the queue for later upload
		 */
		public function get data():Object
		{
			return upload;
		}
		
		
		public function get lastError():String
		{
			return error;
		}
		
		
		private function formPosted(e:Event):void
		{			
			var j:Object = JSON.parse(e.currentTarget.data);			
			
			if (j.Status == 1) {
				upload.responseID = j.ResponseObject;//record ID returned from the server
				submitPhoto();
			}else {
				error = "HubbleService.formPosted - server Status = " + String(j.Status);
				isBusy = false;
				dispatchEvent(new Event(errorEvent));
			}
		}
	
		
		/**
		 * Called if an IOError occurs
		 * No need to set error state in the upload object as the whole process will repeat
		 * @param	e
		 */
		private function formError(e:IOErrorEvent):void
		{
			error = "HubbleService.formError: " + e.toString();
			isBusy = false;
			dispatchEvent(new Event(errorEvent));
		}
		
		
		/**
		 * Called from formPosted() if response.Status == 1
		 */
		private function submitPhoto():void
		{		
			upload.error = 0;
			
			var resp:Object = { "AccessToken":token, "MethodData": { "InteractionResponseId":upload.responseID, "FieldId":photoFieldID, "Response":upload.image }};			
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
				if (photoFieldID2 != 0) {//set to 0 in send() if incoming object had photoFieldID2 undefined
					submitPhoto2();
				}else {
					processFollowups();
				}
			}else {
				error = "HubbleService.photoPosted - server Status: " + String(j.Status);
				isBusy = false;
				upload.error = -1;
				dispatchEvent(new Event(errorEvent));
			}
		}
		
		
		/**
		 * Called if an IOError occurs or from photoPosted if server Status was not 1
		 * Sets error state in the upload object to -1
		 * @param	e
		 */
		private function photoError(e:IOErrorEvent):void
		{
			error = "HubbleService.photoError: " + e.toString();
			isBusy = false;
			upload.error = -1;
			dispatchEvent(new Event(errorEvent));
		}
		
		
		/**
		 * Called from formPosted() if response.Status == 1
		 */
		private function submitPhoto2():void
		{		
			upload.error = 0;
			
			var resp:Object = { "AccessToken":token, "MethodData": { "InteractionResponseId":upload.responseID, "FieldId":photoFieldID2, "Response":upload.image2 }};			
			var js:String = JSON.stringify(resp);
			
			var req:URLRequest = new URLRequest(BASE_URL + "interaction/interactionfieldresponse");
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, photoPosted2, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, photoError2, false, 0, true);
			lo.load(req);
		}
		
		
		private function photoPosted2(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);
			
			if (j.Status == 1) {
				processFollowups();
			}else {
				error = "HubbleService.photoPosted2 - server Status: " + String(j.Status);
				isBusy = false;
				upload.error = -4;
				dispatchEvent(new Event(errorEvent));
			}
		}
		
		
		/**
		 * Called if an IOError occurs or from photoPosted if server Status was not 1
		 * Sets error state in the upload object to -1
		 * @param	e
		 */
		private function photoError2(e:IOErrorEvent):void
		{
			error = "HubbleService.photoError2: " + e.toString();
			isBusy = false;
			upload.error = -4;
			dispatchEvent(new Event(errorEvent));
		}
		
		
		/**
		 * Calls processFollowups on the server
		 */
		private function processFollowups():void
		{			
			upload.error = 0;
			
			var resp:Object = { "AccessToken":token, "MethodData": upload.responseID };			
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
			
			isBusy = false;
			
			if (j.Status == 1) {
				if (upload.printed == true) {
					callPrintAPI();
				}else{
					dispatchEvent(new Event(completeEvent));
				}				
			}else {
				error = "HubbleService.followupsProcessed - server Status = " + String(j.Status);				
				upload.error = -2;
				dispatchEvent(new Event(errorEvent));
			}
		}
		
		
		private function followupError(e:IOErrorEvent):void
		{
			error = "HubbleService.followupError: " + e.toString();
			isBusy = false;
			upload.error = -2;
			dispatchEvent(new Event(errorEvent));
		}
		
		
		/**
		 * called from followUpsProcessed if upload.printed == true
		 */
		private function callPrintAPI():void
		{	
			upload.error = 0;
			
			var ts:String = Utility.hubbleTimeStamp;
			
			var resp:Object = { "AccessToken":token, "MethodData": { "InteractionId":interactionID, "Label":"photoPrinted", "Value":"1", "Timestamp":ts, "DeviceResponseId":autoInc.guid }};		
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
			
			isBusy = false;
			
			if (j.Status == 1) {
				error = "HubbleService.printProcessed: - post complete";
				dispatchEvent(new Event(completeEvent));
			}else {
				error = "Error in printProcessed - server Status = " + String(j.Status);
				upload.error = -3;
				dispatchEvent(new Event(errorEvent));
			}
		}
		
		
		private function printAPIError(e:IOErrorEvent):void
		{
			error = "HubbleService.printAPIError: " + e.toString();
			isBusy = false;
			upload.error = -3;
			dispatchEvent(new Event(errorEvent));
		}
	}
	
}