package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.*;
	import flash.filesystem.*;	
	import flash.events.*;	
	
	import com.gmrmarketing.bcbs.livefearless.Hubble;
	
	public class Test extends MovieClip
	{
		private const DATA_FILE_NAME:String = "bcbsData.csv"; //current users / not yet uploaded
		private var hubble:Hubble;//NowPik integration
		private var token:Boolean;
		private var users:Array;
		
		public function Test()
		{			
			users = getAllUsers();//populate users array from disk file
			
			hubble = new Hubble();
			hubble.addEventListener(Hubble.GOT_TOKEN, gotToken);
			hubble.addEventListener(Hubble.FORM_POSTED, formPosted);
			hubble.addEventListener(Hubble.COMPLETE, uploadComplete);			
			//hubble.addEventListener(Hubble.ERROR, hubbleError);			
		}
		
		/**
		 * callback on hubble - called once hubble gets the api key from the server
		 * @param	e
		 */
		private function gotToken(e:Event):void
		{
			trace("queue.gotToken");
			token = true;
			
			//start uploading immediately if there are records waiting
			if (users.length > 0) {
				uploadNext();
			}
		}
		
		private function getAllUsers():Array
		{			
			var obs:Array = new Array();
			var a:Object = { };
		
			try{
				var file:File = File.desktopDirectory.resolvePath( DATA_FILE_NAME );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.READ );
				
				a = stream.readObject();
				while (a.fname != undefined) {					
					obs.push(a);
					if (a.pledgeCombo == 0) {
						a.pledgeCombo = 2430;//other
					}
					if (a.prizeCombo == 0) {
						a.prizeCombo = 2587;
					}
					if (a.sharephoto == undefined) {
						a.sharephoto = false;
					}
					if (a.emailoptin == undefined) {
						a.emailoptin == false;
					}
					trace(a.fname,a.lname,a.email,a.pledgeCombo,a.sharephoto,a.emailoptin,a.message,a.prizeCombo);
					a = stream.readObject();
				}				
			}catch (e:Error) {
				trace(e.message);
			}	
			
			stream.close();
			file = null;
			stream = null;
			
			
			
			return obs;
		}
		
		/**
		 * uploads the current user form data to the service
		 * Will call formPosted once data is posted
		 */
		private function uploadNext():void
		{			
			trace("uploading next");
			if (token && users.length > 0) {
				var cur:Object = users[0];
				hubble.submitForm(new Array(cur.fname, cur.lname, cur.email, cur.pledgeCombo, cur.sharephoto, cur.emailoptin, cur.message, cur.prizeCombo));
			}
		}
		
		private function formPosted(e:Event):void
		{			
			trace("data posted, posting image");
			hubble.submitPhoto(users[0].image);
		}
		
		private function uploadComplete(e:Event):void
		{		
			trace("image posted");
			var a:Object = users.shift();
			
			if (users.length > 0) {
				uploadNext();
			}else {
				trace("uploading complete");
			}
		}
		
	}
	
}