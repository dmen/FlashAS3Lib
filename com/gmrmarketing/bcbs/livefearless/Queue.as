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
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Queue extends EventDispatcher  
	{
		public static const DEBUG_MESSAGE:String = "newMessageReady";//generated whenever a new debug message is
		public static const READY:String = "gotModelData";//dispatched to main which will then start listening for a tap
		private const DATA_FILE_NAME:String = "bcbsData.csv"; //current users / not yet uploaded
		private const SAVED_FILE_NAME:String = "bcbsSaved.csv"; //users successfully uploaded
		
		private var fileFolder:File;
		private var users:Array;//current queue
		
		private var hubble:Hubble;//NowPik integration		
		private var curUpload:Object; //currently uploading user object - users[0] - set in uploadNext()
		
		
		public function Queue()
		{
			users = getAllUsers();//populate users array from disk file
			
			hubble = new Hubble();
			hubble.addEventListener(Hubble.GOT_MODELS, gotModels);
			hubble.addEventListener(Hubble.COMPLETE, uploadComplete);			
			hubble.addEventListener(Hubble.ERROR, hubbleError);
			hubble.getToken();
		}
		
		
		/**
		 * callback on hubble - called once hubble gets the model data from the server
		 * or, if there was an error, the local cache had model data in it
		 * @param	e
		 */
		private function gotModels(e:Event):void
		{
			dispatchEvent(new Event(READY));
			hubble.removeEventListener(Hubble.GOT_MODELS, gotModels);
			
			uploadNext();
		}
		
		
		public function getPledgeOptions():Array
		{			
			return hubble.getPledgeOptions();			
		}
		
		
		public function getPrizeOptions():Array
		{			
			return hubble.getPrizeOptions();			
		}
		
		
		/**
		 * Adds a user data object to the csv file
		 * Called from Main.removeForm() - once form is complete and Thanks is showing
		 * Data object contains these keys { fname:textData[0], lname:textData[1], email:formData[0], pledgeCombo:textData[2], prizeCombo:textData[4], sharephoto:formData[1], emailoptin:formData[2], message:textData[3], image:im };
		 */
		public function add(data:Object):void
		{
			users.push(data);//add to queue
			writeUser(data);//add to file
			uploadNext();			
		}
		
		
		/**
		 * uploads the current user form data to the service
		 * removes the curUpload object from users array
		 * Will call formPosted once data is posted
		 */
		private function uploadNext():void
		{	
			if (hubble.hasToken() && !hubble.isWorking() && users.length > 0) {
				curUpload = users.shift();				
				hubble.submit(new Array(curUpload.fname, curUpload.lname, curUpload.email, curUpload.pledgeCombo, curUpload.sharephoto, curUpload.emailoptin, curUpload.message, curUpload.prizeCombo, curUpload.image));
			}
		}
		
		
		/**
		 * called if submitting form, photo, or followups generate a hubble error
		 * adds the curUpload object back onto the end users - it was removed with shift in uploadNext()
		 * @param	e
		 */
		private function hubbleError(e:Event):void
		{			
			users.push(curUpload);
		}
		
		
		
		/**
		 * Called once hubble submit is complete
		 * @param	e Event.COMPLETE
		 */
		private function uploadComplete(e:Event):void
		{
			writeSavedUser(curUpload); //keep saved users in sep file
			
			rewriteQueue();//writes the users array to disk - with curUpload object now removed
			users = getAllUsers();//repopulate users array from file
			
			uploadNext();
		}
		
		
		/**
		 * Deletes the user data file, then writes the current
		 * array of user objects to the current users data file
		 * users array is emptied - call getAllUsers() to repopulate users
		 */
		private function rewriteQueue():void
		{
			try{
				var file:File = File.applicationStorageDirectory.resolvePath( DATA_FILE_NAME );
				file.deleteFile();
				
				while (users.length) {
					var aUser:Object = users.shift();
					writeUser(aUser);
				}
				
			}catch (e:Error) {
			}
		}
		
		
		/**
		 * Appends a single user object to the data file
		 * @param	obj
		 */
		private function writeUser(obj:Object):void
		{
			try{
				var file:File = File.applicationStorageDirectory.resolvePath( DATA_FILE_NAME );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.APPEND );
				stream.writeObject(obj);
				stream.close();
				file = null;
				stream = null;
			}catch (e:Error) {
			}			
		}
		
		
		/**
		 * Appends a single user object to the saved data file
		 * called from uploadComplete()
		 * @param	obj
		 */
		private function writeSavedUser(obj:Object):void
		{
			//add a timestamp
			obj.timeAdded = Utility.getTimeStamp();
			try{
				var file:File = File.applicationStorageDirectory.resolvePath( SAVED_FILE_NAME );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.APPEND );
				stream.writeObject(obj);
				stream.close();
				file = null;
				stream = null;
			}catch (e:Error) {
			}			
		}
		
		
		/**
		 * Called from constructor and uploadComplete()
		 * returns an array of all user objects in the data file
		 * 
		 * All key types are strings - sharephoto and emailoptin are string booleans "true" or "false"
		 * uploaded is string boolean - special key added by add()
		 * Object keys: {fname, lname, email, pledgeCombo, prizeCombo, sharephoto, emailoptin, message, image}
		 * 
		 * @return Array of user objects
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
				
				stream.close();
				
			}catch (e:Error) {
				
			}
			
			file = null;
			stream = null;
			
			return obs;
		}
		
	}	
}