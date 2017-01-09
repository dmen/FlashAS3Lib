/**
 * Used by Main
 * Finds bridge IP and uses queue to post data and pics
 */
package com.gmrmarketing.nestle.dolcegusto2016
{
	import com.gmrmarketing.utilities.queue.JSONService;
	import flash.events.*;
	import flash.net.*;
	import flash.errors.IOError;
	import com.gmrmarketing.utilities.queue.Queue;
	
	
	public class NetStuff extends EventDispatcher
	{
		public static const GOTIP:String = "GotBridgeIP";
		
		private var hdr:URLRequestHeader;
		private var hdr2:URLRequestHeader;			
		private var bridgeID:String;
		private var bridgeIP:String = "0";
		
		private var quizQueue:Queue;//for fname,email,quiz answers
		private var photoQueue:Queue;//for email and photo
		
		
		public function NetStuff()
		{
			hdr = new URLRequestHeader("Content-type", "application/json");
			hdr2 = new URLRequestHeader("Accept", "application/json");
			
			quizQueue = new Queue();
			quizQueue.fileName = "nestle_quizQueue";
			quizQueue.service = new JSONService("https://nescafedolcegusto.thesocialtab.net/home/register", {"Message":null,"Success":true});
			quizQueue.addEventListener(Queue.LOG_ENTRY, showQueueLog);
			quizQueue.start();//send any old entries if there are any
			
			photoQueue = new Queue();
			photoQueue.fileName = "nestle_photoQueue";
			photoQueue.service = new JSONService("https://nescafedolcegusto.thesocialtab.net/home/uploadphoto");// {"Message":null, "Success":true});
			photoQueue.start();
		}
		
		
		private function showQueueLog(e:Event):void
		{
			trace(quizQueue.logEntry);
		}
		
		
		/**
		 * Called from Main.postUserData()
		 * @param	userData Object with Email, FName, OptIn, Result, Timestamp, Q1 - Q9 properties
		 */
		public function postResults(userData:Object):void
		{
			quizQueue.add(userData);
			/*
			var js:String = JSON.stringify(userData);
			
			var req:URLRequest = new URLRequest("http://NestleDolceGustoEventQ4.gmrpreprod.com/api/home/register");
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			req.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, postError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			lo.load(req);
			*/
		}
		
		
		private function postError(e:IOErrorEvent):void
		{
			//TODO: Handle this...
		}
		
		
		private function dataPosted(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);			
		}
		
		
		/**
		 * calls the bridge finding service on meethue.com
		 * This because the IP of the bridge changes whenever it power cycles
		 * gets an array of bridge objects
		 * @param	$bridgeID String ID from the back of the bridge like 2BBF52
		 */
		public function getBridgeIP($bridgeID:String):void
		{
			bridgeID = $bridgeID.toUpperCase();
			bridgeIP = "0";
			
			var req:URLRequest = new URLRequest("https://www.meethue.com/api/nupnp");			
			req.requestHeaders.push(hdr2);
			req.method = URLRequestMethod.GET;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, ipError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, gotIP, false, 0, true);
			lo.load(req);
		}
		
		
		/**
		 * gets an arrayof objects with id and internalipaddress properties
		 * @param	e
		 */
		private function gotIP(e:Event):void
		{	
			var bridges:Object = JSON.parse(e.currentTarget.data);
			
			if (bridges.length == 0){
				trace("hue bridge not found");
			}
			
			for (var i:int = 0; i < bridges.length; i++){
				var thisBridge:Object = bridges[i];
				var thisID:String = String(thisBridge.id).toUpperCase();
				
				if (thisID.indexOf(bridgeID) != -1){
					//this is our bridge
					bridgeIP = thisBridge.internalipaddress;
					trace("found the hue bridge");
					break;
				}
			}
			dispatchEvent(new Event(GOTIP));
		}
		
		
		/**
		 * returns the IP of the bridge - located by calling
		 * the bridge finding service on meethue.com
		 */
		public function get IP():String
		{
			return bridgeIP;
		}
		
		
		private function ipError(e:IOErrorEvent):void
		{
			trace("hue bridge not found", e.toString());
			dispatchEvent(new Event(GOTIP));
		}
		
		
		/**
		 * called from Main.postPhoto once thanks is complete - ie the photo has
		 * been converted to b64
		 * 
		 * @param	userData Object with Email,Image,Timestamp properties
		 */
		public function postPhoto(userData:Object):void
		{
			//var req:URLRequest = new URLRequest("http://NestleDolceGustoEventQ4.gmrpreprod.com/api/home/UploadPhoto");			
			
			photoQueue.add(userData);
			/*
			var js:String = JSON.stringify(userData);
			
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			req.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, postPhotoError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, photoPosted, false, 0, true);
			lo.load(req);
			*/
		}
		
		
		private function postPhotoError(e:IOErrorEvent):void
		{
			//TODO: Handle this...
		}
		
		
		private function photoPosted(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);
			
		}
		
	}
	
}