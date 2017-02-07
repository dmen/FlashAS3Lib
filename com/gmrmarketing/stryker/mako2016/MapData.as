package com.gmrmarketing.stryker.mako2016
{
	import flash.net.*;

	public class MapData
	{
		//this kiosks position on the map - set in config dialog
		private var kioskPosition; //A - H
		
		public function MapData()
		{
			var so:SharedObject = SharedObject.getLocal("strykerData");
			kioskPosition = so.data.kioskPosition;
			if (kioskPosition == null){
				kioskPosition = "A";				
			}
		}
	}
	
}