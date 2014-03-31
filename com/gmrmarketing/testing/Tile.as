package com.gmrmarketing.testing
{
	import flash.display.Sprite;
	
	
	public class Tile extends Sprite
	{
		private const MAZE_COLOR:Number = 0x2121FF;
		private const DOT_COLOR:Number = 0xFFFFFF;
		private const MAZE_BG_COLOR:Number = 0x000000;		
		private const half_size:int = 10;		
		private const DOT_RADIUS:int = 1;
		private const POWERUP_RADIUS:int = 5;
		
		
		public function Tile(type:String, size:int, cornerRadius:int = 8):void
		{
			var half_size:int = Math.floor((size + 1) * .5);
			
			graphics.beginFill(MAZE_BG_COLOR, 1);
			graphics.drawRect(0, 0, size, size);
			graphics.endFill();
			
			
			switch(type){
				case "/":
					graphics.lineStyle(2, MAZE_COLOR, 1, true);
					graphics.moveTo(half_size, size);
					graphics.lineTo(half_size, half_size + cornerRadius);
					graphics.curveTo(half_size, half_size, half_size + cornerRadius, half_size);
					graphics.lineTo(size, half_size);
					break;
				case "7":
					graphics.lineStyle(2, MAZE_COLOR, 1, true);
					graphics.moveTo(half_size, size);
					graphics.lineTo(half_size, half_size + cornerRadius);
					graphics.curveTo(half_size, half_size, half_size - cornerRadius, half_size);
					graphics.lineTo(0, half_size);
					break;
				case "L":
					graphics.lineStyle(2, MAZE_COLOR, 1, true);
					graphics.moveTo(half_size, 0);
					graphics.lineTo(half_size, half_size - cornerRadius);
					graphics.curveTo(half_size, half_size, half_size + cornerRadius, half_size);
					graphics.lineTo(size, half_size);
					break;
				case "J":
					graphics.lineStyle(2, MAZE_COLOR, 1, true);
					graphics.moveTo(half_size, 0);
					graphics.lineTo(half_size, half_size - cornerRadius);
					graphics.curveTo(half_size, half_size, half_size - cornerRadius, half_size);
					graphics.lineTo(0, half_size);
					break;
				case "-":
					graphics.lineStyle(2, MAZE_COLOR, 1, true);
					graphics.moveTo(0, half_size);
					graphics.lineTo(size, half_size);
					break;
				case "|":
					graphics.lineStyle(2, MAZE_COLOR, 1, true);
					graphics.moveTo(half_size, 0);
					graphics.lineTo(half_size, size);
					break;
				case ".":
					graphics.beginFill(DOT_COLOR, 1);
					graphics.drawCircle(half_size - DOT_RADIUS, half_size - DOT_RADIUS, DOT_RADIUS);
					graphics.endFill();
					break;
				case "o":
					graphics.beginFill(DOT_COLOR, 1);
					graphics.drawCircle(half_size - POWERUP_RADIUS, half_size - POWERUP_RADIUS, POWERUP_RADIUS);
					graphics.endFill();
					break;
			}
			
		}
	
	}
	
}