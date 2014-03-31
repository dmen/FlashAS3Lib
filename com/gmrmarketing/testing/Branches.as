package com.gmrmarketing.testing
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.gmrmarketing.testing.Twig;
	
	
	public class Branches extends MovieClip
	{
		private var lastX:int;
		private var lastY:int;
		//deltas
		private var dx:int;
		private var dy:int;
		
		private var curAlpha:Number;
		
		private var lineSize:int = 5;
		private var colors:Array = new Array(0x000000, 0x111111, 0x222222, 0x333333, 0x444444, 0x555555, 0x666666, 0x777777);
		private var curColor:Number;
		
		public function Branches()
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, beginDrawing, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, endDrawing, false, 0, true);
		}
		
		
		
		/**
		 * Called on mouseDown
		 * @param	e
		 */
		private function beginDrawing(e:MouseEvent):void
		{
			lineSize = 5;
			curColor = 	colors[Math.round(colors.length * Math.random())];		
			graphics.lineStyle(lineSize, curColor);
			graphics.moveTo(mouseX, mouseY);
			addEventListener(Event.ENTER_FRAME, drawLine, false, 0, true);
		}
		
		
		/**
		 * Called on mouseUp
		 * @param	e
		 */
		private function endDrawing(e:MouseEvent = null):void
		{
			removeEventListener(Event.ENTER_FRAME, drawLine);
			var c:int = Math.round(Math.random() * 10);
			for (var i:int = 0; i < c; i++){				
				var twig:Twig = new Twig(lastX, lastY, dx, dy, lineSize, curColor);
				addChild(twig);
			}			
		}
		
		
		/**
		 * Called on enterFrame while drawing
		 * @param	e
		 */
		private function drawLine(e:Event):void
		{
			dx = mouseX - lastX; //if going right dx is positive
			dy = mouseY - lastY; //if going down dy is positive
			
			if (Math.random() < .2) {
				lineSize-=.5;
				graphics.lineStyle(lineSize, curColor);
			}
			
			if (lineSize <= 1) {
				lineSize = 1;			
			}
			graphics.lineTo(mouseX, mouseY);
			
			lastX = mouseX;
			lastY = mouseY;
			
		}
	}
	
}