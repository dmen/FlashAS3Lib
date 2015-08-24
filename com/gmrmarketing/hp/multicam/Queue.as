/**
 * used by Thanks.as
 * Stores and manages user objects in two csv files 
 */
	
package  com.gmrmarketing.hp.multicam
{	
	import flash.display.MovieClip;	
	import flash.filesystem.*;	
	import flash.events.*;	
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.hp.multicam.Hubble;
	import com.gmrmarketing.png.gifphotobooth.AutoIncrement;
	
	
	public class Queue extends EventDispatcher  
	{
		private const DATA_FILE_NAME:String = "muticamQueued.csv"; //current users / not yet uploaded
		
		private var fileFolder:File;
		private var users:Array;//current queue
		
		private var hubble:Hubble;//NowPik integration		
		private var curUpload:Object; //currently uploading user object - users[0] - set in uploadNext()		
	
		private var autoInc:AutoIncrement;//so each record can have a unique deviceResponseID when sending to hubble	
		
		
		
		public function Queue()
		{
			users = getAllUsers();//populate users array from disk file			
			
			autoInc = new AutoIncrement();
			
			hubble = new Hubble(autoInc.guid);//guid is used for deviceId
			
			hubble.addEventListener(Hubble.GOT_TOKEN, gotToken);			
			hubble.addEventListener(Hubble.COMPLETE, uploadComplete);			
			hubble.addEventListener(Hubble.FORM_ERROR, hubbleFormError);
			hubble.addEventListener(Hubble.PHOTO_ERROR, hubblePhotoError);
			hubble.addEventListener(Hubble.FOLLOWUP_ERROR, hubbleFollowupError);
			hubble.addEventListener(Hubble.PRINTAPI_ERROR, hubblePrintAPIError);
			hubble.getToken();
		}
		
		
		/**
		 * hubble callback - called once the token has been retrieved
		 * calls uploadNext() to send any data that might be waiting in the queue - on disk
		 * @param	e
		 */
		private function gotToken(e:Event):void
		{
			hubble.removeEventListener(Hubble.GOT_TOKEN, gotToken);			
			uploadNext();
		}
		
		
		
		/**
		 * Adds a user data object to the csv file
		 * Called from Main.removeForm() - once form is complete and Thanks is showing
		 * Data array of objects with keys: email, gif
		 * 
		 * deviceResponseID is injected into object for use by Hubble so that each record has a unique identifier
		 * 
		 * called from Thanks.encFrame() once the gif has been created
		 */
		public function add(data:Array):void
		{	
			for (var i:int = 0; i < data.length; i++){
				data[i].deviceResponseID = autoInc.num;
				data[i].responseID = -1;//only used if photo/followup post errors - this is hubble's response id from sending
				//the form data, so that when the photo is sent it can be attached to the proper record - ie if this is -1 then the
				//full form object and photo will be uploaded
				data[i].followupError = false;//set to true in hubbleFollowupError			
				data[i].printAPIError = false;//set to true in hubblePrintAPIError
				
				users.push(data[i]);//add to queue
			}
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
			if (hubble.hasToken() && !hubble.isBusy() && users.length > 0) {
		
				curUpload = users.shift();				
				hubble.submit(curUpload);				
			}
		}
		
		
		/**
		 * called if submitting form data generates a hubble error
		 * adds the curUpload object back onto the end users - it was removed with queue.shift in uploadNext()
		 * Don't worry about responseID here - just keep it -1 so Hubble posts the full record again
		 * @param	e
		 */
		private function hubbleFormError(e:Event):void
		{	
			users.push(curUpload);
			rewriteQueue();
			users = getAllUsers();
			
			uploadNext();
		}
		
		
		/**
		 * Called if posting the photo  or followup generates an error
		 * gets the responseID from Hubble so that the photo/followup can be posted to the proper user record
		 * since the form data has already been posted
		 */
		private function hubblePhotoError(e:Event):void
		{
			curUpload.responseID = hubble.responseID;//change from initial value of -1 to the responseID returned from posting the form
			
			users.push(curUpload);
			rewriteQueue();
			users = getAllUsers();
			
			uploadNext();
		}
		
		
		private function hubbleFollowupError(e:Event):void
		{
			curUpload.followupError = true;
			
			users.push(curUpload);
			rewriteQueue();
			users = getAllUsers();
			
			uploadNext();
		}
		
		
		private function hubblePrintAPIError(e:Event):void
		{
			curUpload.printAPIError = true;
			
			users.push(curUpload);
			rewriteQueue();
			users = getAllUsers();
			
			uploadNext();
		}
		
		/**
		 * Called once hubble submit is complete
		 * @param	e Event.COMPLETE
		 */
		private function uploadComplete(e:Event):void
		{			
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
			obj.timeAdded = Utility.getTimeStamp();
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
				while (a.email != undefined) {					
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