package com.gmrmarketing.sap.metlife.overview
{
	import com.gmrmarketing.sap.metlife.ISchedulerMethods;
	import flash.display.*;
	import flash.events.*;
	import fl.video.*;
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const FINISHED:String = "finished";
		
		
		public function Main(){}
		
		
		public function init(initValue:String = ""):void
		{
			theVideo.addEventListener(MetadataEvent.CUE_POINT, done);
		}
		
		
		public function getFlareList():Array
		{
			var fl:Array = new Array();			
			return fl;
		}
		
		public function isReady():Boolean
		{
			return true;
		}
		
		
		public function show():void
		{
			theVideo.play();
		}
		
		
		public function cleanup():void
		{
			theVideo.seek(0);
			theVideo.stop();
		}
		
		
		private function done(e:MetadataEvent):void
		{			
			dispatchEvent(new Event(FINISHED));
		}
	}
	
}