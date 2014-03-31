package com.gmrmarketing.pm.quickdraw
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import com.greensock.TweenLite;
	
	public class CrossHair extends Sprite
	{
		private var glow:GlowFilter;
		private var myFilters:Array;
		
		public function CrossHair()
		{
			//circle with a + in it
			graphics.lineStyle(3, 0x660000);
			graphics.drawCircle(0,0,20);			
			
			//tick marks
			graphics.lineStyle(1, 0xBB0000);
			graphics.moveTo( -3, -10)
			graphics.lineTo(3, -10);
			graphics.moveTo( -3, 10);
			graphics.lineTo(3, 10);
			graphics.moveTo( -10, -3);
			graphics.lineTo( -10, 3);
			graphics.moveTo(10, -3);
			graphics.lineTo(10, 3);
			
			graphics.moveTo( -2, -5);
			graphics.lineTo(2, -5);
			graphics.moveTo( -2, 5);
			graphics.lineTo(2, 5);
			graphics.moveTo( -5, -2);
			graphics.lineTo( -5, 2);
			graphics.moveTo(5, -2);
			graphics.lineTo(5, 2);
			
			//big +
			graphics.lineStyle(1, 0xFF0000);
			graphics.moveTo(0, -10);
			graphics.lineTo(0, 10);
			graphics.moveTo(-10, 0);
			graphics.lineTo(10, 0);			
			
			glow = new GlowFilter(0xFF0000, .8, 30, 30, 3, 2);
			
			myFilters = new Array();
            myFilters.push(glow);
            filters = myFilters;
		}
		
		public function setPosition(p:Point) {
			x = Math.round(p.x);
			y = Math.round(p.y);
		}
		
		public function getPosition():Point
		{
			return new Point(x, y);
		}
		
		
		public function animTest():void
		{
			TweenLite.to(this, .2, { scaleX:2.2, scaleY:2.2 } );
			TweenLite.to(this, .2, { scaleX:1, scaleY:1, delay:.2, overwrite:0 } );
		}
	}
	
}