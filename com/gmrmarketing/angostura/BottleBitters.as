/**
 * Linked to same named bottle MovieClip in the Library
 */

package com.gmrmarketing.angostura
{		
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class BottleBitters extends BaseBottle implements IBottle
	{
		public function BottleBitters(glass:MovieClip)
		{
			super(glass);
		}
		
		public function getLabel():String
		{
			return "Angostura Bitters";
		}
		
		public function getFillRate():Number
		{
			return .4;
		}
		
		public function getLoc():Point		
		{
			return new Point(x, y);
		}
		
		public function getColor():Number 
		{
			return 0x774433;
		}
		
		public function getStartLoc():Point
		{
			return new Point(335,171);
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