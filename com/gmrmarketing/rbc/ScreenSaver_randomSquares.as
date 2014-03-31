package com.gmrmarketing.rbc
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import gs.TweenLite;

	public class ScreenSaver
	{
		private var theScreen:BitmapData;
		private var myContainer:DisplayObjectContainer;
		private var bmp:Bitmap;		
		private var theOriginal:BitmapData;
		private var ind:int = 0;
		private var myTimer:Timer;
		private var alph:BitmapData;
		
		private var running:Boolean;
		
		public function ScreenSaver()
		{	
			running = false;
			alph = new BitmapData(100, 100, true, 0x66333333);
		}
		
		
		public function show(container:DisplayObjectContainer):void
		{						
			myContainer = container;	
			
			theOriginal = new BitmapData(1360, 768);
			theOriginal.draw(myContainer);
			
			theScreen = new BitmapData(1360, 768);
			theScreen.fillRect(new Rectangle(0, 0, 1360, 768), 0xFF000000);
			theScreen.draw(myContainer);
			
			bmp = new Bitmap(theScreen);
				
			myContainer.addChild(bmp);
			
			myTimer = new Timer(12);
			myTimer.addEventListener(TimerEvent.TIMER, slide, false, 0, true);
			myTimer.start();	
			
			running = true;
		}
		
		
		private function slide(e:TimerEvent):void
		{
			theScreen.copyPixels(theOriginal, new Rectangle(Math.random() * 1260, Math.random() * 668, 100, 100), new Point(Math.random() * 1260, Math.random() * 668), alph, null, true);
		}
		
		
		public function stopSaver():void
		{			
			TweenLite.to(bmp, 2, { alpha:0, onComplete:kill } );
		}
		
		
		public function isRunning():Boolean
		{
			return running;			
		}
		
		
		private function kill():void
		{
			myTimer.stop();
			theOriginal.dispose();
			theScreen.dispose();			
			myTimer.removeEventListener(TimerEvent.TIMER, slide);
			myContainer.removeChild(bmp);	
			
			running = false;
		}
	}
}