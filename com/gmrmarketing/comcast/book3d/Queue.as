/**
 * Stores and manages user objects in two csv files 
 */
	
package  com.gmrmarketing.comcast.book3d
{	
	import flash.display.MovieClip;	
	import flash.filesystem.*;	
	import flash.events.*;	
	import flash.utils.Timer;
	import flash.net.*;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Queue extends EventDispatcher  
	{
		private const DATA_FILE_NAME:String = "comcastShellQueued.csv"; //current users / not yet uploaded
		private const SAVED_FILE_NAME:String = "comcastShellSaved.csv"; //users successfully uploaded
		
		private var fileFolder:File;
		private var users:Array;//current queue		
		
		private var curUpload:Object; //currently uploading user object - users[0] - set in uploadNext()	
		
		
		public function Queue()
		{
			users = getAllUsers();//populate users array from disk file			
			uploadNext();
		}
		
		/**
		 * 
		 * 	firstName: 'ravi', 
			lastName: 'pujari', 
			school: 'University of Wisconsin', 
			wonShellGame: true, 
			dp: '2015-7-23 8:30:00', 
			Email : 'pujarit@gmail.com', 
			PhoneNumber : '6147472636', 
			Agree : true, 
			OptIn : false 

		 * @param	data
		 */
		public function add(data:Object):void
		{
			users.push(data);//add to queue
			rewriteQueue();
			users = getAllUsers();
			uploadNext();			
		}
		
		
		/**
		 * uploads the current user form data to the service
		 * removes the curUpload object from users array
		 * Will call uploadComplete() once data is posted
		 */
		private function uploadNext():void
		{
			if (users.length > 0) {
				
				curUpload = users.shift();
				
				var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
				var hdr2:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
				
				var js:String = JSON.stringify(curUpload);
			
				var req:URLRequest = new URLRequest("http://comcastuniversityshellgame.thesocialtab.net/service/");
				req.data = js;
				req.requestHeaders.push(hdr);
				req.requestHeaders.push(hdr2);
				req.method = URLRequestMethod.POST;
				
				var lo:URLLoader = new URLLoader();
				lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
				lo.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
				lo.load(req);
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			users.push(curUpload);
			rewriteQueue();
			users = getAllUsers();
			
			uploadNext();
		}
		
		
		private function dataPosted(e:Event):void
		{
			writeSavedUser(curUpload); //keep saved users in sep file
			
			rewriteQueue();//writes the users array to disk - with curUpload object now removed
			users = getAllUsers();//repopulate users array from file
			
			uploadNext();
		}
		
		
		
		//FILE METHODS BELOW
		/**
		 * Deletes the user data file, then writes the current
		 * array of user objects to the current users data file
		 * users array is emptied - call getAllUsers() to repopulate users
		 */
		private function rewriteQueue():void
		{
			try{
				//var file:File = File.applicationStorageDirectory.resolvePath( DATA_FILE_NAME );
				var file:File = File.documentsDirectory.resolvePath( DATA_FILE_NAME );
				file.deleteFile();
				
			}catch (e:Error) {
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
			try{
				//var file:File = File.applicationStorageDirectory.resolvePath( DATA_FILE_NAME );
				var file:File = File.documentsDirectory.resolvePath( DATA_FILE_NAME );
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
		 * Saved Data File contains all users that have been sent to the server
		 * called from uploadComplete()
		 * @param	obj
		 */
		private function writeSavedUser(obj:Object):void
		{			
			try{
				//var file:File = File.applicationStorageDirectory.resolvePath( SAVED_FILE_NAME );
				var file:File = File.documentsDirectory.resolvePath( SAVED_FILE_NAME );
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
		 * 
		 * @return Array of user objects
		 */
		private function getAllUsers():Array
		{			
			var obs:Array = new Array();
			var a:Object = { };
		
			try{				
				var file:File = File.documentsDirectory.resolvePath( DATA_FILE_NAME );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.READ );
				
				a = stream.readObject();
				while (a.Email != undefined) {					
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