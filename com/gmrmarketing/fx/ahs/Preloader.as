package com.gmrmarketing.fx.ahs
{
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.display.LoaderInfo;

	public class Preloader extends MovieClip
	{
		private var formURL:String = loaderInfo.parameters.formurl;
		private var postURL:String = loaderInfo.parameters.posturl;
		private var id:String = loaderInfo.parameters.id;

		private var l:Loader
		
		public function Preloader()
		{
			prog.bar.scaleX = 0;
			
			l = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, doneLoading, false, 0, true);
			l.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, updateProgress, false, 0, true);
			l.load(new URLRequest("vtest.swf"));
		}

		private function doneLoading(e:Event):void
		{
			l.removeEventListener(Event.COMPLETE, doneLoading);
			l.removeEventListener(ProgressEvent.PROGRESS, updateProgress);
			removeChild(prog);
			prog = null;
			addChild(l);
			MovieClip(l.content).init(formURL, postURL, id);
		}
		
		private function updateProgress(e:ProgressEvent):void
		{
			prog.bar.scaleX = e.bytesLoaded / e.bytesTotal;
		}
	}
	
}