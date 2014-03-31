package com.gmrmarketing.esurance.sxsw_2014
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.filesystem.*;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	
	public class Slideshow extends EventDispatcher
	{
		private var clip:MovieClip;//lib clip
		private var container:DisplayObjectContainer;		
		private var nsVideo:NetStream;		
		private var nsAudio:NetStream;		
		
		private var file:File; //FMS folder containing videos
		private var vids:Array;
		private var currIndex:int; //current index in the vids array
		private var paused:Boolean;
		private var playAudio:Boolean = false;
		
		
		public function Slideshow()
		{
			clip = new mcSlideshow();			
		}		
		
		public function setAudio(s:String):void
		{
			if(s == "true"){
				playAudio = true;
			}else {
				playAudio = false;
			}
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
			file = new File();
			file.nativePath = "C:\\Program Files\\Adobe\\Flash Media Server 4.5\\applications\\esurance\\streams\\_definst_\\";
			currIndex = 0;
			checkFolder();//populate vids array
		}
		
		
		public function init(nc:NetConnection):void
		{
			nsVideo = new NetStream(nc);	
			nsVideo.bufferTime = 1;
			nsAudio = new NetStream(nc);
			nsVideo.bufferTime = 1;
			nsVideo.client = {onMetaData:metaDataHandler, onPlayStatus:statusHandler};
			nsAudio.client = { onMetaData:audioMetaDataHandler, onPlayStatus:audioStatusHandler };
			clip.vid.smoothing = true;
			clip.vid.attachNetStream(nsVideo);
			clip.audio.attachNetStream(nsAudio);
			paused = false;
		}
		
		
		/**
		 * Called by Main.clientMessage() when 'stop' is received
		 * also called initially from Main when FMS first becomes
		 * available
		 * @param	nc
		 */
		public function show():void
		{
			if(container){
				if (!container.contains(clip)) {					
					container.addChild(clip);
				}
			}			
			if (paused) {
				nsVideo.resume();
				if(playAudio){
					nsAudio.resume();
				}
			}else {
				if (vids.length > 0) {
					playVid();
				}else {
					checkFolder();
				}
			}
			paused = false;
		}
		
		
		/**
		 * Called by Main.clientMessage() when 'start' is received
		 */
		public function hide():void
		{
			if(container){
				if (container.contains(clip)) {					
					container.removeChild(clip);
				}
			}
			nsVideo.pause();
			if(playAudio){
				nsAudio.pause();
			}
			paused = true;
		}
		
		
		private function metaDataHandler(infoObject:Object):void 
		{
		}
		
		
		private function audioMetaDataHandler(infoObject:Object):void 
		{
		}
		
		
		private function statusHandler(infoObject:Object):void
		{
			var status:String = infoObject.code;
			if (status == "NetStream.Play.Complete") {
				currIndex++;
				if (currIndex >= vids.length) {
					currIndex = 0;
					checkFolder();
				}
				if(!paused){
					playVid();
				}
			}			
		}
		
		
		/**
		 * Plays the video - starts audio first then delays starting the
		 * video for .1 seconds, in order to help sync the two streams
		 */
		private function playVid():void
		{
			var n:String = vids[currIndex].name;
			var a:Array = n.split(".");	
			
			if(playAudio){
				nsAudio.play("mp4:" + a[0] + "_audio.f4v");
				TweenMax.delayedCall(1.4, startVideo, ["mp4:" + n]);
			}else{
				nsVideo.play("mp4:" + n);
			}
			//}else{				
								
						
				//		
			//}
		}
		
		
		private function startVideo(a:String):void
		{
			nsVideo.play(a);	
		}
		
		
		private function audioStatusHandler(infoObject:Object):void
		{
			
		}
		
		
		private function checkFolder():void
		{			
			vids = new Array();
			
			for each (var f:File in file.getDirectoryListing()) {
				if(!f.isDirectory){
					var fDate:Date = f.creationDate;					
					var ind:int = -1;
					for (var i:int = 0; i < vids.length; i++) {
						if(fDate > vids[i].creationDate){
							ind = i;
							break;
						}
					}
					if(f.name.indexOf("_audio") == -1 && f.name.indexOf("f4v") != -1){
						if(ind == -1){
							vids.push(f);
						}else{
							vids.splice(i,0,f);
						}
					}
				}
			}
		}
		
	}
	
}