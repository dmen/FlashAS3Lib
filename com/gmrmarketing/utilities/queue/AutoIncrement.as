/**
 * Provides a one-time machine identifier (deviceID - GUID)
 * and auto incrementing record number (deviceResponseID)
 * to Hubble services
 */
package com.gmrmarketing.utilities.queue
{
	import flash.net.SharedObject;
	import com.gmrmarketing.utilities.GUID;
	
	public class AutoIncrement
	{
		private var so:SharedObject;
		private var num:int;
		private var myGuid:String;
		
		
		public function AutoIncrement()
		{
			so = SharedObject.getLocal("autoInc");
			num = so.data.num;
			myGuid = so.data.guid;			
			
			if (num == 0) {
				num = -1;
				so.data.num = num;
				so.flush();
			}
			
			if (myGuid == null) {
				myGuid = GUID.create();
				so.data.guid = myGuid;
				so.flush();
			}
		}
		
		
		/**
		 * Gets the next integer
		 * Begins at 0
		 * Used for a deviceResponseID for Hubble
		 */
		public function get nextNum():int
		{
			num++;
			so.data.num = num;
			so.flush();
			return num;
		}
		
		
		/**
		 * Gets a GUID - used as a deviceID for Hubble
		 */
		public function get guid():String
		{
			return myGuid;
		}
	}
	
}