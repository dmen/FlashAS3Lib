package com.gmrmarketing.empirestate.ilny
{
	import flash.display.*;
	import flash.filesystem.*;	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class MainReader extends MovieClip 
	{
		public function MainReader()
		{
			var o:Array = getAllUsers();
			for (var i:int = 0; i < o.length; i++) {
				var user:Object = o[i];
				trace(user.fname, user.lname, user.email, user.zipcode, user.optin);
			}
		}
		
		private function getAllUsers():Array
		{			
			var obs:Array = new Array();
			var a:Object = { };
		
			try{
				//var file:File = File.applicationStorageDirectory.resolvePath(DATA_FILE_NAME);
				var file:File = File.documentsDirectory.resolvePath("ilnySaved.csv");
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.READ );
				
				a = stream.readObject();
				while (a) {					
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