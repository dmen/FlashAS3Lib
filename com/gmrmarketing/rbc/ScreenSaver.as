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
		private var running:Boolean;
		private var mov:bigEnerGuideLogo;
		private var bg:bigBlack;
		private var myContainer:DisplayObjectContainer;
		
		public function ScreenSaver()
		{	
			running = false;
			mov = new bigEnerGuideLogo();
			bg = new bigBlack();
			mov.gotoAndStop(1);
			mov.x = 185; mov.y = 220;			
		}
				
		public function show(container:DisplayObjectContainer):void
		{						
			myContainer = container;
			myContainer.addChild(bg);
			myContainer.addChild(mov);
			mov.addEventListener("ssEnd", startLoop, false, 0, true);
			startSaver();
		}		
		
		public function startSaver():void
		{			
			mov.gotoAndPlay(1);
			mov.alpha = 1;
			running = true
		}
		
				
		public function isRunning():Boolean
		{
			return running;			
		}
		
		private function startLoop(e:Event)
		{
			TweenLite.to(mov, 3, { alpha:0, delay:5, onComplete:startSaver } );
		}
		
		public function kill():void
		{	
			TweenLite.killTweensOf(mov);
			mov.removeEventListener("ssEnd", startLoop);
			myContainer.removeChild(mov);
			myContainer.removeChild(bg);
			mov.gotoAndStop(1);
			running = false;
		}
	}
}