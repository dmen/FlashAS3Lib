package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.MovieClip;	
	import flash.filesystem.*;	
	import flash.events.*;	
	import flash.utils.Timer;
	import com.gmrmarketing.bcbs.livefearless.Hubble;
	
	
	public class Queue extends EventDispatcher  
	{
		public static const DEBUG_MESSAGE:String = "newMessageReady";	
		
		private const DATA_FILE_NAME:String = "bcbsData.csv";
		
		private var fileFolder:File;
		private var users:Array;	
		
		private var hubble:Hubble;
		private var token:Boolean;
		
		
		public function Queue()
		{			
			token = false; //true once hubble gets token
			users = getAllUsers();
			
			hubble = new Hubble();
			hubble.addEventListener(Hubble.GOT_TOKEN, gotToken);
			hubble.addEventListener(Hubble.FORM_POSTED, formPosted);
			hubble.addEventListener(Hubble.COMPLETE, uploadComplete);			
			hubble.addEventListener(Hubble.ERROR, hubbleError);			
		}
		
		
		private function gotToken(e:Event):void
		{
			token = true;
			
			//start uploading immediately if there are records waiting
			if (users.length > 0) {
				uploadNext();
			}
		}
		
		/**
		 * Data object contains these keys { fname, lname, email, combo, sharephoto, emailoptin, message, image }
		 */
		public function add(data:Object):void
		{
			users.push(data);
			writeUser(data);
			
			//if it were > 1 the queue would already be uploading
			if (users.length == 1) {
				uploadNext();
			}
		}
		
		/**
		 * uploads the current user form data to the service
		 */
		private function uploadNext(e:TimerEvent = null):void
		{			
			if (token && users.length > 0) {
				var cur:Object = users[0];
				hubble.submitForm(new Array(cur.fname, cur.lname, cur.email, cur.combo, cur.sharephoto, cur.emailoptin, cur.message));
			}
		}
		
		
		/**
		 * Called when the form data for currentUser has posted
		 * uploads the image
		 * @param	e Event.COMPLETE
		 */
		private function formPosted(e:Event):void
		{
			hubble.submitPhoto(users[0].image);
		}		
		
		
		/**
		 * called if submitting form, photo, or followups generate a hubble error
		 * moves the current user to the end of the queue
		 * @param	e
		 */
		private function hubbleError(e:Event):void
		{
			var user:Object = users.shift();
			users.push(user);
			delayedRestart();
		}
		
		
		
		/**
		 * Called once hubble image upload is complete
		 * @param	e Event.COMPLETE
		 */
		private function uploadComplete(e:Event):void
		{
			users.shift();//remove now uploaded user from the queue
			
			rewriteQueue();//empties the users array
			users = getAllUsers();//repopulate users array
			
			if (users.length > 0) {
				delayedRestart();
			}
		}
		
		
		/**
		 * Deletes the user data file, then writes the current
		 * array of user objects to the file
		 */
		private function rewriteQueue():void
		{
			try{
				var file:File = File.applicationStorageDirectory.resolvePath( DATA_FILE_NAME );
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
				var file:File = File.applicationStorageDirectory.resolvePath( DATA_FILE_NAME );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.APPEND );
				stream.writeObject(obj );
				stream.close();
				file = null;
				stream = null;
			}catch (e:Error) {
			}			
		}
		
		
		/**
		 * called from constructor and uploadCOmplete()
		 * returns an array of all user objects in the data file
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
			}	
			
			stream.close();
			file = null;
			stream = null;
			
			//FOR DEBUGGING
			//obs = [ { fname:"Dave", lname:"Mennenoh", email:"dmennenoh@gmrmarketing.com", optin:"true", guid:"abcdefg-jkl" } ];
			
			return obs;
		}
		
		
		/**
		 * Delayed queue restart
		 * Calls uploadNext() after 20 seconds
		 */
		private function delayedRestart():void
		{
			var dc:Timer = new Timer(20000, 1);
			dc.addEventListener(TimerEvent.TIMER, uploadNext, false, 0, true);
			dc.start();
		}
	}	
}