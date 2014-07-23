package com.indiemaps.mapping.utils
{
	import flash.geom.Point;
	
	/**
	 * A couple utility methods for working with working with Well Known Text geometries.
	 * 
	 */
	public class WKTUtils
	{
		public function WKTUtils()
		{
		}
		
		public static function createWKTMultiPointFromArray(arrayOfPoints:Array, xField:String='x', yField:String='y'):String {
			var wktString:String = 'MULTIPOINT(';
			
			for each (var pt:Object in arrayOfPoints) {
				wktString += wktPointFromPoint(pt);
				wktString += ',';
			}
			wktString = wktString.substr(0, wktString.length-1); //remove final comma
			wktString += ')'; //add closing paren
			
			return wktString;
		}
		
		public static function wktPointFromPoint(pt:Object, xField:String='x', yField:String='y'):String {
			return pt[xField] + ' ' + pt[yField];
		}
		
		public static function createArrayFromWKTMultiPoint(wktString:String):Array {
			var ptsArray:Array = [];
			var ptStrings:Array = ((wktString.split('(')[1] as String).split(')')[0] as String).split(',');
			
			for each (var ptString:String in ptStrings) {
				var xy:Array = ptString.split(' ');
				ptsArray.push( new Point(Number(xy[0]), Number(xy[1])) );
			}	
					
			return ptsArray;
		}

	}
}