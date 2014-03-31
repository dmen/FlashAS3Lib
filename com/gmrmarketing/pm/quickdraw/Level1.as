package com.gmrmarketing.pm.quickdraw
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public class Level1 extends Sprite
	{
		public const COMPLETE:String = "L1IsComplete";
		public const CONTENT_LOADED:String = "L1IsLoaded";
		
		private var loader:Loader;		
		
		private var myClip:MovieClip;		
		private var targets:Array;
		
		
		public function Level1()
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, assignClip, false, 0, true);
			loader.load(new URLRequest("level1.swf"));
			addChild(loader);
		}
		
		
		private function assignClip(e:Event):void
		{
			myClip = MovieClip(loader.content);
			targets = new Array(myClip.tumbleweed);
			dispatchEvent(new Event(CONTENT_LOADED)); //engine listens
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, assignClip);			
		}				
		
		public function begin():void
		{			
		}
		
		public function getTargets():Array
		{
			return targets;
		}
	}	
}