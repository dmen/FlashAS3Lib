package com.gmrmarketing.utilities
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
		
		
		public function get nextNum():int
		{
			num++;
			so.data.num = num;
			so.flush();
			return num;
		}
		
		
		public function get guid():String
		{
			return myGuid;
		}
	}
	
}