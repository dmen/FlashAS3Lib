package com.rimv.utils
{
	
	/**
	 * 
	 * @author RimV
	 * XML Loader Event Class
	*/
	
	import flash.events.Event;
	
	public class XMLLoaderEvent extends Event
	{
		// Static event
		public static const LOADED:String = "loaded";
		
		// private property
		private var xmlData:XML;
		
		public function get xmlObjectData():XML
		{
			return xmlData;
		}
		
		public function XMLLoaderEvent(type:String, xmlData:XML)
		{
			super(type, true);
			this.xmlData = xmlData;
		}
		
		public override function clone():Event
		{
			return new XMLLoaderEvent(type, xmlData);
		}
	}
	
}