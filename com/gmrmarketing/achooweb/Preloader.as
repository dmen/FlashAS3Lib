package com.gmrmarketing.achooweb	
{	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
    import flash.net.URLRequest;
	
	public class Preloader extends MovieClip
	{
		 private var loader:Loader;
		 private var globals:MyGlobals;
		 
		 public function Preloader()
		 {		
			bar.scaleX = 0;
			
			globals = MyGlobals.getInstance(); //instantiate the globals singleton
			//hsurl is a FlashVar - save it in globals so HighScoreManager can access it
			globals.setXMLURL(this.loaderInfo.parameters.hsurl);
			
            loader = new Loader();
			loader.load(new URLRequest("achoo_web.swf"));
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, updateProgress);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
		 }
		 
		 private function updateProgress(e:ProgressEvent)
		 {			
			bar.scaleX = e.bytesLoaded / e.bytesTotal;
		 }
		 
		 
		 private function loaderComplete(e:Event)
		 {
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, updateProgress);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderComplete);
			addChild(loader);
		 }
	}	
}