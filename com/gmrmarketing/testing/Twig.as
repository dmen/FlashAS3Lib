package com.gmrmarketing.testing
{	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.Event;

	public class Twig extends MovieClip
	{		
		private var dx:int;
		private var dy:int;
		private var lineSize:int;
		private var lineColor:Number;
		private var curX:int;
		private var curY:int;
		
		
		public function Twig(mx:int, my:int, $dx:int, $dy:int, $lineSize:int, $lineColor:Number)
		{		
			dx = $dx * Math.random();
			dy = $dy * Math.random();
			lineSize = $lineSize;
			lineColor = $lineColor;
			graphics.lineStyle(lineSize, lineColor);
			curX = mx;
			curY = my;
			graphics.moveTo(curX, curY);			
			addEventListener(Event.ENTER_FRAME, draw, false, 0, true);
		}
		
		
		private function draw(e:Event):void
		{	
			curX += dx;
			curY += dy;
			
			graphics.lineTo(curX, curY);
			if (Math.random() < .4) {
				lineSize--;
				graphics.lineStyle(lineSize, lineColor);
			}
			if (lineSize <= 1) {
				removeEventListener(Event.ENTER_FRAME, draw);				
			}
		}		
		
	}
	
}