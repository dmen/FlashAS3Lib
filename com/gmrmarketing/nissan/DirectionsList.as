package com.gmrmarketing.nissan
{
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.services.*;
	import com.google.maps.overlays.Marker;	
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.interfaces.IPolyline;
	import com.google.maps.overlays.PolylineOptions;
	import flash.events.Event;
	
	import flash.events.EventDispatcher;
	
	
	
	
	public class DirectionsList extends EventDispatcher
	{
		public static const DONE_CALCULATING:String = "directionsCalculated";
		public static const DIRECTIONS_ERROR:String = "errorCalculatingDirections";
		
		private var map:Map;
		private var curMiles:Number;
		private var directionOverlays:Array;
		private var markers:Array;
		private var colors:Array;
		private var markerIndex:int;
		private var dir:Directions;
		private var currMarkerColor:Number;
		
		private var totalDistance:int;
		private var distances:Array;
		
		private var errorLocation:int = 0;
		
		
		
		public function DirectionsList($map:Map)
		{
			map = $map;
			directionOverlays = new Array();
			distances = new Array();
		}
		
		
		
		/**
		 * Called from updateDirections() in Leaf whenever a map marker is dragged and dropped
		 * @param	$markers
		 * @param 	$colors
		 */
		public function calculateRoute($markers:Array, $colors:Array):void
		{
			clearCurrentRoute();
			
			totalDistance = 0;
			markers = $markers;		
			colors = $colors;
			
			markerIndex = 0;
			
			if (markers.length > 1) {
				
				//push the last marker on to the end, so we make a loop - back to the first marker added
				markers.push(markers[0]);
				
				var dirOptions:DirectionsOptions = new DirectionsOptions( { travelMode:DirectionsOptions.TRAVEL_MODE_DRIVING } );
				
				dir = new Directions(dirOptions);
				dir.addEventListener(DirectionsEvent.DIRECTIONS_SUCCESS, onDirectionsLoaded, false, 0, true);
				dir.addEventListener(DirectionsEvent.DIRECTIONS_FAILURE, onDirectionsError, false, 0, true);
				dir.addEventListener(DirectionsEvent.DIRECTIONS_ABORTED, onDirectionsError, false, 0, true);
				doLoad();
			}
		}
		
		
		
		private function doLoad():void
		{
			errorLocation++;
			
			var ptA:Marker = markers.splice(0, 1)[0];
			var ptB:Marker = markers[0];
			
			dir.loadFromWaypoints([ptA.getLatLng(), ptB.getLatLng()]);
		}
		
		
		
		/**
		 * Removes all polyline overlays from the map
		 * and resets the total distance to zero
		 */
		public function clearCurrentRoute():void
		{
			var p:IPolyline;
			while (directionOverlays.length) {
				p = directionOverlays.splice(0, 1)[0];
				map.removeOverlay(p);
			}
			totalDistance = 0;
			distances = new Array();
			errorLocation = 0;
		}
		
		
		
		public function getTotalDistance():int
		{
			return totalDistance;
		}
		
		
		/**
		 * Returns the array of distances
		 * @return
		 */
		public function getDistances():Array
		{
			return distances;
		}
		
		
		
		private function onDirectionsError(e:DirectionsEvent):void
		{
			dispatchEvent(new Event(DIRECTIONS_ERROR));
		}
		
		public function getErrorLocation():int
		{
			return errorLocation;
		}
		
		
		
		/**
		 * Called when a directions object has been loaded
		 * increments the totalDistance with the new distance
		 * dispatches a done calculating event if there are no
		 * more distances to calculate
		 * 
		 * @param	e
		 */
		private function onDirectionsLoaded(e:DirectionsEvent):void
		{
			var returnedDirection:Directions = Directions(e.directions);
			
			curMiles = Math.round(metersToMiles(returnedDirection.distance));			
			totalDistance += curMiles;
			distances.push(curMiles);

			var polyLineOptions:PolylineOptions = new PolylineOptions({strokeStyle:{color:colors[markerIndex].iconColor, alpha:.8, thickness:4, pixelHinting:false } });
			
			var polyline:IPolyline = returnedDirection.createPolyline(polyLineOptions);
			trace(polyline.getVertexCount());

			// Remove everything from map and add back the markers and polyline			
			map.addOverlay(polyline);
			
			directionOverlays.push(polyline);
			
			if (markers.length > 1) {
				doLoad();
				markerIndex++;
			}else {
				//done calculating - calls directionsFinished() in Leaf
				dispatchEvent(new Event(DONE_CALCULATING));
			}
		}
		
		
		
		private function metersToMiles(m:Number):Number
		{
			return m / 1609.344;
		}
	}
	
}