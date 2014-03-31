package com.gmrmarketing.patternmaker
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;	
	
	
	public class BrushSquare extends Sprite implements IBrush
	{
		private var canvas:Sprite;
		
		private var palette:Array;
		private var palIndex:int;
		
		public function BrushSquare($canvas:Sprite, $palette:Array)
		{
			canvas = $canvas;			
			palette = $palette;
			palIndex = 0;
		}
		
		public function draw(tx:int, ty:int, radius:int):void
		{			
			canvas.graphics.beginFill(palette[palIndex]);
			canvas.graphics.drawRect(tx, ty, radius, radius);			
			palIndex++;
			if (palIndex >= palette.length) {
				palIndex = 0;
			}			
		}
		
	}
	
}