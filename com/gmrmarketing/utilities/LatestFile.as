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
		 * @return
		 */
		public function get latestFile():File
		{
			var files:Array = _folder.getDirectoryListing();
			
			if (files.length) {
				files.sortOn("creationDate", Array.DESCENDING);
				return files[0];
			}
			
			return new File();
		}
		
	}
	
}