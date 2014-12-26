package com.gmrmarketing.sap
{
	import flash.filesystem.*;
	
	
	public class LatestFile
	{
		
		private var folder:File;
		
		
		public function LatestFile($folder:String)
		{
			folder = new File($folder);
		}
		
		
		public function getLatest():File
		{
			var files:Array = folder.getDirectoryListing();
			
			if (files.length) {
				files.sortOn("creationDate", Array.DESCENDING);
				return files[0];
			}
			
			return new File();
		}
		
	}
	
}