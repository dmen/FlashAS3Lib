/**
 * Manages sending user data to the webservice
 * also stores the data locally in order to be able
 * to display the high scores.
 */
package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.events.*;
	import flash.net.*;
	
	
	public class WebService extends EventDispatcher
	{		
		private const URL:String = "http://bluecrosshorizon.thesocialtab.net/home/SaveGame";
		
		private var isPosting:Boolean; //true while posting
		
		private var allData:SharedObject;//local storage for top ten scoring users
		private var allUsers:Array; //all the users in allData - used for high scores		
		
		private var sendQueue:SharedObject;//local store for all users not yet sent to server
		private var currQueue:Array; //users waiting to send
		private var currUser:Array; //currently posting userData
		
		
		public function WebService()
		{			
			allData = SharedObject.getLocal("allData");
			allUsers = allData.data.users;
			if (allUsers == null) {
				allUsers = new Array();				
			}
			
			sendQueue = SharedObject.getLocal("queueData");
			currQueue = sendQueue.data.users;
			if (currQueue == null) {
				currQueue = new Array();
				updateQueue();
			}			
			
			isPosting = false;
			
			postNextUser();
		}
		
		
		/**
		 * inserts a user to allUsers/allData in score sorted order
		 * also adds user to the send queue
		 * @param	user Array fname,lname,email,phone,state,sweeps entry,optin,moreInfo,q1a,q2a,event,score
		 */
		public function addUser(user:Array):void
		{
			var inserted:Boolean = false;
			for (var i:int = 0; i < allUsers.length; i++) {
				if (user[11] > allUsers[i][11]) {
					allUsers.splice(i, 0, user);
					inserted = true;
					break;
				}
			}
			if (!inserted) {
				allUsers.push(user);
			}
			
			updateAllData();//updates allData sharedObject with allUsers array
			
			currQueue.push(user);
			updateQueue();//updates sendQueue sharedObject with array
			
			if (!isPosting) {
				postNextUser();
			}
		}		
		
		
		/**
		 * Returns a score sorted array for leaderboard display
		 * @return Array - max 10 items
		 */
		public function getLeaderboard():Array
		{
			return allUsers
		}
		
		
		private function postNextUser():void
		{			
			if (currQueue.length > 0) {
				
				currUser = currQueue[0];
				isPosting = true;
				
				var vars:URLVariables = new URLVariables();
				
				vars.fname = currUser[0];
				vars.lname = currUser[1];
				vars.email = currUser[2];
				vars.phone = currUser[3];				
				vars.state = currUser[4];
				
				//get event pid from event string: pid:desc
				//if no event selected the string is "-" - in that case send empty string to service
				var ev:String = currUser[10];
				if (ev == "-") {
					vars.programId = "";
				}else{
					var a:Array = ev.split(":");				
					vars.programId = a[0];
				}
				
				vars.interestedIn = currUser[9]; //answer to question 2
				vars.currentHealthIns = currUser[8];//answer to question 1
				
				vars.moreInfo = currUser[7];//more info on from sweeps page dropdown
				
				vars.sweepsEntry = currUser[5] == "true" ? true : false;//true false - sweeps page
				vars.optIn = currUser[6] == "true" ? true : false; //true false - sweeps page
				vars.gameScore = parseInt(currUser[11]);				
				
				var request:URLRequest = new URLRequest(URL);
				request.data = vars;
				request.method = URLRequestMethod.POST;
				
				var lo:URLLoader = new URLLoader();
				lo.addEventListener(Event.COMPLETE, saveDone, false, 0, true);
				lo.addEventListener(IOErrorEvent.IO_ERROR, saveError, false, 0, true);
				lo.load(request);
			}			
		}
		
		
		private function saveDone(e:Event):void
		{
			isPosting = false;
			currQueue.shift();
			updateQueue();//removes newly posted user		
			postNextUser();
		}		
		
		
		private function saveError(e:IOErrorEvent):void
		{			
			isPosting = false;
			postNextUser();
		}
		
		
		private function updateAllData():void
		{			
			var topTen:Array = new Array();
			var user:Object;
			while (topTen.length < 10 && allUsers.length > 0) {
				user = allUsers.shift();				
				topTen.push(user);				
			}
			allUsers = topTen;
			allData.data.users = topTen;
			allData.flush();
		}
		
		
		private function updateQueue():void
		{
			sendQueue.data.users = currQueue;
			sendQueue.flush();
		}
		
	}
	
}