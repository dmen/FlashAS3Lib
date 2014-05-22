package 
{
	import com.zeropointnine.flv.SimpleFlvWriter
	import flash.display.BitmapData;
	import flash.filesystem.*;
	
	public class Encoder2 
	{
		private var myFile:File;
		private var myWriter:SimpleFlvWriter;
		private var width:int;
		private var height:int;
		
		public function Encoder2(w:int, h:int)
		{
			width = w;
			height = h;
			myWriter = SimpleFlvWriter.getInstance();
		}
		
		public function record(fileName:String = "video.flv"):void
		{
			myFile = File.documentsDirectory.resolvePath(fileName);
			myWriter.createFile(myFile, width, height, 30);
		}
		
		public function addFrame(bmd:BitmapData):void
		{
			myWriter.saveFrame(bmd);
		}
		
		public function stop():void
		{
			myWriter.closeFile();
		}	
	}
	
}