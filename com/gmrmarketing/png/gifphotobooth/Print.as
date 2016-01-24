package com.gmrmarketing.png.gifphotobooth
{
	import com.gmrmarketing.sap.levisstadium.tagcloud.RectFinder;
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
		
		private var printImage:BitmapData;//600x1800 for printing - 2x6
		
		
		public function Print(){}		
  
		
		/**
		 * 
		 * @param	pics Array of 749x657 images
		 * currently 10 - draw image 1,5,10
		 */
		public function doPrint(pics:Array):void
		{			
			var m:Matrix = new Matrix();			
			m.scale(.694259, .694259);//scale 749x657 to 520x456
			
			printImage = new photoStrip(); //lib 600x1800
			//var over:BitmapData = new overlayLarge(); //749x657
			//var overScaled:BitmapData = new BitmapData(520, 456, true, 0x00000000);
			//overScaled.draw(over, m, null, null, null, true);			
			
			var p1:BitmapData = new BitmapData(520, 456);
			p1.draw(pics[0], m, null, null, null, true);
			//p1.copyPixels(overScaled, new Rectangle(0, 0, 520, 456), new Point(0, 0), null, null, true);
			
			var p2:BitmapData = new BitmapData(520, 456);
			p2.draw(pics[4], m, null, null, null, true);
			//p2.copyPixels(overScaled, new Rectangle(0, 0, 520, 456), new Point(0, 0), null, null, true);
			
			var p3:BitmapData = new BitmapData(520, 456);
			p3.draw(pics[9], m, null, null, null, true);
			//p3.copyPixels(overScaled, new Rectangle(0, 0, 520, 456), new Point(0, 0), null, null, true);
			
			printImage.copyPixels(p1, new Rectangle(0, 0, 562, 492), new Point(40, 235));
			printImage.copyPixels(p2, new Rectangle(0, 0, 562, 492), new Point(40, 734));
			printImage.copyPixels(p3, new Rectangle(0, 0, 562, 492), new Point(40, 1234));
			
			beginPrint();
		}
		
		
		
		private function beginPrint():void 
		{			
            var printJob:PrintJob = new PrintJob();           
			
			var options:PrintJobOptions = new PrintJobOptions();
            //options.printAsBitmap = true;           
			
			if (printJob.start2(null, false)) {				
				
				var page:Sprite = new Sprite();
				var bmp:Bitmap = new Bitmap(printImage);//printBMD);				
				
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