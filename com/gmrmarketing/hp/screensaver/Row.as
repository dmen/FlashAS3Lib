package com.gmrmarketing.hp.screensaver
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import flash.geom.Point;
	
	
	public class Row extends Sprite
	{	
		private const BASE_COLOR:Number = 0x333333;
		
		private var theRow:MovieClip;		
		
		private var widths:Array;//original widths
		private var heights:Array; //original heights
		private var xes:Array; //the original x positions
		private var changingIndex:int;
		
		private var theStart:int;
		private var theEnd:int;
		private var theDirection:Number;
		
		private var okToTween:Boolean;
		private var changeBackTimer:Timer;
		
		
		
		public function Row(libClip:MovieClip)
		{
			theRow = libClip;
			addChild(theRow);
			widths = new Array();
			heights = new Array();
			xes = new Array();
			okToTween = true;			
			for (var i:int = 0; i < theRow.numChildren; i++) {
				widths.push(theRow.getChildAt(i).width);
				heights.push(theRow.getChildAt(i).height);
				xes.push(theRow.getChildAt(i).x);
			}
		}		
		
		
		public function setData(rowStart:int, rowEnd:int, rowDirection:Number):void
		{
			theStart = rowStart;
			x = theStart;
			theEnd = rowEnd;
			theDirection = rowDirection;
			addEventListener(Event.ENTER_FRAME, moveRow, false, 0, true);
		}
		
		
		public function getX():int
		{
			return x;
		}
		
		
		public function reset():void
		{
			TweenMax.killAll();
			TweenMax.to(theRow.getChildAt(changingIndex), 0, { tint:BASE_COLOR, width:widths[changingIndex], height:heights[changingIndex] } );					
			update();
			okToTween = true;
			x = theStart;
		}		
		
		
		/**
		 * Tweens the clip at the given index to double its current width
		 * Tweens the color to hp blue
		 */
		public function changeWidth():void
		{
			if(okToTween){
				okToTween = false;
				changingIndex = Math.floor(Math.random() * theRow.numChildren);
				
				//find a clip that's showing on screen				
				var found:Boolean = false;
				var curIndex:int = changingIndex;
				var p:Point;
				var m:MovieClip;
				
				//first go forward
				while (curIndex < theRow.numChildren) {
					m = MovieClip(theRow.getChildAt(curIndex));
					p = new Point(m.x, m.y);
					p = localToGlobal(p);
					if (p.x >= 100 && p.x <= 1260) {
						changingIndex = curIndex;
						found = true;
						break;
					}
					curIndex++;
				}
				//if not found then go backwards
				curIndex = changingIndex;
				if (!found) {
					while (curIndex > 0) {
						m = MovieClip(theRow.getChildAt(curIndex));
						p = new Point(m.x, m.y);
						p = localToGlobal(p);
						if (p.x >= 100 && p.x <= 1260) {
						changingIndex = curIndex;
						found = true;
						break;
					}
					curIndex--;
					}
				}				
				
				//
				changeBackTimer = new Timer(3000 + (Math.random() * 4000),1);
				changeBackTimer.addEventListener(TimerEvent.TIMER, changeBack, false, 0, true);
				changeBackTimer.start();
				TweenMax.to(theRow.getChildAt(changingIndex), 1, { tint:0x1dc6d6, width:widths[changingIndex] * 2, height:heights[changingIndex] * 1.4, ease:Back.easeInOut, onUpdate:update } );
			}
		}
		
		
		/**
		 * Tweens the current big, blue text back to normal size
		 */
		private function changeBack(e:TimerEvent = null):void
		{
			TweenMax.to(theRow.getChildAt(changingIndex), 1, { tint:BASE_COLOR, width:widths[changingIndex], height:heights[changingIndex], ease:Back.easeInOut, onUpdate:update, onComplete:rowClear } );		
		}
		
		
		/**
		 * Called from changeBack() when the text is done tweening back to normal
		 */
		private function rowClear():void
		{
			okToTween = true;
		}
		
		
		/**
		 * Called by TweenMax.onUpdate while the width is changing
		 */
		private function update():void
		{			
			var delta:int = theRow.getChildAt(changingIndex).width - widths[changingIndex];
			delta /= 2;			
			
			for (var i:int = changingIndex - 1; i > -1; i--) {
				theRow.getChildAt(i).x = xes[i] - delta;
			}
			for (var j:int = changingIndex + 1; j < widths.length; j++) {
				theRow.getChildAt(j).x = xes[j] + delta;
			}
		}
		
		
		/**
		 * Called by ENTER_FRAME
		 * @param	e
		 */
		private function moveRow(e:Event):void
		{
			x += theDirection;			
		}
		
	}
	
}