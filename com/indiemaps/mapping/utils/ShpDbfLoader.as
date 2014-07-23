package com.indiemaps.mapping.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import org.vanrijkom.dbf.DbfHeader;
	import org.vanrijkom.dbf.DbfTools;
	import org.vanrijkom.shp.ShpHeader;
	import org.vanrijkom.shp.ShpTools;
	
	
	/**
	 * Loads a shapefile/dbf combo using Edwin Van Rijkom's SHP and DBF classes.
	 * Dispatches 'dataLoaded' event when complete.
	 * 
	 */
	public class ShpDbfLoader extends EventDispatcher
	{
		protected var dbfLoaded:Boolean = false;
		protected var shpLoaded:Boolean = false;
		
		protected var dbfData:ByteArray;
		
		public var dbfRecords:Array;
		public var shpRecords:Array;
		public var shpHeader:ShpHeader;
		public var dbfHeader:DbfHeader;
		
		public static const DATA_LOADED:String = "dataLoaded";
		
		public function ShpDbfLoader(shpLocation:String)//, dbfLocation:String)
		{
			loadShapefile(shpLocation, processShapefileData);
			//loadDBF(dbfLocation, processDBFData);
		}
		
		protected function loadShapefile(location:String, handlerFunction:Function):void {
			var dataLoader:URLLoader = new URLLoader();
			dataLoader.dataFormat = URLLoaderDataFormat.BINARY;
			dataLoader.load(new URLRequest(location) );
			dataLoader.addEventListener(Event.COMPLETE, handlerFunction);
		}
		
		protected function processShapefileData(e:Event):void {
			shpHeader = new ShpHeader(e.target.data); //necessary to move beyond the header
			shpRecords = ShpTools.readRecords(e.target.data);
			shpLoaded = true;
			//if (dbfLoaded) {
				onBothLoaded();
			//}
		}
		
		/*
		protected function loadDBF(location:String, handlerFunction:Function):void {
			var dataLoader:URLLoader = new URLLoader();
			dataLoader.dataFormat = URLLoaderDataFormat.BINARY;
      		dataLoader.load(new URLRequest(location));
      		dataLoader.addEventListener(Event.COMPLETE, handlerFunction);
		}
		
		protected function processDBFData(e:Event):void {
			dbfData = e.target.data;
			dbfHeader = new DbfHeader(dbfData);
			dbfLoaded = true;
      		if (shpLoaded) {
      			onBothLoaded();
      		}
		}
		*/
		
		protected function onBothLoaded():void {
			//getDbfRecords();
			dispatchEvent(new Event(ShpDbfLoader.DATA_LOADED, false));	
		}
		
		protected function getDbfRecords():void {
			dbfRecords = [];
			for (var i:int=0; i<shpRecords.length; i++) {
				dbfRecords[i] = DbfTools.getRecord(dbfData, dbfHeader, i);
			}
		}

	}
}