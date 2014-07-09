package com.gmrmarketing.sap.levisstadium.avatar.testing
{
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.net.*;
	import com.gmrmarketing.sap.boulevard.avatar.ImageService;
	import flash.utils.Timer;
	
	
	public class Comm extends EventDispatcher
	{
		public static const GOT_USER_DATA:String = "gotDataFromRFID";
		public static const USER_ERROR:String = "userERROR";//dispatched if null or empty strings in the returned json
		public static const USER_DATA_ERROR:String = "userDataError";//called on IOerror event
		public static const TIMEOUT:String = "networkTimeout";
		
		private const GUID:String = "81936263-7B3F-49CE-953F-D229CF981F7E";//for verifying the server call is from our app
		private var ims:ImageService;//for queueing images
		private var user:Object;
		private var userLoader:URLLoader;
		private var timeoutTimer:Timer;
		
		
		public function Comm()
		{
			ims = new ImageService();
			
			//ims.setServiceURL("http://sapsb48service.thesocialtab.net/rfid/UploadImage");
			
			//OMNICOM
			//parameters: email,type,base64Image
			ims.setServiceURL("http://omcnowpik.thesocialtab.net/home/UploadImage");
			
			ims.setSaveFolder("sap_avatar/"); //folder on the desktop - will get created
			
			userLoader = new URLLoader();
			
			timeoutTimer = new Timer(45000);
			timeoutTimer.addEventListener(TimerEvent.TIMER, timedOut);
		}
		
		
		/**
		 * called from Main.gotRFID() once the users scan is good
		 * sends users rfid # to service and gets data back
		 * Gets JSON back from the service
		 * 
		 * @param	visitorID from the visitor.json file
		 */
		public function userData(visitorID:String):void
		{			
			var request:URLRequest = new URLRequest("http://sapsb48service.thesocialtab.net/rfid/register");
				
			var vars:URLVariables = new URLVariables();
			vars.guid = GUID;
			vars.rfid = visitorID;					
					
			request.data = vars;			
			request.method = URLRequestMethod.POST;
			
			var jsonHeader:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			request.requestHeaders.push(jsonHeader);
			
			timeoutTimer.reset();
			timeoutTimer.start();			
			
			userLoader.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			userLoader.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			userLoader.load(request);
		}
		
		
		private function timedOut(e:TimerEvent):void
		{
			userLoader.close();//close the loader if still in progress
			timeoutTimer.reset();
			dispatchEvent(new Event(TIMEOUT));
		}
		
		
		//gets JSON back like:
		//{"FirstName":"antonio","LastName":"zugno","City":"Rochester","State":"NY","FavoriteTeam":"GB"}
		private function dataPosted(e:Event):void
		{
			user = JSON.parse(e.currentTarget.data);
			timeoutTimer.reset();
			
			if (user.FirstName == null || user.FirstName == "") {
				
				user.FirstName = "";
				user.LastName = "";
				if(Math.random() < .5){
					user.FavoriteTeam = "broncos";
				}else {
					user.FavoriteTeam = "seahawks";
				}
				user.City = "";
				user.State = "";
				
				//rfid not found - JSON returned null data
				dispatchEvent(new Event(USER_ERROR));
				
			}else{
				
				//need to convert team strings coming from Fish into strings used in these classes...
				user.FavoriteTeam = "";
				if (user.FavoriteTeam == "" || user.FavoriteTeam == null) {
					if(Math.random() < .5){
						user.FavoriteTeam = "broncos";
					}else {
						user.FavoriteTeam = "seahawks";
					}
				}
				switch(user.FavoriteTeam) {
					case "Arizona Cardinals":
						user.FavoriteTeam = "cardinals";
						break;
					case "Atlanta Falcons":
						user.FavoriteTeam = "falcons";
						break;
					case "Baltimore Ravens":
						user.FavoriteTeam = "ravens";
						break;
					case "Buffalo Bills":
						user.FavoriteTeam = "bills";
						break;
					case "Carolina Panthers":
						user.FavoriteTeam = "panthers";
						break;
					case "Chicago Bears":
						user.FavoriteTeam = "bears";
						break;
					case "Cincinnati Bengals":
						user.FavoriteTeam = "bengals";
						break;
					case "Cleveland Browns":
						user.FavoriteTeam = "browns";
						break;
					case "Dallas Cowboys":
						user.FavoriteTeam = "cowboys";
						break;
					case "Denver Broncos":
						user.FavoriteTeam = "broncos";
						break;
					case "Detroit Lions":
						user.FavoriteTeam = "lions";
						break;
					case "Green Bay Packers":
						user.FavoriteTeam = "packers";
						break;
					case "Houston Texans":
						user.FavoriteTeam = "texans";
						break;
					case "Indianapolis Colts":
						user.FavoriteTeam = "colts";
						break;
					case "Jacksonville Jaguars":
						user.FavoriteTeam = "jaguars";
						break;
					case "Kansas City Chiefs":
						user.FavoriteTeam = "chiefs";
						break;
					case "Miami Dolphins":
						user.FavoriteTeam = "dolphins";
						break;
					case "Minnesota Vikings":
						user.FavoriteTeam = "vikings";
						break;
					case "New England Patriots":
						user.FavoriteTeam = "patriots";
						break;
					case "New Orleans Saints":
						user.FavoriteTeam = "saints";
						break;
					case "New York Giants":
						user.FavoriteTeam = "giants";
						break;
					case "New York Jets":
						user.FavoriteTeam = "jets";
						break;
					case "Oakland Raiders":
						user.FavoriteTeam = "raiders";
						break;
					case "Philadelphia Eagles":
						user.FavoriteTeam = "eagles";
						break;
					case "Pittsburgh Steelers":
						user.FavoriteTeam = "steelers";
						break;
					case "San Diego Chargers":
						user.FavoriteTeam = "chargers";
						break;
					case "San Francisco 49ers":
						user.FavoriteTeam = "49ers";
						break;
					case "Seattle Seahawks":
						user.FavoriteTeam = "seahawks";
						break;
					case "St. Louis Rams":
						user.FavoriteTeam = "rams";
						break;
					case "Tampa Bay Buccaneers":
						user.FavoriteTeam = "buccaneers";
						break;
					case "Tennessee Titans":
						user.FavoriteTeam = "titans";
						break;
					case "Washington Redskins":
						user.FavoriteTeam = "redskins";
						break;
				}
				dispatchEvent(new Event(GOT_USER_DATA));
			}
		}		
		
		
		/**
		 * Returns the user data object
		 * {"FirstName":"antonio","LastName":"zugno","City":"Rochester","State":"NY","FavoriteTeam":"packers"}
		 * @return
		 */
		public function getUserData():Object 
		{
			//return user;//RASCH MEETING
			return {"FirstName":"guest","LastName":"","City":"Milwaukee","State":"WI","FavoriteTeam":"packers"}
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			timeoutTimer.reset();
			dispatchEvent(new Event(USER_DATA_ERROR));
		}
		
		
		//called from Main
		public function saveImage(image:BitmapData, rfid:String):void
		{
			//trace("comm.saveImage()");
			ims.addToQueue(image, GUID, rfid);
		}
		//called from Main - for OMNICOM meeting
		public function saveImage2(image:BitmapData, email:String):void
		{
			//trace("comm.saveImage()");
			ims.addToQueue2(image, email);
		}
		
	}
	
}