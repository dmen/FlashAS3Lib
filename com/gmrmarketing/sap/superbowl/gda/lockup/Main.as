package com.gmrmarketing.sap.superbowl.gda.lockup
{
	import com.gmrmarketing.bcbs.findyourbalance.TimerDisplay;
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Main extends MovieClip implements IModuleMethods
	{
		public static const FINISHED:String = "finished";
		private const DISPLAY_TIME:int = 8;
		private var bmd:BitmapData;
		private var bmp:Bitmap;
		private var tx:int;
		private var ty:int;
		private var updateTimer:Timer;
		private var lines:Array;
		private var lineIndex:int;
		
		
		public function Main()
		{
			bmd = new BitmapData(640, 70, true, 0x00000000);
			bmp = new Bitmap(bmd);
			bmp.x = 0;
			bmp.y = 117;
			addChild(bmp);
			
			statsZone.cacheAsBitmap = true;
			bmp.cacheAsBitmap = true;
			statsZone.mask = bmp;
			
			updateTimer = new Timer(20);
		}
		
		
		public function init(initValue:String = ""):void
		{
			
		}
		
		
		public function isReady():Boolean
		{
			return true;
		}
		
		
		public function show():void
		{
			lines = new Array();
			for (var i:int = 0; i < 70; i++) {
				lines.push(i);
			}
			lines = Utility.randomizeArray(lines);
			lineIndex = 0;
			
			updateTimer.addEventListener(TimerEvent.TIMER, update, false, 0, true);
			updateTimer.start();			
		}
		
		
		private function update(e:TimerEvent):void
		{
			bmd.fillRect(new Rectangle(0, lines[lineIndex], 640, 1), 0xffffffff);
			bmd.fillRect(new Rectangle(0, lines[lineIndex+1], 640, 1), 0xffffffff);
			lineIndex+=2;
			if (lineIndex >= lines.length) {
				updateTimer.reset();
				doneTimer();
			}
		}
		
		
		private function doneTimer():void
		{
			TweenMax.delayedCall(DISPLAY_TIME, done);
		}
		
		
		private function done():void
		{
			dispatchEvent(new Event(FINISHED));
		}
		
		
		public function cleanup():void
		{			
			bmd.fillRect(bmd.rect, 0);
		}
	}
	
}