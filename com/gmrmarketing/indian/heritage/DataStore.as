/**
 * Uses a shared object to store the selected section - from the admin menu
 */
package com.gmrmarketing.indian.heritage
{
	import flash.net.SharedObject;
	
	public class DataStore
	{
		private var shared:SharedObject;
		private var section:String;
		
		public function DataStore()
		{
			shared = SharedObject.getLocal("indianHeritage", "/");
			section = shared.data.section; //section will be 'undefined' if not set - but is cast to null because it's a string
			if (section == null) {
				section = "";
			}			
		}
		
		
		public function getSection():String
		{
			return section;
		}
		
		
		public function setSection(newSection:String):void
		{
			section = newSection;
			shared.data.section = section;
			shared.flush();
		}
	}
	
}