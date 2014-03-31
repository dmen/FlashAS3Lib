/**
 * Writes an array as comma separated values to a specified file on the desktop
 * Used in Indian - Heritage
 */
package com.gmrmarketing.utilities
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class  CSVWriter
	{
		private var fileName:String;
		
		public function CSVWriter()	
		{
			fileName = "";
		}
		
		/**
		 * Call first
		 * Sets the file name to be written to
		 * @param	$fileName
		 */
		public function setFileName($fileName:String):void
		{
			fileName = $fileName;
		}
		
		
		public function writeLine(newLine:Array):void
		{
			if (fileName != "") {
				try{
					var file:File = File.desktopDirectory.resolvePath( fileName );
					var stream:FileStream = new FileStream();
					stream.open( file, FileMode.APPEND );
					stream.writeUTFBytes( "\n" + newLine );
					stream.close();
					file = null;
					stream = null;
				}catch (e:Error) {
						
				}
			}
		}
		
		
		public function writeObject(obj:Object):void
		{
			if (fileName != "") {
				try{
					var file:File = File.desktopDirectory.resolvePath( fileName );
					var stream:FileStream = new FileStream();
					stream.open( file, FileMode.APPEND );
					stream.writeObject(obj );
					stream.close();
					file = null;
					stream = null;
				}catch (e:Error) {
					
				}
			}
		}
		
		
		
		public function readObject():Object
		{
			var a:Object = { };
			if (fileName != "") {
				try{
					var file:File = File.desktopDirectory.resolvePath( fileName );
					var stream:FileStream = new FileStream();
					stream.open( file, FileMode.READ );
					a = stream.readObject();
					stream.close();
					file = null;
					stream = null;
				}catch (e:Error) {
					
				}				
			}
			return a;
		}
	}
	
}