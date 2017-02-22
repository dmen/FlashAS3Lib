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
		private var _gates:Array; //these are the gates the info kiosk cares about 
		
		private var userData:Object;
		
		
		public function Orchestrate()
		{	
			jsonHeader1 = new URLRequestHeader("Content-type", "application/json");
			jsonHeader2 = new URLRequestHeader("Accept", "application/json");
			
			//name is the gate name as returned from the call to GetGates
			//clip is the name of the background clip for that section - for coloring when it's been visited
			//holder is the icon holder for the area or demo
			_gates = [
						{"name":"Kneedeep entry", "clip":"kneedeep", "id":0},
						{"name":"Demo 1", "prettyName":"Mako Partial Knee #1", "icon":"holder1", "id":0},
						{"name":"Demo 2", "prettyName":"Mako Total Knee #2", "icon":"holder2", "id":0},
						
						{"name":"Hipnotic entry", "clip":"hipnotic", "id":0},
						{"name":"Demo 3", "prettyName":"Mako Total Hip #3", "icon":"holder3", "id":0},
						
						{"name":"Kneet! entry", "prettyName":"Kneet! - Triath10n", "clip":"kneet", "icon":"holderKneet", "id":0},
						{"name":"A Cut Above entry", "prettyName":"A Cut Above - New Technologies", "clip":"aCutAbove",  "icon":"holderAbove", "id":0},
						
						{"name":"The Balconknee", "clip":"theBalconKnee", "id":0},
						{"name":"Demo 4", "prettyName":"Mako Total Knee #4", "icon":"holder4", "id":0},
						{"name":"Demo 5", "prettyName":"Mako Total Knee #5", "icon":"holder5", "id":0},
						
						{"name":"The Joint entry", "clip":"theJoint", "id":0},
						{"name":"Demo 6", "prettyName":"Mako Total Knee #6", "icon":"holder6", "id":0},
						{"name":"Demo 7", "prettyName":"Mako Total Knee #7", "icon":"holder7", "id":0},
						
						{"name":"Predictability game", "prettyName":"Experience Predicatbility", "clip":"experiencePredictability", "icon":"holderExp", "id":0}, 
						{"name":"Operation game",  "prettyName":"Operation Mako", "clip":"operationMako", "icon":"holderOp", "id":0}, 
						{"name":"Virtual Reality",  "prettyName":"Virtual Reality", "clip":"virtualReality", "icon":"holderVR", "id":0}, 
						{"name":"Performance solutions",  "prettyName":"Performance Solutions", "clip":"performanceSolutions", "icon":"holderPerf", "id":0},						
						
						{"name":"Info kiosk 1", "id":0},
						{"name":"Info kiosk 2", "id":0},
						{"name":"Info kiosk 3", "id":0},
						{"name":"Info kiosk 4", "id":0},
						{"name":"Info kiosk 5", "id":0},
						{"name":"Info kiosk 6", "id":0},
						{"name":"Info kiosk 7", "id":0},
						{"name":"Info kiosk 8", "id":0}
			];			
		}
		
		
		/**
		 * Called from Main.rfidScanned()
		 * @param	scanID String - long integer from scan
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

		
		/**
		 * gets the user details
		 * @param	e
		 */
		private function getUserData(e:Event):void
		{
			userData = JSON.parse(e.currentTarget.data)[0];
			
			switch (userData.namePrefix) 
			{
				case "Hospital Administrator":
				case "MD, MHA":
				case "MD":
				case "DO":
					userData.profileType = 1;
					break;

				case "MD, PhD":
				case "PhD":
				case "DDS, MD":
				case "DPM":
				case "MD, Resident":
				case "DO, Resident":
					userData.profileType = 2;
					break;

				case "CRNA":
				case "APRN":
				case "DO, Fellow":
				case "RN":
				case "CST":
				case "LPN":
				case "PA":
				case "NP":
				case "MD, Fellow":
				case "N/A":
				case "Other":
					userData.profileType = 3;
					break;

				case null:
					switch(userData.packageTypeName) {
						case "Media partner":
						case "Stryker employee":
							userData.profileType = 4;
							break;
						default:
							userData.profileType = 1;//Health care professional
					}
					break;
					
				default:
					 userData.profileType = 1;
            }
			
			dispatchEvent(new Event(GOT_USER_DATA));
		}
		
		
		/**
		 * returns the userData object
		 */
		public function get user():Object
		{
			return userData;
		}
		
		public function get gates():Array
		{
			return _gates;
		}
		
		
		/**
		 * called from Main whenever a user scans their RFID
		 * @param	kioskName
		 * @param	guestID
		 */
		public function submitKioskUse(kioskName:String, guestID:String):void
		{
			var req:URLRequest = new URLRequest(baseURL + "SubmitGuestFacilityAccess");			
			var js:String = JSON.stringify({"deviceUUID":"unknown", "station":"unknown", "guestId": guestID, "gateName": kioskName, "timestamp":Utility.UTCTimeStamp("-08:00"), "inOut": "in"});
			
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
			
			for (var i:int = 0; i < _gates.length; i++){
				
				for (var j:int = 0; j < js.length; j++){
					if (js[j].name == _gates[i].name){
						_gates[i].id = js[j].id;
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