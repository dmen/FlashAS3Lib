/**
 * Loads and parses chargingStations.xml
 * creates a marker on the map for each station in the XML
 * 
 * Markers are shown or hidden from the showMarkers() method
 * which is called anytime the map is changed - ie zoomed or panned
 */

package com.gmrmarketing.nissan
{	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import flash.display.DisplayObjectContainer;
	import flash.events.*;	
	import com.gmrmarketing.utilities.XMLLoader;
	import com.google.maps.Map;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	
	//mac version only with inlined xml
	import com.gmrmarketing.nissan.RechargeXML;
	
	public class RechargingStations
	{
		private var map:Map;
		private var xmlLoader:XMLLoader;
		private var stationList:XMLList;
		private var markers:Array;
		private var numStations:int;
		private var forWeb:Boolean;
		
		private var container:DisplayObjectContainer;		
		
		/**
		 * CONSTRUCTOR
		 * @param	$map Google Map object reference
		 * @param	$forWeb Boolean - if true turns on hand cursor and tooltips for stations
		 */
		public function RechargingStations($map:Map, $forWeb:Boolean = false)
		{
			map = $map;
			markers = new Array();			
			forWeb = $forWeb;			
			
			xmlLoader = new XMLLoader();
			xmlLoader.load("chargingStations.xml");
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			//xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlError, false, 0, true);
			
			/*
			//mac version - use the inlined xml
			var stations:RechargeXML = new RechargeXML();
			var b:XML = stations.getXML();
			stationList = b.item;
			numStations = stationList.length();
			*/
			
			addMarkers();
		}
		
		
		
		/**
		 * Creates the stationList XMLList which contains all the item nodes in the xml
		 * @param	e
		 */		
		private function xmlLoaded(e:Event):void
		{			
			var b:XML = xmlLoader.getXML();
			stationList = b.item;
			numStations = stationList.length();
			
			addMarkers();
		}
		
		
		/**
		 * Station list not found... do nothing
		 * @param	e
		 */		
		private function xmlError(e:IOErrorEvent):void
		{			
			//alert.show(e.toString());
		}
		
		
		/**
		 * Called from xmlLoaded()
		 * Creates a new marker for each charging station in the stationList XMLList
		 * adds each marker to the map - but invisible at first
		 * Marker visibility is handled by showMarkers()
		 * 
		 * Calls showMarkers() in case any markers are present in the initial map view
		 */
		private function addMarkers():void
		{
			for (var i:int = 0; i < numStations; i++){
				var ic:MovieClip = new chargingIcon(); //library clip				
				var markerOptions:MarkerOptions = new MarkerOptions( { icon:ic, iconOffset:new Point(-13, -34), draggable:false, hasShadow:false} );
				
				if(forWeb){
					markerOptions.clickable = true; //show hand cursor and tooltips on web
					markerOptions.tooltip = stationList[i].name + "\n" + stationList[i].address;
				}else {
					markerOptions.clickable = false; //no hand cursor or tooltips on kiosk version
				}
				
				var marker:Marker = new Marker(new LatLng(stationList[i].lat, stationList[i].lng), markerOptions);
				
				markers.push(marker);
				marker.visible = false;
				map.addOverlay(marker);				
			}
			
			showMarkers();
		}
		
		
		
		/**
		 * Called from Leaf.mapViewChanged() whenever the map is dragged or the zoom buttons are clicked
		 * and Leaf.wheelZoom() whenever the mouse wheel is used to change the zoom 
		 * 
		 * Shows any markers in the current map viewport and hides the others
		 */
		public function showMarkers():void
		{
			//get latLngBounds for current viewport
			var bounds:LatLngBounds = map.getLatLngBounds();
			
			for (var i:int = 0; i < numStations; i++) {
				var m:Marker = Marker(markers[i]);
				if(bounds.containsLatLng(m.getLatLng())){
					m.visible = true;
				}else {
					m.visible = false;
				}
			}
		}
		
	}
	
}