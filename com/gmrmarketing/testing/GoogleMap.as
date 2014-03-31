package com.gmrmarketing.testing
{
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapType;
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.LatLngBounds;
	import com.google.maps.MapMoveEvent;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.interfaces.IPolyline;
	import com.google.maps.services.*;
	import com.google.maps.overlays.*;
	import com.google.maps.styles.*;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.Point;
	
	public class GoogleMap extends MovieClip
	{
		private var dir:Directions;
		private var polyline:IPolyline;
		private var map:Map;
		private var searchAPIKey:String = "ABQIAAAAEmsJFo7jmBpA2NUE9158PxQ3wgJei0XVWFg16ktT0ft_DTvNSxQrRbAagvWpHi7foBaKa0XtE4E5Eg"

		public function GoogleMap()
		{
			map = new Map();
			map.key = "ABQIAAAAJUbOSmHwmi48ssJ4ODIcYhQ3wgJei0XVWFg16ktT0ft_DTvNSxTwtKCTl4zRy82-Xlp5Xg1FRt03xQ";
			map.setSize(new Point(600, 600));
			map.x = 0;
			map.y = 0;
			map.addEventListener(MapEvent.MAP_READY, onMapReady);
			addChild(map);
		}

		private function onMapReady(e:Event):void
		{
			map.setCenter(new LatLng(42.976, -88.108), 11);
			map.addEventListener(MapMouseEvent.CLICK, mapClicked, false, 0, true);
			/*
			dir = new Directions();
			dir.addEventListener(DirectionsEvent.DIRECTIONS_SUCCESS, onDirectionsLoaded);
			dir.load("121 S Porter Ave, Waukesha, WI to 5000 S Towne Dr., New Berlin, WI");
			*/
		}
		
		private function mapClicked(e:MapMouseEvent):void
		{
			drawCircle(e.latLng.lat(), e.latLng.lng(), 3, 0x000000, 1, .8, 0xffff00, .4);
		}

		private function onDirectionsLoaded(e:DirectionsEvent):void
		{
			var returnedDirection:Directions = e.directions;
			
			//trace(metersToMiles(returnedDirection.distance));

			var startLatLng:LatLng = returnedDirection.getRoute(0).getStep(0).latLng;
			var endLatLng:LatLng = returnedDirection.getRoute(returnedDirection.numRoutes - 1).endLatLng;

			polyline = returnedDirection.createPolyline();

			// Remove everything from map and add back the markers and polyline
			map.clearOverlays();
			map.addOverlay(polyline);
			map.addOverlay(new Marker(startLatLng));
			map.addOverlay(new Marker(endLatLng));
			
			//var bnds:LatLngBounds = returnedDirection.bounds;
			//map.addOverlay(new Marker(bnds.getSouthWest()));
			//map.addOverlay(new Marker(bnds.getNorthEast()));
			
			map.setCenter(returnedDirection.bounds.getCenter(), map.getBoundsZoomLevel(returnedDirection.bounds));
			
			drawCircle(startLatLng.lat(), startLatLng.lng(), 1, 0x000000, 1, 1, 0xffff00, .5);
		}

		private function drawCircle(lat:Number, lng:Number, radius:Number, strokeColor:Number, strokeWidth:Number, strokeOpacity:Number, fillColor:Number, fillOpacity:Number):void
		{
			map.clearOverlays();
			
			var d2r:Number = Math.PI/180;
			var r2d:Number = 180/Math.PI;
			var circleLat:Number = radius * 0.014483;  // Convert statute miles into degrees latitude
			var circleLng:Number = circleLat/Math.cos(lat*d2r); 
			var circleLatLngs:Array = new Array();
			for (var i:Number = 0; i < 33; i++) { 
				var theta:Number = Math.PI * (i/16); 
				var vertexLat:Number = lat + (circleLat * Math.sin(theta)); 
				var vertexLng:Number = lng + (circleLng * Math.cos(theta)); 
				var latLng:LatLng = new LatLng(vertexLat, vertexLng); 
				circleLatLngs.push(latLng); 
			}
		  
			var polygonOptions:PolygonOptions = new PolygonOptions();
			var fillStyle:FillStyle = new FillStyle();
			fillStyle.alpha = fillOpacity;
			fillStyle.color = fillColor;
			polygonOptions.fillStyle = fillStyle; 
			
			var strokeStyle:StrokeStyle = new StrokeStyle();
			strokeStyle.alpha = strokeOpacity;
			strokeStyle.color = strokeColor;
			strokeStyle.thickness = strokeWidth;
			polygonOptions.strokeStyle = strokeStyle
			
			var polygon:Polygon = new Polygon(circleLatLngs, polygonOptions);
			map.addOverlay(polygon);
		}


		private function metersToMiles(m:Number):Number
		{
			return m / 1609.344;
		}
	}
	
}