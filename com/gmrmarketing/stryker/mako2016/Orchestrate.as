package com.gmrmarketing.stryker.mako2016
{
	import flash.events.*;
	import flash.net.*;
	import com.gmrmarketing.utilities.Utility;
	import com.dynamicflash.util.Base64;
	
	public class Orchestrate extends EventDispatcher 
	{
		public static const GOT_BASE_URL:String = "gotBaseURL";
		public static const GOT_TOKEN:String = "gotAuthToken";
		public static const GOT_GATES:String = "gotGateData";
		public static const GOT_USER_DATA:String = "gotUser";
		
		private var authHeader:URLRequestHeader;//built in getLoginData()
		private var jsonHeader1:URLRequestHeader;	
		private var jsonHeader2:URLRequestHeader;	
		
		private var baseURL:String;
		private var gates:Array; //these are the gates the info kiosk cares about 
		
		private var userData:Object;
		
		
		public function Orchestrate()
		{	
			jsonHeader1 = new URLRequestHeader("Content-type", "application/json");
			jsonHeader2 = new URLRequestHeader("Accept", "application/json");
			
			gates = [{"name":"Demo 1", "id":0}, {"name":"Demo 2", "id":0}, {"name":"Demo 3", "id":0}, {"name":"Demo 4", "id":0}, {"name":"Demo 5", "id":0}, {"name":"Demo 6", "id":0}, {"name":"Demo 7", "id":0}, {"name":"Predictability game", "id":0}, {"name":"Operation game", "id":0}, {"name":"Virtual Reality", "id":0}, {"name":"Performance solutions", "id":0}, {"name":"Info kiosk 1", "id":0}, {"name":"Info kiosk 2", "id":0}, {"name":"Info kiosk 3", "id":0}, {"name":"Info kiosk 4", "id":0}, {"name":"Info kiosk 5", "id":0}, {"name":"Info kiosk 6", "id":0}, {"name":"Info kiosk 7", "id":0}, {"name":"Info kiosk 8", "id":0}];
			
		}
		
		
		/**
		 * Called from Main.rfidScanned()
		 * @param	scanID
		 */
		public function getUser(scanID:String):void
		{
			var req:URLRequest = new URLRequest(baseURL + "GetGuests");
			
			var variables:URLVariables = new URLVariables();
            variables.fullDetails = true;
			variables.rfid = scanID;
			
			req.data = variables;
			
			req.requestHeaders.push(authHeader);
			req.requestHeaders.push(jsonHeader2);//accept
			
			req.method = URLRequestMethod.GET;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, orchestrateError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, getUserData, false, 0, true);
			lo.load(req);
		}

		
		private function getUserData(e:Event):void
		{
			userData = JSON.parse(e.currentTarget.data);
			dispatchEvent(new Event(GOT_USER_DATA));
		}
		
		
		/**
		 * the userData JSON is an array - with the single user data object in it
		 */
		public function get user():Object
		{
			return userData[0];
		}
		
		
		/**
		 * called from Main whenever a user scans their RFID
		 * @param	kioskName
		 * @param	guestID
		 */
		public function submitKioskUse(kioskName:String, guestID:String):void
		{
			var req:URLRequest = new URLRequest(baseURL + "SubmitGuestFacilityAccess");			
			var js:String = JSON.stringify({"deviceUUID":"unknown", "station":"unknown", "guestId": guestID, "gateName": kioskName, "timestamp": Utility.hubbleTimeStamp, "inOut": "in"});
			
			req.data = js;
			req.requestHeaders.push(authHeader);
			req.requestHeaders.push(jsonHeader1);
			req.requestHeaders.push(jsonHeader2);//accept

		}
		
		
		public function getBaseURL():void
		{
			var req:URLRequest = new URLRequest("https://register.gmrevents.com/guesttracking/Service.svc/GetURL");
			var variables:URLVariables = new URLVariables();
            variables.site = "stryker";
			req.data = variables;
			req.requestHeaders.push(jsonHeader2);//accept
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, orchestrateError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, getBaseURLData, false, 0, true);
			lo.load(req);
		}
		
		
		private function getBaseURLData(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);
			baseURL = j.url;
			
			dispatchEvent(new Event(GOT_BASE_URL));
		}
		
		
		/**
		 * Called from Main.gotBaseURL once the base url has been retrieved
		 * creates the Authroization header used in subsequent calls
		 * @param	credentials String username:password - like: Kiosk2:Diego2017
		 */
		public function login(credentials:String):void
		{
			var b64:String = Base64.encode(credentials);
			
			var req:URLRequest = new URLRequest(baseURL + "login");
			
			var authHdr:URLRequestHeader = new URLRequestHeader("Authorization", "Basic " + b64);			
			req.requestHeaders.push(authHdr)	
			req.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, orchestrateError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, getLoginData, false, 0, true);
			lo.load(req);
		}
		
		
		private function getLoginData(e:Event):void
		{			
			authHeader = new URLRequestHeader("Authorization", "Bearer token=" + e.currentTarget.data);
			dispatchEvent(new Event(GOT_TOKEN));
		}
		
		
		/**
		 * called from Main.gotToken() once the token has been retrieved
		 */
		public function getGates():void
		{
			var req:URLRequest = new URLRequest(baseURL + "GetGates");
			req.requestHeaders.push(authHeader);
			req.requestHeaders.push(jsonHeader2);//accept
			
			req.method = URLRequestMethod.GET;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, orchestrateError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, getGatesData, false, 0, true);
			lo.load(req);
		}
		
		
		/**
		 * populates the gates array with the gate id's
		 * @param	e
		 */
		private function getGatesData(e:Event):void
		{
			//array of objects
			var js:Object = JSON.parse(e.currentTarget.data);
			
			for (var i:int = 0; i < gates.length; i++){
				
				for (var j:int = 0; j < js.length; j++){
					if (js[j].name == gates[i].name){
						gates[i].id = js[j].id;
						break;
					}
				}
			}
			
			dispatchEvent(new Event(GOT_GATES));
		}
		
		
		private function orchestrateError(e:IOErrorEvent):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);			
			trace("orchestrateError - ", j);
		}
		
		
			
		
		
		
		
		
		
		
	}
	
}