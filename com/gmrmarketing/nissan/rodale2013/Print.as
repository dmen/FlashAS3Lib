package com.gmrmarketing.nissan.rodale2013
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;
    import flash.printing.PrintJobOptions;
	
	public class Print extends EventDispatcher
	{
		public static const ADD_ERROR:String = "addPageError";
		public static const SEND_ERROR:String = "sendError";
		
		
		public function Print()
		{			
		}
		
		
		public function beginPrint(bmd:BitmapData):void 
		{
            var printJob:PrintJob = new PrintJob();
            
			var options:PrintJobOptions = new PrintJobOptions();
            //options.printAsBitmap = true;           
			
			if (printJob.start2(null, false)) {				
				
				var page:Sprite = new Sprite();
				var bmp:Bitmap = new Bitmap(bmd);				
				
				page.addChild(bmp);
				page.width = printJob.pageWidth;
				page.scaleY = page.scaleX;
				page.rotation = 180;
				
				try {
					printJob.addPage(page, null, options);
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