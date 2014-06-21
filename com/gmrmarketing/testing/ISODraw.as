package com.gmrmarketing.testing
{		
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	public class ISODraw
	{
		private const COS_X:Number = 0.8944261217100129; //Math.cos(0.46365)
		private const SIN_Y:Number = 0.4472157340733723; //Math.sin(0.46365)
		
		private var container:Sprite;
		
		private var xCart:Number;
		private var yCart:Number;
		
		//xOrigin, yOrigin – drawing center within container
		private var xOrigin:int;
		private var yOrigin:int;
		
		
		public function ISODraw($container:Sprite, $xOrigin:int = 0, $yOrigin:int = 0)
		{
			container = $container;
			xOrigin = $xOrigin;
			yOrigin = $yOrigin;
		}		
		
		public function clear():void
		{
			container.graphics.clear();
		}
		
		public function style(thickness:int, color:Number, alpha:Number ):void
		{
			container.graphics.lineStyle(thickness, color, alpha);
		}
		
		
		public function plot (x:int, y:int, z:int):void
		{
			container.graphics.moveTo(xIso(x, y, z), yIso(x, y, z));
		}
		

		public function draw(x:int, y:int, z:int):void
		{
			container.graphics.lineTo(xIso(x, y, z), yIso(x, y, z));
		}
		
		/**
		 * Creates a box at x,y,x - l,w,h are sizes in the x,y,x direction
		 * @param	x
		 * @param	y
		 * @param	z
		 * @param	l
		 * @param	w
		 * @param	h
		 * @param	color
		 */
		public function box (x:int, y:int, z:int, l, w, h, color:Number, fillColor:Number = -1):void
		{
			if (fillColor != -1) {
				container.graphics.beginFill(fillColor);
			}
			style(1, color, 100);
			plot(x, y, z);
			draw(x + l, y, z);
			draw(x + l, y + w, z);
			draw(x, y + w, z);
			draw(x, y, z);
			plot(x, y + w, z);
			draw(x + l, y + w, z);
			draw(x + l, y + w, z + h);
			draw(x, y + w, z + h);
			draw(x, y + w, z);
			plot(x, y, z);
			draw(x, y + w, z);
			draw(x, y + w, z + h);
			draw(x, y, z + h);
			draw(x, y, z);
			container.graphics.endFill();			
		}
		
		
		/**
		 * transforms x,y,z coordinates into Flash x coordinate
		 * @param	x
		 * @param	y
		 * @param	z
		 * @return
		 */
		private function xIso(x:int, y:int, z:int):Number
		{
			// cartesian coordinates
			xCart = (x - z) * COS_X
			// flash coordinates
			return xCart + xOrigin;
		}
 
		
		/**
		 * transforms x,y,z coordinates into Flash y coordinate
		 * @param	x
		 * @param	y
		 * @param	z
		 * @return
		 */
		private function yIso(x:int, y:int, z:int):Number
		{
			// cartesian coordinates
			yCart = y + (x + z) * SIN_Y;
			// flash coordinates
			return -yCart + yOrigin;
		}
	}
	
}