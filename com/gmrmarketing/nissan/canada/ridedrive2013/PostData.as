/**
 * Used by PrizeStorage
 */
package com.gmrmarketing.nissan.canada.ridedrive2013
{
	import flash.net.*;
	import flash.events.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Utility;
	
	public class PostData extends EventDispatcher
	{
		public static const TOKEN_RECEIVED:String = "tokenReceived";		
		public static const DATA_POSTED:String = "dataPosted";
		public static const POST_ERROR:String = "postError";
		public static const FAIL_DATA_POSTED:String = "failDataPosted";
		public static const FAIL_POST_ERROR:String = "failPostError";
		
		private const VALIDATE_URL:String = "http://api.mypik.me/api/authorize/validateuser";
		private const POST_URL:String = "http://api.mypik.me/api/interaction/interactionresponse";
		private const FOLLOWUP_URL:String = "http://api.mypik.me/api/interaction/processfollowups";
		private var authToken:String;
		
		
		public function PostData()
		{			
			authToken = "";
			getToken();
		}
		
		
		public function getToken(e:TimerEvent = null):void
		{
			var js:String = JSON.stringify({ userName: "NissanSpin", password: "$p!n" });
			var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
			var hdr2:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			
			var req:URLRequest = new URLRequest();
			
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.url = VALIDATE_URL;
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
			authToken = j.ResponseObject;
			dispatchEvent(new Event(TOKEN_RECEIVED));//calls tokenReceived() in PrizeStorage
		}
		
		
		private function ioError(e:IOErrorEvent):void
		{
			authToken = "";			
			var t:Timer = new Timer(30000, 1);
			t.addEventListener(TimerEvent.TIMER, getToken, false, 0, true);
			t.start();
		}
		

		
		/**
		 * Posts the userID and prize to the web service
		 * dispatches DATA_POSTED when complete, if the post was successful
		 * and the follow_up post is successful
		 * otherwise it dispatches POST_ERROR
		 * @param	id
		 * @param	prize
		 */
		public function post(id:String, prize:String):void
		{			
			var js:String = JSON.stringify( { AccessToken:authToken, MethodData: { InteractionId:39, deviceId:"flashKiosk", ResponseDate:Utility.getTimeStamp(), FieldResponses:[ { fieldId:279, Response:id }, { fieldId:280, Response:prize } ] }} );
			
			var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
			var hdr2:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			
			var req:URLRequest = new URLRequest();
			
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.url = POST_URL;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);

			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, postError, false, 0, true);
			
			lo.load(req);
		}
		
		
		private function dataPosted(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);
			if (j.Status == "1") {				
				postFollowUp(j.ResponseObject);//id
			}else {				
				dispatchEvent(new Event(POST_ERROR)); //calls prizeNotPosted() in PrizeStorage
			}
		}
		
		
		private function postFollowUp(id:int):void
		{
			var js:String = JSON.stringify( { AccessToken:authToken, MethodData:id } );
			
			var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
			var hdr2:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			
			var req:URLRequest = new URLRequest();
			
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.url = FOLLOWUP_URL;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);

			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, followupPosted, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, postError, false, 0, true);
			
			lo.load(req);
		}
		
		
		private function postError(e:IOErrorEvent):void
		{			
			dispatchEvent(new Event(POST_ERROR));
		}
		
		
		private function followupPosted(e:Event):void
		{
			//var j:Object = JSON.parse(e.currentTarget.data);
			dispatchEvent(new Event(DATA_POSTED));//calls prizePosted() in PrizeStorage
		}
		
		
		/**
		 * posts failed data to the service
		 * @param	id
		 * @param	prize
		 */
		public function postFail(id:String, prize:String):void
		{
			var js:String = JSON.stringify( { AccessToken:authToken, MethodData: { InteractionId:39, deviceId:"flashKiosk", ResponseDate:Utility.getTimeStamp(), FieldResponses:[ { fieldId:279, Response:id }, { fieldId:280, Response:prize } ] }} );
			
			var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
			var hdr2:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			
			var req:URLRequest = new URLRequest();
			
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.url = POST_URL;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);

			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, failDataPosted, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, failPostError, false, 0, true);
			
			lo.load(req);
		}
		
		
		private function failDataPosted(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);
			if (j.Status == "1") {
				postFailFollowUp(j.ResponseObject);//id				
			}else {
				dispatchEvent(new Event(FAIL_POST_ERROR)); //calls failPrizeError() in PrizeStorage
			}
		}
		
		
		private function failPostError(e:IOErrorEvent):void
		{			
			dispatchEvent(new Event(FAIL_POST_ERROR)); //calls failPrizeError() in PrizeStorage
		}
		
		
		private function postFailFollowUp(id:int):void
		{
			var js:String = JSON.stringify( { AccessToken:authToken, MethodData:id } );
			
			var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
			var hdr2:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			
			var req:URLRequest = new URLRequest();
			
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.url = FOLLOWUP_URL;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);

			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, failFollowPosted, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, failPostError, false, 0, true);
			
			lo.load(req);
		}
		
		private function failFollowPosted(e:Event):void
		{
			dispatchEvent(new Event(FAIL_DATA_POSTED)); //calls failPrizePosted() in PrizeStorage
		}
	}
	
}