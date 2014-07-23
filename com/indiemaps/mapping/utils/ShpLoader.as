package com.indiemaps.mapping.utils
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	
	import org.vanrijkom.shp.ShpHeader;
	import org.vanrijkom.shp.ShpTools;	
	
	public class ShpLoader extends EventDispatcher
	{
		public var shpRecords:Array;
		public var shpHeader:ShpHeader;
		public static const DATA_LOADED:String = "dataLoaded";
		
		public function ShpLoader(shpLocation:String)
		{
			loadShapefile(shpLocation);
		}
		
		protected function loadShapefile(location:String):void 
		{
			var dataLoader:URLLoader = new URLLoader();
			dataLoader.dataFormat = URLLoaderDataFormat.BINARY;
			dataLoader.load(new URLRequest(location) );
			dataLoader.addEventListener(Event.COMPLETE, processShapefileData);
		}
		
		protected function processShapefileData(e:Event):void 
		{
			shpHeader = new ShpHeader(e.target.data); //necessary to move beyond the header
			shpRecords = ShpTools.readRecords(e.target.data);
			dispatchEvent(new Event(ShpLoader.DATA_LOADED, false));
		}	

	}
}