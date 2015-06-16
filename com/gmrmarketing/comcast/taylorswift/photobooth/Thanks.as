package com.gmrmarketing.comcast.taylorswift.photobooth
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.printing.PrintJob;
    import flash.printing.PrintJobOptions;
	import flash.geom.*
	
	
	public class Thanks extends EventDispatcher
	{
		public static const ADD_ERROR:String = "printJob.addPage_Error";
		public static const SEND_ERROR:String = "printJob.send_Error";
		public static const SHOWING:String = "thanksShowing";
		public static const COMPLETE:String = "thanksComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var tim:TimeoutHelper;
		private var printImage:BitmapData;//600x1800 for printing
		
		
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
		public function show(email:Boolean):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			if (email) {
				clip.theText.text = "Your photo has printed and will be\nemailed to you shortly";
				clip.exit.y = 612;
			}else {
				clip.theText.text = "Your photo has printed";
				clip.exit.y = 532;
			}
			
			/**
			 * Start moved from Print.as
			 */
			/*var pic:BitmapData;
			var m:Matrix = new Matrix();
			//600 x 1800 (2"x6") from library
			printImage = new printHolder();
			
			pic = new BitmapData(468, 468);
			
			m = new Matrix();
			m.scale(.624, .624);//scale 750 to 468
			
			//colorTransform to add brightness for printing
			//var co:ColorTransform = new ColorTransform(1.2, 1.2, 1.2, 1) 
			
			//pic 1
			pic.draw(pics[0], m, null, null, null, true);
			printImage.copyPixels(pic, pic.rect, new Point(66, 124));
			//printImage.copyPixels(pic, pic.rect, new Point(670, 180));
			
			//pic 2
			pic.draw(pics[1], m, null, null, null, true);
			printImage.copyPixels(pic, pic.rect, new Point(66, 618));
			//printImage.copyPixels(pic, pic.rect, new Point(670, 682));
			
			//pic 3
			pic.draw(pics[2], m, null, null, null, true);
			printImage.copyPixels(pic, pic.rect, new Point(66, 1115));
			*/
			/**
			 * End Moved from Print.as
			 */
			
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		public function hide():void
		{
			clip.removeEventListener(Event.ENTER_FRAME, updateGlow);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function showing():void
		{
			//beginPrint();//was in Print.showing()
			
			clip.addEventListener(Event.ENTER_FRAME, updateGlow);			
			dispatchEvent(new Event(SHOWING));
			TweenMax.delayedCall(15, thanksComplete);
		}
		
		
		private function thanksComplete():void
		{
			tim.buttonClicked();			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function updateGlow(e:Event):void
		{
			TweenMax.to(clip.xfin, 0, { glowFilter: { color:0x33ccff, alpha:.2 + Math.random()*.8, blurX:5, blurY:5 } } );
			TweenMax.to(clip.year, 0, { glowFilter: { color:0xff9999, alpha:.2 + Math.random()*.8, blurX:5, blurY:5 } } );
		}
		
		/*
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
		}*/
	}
	
}