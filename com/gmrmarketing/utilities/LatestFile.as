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
		
		
		/**
		 * Returns the latest file in the watched folder
		 * @return File object
		 */
		public function get latestFile():File
		{
			var files:Array = _folder.getDirectoryListing();
			
			if (files.length) {
				files.sortOn("creationDate", Array.NUMERIC | Array.DESCENDING);
				return files[0];
			}
			
			return new File();
		}
		
		
		/**
		 * Returns the full native path of the latest file in the watched folder
		 * @return String full path and file name
		 */
		public function get latestFileName():String
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