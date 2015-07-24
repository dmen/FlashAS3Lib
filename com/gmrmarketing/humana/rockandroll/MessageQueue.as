/**
 * The current queue of message objects waiting to display
 */

package com.gmrmarketing.humana.rockandroll
{		
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class MessageQueue extends EventDispatcher
	{
		public static const RUNNERS_ADDED:String = "runnersAdded";		
		private var DEFAULT_START_TIME:String = "";
		private var allRunners:Array;
		private var queue:Array;		
		private var viewDivisor:int;
		private var numCompletelyMissed:int;//number past the message.missedTime
		
		private var startToMat:Number;//distance in miles from start to mat
		private var matToSign:Number;//distance from mat to sign, in miles
		
		
		/**
		 * Instantiated by Main once xml is ready
		 * @param	defStart String default start time of race - from config.xml
		 * @param	startMat Number distance from start to mat in miles - from config.xml
		 * @param	matDist Number distance from mat to sign in miles - from config.xml
		 */
		public function MessageQueue(defStart:String, startMat:Number, matDist:Number)
		{
			DEFAULT_START_TIME = defStart;
			startToMat = startMat;
			matToSign = matDist;
			
			//queue is an array of objects - each object has keys: id, fName, lName, tenTime, time, messages
			//within the object, the messages key contains an array of message objects - each with keys: message, fromFName, fromLName
			queue = new Array();
			allRunners = new Array();//all individual runners returned from the service
			viewDivisor = 12;// 1/12 mile
			numCompletelyMissed = 0;
		}		
		
		
		/**
		 * Called from Main.gotNewRunners() whenever new runners are returned from the service
		 * 
		 * @param	newRunners parsed JSON from the service
		 */
		public function addRunners(newRunners:Object):void
		{	
			//We only want from newRunners those runners not already in allRunners
			var actualNewRunners:Array = new Array();
			var inAllRunners:Boolean;
			
			for (var i:int = 0; i < newRunners.length; i++) {
				var a:Object = newRunners[i];
				inAllRunners = false;
				
				for (var kk:int = 0; kk < allRunners.length; kk++) {
					if (a.FirstName == allRunners[kk].FirstName && a.LastName == allRunners[kk].LastName && a.TenMileTime == allRunners[kk].TenMileTime) {
						inAllRunners = true;
						break;
					}
				}
				
				if (!inAllRunners) {
					actualNewRunners.push(a);
					allRunners.push(a);
				}
			}
			
			var now:Number = new Date().valueOf();//epoch time in ms
			var ind:int = 0;					
			var numPast:int = 0;			
			
			//check the queue for late or missed messages - if there are late messages adjust them in the queue
			//and modify viewDivisor to make new messages display faster
			while (ind < queue.length) {
				if (now > queue[ind].viewingTime) {
					numPast++;					
					viewDivisor += 2;
					if(queue[ind].timeAdjusted == 0){
						queue[ind].messageTime = queue[ind].messageTime * .75;//speed up the past-due messages
						queue[ind].timeAdjusted = 1; //prevents time from being adjusted multiple times
					}
					if (now > queue[ind].missedTime) {
						numCompletelyMissed++;
						//cull this entry from the queue
						queue.splice(ind, 1);
						break;
					}
					ind++;
				}else {
					break;
				}
			}	
			
			if (numPast == 0) {
				viewDivisor = 12; //reset initial viewing time
			}
			
			//limit divisor to 16				
			viewDivisor = viewDivisor > 16 ? 16 : viewDivisor;
			
			for (i = 0; i < actualNewRunners.length; i++) {				
				
				//each runner object straight from JSON
				var theRunner:Object = actualNewRunners[i];				
				
				var fName:String = theRunner.FirstName;
				var lName:String = theRunner.LastName;
				var messages:Array = theRunner.Messages;//array of message objects with keys:Message, FromFirstName, FromLastName
				
				//String like: "7/4/2013 11:29:33 AM"
				var matMileTime:Number;				
				if (theRunner.TenMileTime == "") {					
					matMileTime = now;
				}else {
					matMileTime = new Date(theRunner.TenMileTime).valueOf();
				}
				
				//String like: "7/4/2013 06:30:00 AM"
				var startTime:Number;
				if (theRunner.StartTime == "") {
					startTime = new Date(DEFAULT_START_TIME).valueOf();
				}else{
					startTime = new Date(theRunner.StartTime).valueOf();				
				}
				
				var matMileElapsed:Number = (matMileTime - startTime) / 1000;//total seconds from start to mat
				var oneMileTime:Number = matMileElapsed / startToMat;//average seconds for 1 mile		
				
				//Calculate viewing times based on distance to display
				//display is 578 yards from mat = 1734 feet = .32840909 miles
				
				var fullMessageTime:Number = oneMileTime * matToSign; //seconds - full time from mat to display			
				var displayMessageTime:Number = oneMileTime / viewDivisor; //display for time				
				
				var mess:Object = new Object();	
				mess.timeAdjusted = 0;
				mess.fName = fName;
				mess.lName = lName;								
				
				//scheduled viewing time: now in milliseconds plus the runners 1/8 mile time in milliseconds
				mess.viewingTime = now + ((fullMessageTime - displayMessageTime) * 1000);
				mess.messageTime = displayMessageTime / messages.length; //time for each message			
				mess.missedTime = now + (fullMessageTime * 1000);//if message hasn't been displayed by this time it can be culled
				
				/*
				trace("adding runner - tenMileElapsed:", matMileElapsed);
				trace("oneMileTime:", oneMileTime);
				trace("fullMessageTime", fullMessageTime);
				trace("displayMessageTime:", displayMessageTime);
				trace("scheduled viewing time - seconds from now:",fullMessageTime - displayMessageTime);
				trace("message display time:", mess.messageTime);
				*/
				
				var messArray:Array = new Array();	
				for (var j:int = 0; j < messages.length; j++) {						
					var mObject = new Object();
					mObject.message = messages[j].Message;
					mObject.fromFName = messages[j].FromFirstName;
					mObject.fromLName = messages[j].FromLastName;
					messArray.push(mObject);						
				}					
				
				mess.messages = messArray;
				
				//place mess in the queue sorted by viewing time
				var added:Boolean = false;					
				for (var k:int = 0; k < queue.length; k++) {
					if (mess.viewingTime < queue[k].viewingTime) {
						queue.splice(k, 0, mess);
						added = true;
						break;
					}
				}					
				//not less than anyone else in the queue - add at end
				if(!added){
					queue.push(mess);
				}				
			}			
			
			dispatchEvent(new Event(RUNNERS_ADDED));				
		}
		
		
		/**
		 * Returns the length of the queue
		 */
		public function get length():int
		{
			return queue.length;
		}		
		
		public function getMissed():int
		{
			return numCompletelyMissed;
		}
		
		
		/**
		 * Returns a message object
		 * The object is removed from the queue
		 * each object has keys: id, fName, lName, messages, time, viewingTime
		 * messages is an array of objects each having keys: message, fromFName, fromLName
		 */
		public function getMessage():Object
		{
			var ret:Object = -1;
			if (queue.length) {
				ret = queue.shift();
			}			
			return ret;			
		}
		
		
		/**
		 * Returns true if the first message in the queue is ready for viewing
		 * @return
		 */
		public function pastViewingTime():Boolean
		{
			if (queue.length) {
				if (new Date().valueOf() > queue[0].viewingTime) {
					return true;
				}
			}			
			return false;
		}
		
		
	}
	
}