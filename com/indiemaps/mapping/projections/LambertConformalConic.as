package com.indiemaps.mapping.projections
{
	import com.indiemaps.mapping.utils.AngleUtils;
	
	import flash.geom.Point;
	
	/**
	 * Contains methods for projecting lat/long geometries in Lambert's Conformal Conic projection.
	 * 
	 */
	public class LambertConformalConic extends Projection
	{
		public function LambertConformalConic()
		{
		}
		
		static public function projectPoint
		(
			latitude_degrees:Number,
			longitude_degrees:Number,
			
			maxProjectedX:Number = NaN,
			minProjectedX:Number = NaN,
			maxProjectedY:Number = NaN,
			minProjectedY:Number = NaN,
			
			standardParallel1_degrees:Number = 45,
			standardParallel2_degrees:Number = 55,
			
			latitudeOrigin_degrees:Number = 45,
			longitudeOrigin_degrees:Number = 0
		) : Point
		{
			var projectedPoint:Point = new Point();
			
			var latitude_radians:Number = AngleUtils.deg2rad(latitude_degrees);
			var longitude_radians:Number = AngleUtils.deg2rad(longitude_degrees);
			
			var standardParallel1_radians:Number = AngleUtils.deg2rad(standardParallel1_degrees);
			var standardParallel2_radians:Number = AngleUtils.deg2rad(standardParallel2_degrees);
			
			var latitudeOrigin_radians:Number = AngleUtils.deg2rad(latitudeOrigin_degrees);
			var longitudeOrigin_radians:Number = AngleUtils.deg2rad(longitudeOrigin_degrees);
						
			//general constants
			var n:Number = 
			(
				( Math.log( Math.cos(standardParallel1_radians) / Math.cos(standardParallel2_radians) ) )
				/
				( Math.log( Math.tan( Math.PI/4 + standardParallel2_radians/2 ) / Math.tan( Math.PI/4 + standardParallel1_radians/2 ) ) )
			);
			
			var F:Number = (Math.cos(standardParallel1_radians) * Math.pow( Math.tan( Math.PI/4 + standardParallel1_radians/2 ) , n))
							/
							n;
			var p0:Number = F / Math.pow( Math.tan(Math.PI/4 + latitudeOrigin_radians/2 ) , n);
						
			//figured for each point
			var p:Number = F / Math.pow( Math.tan(Math.PI/4 + latitude_radians/2) , n);
			var o0:Number = n * ( longitude_radians - longitudeOrigin_radians );
			
			projectedPoint.x = p * Math.sin( o0 );
			projectedPoint.y = p0 - p * Math.cos( o0 );
			
			if (!isNaN(maxProjectedX)) {
				if (projectedPoint.x > maxProjectedX) {
					projectedPoint.x = maxProjectedX;
				}
			}
			if (!isNaN(minProjectedX)) {
				if (projectedPoint.x < minProjectedX)
					projectedPoint.x = minProjectedX;
			}
			
			
			
			if (!isNaN(maxProjectedY)) {
				if (projectedPoint.y > maxProjectedY) {
					projectedPoint.y = maxProjectedY;
				}
			}
			if (!isNaN(minProjectedY)) {
				if (projectedPoint.y < minProjectedY)
					projectedPoint.y = minProjectedY;
			}
			
			return projectedPoint;
		}
		static public function projectMultiPolygon(
		
			multipolygon:Array, 
			maxProjectedX:Number = NaN,
			minProjectedX:Number = NaN,
			maxProjectedY:Number = NaN,
			minProjectedY:Number = NaN,
			
			standardParallel1_degrees:Number = 45,
			standardParallel2_degrees:Number = 55,
			
			latitudeOrigin_degrees:Number = 45,
			longitudeOrigin_degrees:Number = 0
		) : Array 
		{
			var newMultiPolygon:Array = new Array(); //an array of rings, which are just arrays of points
			for each (var polygon:Array in multipolygon) {
				newMultiPolygon.push(
					projectPolygon(polygon, maxProjectedX, minProjectedX, maxProjectedY, minProjectedY, standardParallel1_degrees, standardParallel2_degrees, latitudeOrigin_degrees, longitudeOrigin_degrees)
				);
			}
			return newMultiPolygon;
		}
		
		static public function projectPolygon(
			polygon:Array,
			maxProjectedX:Number = NaN,
			minProjectedX:Number = NaN,
			maxProjectedY:Number = NaN,
			minProjectedY:Number = NaN,
			
			standardParallel1_degrees:Number = 45,
			standardParallel2_degrees:Number = 55,
			
			latitudeOrigin_degrees:Number = 45,
			longitudeOrigin_degrees:Number = 0
		) : Array {
			var newPolygon:Array = new Array(); //an array of points
			for each (var pt:Object in polygon) {
				newPolygon.push(
					projectPoint(pt.y, pt.x, maxProjectedX, minProjectedX, maxProjectedY, minProjectedY, standardParallel1_degrees, standardParallel2_degrees, latitudeOrigin_degrees, longitudeOrigin_degrees)
				);
			}
			return newPolygon;
		}
		
	}
}