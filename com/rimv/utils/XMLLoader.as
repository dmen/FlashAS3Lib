package com.rimv.utils
{
	
	/**
	 * 
	 * @author RimV - XML Loader Class
	 */
	
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import com.rimv.utils.XMLLoaderEvent;
	
	public class XMLLoader extends EventDispatcher
	{
		
		private var xmlLoader:URLLoader;
		
		// Constructor
		public function XMLLoader()
		{
			xmlLoader = new URLLoader();
		}
		
		//__________________________________________________________ LOAD XML
		
		public function load(xmlPath:String):void		{
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded);
			xmlLoader.load(new URLRequest(xmlPath));
		}
		
		private function xmlLoaded(e:Event):void
		{
			//return data
			dispatchEvent(new XMLLoaderEvent(XMLLoaderEvent.LOADED, new XML(e.target.data)));
		}
	}
	
}