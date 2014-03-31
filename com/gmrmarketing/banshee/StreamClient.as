package com.gmrmarketing.banshee
{	
	import flash.events.EventDispatcher;

	public class StreamClient extends EventDispatcher
	{
		public function StreamClient() { }
		
		public function onCuePoint(info:Object):void
		{
			trace("onCuePoint:", info.name, info.parameters, info.time, info.type);
		}
		
		public function onImageData(info:Object):void 
		{
			trace("onImageData:");
		}
		
		public function onMetaData(info:Object):void
		{
			trace("onMetaData:", info.duration, info.framerate);
		}
		
		public function onPlayStatus(info:Object):void
		{
			trace("onPlayStatus:", info.code);
		}
		
		public function onTextData(info:Object):void
		{
			trace("onTextData:");
		}
		
		public function onXMPData(info:Object):void
		{
			trace("onXMPData");
		}
	}
	
}