package com.gmrmarketing.sap.superbowl.gda.video
{
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.loading.*;
	import com.greensock.loading.display.*;
	import com.greensock.*;
	import com.greensock.events.LoaderEvent;
	import com.gmrmarketing.utilities.LatestFile;
	
	
	public class Main extends MovieClip implements IModuleMethods
	{
		public static const FINISHED:String = "finished";
		private var video:VideoLoader;
		private var latest:LatestFile;
		private var TESTING:Boolean = false;
		
		
		public function Main()
		{
			latest = new LatestFile();
			latest.folder = "c:\\gdaplayer";
			if (TESTING) {
				show();
			}
		}
		
		
		public function init(initValue:String = ""):void
		{
			
		}
		
		
		/**
		 * Need to have a default video in c:\gdaplayer
		 * @return
		 */
		public function isReady():Boolean
		{
			return true;
		}		
		
		
		public function show():void
		{
			video = new VideoLoader(latest.latestFileName, { width:550, height:310, x:45, y:114, autoPlay:true, container:this } );
			video.load();
			video.content.alpha = 0;
			
			video.playVideo();
			video.addEventListener(VideoLoader.VIDEO_COMPLETE, done);

			TweenMax.to(video.content, .5, { alpha:1 } );
		}
		
		
		private function done(e:Event):void
		{
			video.removeEventListener(VideoLoader.VIDEO_COMPLETE, done);
			dispatchEvent(new Event(FINISHED));
		}
		
		
		public function cleanup():void
		{
			video.dispose(true);
		}
	}
	
}