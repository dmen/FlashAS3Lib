/**
 * used by Main
 * Stores and manages user objects in two csv files
 * 
 * Each user object:
	All key types are strings - sharephoto and emailoptin are string booleans "true" or "false"
	image is a base64 encoded jpeg
	Object keys: {fname, lname, email, combo, sharephoto, emailoptin, message, image}	
 */
	
package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.MovieClip;	
	import flash.filesystem.*;	
	import flash.events.*;	
	import flash.utils.Timer;
	import com.gmrmarketing.bcbs.livefearless.Hubble;
	
	
	public class Queue extends EventDispatcher  
	{
		public static const DEBUG_MESSAGE:String = "newMessageReady";//generated whenever a new debug message is
		public static const GOT_TOKEN:String = "gotToken";
		private const DATA_FILE_NAME:String = "bcbsData.csv"; //current users / not yet uploaded
		private const SAVED_FILE_NAME:String = "bcbsSaved.csv"; //users successfully uploaded
		
		private var fileFolder:File;
		private var users:Array;//current queue
		
		private var lastDebug:String; //last debug message set in debug()
		
		private var hubble:Hubble;//NowPik integration
		private var token:Boolean;
		
		
		public function Queue()
		{		
			lastDebug = "";
			token = false; //true once hubble gets token
			users = getAllUsers();//populate users array from disk file
			
			hubble = new Hubble();
			hubble.addEventListener(Hubble.GOT_TOKEN, gotToken);
			hubble.addEventListener(Hubble.FORM_POSTED, formPosted);
			hubble.addEventListener(Hubble.COMPLETE, uploadComplete);			
			hubble.addEventListener(Hubble.ERROR, hubbleError);			
		}
		
		
		/**
		 * callback on hubble - called once hubble gets the api key from the server
		 * @param	e
		 */
		private function gotToken(e:Event):void
		{			
			debug("gotToken() - nowpik token");
			token = true;
			dispatchEvent(new Event(GOT_TOKEN));
			//start uploading immediately if there are records waiting
			if (users.length > 0) {
				uploadNext();
			}
		}
		
		public function getPledgeOptions():Array
		{
			if (token) {
				return hubble.getPledgeOptions();
			}else {
				//defaults as of 08/27/2014
				return new Array([["",0]]);
			}
		}
		
		public function getPrizeOptions():Array
		{
			if (token) {
				return hubble.getPrizeOptions();
			}else {
				//defaults as of 08/27/2014
				return new Array([["",0]]);
			}
		}
		
		public function getInterestOptions():Array
		{
			if (token) {
				return hubble.getInterestOptions();
			}else {
				//defaults as of 08/27/2014
				return new Array([["",0]]);
			}
		}
		
		/**
		 * Adds a user data object to the csv file
		 * Called from Main.removeForm() - once form is complete and Thanks is showing
		 * Data object contains these keys { fname:textData[0], lname:textData[1], email:formData[0], pledgeCombo:textData[2], prizeCombo:textData[4], sharephoto:formData[1], emailoptin:formData[2], message:textData[3], image:im };
		 */
		public function add(data:Object):void
		{
			debug("add() - new user: " + data.fname + " " + data.lname);
			users.push(data);
			writeUser(data);//add to file
			
			//if it were > 1 the queue would already be uploading
			if (users.length == 1) {
				uploadNext();
			}
		}
		
		
		/**
		 * uploads the current user form data to the service
		 * Will call formPosted once data is posted
		 */
		private function uploadNext(e:TimerEvent = null):void
		{			
			debug("uploadNext()");
			if (token && users.length > 0) {
				var cur:Object = users[0];
				debug("submitting user form data: "+cur.fname+" "+cur.lname+"  pledge:"+ cur.pledgeCombo + "  share:" + cur.sharephoto + " emailOptin:" + cur.emailoptin + "  message: " + cur.message + "  prize: " + cur.prizeCombo);
				hubble.submitForm(new Array(cur.fname, cur.lname, cur.email, cur.pledgeCombo, cur.sharephoto, cur.emailoptin, cur.message, cur.prizeCombo));//, cur.interestCombo));
				//hubble.submitForm(new Array(cur.fname, cur.lname, cur.email, cur.sharephoto, cur.emailoptin, cur.message));
			}
		}
		
		
		/**
		 * Called when the form data for currentUser has posted
		 * uploads the image
		 * @param	e Event.COMPLETE
		 */
		private function formPosted(e:Event):void
		{
			debug("formPosted() - submitting photo");
			hubble.submitPhoto(users[0].image);
		}		
		
		
		/**
		 * called if submitting form, photo, or followups generate a hubble error
		 * moves the current (error prone?) user to the end of the queue
		 * @param	e
		 */
		private function hubbleError(e:Event):void
		{			
			debug("hubbleError() - moving user to end of queue");
			users.push(users.shift());
			delayedRestart();
		}
		
		
		
		/**
		 * Called once hubble image upload is complete
		 * @param	e Event.COMPLETE
		 */
		private function uploadComplete(e:Event):void
		{
			debug("uploadComplete() - adding saved user to saved file");
			
			var savedUser:Object = users.shift();//remove now uploaded user from the queue
			writeSavedUser(savedUser); //keep saved users in sep file
			
			rewriteQueue();//empties the users array
			users = getAllUsers();//repopulate users array
			
			if (users.length > 0) {
				delayedRestart();
			}
		}
		
		
		/**
		 * Deletes the user data file, then writes the current
		 * array of user objects to the current users data file
		 * users array is emptied - call getAllUsers() to repopulate users
		 */
		private function rewriteQueue():void
		{
			debug("rewriteQueue()");
			try{
				var file:File = File.applicationStorageDirectory.resolvePath( DATA_FILE_NAME );
				file.deleteFile();
				
			}catch (e:Error) {
				debug("rewriteQueue() error: " + e.message);
			}	
			
			while (users.length) {
				var aUser:Object = users.shift();
				writeUser(aUser);
			}
		}
		
		
		/**
		 * Appends a single user object to the data file
		 * @param	obj
		 */
		private function writeUser(obj:Object):void
		{			
			debug("writeUser() - user: "+obj.fname+" "+obj.lname);
			try{
				var file:File = File.applicationStorageDirectory.resolvePath( DATA_FILE_NAME );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.APPEND );
				stream.writeObject(obj);
				stream.close();
				file = null;
				stream = null;
			}catch (e:Error) {
				debug("writeUser() error: " + e.message);
			}			
		}
		
		
		/**
		 * Appends a single user object to the saved data file
		 * @param	obj
		 */
		private function writeSavedUser(obj:Object):void
		{			
			debug("writeSavedUser() - user: "+obj.fname+" "+obj.lname);
			try{
				var file:File = File.applicationStorageDirectory.resolvePath( SAVED_FILE_NAME );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.APPEND );
				stream.writeObject(obj);
				stream.close();
				file = null;
				stream = null;
			}catch (e:Error) {
				debug("writeSavedUser() error: " + e.message);
			}			
		}
		
		
		/**
		 * called from constructor and uploadCOmplete()
		 * returns an array of all user objects in the data file
		 * 
		 * All key types are strings - sharephoto and emailoptin are string booleans "true" or "false"
		 * uploaded is string boolean - special key added by add()
		 * Object keys: {fname, lname, email, combo, sharephoto, emailoptin, message, image}
		 * @return
		 */
		private function getAllUsers():Array
		{			
			var obs:Array = new Array();
			var a:Object = { };
		
			try{
				var file:File = File.applicationStorageDirectory.resolvePath( DATA_FILE_NAME );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.READ );
				
				a = stream.readObject();
				while (a.fname != undefined) {					
					obs.push(a);					
					a = stream.readObject();
				}				
			}catch (e:Error) {
				debug("getAllUsers() error: " + e.message);
			}	
			
			stream.close();
			file = null;
			stream = null;
			
			debug("getAllUsers() - # users: " + obs.length);
			
			return obs;
		}
		
		
		/**
		 * Delayed queue restart
		 * Calls uploadNext() after 20 seconds
		 */
		private function delayedRestart():void
		{
			debug("delayedRestart() - restarting queue in 20 seconds");
			var dc:Timer = new Timer(20000, 1);
			dc.addEventListener(TimerEvent.TIMER, uploadNext, false, 0, true);
			dc.start();
		}
		
		
		private function debug(mess:String):void
		{
			lastDebug = mess;
			dispatchEvent(new Event(DEBUG_MESSAGE));
		}
		
		
		/**
		 * Returns the last debug message
		 * @return
		 */
		public function getDebug():String
		{
			return lastDebug;
		}
	}	
}