package com.gmrmarketing.patternmaker
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;	
	import flash.display.Sprite;
	import flash.events.Event;

	public class Main extends MovieClip
	{		
		private var canvas:Sprite;
		private var brush:IBrush;		
		private var curRadius:int;
		private var curSpacing:int;
		private var curGrid:int; //per row		
		
		public function Main()
		{		
			curRadius = 20;
			curSpacing = 14;
			curGrid = 20;			
			
			canvas = new Sprite();
			addChildAt(canvas, 0);			
			
			sl1.addEventListener(Event.CHANGE, updateRadius, false, 0, true);
			sl2.addEventListener(Event.CHANGE, updateSpacing, false, 0, true);
			sl3.addEventListener(Event.CHANGE, updateGrid, false, 0, true);
			
			radC.addEventListener(Event.CHANGE, chooseCircle, false, 0, true);			
			radS.addEventListener(Event.CHANGE, chooseSquare, false, 0, true);
			
			chooseCircle();
		}
		
		
		private function chooseCircle(e:Event = null):void
		{			
			brush = new BrushDot(canvas, [0xFF9900, 0x9EC9E0, 0x66CC00]);
			drawGrid();
		}
		
		
		private function chooseSquare(e:Event):void
		{			
			brush = new BrushSquare(canvas, [0xFF9900, 0x9EC9E0, 0x66CC00]);
			drawGrid();
		}
		
		
		private function updateRadius(e:Event):void
		{			
			curRadius = e.currentTarget.value;
			drawGrid();	
		}
		
		
		private function updateSpacing(e:Event):void
		{
			curSpacing = e.currentTarget.value;
			drawGrid();
		}
		
		
		private function updateGrid(e:Event):void
		{
			curGrid = e.currentTarget.value;
			drawGrid();
		}		
		
			
		private function drawGrid():void
		{
			canvas.graphics.clear();			
			
			var index:int = 1;
			var loc:Array;
			while (index < 400) {
				loc = gridLoc(index, curGrid);
				brush.draw(loc[0] * curSpacing, loc[1] * curSpacing, curRadius);
				index++;
			}
		}
		
		
		/** 
		 * Returns column,row in array like 1,1 for upper left corner
		 * @param	index 1 - n
		 * @param	perRow
		 * @return	Array with two elements x,y
		 */
		private function gridLoc(index:Number, perRow:Number):Array
        {
            return new Array(index % perRow == 0 ? perRow : index % perRow, Math.ceil(index / perRow));
        }
	}
	
}