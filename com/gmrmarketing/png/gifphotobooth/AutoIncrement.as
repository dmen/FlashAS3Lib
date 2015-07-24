/**
 * 
 * Used by Queue.as - for NowPik
 * provides a unique machine/device identifier (GUID) and unique record identifier - simple int
 * 
 */
package com.gmrmarketing.png.gifphotobooth
{
	import flash.net.SharedObject;
	import com.gmrmarketing.utilities.GUID;
	
	public class AutoIncrement
	{
		private var so:SharedObject;
		private var myNum:int;
		private var myGuid:String;		
		
		public function AutoIncrement()
		{
			so = SharedObject.getLocal("autoInc");
			
			myNum = so.data.num;
			myGuid = so.data.guid;			
			
			//if 1st use init vars
			if (myGuid == null) {
				myGuid = GUID.create();
				myNum = -1;
				
				so.data.guid = myGuid;
				so.data.num = myNum;
				
				so.flush();
			}
		}
		
		
		public function get num():int
		{
			myNum++;
			so.data.num = myNum;
			so.flush();
			return myNum;
		}
		
		
		public function get guid():String
		{
			return myGuid;
		}
	}
	
}