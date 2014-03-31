package com.gmrmarketing.utilities
{	
	import flash.events.*;
	import flash.filesystem.*;
	import flash.utils.ByteArray;	
	import com.gmrmarketing.utilities.GUID;
	
	public class AIRFile
	{	
		//use for passing to the sort option of getFilesByDate()
		public static const SORT_ASCENDING:String = "asc";
		public static const SORT_DESCENDING:String = "desc";
		
		
		public function AIRFile() { }	
		
		
		/**
		 * Writes a data object to a GUID named file
		 * @param	newDataLine
		 */
		public function writeData(newData:Object, path:String, fileName:String = ""):void
		{
			var targetDir:File = new File(path);		
			targetDir.createDirectory();
			
			var fName:String = fileName == "" ? GUID.create() : fileName;
			
			var targetFile:File = targetDir.resolvePath(fName + ".obj");
			var fs:FileStream = new FileStream();
			
			try {
				fs.open(targetFile, FileMode.WRITE);
				fs.writeObject(newData);
				fs.close();
			}catch (e:Error) {
				trace(e);
			}			
		}		
		
		
		/**
		 * returns an array of file objects
		 * The array is alpha sorted
		 * If the path does not exist an empty array is returned
		 * @return
		 */
		public function getFiles(path:String):Array
		{
			var targetDir:File = new File(path);
			var ar:Array = new Array();
			if(targetDir.exists){
				try{
					ar = targetDir.getDirectoryListing();				
				}catch (e:Error) {
					trace("getFiles error", e);
				}
			}
			return ar;
		}
		
		
		/**
		 * Returns a date sorted array of file objects
		 * @param	sort
		 * @return
		 */
		public function getFilesByDate(path:String, sort:String = SORT_DESCENDING):Array
		{
			var n:Array = new Array();	
			var targetDir:File = new File(path);
			
			if(targetDir.exists){
				var l:Array = targetDir.getDirectoryListing();
				var it:File;
				var ins:Boolean;
				while (l.length) {
					it = l.shift();
					ins = false;
					for (var i:int = 0; i < n.length; i++) {
						if (it.creationDate < n[i].creationDate) {
							n.splice(i, 0, it);
							ins = true;
							break;
						}
					}
					if (!ins) {
						n.push(it);
					}
				}
			}
			
			if(sort == SORT_DESCENDING){
				return n.reverse();
			}else {
				return n;
			}
		}
		
		
		/**
		 * Returns the object associated with the file object
		 * @param	fo
		 * @return
		 */
		public function getFile(fo:File):Object
		{			
			var targetFile:File = fo;
			var fileStream:FileStream = new FileStream();			
			fileStream.open(targetFile, FileMode.READ);						
			
			return fileStream.readObject();
		}
		
		
		/**
		 * Deletes the specified file
		 */
		public function deleteFile(path:String, fileName:String):void
		{
			var targetDir:File = new File(path);
			var targetFile:File = targetDir.resolvePath(fileName);
			
			if(targetFile.exists){
					targetFile.deleteFile();
			}
		}
		
		
		public function deleteFiles(path:String):void
		{
			var f:File;
			var targetDir:File = new File(path);
			if(targetDir.exists){
				//array of file objects
				var list:Array = targetDir.getDirectoryListing();
				while (list.length) {
					f = list.splice(0, 1)[0];
					f.deleteFile();
				}
			}
		}
		
	}
	
}