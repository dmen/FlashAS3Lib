package com.gmrmarketing.googlemaps
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.google.maps.services.ClientGeocoder;
	import com.google.maps.services.GeocodingEvent;
	import com.google.maps.services.GeocodingResponse;
	import com.google.maps.services.Placemark;

	
	public class GeoCoder extends EventDispatcher
	{
		public static const LOC_COMPLETE:String = "GeoCoderLocationFound";
		public static const LOC_FAILED:String = "GeoCoderLocationNotFound";	
		
		private var lat:Number = -1;
		private var lng:Number = -1;
		private var geo:ClientGeocoder;		

		
		public function GeoCoder()
		{		
			geo = new ClientGeocoder();
			geo.addEventListener(GeocodingEvent.GEOCODING_SUCCESS, geoSuccess, false, 0, true);
			geo.addEventListener(GeocodingEvent.GEOCODING_FAILURE, geoFail, false, 0, true);
		}		
		
		public function getGeoCode(address:String):void
		{			
			geo.geocode(address);			
		}
		
		public function getLat():Number
		{
			return lat
		}		
		
		public function getLng():Number
		{
			return lng;
		}
		
		private function geoSuccess(e:GeocodingEvent):void
		{			
			var result:GeocodingResponse = e.response as GeocodingResponse;
			var pm:Placemark = result.placemarks[0] as Placemark;
	 		lat = pm.point.lat();
			lng = pm.point.lng();

			dispatchEvent(new Event(LOC_COMPLETE));
		}
		
		private function geoFail(e:GeocodingEvent):void
		{
			lat = -1;
			lng = -1;
			dispatchEvent(new Event(LOC_FAILED));
		}
	}	
}