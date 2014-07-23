package com.indiemaps.mapping.cartograms.utils
{
	import org.vanrijkom.dbf.DbfRecord;
	import org.vanrijkom.shp.ShpPolygon;
	import org.vanrijkom.shp.ShpRecord;
	
	/**
	 * A utility class for a few tasks related to cartogram creation
	 * 
	 */
	public class CartogramUtils
	{
		public function CartogramUtils()
		{
		}
		
		/**
		 * Creates an array of objects from shp/dbf input.
		 * Creates the input format expected by indiemaps cartogram classes.
		 * 
		 */
		public static function createCombinedArrayFromShpDbf(shpRecords:Array, dbfRecords:Array, multiPolygonConversionFunction:Function=null):Array {
			var combinedArray:Array = [];
			for (var i:Object in shpRecords) { 
				combinedArray[i as int] = {
					geometry : (multiPolygonConversionFunction != null) ? multiPolygonConversionFunction(((shpRecords[i] as ShpRecord).shape as ShpPolygon).rings) : ((shpRecords[i] as ShpRecord).shape as ShpPolygon).rings,
					attributes : (dbfRecords[i] as Object).values
				}
			}
			
			return combinedArray;
		}
		
		/**
		 * Removes objects with matching values from the combined array.
		 * 
		 * @param combinedArray An Array of objects, likely created by the method CartogramUtils.createCombinedArrayFromShpDbf.
		 * @param property The property of the object to test.
		 * @param value The String to check for.
		 * @param propertyOfObject If the property is nested, this is the property of the object it is nested within.
		 * 
		 */
		public static function removeObjectsFromCombinedArray(combinedArray:Array, property:String, value:String, propertyOfObject:Object=null):void {
			for (var i:Object in combinedArray) {	
				while (true) {
					if (i > (combinedArray.length-1)) break;
					var obj:Object = combinedArray[i];
					var valToEvaluate:String = (propertyOfObject == null) ? (obj[property]) : (obj[propertyOfObject][property]);
					if (value == valToEvaluate.substr(0,value.length)) {
						combinedArray.splice(combinedArray.indexOf(obj), 1);
					} else {
						break;
					}
				}
			}
		}
		
		
	}
}