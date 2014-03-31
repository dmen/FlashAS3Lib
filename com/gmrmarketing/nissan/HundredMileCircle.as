package com.gmrmarketing.nissan
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.overlays.*;
	import com.google.maps.styles.*;
	
	
	
	public class HundredMileCircle	
	{
		private var map:Map;
		private var polygon:Polygon;
		private var circleLoc:LatLng;
		private var circleShowing:Boolean;
		
		
		public function HundredMileCircle($map:Map)
		{
			map = $map;
		}
		
		
		
		/**
		 * Returns the zoom level for the 100 mile circle or the map itself
		 * if the circle is not present
		 * @return
		 */
		public function getZoomBounds():Number
		{
			if(polygon){
				return map.getBoundsZoomLevel(polygon.getLatLngBounds());
			}else {
				return map.getZoom();
			}
		}
		
		
		
		/**
		 * removes the circle from the map
		 */
		public function clearCircle():void
		{
			if(polygon){
				map.removeOverlay(polygon);
			}
			circleShowing = false;
		}
		
		
		public function getCircleLoc():LatLng
		{
			return circleLoc;
		}
		
		public function isCircleShowing():Boolean
		{
			return circleShowing;
		}
		
		/**
		 * Draws a circle with a 100 mile diameter at the specified location
		 * called from hundredMilesClicked() within Leaf
		 * 
		 * @param	loc LatLng Google maps object
		 */
		public function drawCircle(loc:LatLng):void
		{
			clearCircle();
			
			circleLoc = loc;
			
			var d2r:Number = Math.PI/180;
			var r2d:Number = 180/Math.PI;
			var circleLat:Number = 50 * 0.014483;  // Convert statute miles into degrees latitude
			var circleLng:Number = circleLat / Math.cos(loc.lat() * d2r); 
			var circleLatLngs:Array = new Array();
			for (var i:Number = 0; i < 33; i++) { 
				var theta:Number = Math.PI * (i/16); 
				var vertexLat:Number = loc.lat() + (circleLat * Math.sin(theta)); 
				var vertexLng:Number = loc.lng() + (circleLng * Math.cos(theta)); 
				var latLng:LatLng = new LatLng(vertexLat, vertexLng); 
				circleLatLngs.push(latLng); 
			}
		  
			var polygonOptions:PolygonOptions = new PolygonOptions();
			var fillStyle:FillStyle = new FillStyle();
			fillStyle.alpha = 0;
			//fillStyle.color = fillColor;
			polygonOptions.fillStyle = fillStyle; 
			
			var strokeStyle:StrokeStyle = new StrokeStyle();
			strokeStyle.alpha = 1;
			strokeStyle.color = 0x00457C;
			strokeStyle.thickness = 2;
			polygonOptions.strokeStyle = strokeStyle;
			
			polygon = new Polygon(circleLatLngs, polygonOptions);
			map.addOverlay(polygon);
			
			circleShowing = true;
		}

	}
	
}