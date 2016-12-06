package com.gmrmarketing.holiday2016.photostrip
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.printing.PrintJob;
    import flash.printing.PrintJobOptions;
	import flash.geom.*;
	import com.dynamicflash.util.Base64;
	import flash.utils.ByteArray;
	import com.adobe.images.JPEGEncoder;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const ADD_ERROR:String = "printJob.addPage_Error";
		public static const SEND_ERROR:String = "printJob.send_Error";
		public static const SHOWING:String = "thanksShowing";
		public static const COMPLETE:String = "thanksComplete";
		public static const PROCESS:String = "processComplete";	
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var tim:TimeoutHelper;
		private var imageString:String;
		private var printImage:BitmapData;//600x1800 for printing
		private var shareImage:BitmapData;//square for sharing
		
		public function Thanks()
		{
			clip = new mcThanks();
			tim = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		//pics:Array
		public function show(pics:Array):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			shareImage = new BitmapData(789, 786);
			shareImage.draw(pics[1], new Matrix(), null, null, null, true);
			
			
			
			//colorTransform to add brightness for printing
			//var co:ColorTransform = new ColorTransform(1.2, 1.2, 1.2, 1) 
			
			//1200 x 1800 (4"x6") from library
			printImage = new printHolder();			
			
			var pic:BitmapData = new BitmapData(468, 466);
		
			var m:Matrix = new Matrix();
			m.scale(0.5931558935361217, 0.5931558935361217);//scale 750 to 468			
			
			
			//pic 1
			pic.draw(pics[0], m, null, null, null, true);
			printImage.copyPixels(pic, pic.rect, new Point(63, 179));
			
			//pic 2
			pic.draw(pics[1], m, null, null, null, true);
			printImage.copyPixels(pic, pic.rect, new Point(63, 683));
			
			//pic 3
			pic.draw(pics[2], m, null, null, null, true);
			printImage.copyPixels(pic, pic.rect, new Point(63, 1186));
			
			//pic 4
			pic.draw(pics[0], m, null, null, null, true);
			printImage.copyPixels(pic, pic.rect, new Point(669, 179));
			
			//pic 5
			pic.draw(pics[1], m, null, null, null, true);
			printImage.copyPixels(pic, pic.rect, new Point(669, 683));
			
			//pic 6
			pic.draw(pics[2], m, null, null, null, true);
			printImage.copyPixels(pic, pic.rect, new Point(669, 1186));			
			
			/**
			 * End Moved from Print.as
			 */
			
			/*var b = new Bitmap(printImage, "auto", true);
			b.y = -900;
			clip.addChild(b);*/
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		public function get data():Object
		{			
			return {email:"", image:imageString};
		}
		
		public function hide():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function showing():void
		{
			beginPrint();//was in Print.showing()
					
			dispatchEvent(new Event(SHOWING));
			TweenMax.delayedCall(15, thanksComplete);
		}
		
		
		private function thanksComplete():void
		{
			tim.buttonClicked();			
			dispatchEvent(new Event(COMPLETE));
		}
		
		private function beginPrint():void 
		{			
            var printJob:PrintJob = new PrintJob();           
			
			var options:PrintJobOptions = new PrintJobOptions();
			var printArea:Rectangle;
            //options.printAsBitmap = true;        
			
			if (printJob.start2(null, false)) {				
				// correcting for zooming
				var border = 30;
				var page:Sprite = new Sprite();
				var bmp:Bitmap = new Bitmap(printImage);//printBMD);
				
				
				var imageRatio = bmp.height / bmp.width;
				var borderRect:Shape = new Shape();
				borderRect.graphics.beginFill(0xFFFFFF);
				borderRect.graphics.drawRect(0,0, bmp.width + (border * 2), bmp.height + (border * imageRatio * 2));

				page.addChild(borderRect);
				
				bmp.x = border;
				bmp.y = border * imageRatio;
				
				trace("bmp: " + bmp.width);
				page.addChild(bmp);
				trace("page: " + page.width);
				page.width = printJob.pageWidth;
				trace("pageWidth: " + printJob.pageWidth);
				page.scaleY = page.scaleX;
				trace("scale: " + page.scaleY);
				//page.rotation = 180;

				try {
					//printJob.addPage(page, null, options);
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
		
				/**
		 * Three functions process shareImage into imageString to be sent to NowPik
		 */
		public function process():void
		{
			var jpeg:ByteArray = getJpeg(shareImage);
			imageString = getBase64(jpeg);
			dispatchEvent(new Event(PROCESS));
		}
		
		
		private function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		
		private function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPEGEncoder = new JPEGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
	}
	
}