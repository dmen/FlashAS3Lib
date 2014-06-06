package com.gmrmarketing.testing
{
	import flash.display.*;
	import com.greensock.TweenMax;
	
	public class Swatches
	{
		private var colors:Array;
		private var curX:int = 23;
		private var curY:int = 183;
		private var sqSize:int = 25;
		private var buff:int = 1;
		private var container:DisplayObjectContainer;
		private var swatchCount:int;
		
		public function Swatches()
		{
			colors = [];
			swatchCount = 0;
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function getColors():Array
		{
			var c:Array = new Array();
			for (var i:int = 0; i < colors.length; i++) {
				c.push(colors[i][0]);
			}			
			return c;
		}
		
		
		public function addColor(nc:int):void
		{
			var sw:MovieClip = new swatch(); //lib clip
			sw.x = curX;
			sw.y = curY;
			container.addChild(sw);
			
			curX += sqSize + buff;
			swatchCount++;
			if (swatchCount % 4 == 0) {
				curX = 23;
				curY += sqSize + buff;
			}
			TweenMax.to(sw, 1, {colorTransform:{tint:nc, tintAmount:1}});
			colors.push([nc, sw]);			
		}
		
		
		public function clear():void
		{
			var aColor:Array;
			while (colors.length) {
				aColor = colors.shift();
				container.removeChild(MovieClip(aColor[1]));
			}
			colors = [];
			curX = 23;
			curY = 183;
			swatchCount = 0;
		}		
		
	}
	
}