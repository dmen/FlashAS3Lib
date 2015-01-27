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
		private var theVideos:Array; //latest two videos from LatestFile
		private var vidIndex:int;
		private var whichSet:int;//1 or 2 set in init from config - plays either the first two of 4, or the second 2
		private var TESTING:Boolean = false;
		
		
		public function Main()
		{
			latest = new LatestFile();
			theVideos = [];
			latest.folder = "c:\\gdaplayer";
			refreshVideos();
			if (TESTING) {
				show();
			}
		}
		
		
		public function init(initValue:String = "1"):void
		{
			whichSet = parseInt(initValue);
			refreshVideos();
		}
		
		
		private function refreshVideos():void
		{
			theVideos = latest.getLatestFiles(4); //latest video file names
			if (theVideos.length == 0) {
				theVideos = [latest.latestFile];//make sure at least one video (default.mp4) is in the folder
			}
			if(whichSet == 1){
				vidIndex = 0;//0 and 1
			}else {
				vidIndex = 2;//2 and 3
			}
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
			video = new VideoLoader(theVideos[vidIndex], { width:550, height:310, x:45, y:117, autoPlay:true, container:this } );
			video.load();
			video.content.alpha = 0;
			
			video.playVideo();
			video.addEventListener(VideoLoader.VIDEO_COMPLETE, done);

			TweenMax.to(video.content, .5, { alpha:1 } );
		}
		
		
		private function done(e:Event):void
		{
			vidIndex++;
			if(whichSet == 1){
				if (vidIndex >= 2) {
					refreshVideos();
				}
			}else {
				if (vidIndex >= theVideos.length) {
					refreshVideos();
				}
			}
			video.removeEventListener(VideoLoader.VIDEO_COMPLETE, done);
			dispatchEvent(new Event(FINISHED));
		}
		
		
		public function cleanup():void
		{
			video.dispose(true);			
		}
	}
	
}