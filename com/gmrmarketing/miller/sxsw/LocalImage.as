package com.gmrmarketing.miller.sxsw
{
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.utils.ByteArray;
	import com.adobe.images.JPEGEncoder;
	import flash.filesystem.*;
	
	public class LocalImage
	{
		private var ba:ByteArray;
		
		
		public function LocalImage()
		{			
		}
		
		
		public function compress(bmpd:BitmapData, q:int = 80):void
		{
			var encoder:JPEGEncoder = new JPEGEncoder(q);
			ba = encoder.encode(bmpd);
		}
		
		
		public function save(id:String = ""):void
		{
			var filename:String;
			
			if (id == "") {
				var d:Date = new Date();
				var ds:String = String(d.getMonth() + 1) + "_" + String(d.getDate()) + "_" + String(d.getFullYear()) + "_" + String(d.getHours()) + "_" + String(d.getMinutes()) + "_" + String(d.getSeconds());			
				filename = ds + ".jpg";
			}else {
				filename = id + ".jpg";
			}
			
			var file:File = File.applicationDirectory.resolvePath("images/" + filename);			
			var wr:File = new File(file.nativePath);			
			var stream:FileStream = new FileStream();		
			stream.open(wr , FileMode.WRITE);			
			stream.writeBytes (ba, 0, ba.length);			
			stream.close();
		}
	}
	
}