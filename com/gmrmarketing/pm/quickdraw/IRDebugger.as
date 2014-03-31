package com.gmrmarketing.pm.quickdraw
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.wiiflash.Wiimote;
	import flash.filters.BlurFilter;
	import flash.filters.BitmapFilterQuality;

	
	public class IRDebugger
	{
		private var myMote:IController;
		private var irDot1:Sprite;
		private var irDot2:Sprite;
		private var update:Timer;
		private var blur:BlurFilter;
		private var myFilters:Array;
		
		public function IRDebugger(wm:IController, container:DisplayObjectContainer)
		{
			myMote = wm;
			
			irDot1 = new Sprite();
			irDot2 = new Sprite();
			irDot1.graphics.beginFill(0xFF00AA);
			irDot1.graphics.drawCircle(0,0,15);
			irDot1.graphics.endFill();
			irDot2.graphics.beginFill(0xFF00AA);
			irDot2.graphics.drawCircle(0,0,15);
			irDot2.graphics.endFill();
			
			blur = new BlurFilter(8,8, BitmapFilterQuality.MEDIUM);			
			myFilters = new Array();
            myFilters.push(blur);
            irDot1.filters = myFilters;
			irDot2.filters = myFilters;

			container.addChild(irDot1);
			container.addChild(irDot2);
			
			update = new Timer(20);
			update.addEventListener(TimerEvent.TIMER, moveDots, false, 0, true);
			update.start();
		}
		
			
		public function moveDots(e:TimerEvent):void
		{
			var theIR:* = myMote.getIR();
			irDot1.x = theIR.x1 * 1024;
			irDot1.y = theIR.y1 * 550;
			irDot2.x = theIR.x2 * 1024;
			irDot2.y = theIR.y2 * 550;	
		}		
	}	
}