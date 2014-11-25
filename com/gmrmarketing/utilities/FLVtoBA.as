package com.gmrmarketing.utilities
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	
	public class FLVtoBA extends EventDispatcher	
	{
		public static const VID_LOADED:String = "videoLoaded";
		private var loader:URLLoader;
		private var ba:ByteArray;
		
		public function FLVtoBA() { }
		
		public function loadVideo(vid:String):void
		{
			var req:URLRequest = new URLRequest(vid);
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, vidLoaded);
			loader.load(req);
		}
		
		private function vidLoaded(e:Event):void
		{
			ba = loader.data;
			dispatchEvent(new Event(VID_LOADED));
		}
		
		public function getVid():ByteArray
		{
			return ba;
		}
	}
	
}