package com.gmrmarketing.patternmaker
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	
	public class BrushDot extends Sprite implements IBrush	
	{
		private var canvas:Sprite;
		
		private var palette:Array;
		private var palIndex:int;
		
		public function BrushDot($canvas:Sprite, $palette:Array)
		{
			canvas = $canvas;			
			palette = $palette;
			palIndex = 0;
		}
		
		public function draw(tx:int, ty:int, radius:int):void
		{
			canvas.graphics.beginFill(palette[palIndex]);
			canvas.graphics.drawCircle(tx, ty, radius);
			palIndex++;
			if (palIndex >= palette.length) {
				palIndex = 0;
			}
		}
		
	}
	
}