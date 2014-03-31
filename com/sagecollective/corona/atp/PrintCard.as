package com.sagecollective.corona.atp
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.geom.Rectangle;
	
	public class PrintCard extends EventDispatcher
	{
		public static const PRINT_ERROR:String = "printerError";
		
		private var printJob:PrintJob;
		
		
		public function PrintCard()
		{			
		}
		
		public function printContent(printData:BitmapData):void
		{
			var fullPrint:Sprite = new Sprite();
			var bmp:Bitmap = new Bitmap(printData);
			fullPrint.addChild(bmp);			
			
			var options:PrintJobOptions = new PrintJobOptions();
			//options.printAsBitmap = true;
			//options.pixelsPerInch = 234;
			
			printJob = new PrintJob();
			//for shinko
			var rect:Rectangle = new Rectangle( 0, -10, fullPrint.width, fullPrint.height+10);
			fullPrint.scaleX = .325;
			fullPrint.scaleY = .325;//for shinko
			
			

					
			//AIR2 - start2() can suppress the print dialog - YAY
			if (printJob.start2(null, false)) {	
				
				//var marginWidth:Number = (printJob.pageWidth - fullPrint.width) / 2;
				//var marginHeight:Number = (printJob.pageHeight- fullPrint.height) / 2;				
				
				try{
					printJob.addPage(fullPrint, rect, options);
				}catch(e:Error) {
					printError();
				}				
				
				try{
					printJob.send();
				}catch (e:Error) {
					printError();
				}				
			}		
		}
		
		
		private function printError():void
		{
			dispatchEvent(new Event(PRINT_ERROR));
		}
	}
	
}