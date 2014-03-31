/**
 * Linked to same named bottle MovieClip in the Library
 */

package com.gmrmarketing.angostura
{		
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class BottleVodka extends BaseBottle implements IBottle
	{
		public function BottleVodka(glass:MovieClip)
		{
			super(glass);
		}
		
		public function getLabel():String
		{
			return "Vodka";
		}		
		
		public function getFillRate():Number
		{
			return 1;
		}
		
		public function getLoc():Point
		{
			return new Point(x, y);
		}
		
		public function getColor():Number 
		{
			return 0xAAAAAA;
		}
		
		public function getStartLoc():Point
		{
			return new Point(390, 120);
		}
		
		public function getSpoutLoc():Point
		{
			var bLoc:Point = getLoc();
			bLoc.x -= 7;
			bLoc.y -= 11;
			return bLoc;
		}
	}
	
}