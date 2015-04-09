package com.gmrmarketing.toyota.witw
{
	import flash.display.*;
	
	public class Handle extends Sprite
	{
		public function Handle(handle:String, color:Number)
		{
			graphics.beginFill(color, 1);
			graphics.drawRect(0, 0, 244, 60);
			graphics.endFill();
		}
	}
	
}