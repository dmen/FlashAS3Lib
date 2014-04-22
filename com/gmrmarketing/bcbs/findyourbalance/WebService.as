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
		
		private var allData:SharedObject;//local storage for all user data
		private var allUsers:Array; //all the users in allData - used for high scores
		private var currUser:Array; //currently posting userData
		
		private var sendQueue:SharedObject;//local store for all users not yet sent to server
		private var currQueue:Array; //users waiting to send
		
		
		
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
		 * adds a user to allUsers/allData 
		 * also adds to the send queue
		 * @param	user Array fname,lname,email,phone,state,sweeps entry,optin,moreInfo,q1a,q2a,event,score
		 */
		public function addUser(user:Array):void
		{
			allUsers.push(user);
			updateAllData();//updates sharedObject with allUsers array
			
			currQueue.push(user);
			updateQueue();//updates sharedObject with array
			
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
			//array of arrays. Sub arrays contain: fname,lname,email,phone,state,sweeps entry,optin,moreInfo,q1a,q2a,event,score
			
			var ad:Array = allUsers.concat();//duplicate array for sorting
			
			ad.sortOn('11', Array.DESCENDING | Array.NUMERIC);//index 11 is score field
			
			var ret:Array = new Array();
			while (ad.length > 0 && ret.length < 10) {
				ret.push(ad.shift());
			}
			
			return ret;
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
				var ev:String = currUser[10];
				var a:Array = ev.split(":");				
				vars.programId = a[0];
				
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
			allData.data.users = allUsers;
			allData.flush();
		}
		
		
		private function updateQueue():void
		{
			sendQueue.data.users = currQueue;
			sendQueue.flush();
		}
		
	}
	
}