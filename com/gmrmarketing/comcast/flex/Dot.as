package com.gmrmarketing.comcast.flex
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;

	
	public class Dot extends Shape
	{
		private var container:DisplayObjectContainer;		
		private var rand:Number;
		
		public function Dot($container:DisplayObjectContainer)
		{
			container = $container;
			
			if(Math.random() < .5){
				graphics.beginFill(0xFF0000);				
			}else {
				graphics.beginFill(0x0000FF);				
			}
			graphics.drawCircle(0, 0, Math.random() * 10);			
			
			x = Math.random() * 1280;
			y = Math.random() * 720;	
			
			rand = Math.random() / 3;
		}
		
		
		public function change():void
		{			
			scaleX += rand;
			scaleY += rand;
			y += 1;
			alpha -= (rand / 5);
			if (alpha <= 0) {
				scaleX = scaleY = 1;
				alpha = 1;
				x = Math.random() * 1280;
				y = Math.random() * 720;
				rand = Math.random() / 3;
			}
		}		
	
	}
	
}