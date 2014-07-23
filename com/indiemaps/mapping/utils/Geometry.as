package com.indiemaps.mapping.utils
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Geometry
	{
		public function Geometry()
		{
		}
		
		/**
		 * 
		 */
		public static function areaOfPolygon(arrayOfPoints:Array):Number {
			var area:Number=0;
			var j:int;
			for (var i:int=0; i<arrayOfPoints.length-1; i++) {
				j = (i + 1) % (arrayOfPoints.length-1);
				area += arrayOfPoints[i].x * arrayOfPoints[j].y;
				area -= arrayOfPoints[i].y * arrayOfPoints[j].x;
			}
			return Math.abs(area / 2);
		}
		
		/**
		 * 
		 */
		public static function insidePolygon(polygon:Array, n:Number, p:Point):Boolean {
			//standard point-in-polygon test; returns true if inside polygon
			var i:int = 0;
			var j:int = 0;
			var inside:Boolean = false;
			for (i = 0, j = n-1; i < n; j = i++) {
				if ((((polygon[i][1] <= p.y) && (p.y < polygon[j][1])) ||
				             ((polygon[j][1] <= p.y) && (p.y < polygon[i][1]))) &&
				            (p.x < (polygon[j][0] - polygon[i][0]) * (p.y - polygon[i][1]) / (polygon[j][1] - polygon[i][1]) + polygon[i][0])) {
					inside = !inside;
				}
			}
			return inside;
		}
		
		/**
		 * 
		 */
		public static function centerOfPolygonArea(polygon:Array, area:Number):Point {
			var center:Point = new Point();
			for (var i:int=(polygon.length-1); i>0; i--) {
   		   		center.x += (polygon[i].x + polygon[i-1].x) * ((polygon[i].x * polygon[i-1].y) - (polygon[i-1].x * polygon[i].y));
 		       	center.y += (polygon[i].y + polygon[i-1].y) * ((polygon[i].x * polygon[i-1].y) - (polygon[i-1].x * polygon[i].y));
 			}
			center.x /= ((6) * area);
 			center.y /= ((6) * area);
			return center;
		}
		
		/**
		 * 
		 * 
		 */
		public static function centerOfMultiPolygonBoundingBox(rings:Array):Point {
			var topLeft:Point = new Point(Infinity, Infinity);
			var bottomRight:Point = new Point(-Infinity, -Infinity);
			for each (var ring:Array in rings) {
				for each (var pt:Object in ring) {
					if (pt.x < topLeft.x)
						topLeft.x = pt.x;
					if (pt.x > bottomRight.x)
						bottomRight.x = pt.x;
					if (pt.y < topLeft.y)
						topLeft.y = pt.y;
					if (pt.y > bottomRight.y)
						bottomRight.y = pt.y;
				}
			}
			return new Point((bottomRight.x-topLeft.x)*.5 + topLeft.x, (bottomRight.y-topLeft.y)*.5 + topLeft.y);
		}
		
		/**
		 * 
		 */
		public static function getMultiPolygonBounds(multipolygon:Array, yMultiplier:Number=-1):Rectangle {
			var topLeft:Point = new Point(Infinity, Infinity);
			var bottomRight:Point = new Point(-Infinity, -Infinity);
			
			for each (var ring:Array in multipolygon) {
				for each (var pt:Object in ring) {
					if (pt.x < topLeft.x)
						topLeft.x = pt.x;
					if (pt.x > bottomRight.x)
						bottomRight.x = pt.x;
					if ((pt.y*yMultiplier) < (topLeft.y))
						topLeft.y = pt.y*yMultiplier;
					if ((pt.y*yMultiplier) > (bottomRight.y))
						bottomRight.y = pt.y*yMultiplier;
				}
			}
			return new Rectangle(topLeft.x, topLeft.y, bottomRight.x-topLeft.x, bottomRight.y-topLeft.y);
		}
		
		/**
		 * 
		 */
		public static function getPolygonBounds(polygon:Array, yMultiplier:Number=-1):Rectangle {
			var topLeft:Point = new Point(Infinity, Infinity);
			var bottomRight:Point = new Point(-Infinity, -Infinity);
			
			for each (var pt:Object in polygon) {
				if (pt.x < topLeft.x)
						topLeft.x = pt.x;
					if (pt.x > bottomRight.x)
						bottomRight.x = pt.x;
					if (pt.y*yMultiplier < topLeft.y*yMultiplier)
						topLeft.y = pt.y*yMultiplier;
					if (pt.y*yMultiplier > bottomRight.y*yMultiplier)
						bottomRight.y = pt.y*yMultiplier;
			}
			return new Rectangle(topLeft.x, topLeft.y, bottomRight.x-topLeft.x, bottomRight.y-topLeft.y);
		}

	}
}