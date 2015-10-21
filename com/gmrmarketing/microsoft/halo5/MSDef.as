/**
 * Microsoft - Get Interaction Definition from NowPik
 * Used for populating store list dropdown
 */
package com.gmrmarketing.microsoft.halo5
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;	
	
	
	public class MSDef extends EventDispatcher
	{
		public static const COMPLETE:String = "ID_complete";
		public static const ERROR:String = "ID_error";
		private const BASE_URL:String = "http://api.nowpik.com/api/";
		
		private var myData:Array;
		
		
		public function MSDef()
		{
			myData = [];
		}
		
				
		public function getInteractionDefinition(token:String):void
		{
			var js:String = JSON.stringify({"AccessToken":token});
			var req:URLRequest = new URLRequest(BASE_URL + "interaction/interactiondefinition");
			
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.requestHeaders.push(new URLRequestHeader("Content-type", "application/json"));
			req.requestHeaders.push(new URLRequestHeader("Accept", "application/json"));
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, gotID, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, IDError, false, 0, true);
			lo.load(req);
		}
		
		
		/**
		 * Returns an array of objects
		 * each object has id,label, and value keys
		 */
		public function get data():Array
		{
			return myData;
		}
		
		
		private function gotID(e:Event):void
		{	
			var j:Object = JSON.parse(e.currentTarget.data);
			
			//array of objects with id,label,value properties (label and value are equal)
			myData = j.ResponseObject[0].steps[0].fields[0].options as Array;
			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function IDError(e:IOErrorEvent):void
		{
			dispatchEvent(new Event(ERROR));
		}
	}
	
}