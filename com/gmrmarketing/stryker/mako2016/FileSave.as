package com.gmrmarketing.stryker.mako2016
{
	import flash.events.*;
	import flash.filesystem.*;
	
	public class FileSave 
	{
		private var file:File;		
		
		public function FileSave()
		{
			file = File.desktopDirectory.resolvePath("Stryker_errors.txt");
		}		
		
		public function write(message:String):void
		{
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.APPEND);
			stream.writeUTFBytes(message);
			stream.close();
		}

	}
	
}