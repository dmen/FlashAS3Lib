package com.gmrmarketing.esurance.usopen2015
{	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.printing.PrintJob;
    import flash.printing.PrintJobOptions;
	
	
	public class Print extends EventDispatcher 
	{
		public static const ADD_ERROR:String = "printJob.addPage_Error";
		public static const SEND_ERROR:String = "printJob.send_Error";
		public static const COMPLETE:String = "printComplete";
		
		
		public function Print(){}
		
		
		public function doPrint(pic:BitmapData):void
		{		
            var printJob:PrintJob = new PrintJob();           
			
			var options:PrintJobOptions = new PrintJobOptions();
            //options.printAsBitmap = true;           
			
			if (printJob.start2(null, false)) {				
				
				var page:Sprite = new Sprite();
				var bmp:Bitmap = new Bitmap(pic);//printBMD);				
				
				page.addChild(bmp);
				page.width = printJob.pageWidth;
				page.scaleY = page.scaleX;
				//page.rotation = 180;
				
				try {
					printJob.addPage(page, null, options);
					//printJob.addPage(page, null, options);
				}
				catch(e:Error) {
					dispatchEvent(new Event(ADD_ERROR));
				}
	 
				try {
					printJob.send();					
				}
				catch (e:Error) {
					dispatchEvent(new Event(SEND_ERROR));   
				}				
		   }
		}
		
	}
	
}