/**
 * Manages sending user data to the webservice
 * also stores the data locally in order to be able
 * to display the high scores.
 */
package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.events.*;
	import flash.net.*;
	
	
	public class WebService 
	{
		private const URL:String = "http://thesocialtab";
		
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
		 * @param	user Array fname,lname,email,phone,state,sweeps entry,optin,q1a,q2a,score
		 */
		public function addUser(user:Array):void
		{
			allUsers.push(user);
			updateAllData();//updates sharedObject with array
			
			currQueue.push(user);
			updateQueue();//updates sharedObject with array
			
			if (!isPosting) {
				postNextUser();
			}
		}
		
		
		/**
		 * Returns a score sorted array for leaderboard display
		 * @return Array - max 20 items
		 */
		public function getLeaderboard():Array
		{
			//array of arrays. Sub arrays contain: fname,lname,email,phone,state,sweeps entry,optin,q1a,q2a,score
			
			var ad:Array = allUsers.concat();//duplicate array for sorting
			
			ad.sortOn('9', Array.DESCENDING | Array.NUMERIC);//index 9 is score field
			
			var ret:Array = new Array();
			while (ad.length > 0 && ret.length < 20) {
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
				vars.sweeps = currUser[5];//true false
				vars.optin = currUser[6];
				vars.q1a = currUser[7];
				vars.q2a = currUser[8];
				vars.score = currUser[9];
				
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