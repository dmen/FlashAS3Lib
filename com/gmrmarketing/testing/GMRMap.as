package com.gmrmarketing.testing
{
	import flash.display.MovieClip;
	import flash.sensors.Geolocation;
	import flash.events.GeolocationEvent;	
	
	public class GMRMap extends MovieClip
	{
		private var geo:Geolocation;
		
		public function GMRMap() 
		{			
			if (Geolocation.isSupported) { 
				geo = new Geolocation(); 
				if (! geo.muted) {
					
					//up the interval to conserve battery life...
					geo.setRequestedUpdateInterval(5000);
					
					geo.addEventListener(GeolocationEvent.UPDATE, geolocationUpdateHandler);
				}
			}
		}
		
		
		/**
		 * Event properties:
		 * latitude, longitude, altitude, horizontalAccuracy, verticalAccuracy, speed, timestamp, heading properties
		 * 
		 * @param	event
		 */
		private function geolocationUpdateHandler(event:GeolocationEvent):void 
		{
			geoLat.text = "Latitude: " + event.latitude.toString(); 
			geoLong.text = "Longitude: " + event.longitude.toString(); 
			geoAccu.text = "Accuracy: " + event.horizontalAccuracy.toString(); 
			geoSpeed.text = "Speed: " + event.speed.toString();
			geoHeading.text = "Speed: " + event.heading.toString(); 
		}
		
	}
	
}