//Used by Main
//Called from Main.showResults()

package com.gmrmarketing.miller.stc
{
	import flash.events.*;
	import flash.net.*;
	
	
	public class DataPost extends EventDispatcher
	{
		public function DataPost()
		{			
		}
		
		
		/**
		 * 
		 * @param	selection String l or r
		 * @param	passion String sports or music
		 * @param	formData Object with DOB, Gender, FirstName, MobilePhone keys from DataEntry
		 */
		public function post(selection:String, passion:String, formData:Object):void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
			var hdr2:URLRequestHeader = new URLRequestHeader("Accept", "application/json");			
			
			formData.Choice = selection; //l or r
			formData.PrizeType = passion; //sports or music
			var js:String = JSON.stringify(formData);
			
			var req:URLRequest = new URLRequest("http://secrettastechallenge.thesocialtab.net/Service");
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			req.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			try{
				lo.load(req);
			}catch (e:Error) {
				dataError();
			}
		}
		
		
		private function dataPosted(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);
			//trace("dataPosted", j);
		}
		
		
		private function dataError(e:IOErrorEvent = null):void
		{
			//trace("DataError:", e.toString());
		}
	}
	
}