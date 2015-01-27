/**
 * Returns the latest file in a folder
 * according to its creationDate property
 */
package com.gmrmarketing.utilities
{
	import flash.filesystem.*;	
	
	public class LatestFile
	{		
		private var _folder:File;		
		
		
		public function LatestFile() { }
		
		
		/**
		 * sets the watched folder
		 */
		public function set folder(f:String):void
		{
			_folder = new File(f);
		}
		
		
		
		public function getLatestFiles(num:int):Array
		{
			var files:Array = _folder.getDirectoryListing();
			var ret:Array = [];
			
			if (files.length >= num) {
				files.sortOn("creationDate", Array.NUMERIC | Array.DESCENDING);	
				for (var i:int = 0; i < num; i++) {
					ret.push(files[i].nativePath);
				}				
			}			
			return ret;
		}
		
		
		/**
		 * Returns the full native path of the latest file in the watched folder
		 * @return String full path and file name
		 */
		public function get latestFile():String
		{
			var files:Array = _folder.getDirectoryListing();
			
			if (files.length) {
				files.sortOn("creationDate", Array.NUMERIC | Array.DESCENDING);
				return files[0].nativePath;
			}
			
			return "";
		}
		
		
		//test method
		public function listFiles():void
		{
			var files:Array = _folder.getDirectoryListing();
			
			for (var i:int = 0; i < files.length; i++){
				//
				trace(files[i].nativePath);
			}
			trace("sort");
			files.sortOn("creationDate", Array.NUMERIC | Array.DESCENDING);
			for (i = 0; i < files.length; i++){
				//files.sortOn("creationDate", Array.DESCENDING);
				trace(files[i].nativePath);
			}
		}
	}
	
}