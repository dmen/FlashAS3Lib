package com.gmrmarketing.nissan.rodale2013
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
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
		
		/**
		 * Comes in as 800x800 bmd
		 * @param	bmd
		 */
		public function beginPrint(bmd:BitmapData):void 
		{
			//var mat:Matrix = new Matrix();
			//mat.scale(4, 4);
			
			//var printBMD:BitmapData = new BitmapData(3200, 3200);
			//printBMD.draw(bmd, mat, null, null, null, true);
			
            var printJob:PrintJob = new PrintJob();
            
			var options:PrintJobOptions = new PrintJobOptions();
            //options.printAsBitmap = true;           
			
			if (printJob.start2(null, false)) {				
				
				var page:Sprite = new Sprite();
				var bmp:Bitmap = new Bitmap(bmd);//printBMD);				
				
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