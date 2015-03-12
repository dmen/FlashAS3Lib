package com.gmrmarketing.sap.superbowl.gda.video
{
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	import com.gmrmarketing.utilities.GUID;
	import flash.utils.Timer;
	
	
	public class Downloader extends MovieClip
	{
		private var urlStream:URLStream;
		private var urlReq:URLRequest;
		private var fileData:ByteArray;
		
		private var checkTimer:Timer;
		private var refreshTime:int;//number of minutes between calls
		private var so:SharedObject;
		
		private var pendingVideos:Array; //videos waiting to download
		private var curDownload:int; //index in videosQueued
		private var lastFileNames:Array;//names of last loaded video - used to the same video isn't loaded twice
		
		
		public function Downloader()
		{
			so = SharedObject.getLocal("downloaderTime");
			if (so.data.time == null) {
				so.data.time = "5";
			}
			numSet.text = so.data.time;
			
			pendingVideos = [];
			lastFileNames = [];
			
			btn.addEventListener(MouseEvent.CLICK, setTime);
			setTime();
		}
		
		
		private function setTime(e:MouseEvent = null):void
		{
			refreshTime = parseInt(numSet.text);
			
			so.data.time = numSet.text;
			so.flush();
			
			checkTimer = new Timer(60000, refreshTime);
			checkTimer.addEventListener(TimerEvent.TIMER, checkTime);
			checkTimer.start();
			
			getLatestVideo();
		}
		
		
		private function checkTime(e:TimerEvent):void
		{
			var r:int = checkTimer.currentCount;
			min.text = String(refreshTime - r);
			if (r == refreshTime) {
				checkTimer.reset();
				getLatestVideo();
			}
		}
		
		
		/**
		 * called once initially from constructor and then every 10min by timer
		 * retrieves the list of files from the service
		 * @param	e
		 */
		private function getLatestVideo():void
		{
			if(pendingVideos.length == 0){
				status.text = "calling service";
				
				var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
				var r:URLRequest = new URLRequest("https://sapsuperbowl49service.thesocialtab.net/api/video?count=4&onlySocial=true");
				r.requestHeaders.push(hdr);
				var l:URLLoader = new URLLoader();
				l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
				l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
				try{
					l.load(r);
				}catch (e:Error) {
					
				}
			}else {
				status.text = "downloads in progress";
			}
		}	
		
		private function dataError(e:IOErrorEvent):void	
		{
			status.text = "error calling service";
			min.text = String(refreshTime);
			checkTimer.start();
		}
		
		/**
		 * callback from service
		 * begins loading the videos
		 * @param	e
		 */
		private function dataLoaded(e:Event = null):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);
			pendingVideos = j.Videos;
			
			if (pendingVideos.length > 0) {
				var p:int;
				var n:int = pendingVideos.length;
				for (var i:int = n - 1; i >= 0; i-- ) {
					p = lastFileNames.indexOf(pendingVideos[i].VideoPath);
					if (p != -1) {
						//already downloaded this file last time - remove from pendingVideos
						pendingVideos.splice(i, 1);
					}
				}
				
				curDownload = 0;
				if (pendingVideos.length > 0) {
					doNextDownload();
				}else {
					status.text = "latest videos downloaded - waiting";
					min.text = String(refreshTime);
					checkTimer.start();
				}
			}else {
				status.text = "service returned empty - waiting";
				min.text = String(refreshTime);
				checkTimer.start();
			}
		}
		
		
		private function doNextDownload():void
		{			
			var vidURL:String = pendingVideos[curDownload].VideoPath;
			
			status.text = "downloading video #" + String(curDownload + 1);
			lastFileNames.push(vidURL);
			
			urlReq = new URLRequest(vidURL);
			urlStream = new URLStream();
			fileData = new ByteArray();
			urlStream.addEventListener(Event.COMPLETE, fileLoaded);
			urlStream.addEventListener(ProgressEvent.PROGRESS, dlProgress);
			urlStream.load(urlReq);			
		}
		
		private function dlProgress(e:ProgressEvent):void
		{
			fileInfo.text = e.bytesLoaded + " of " + e.bytesTotal;
			progBar.scaleX = e.bytesLoaded / e.bytesTotal;
		}			
		
		
		private function fileLoaded(event:Event):void
		{
			urlStream.readBytes(fileData, 0, urlStream.bytesAvailable);
			urlStream.removeEventListener(Event.COMPLETE, fileLoaded);
			urlStream.removeEventListener(ProgressEvent.PROGRESS, dlProgress);
			
			var fName:String = pendingVideos[curDownload].VideoPath;
			fName = fName.substr(fName.lastIndexOf("/") + 1); 
			
			//var fName:String = GUID.create();
			//var file:File = File.userDirectory.resolvePath(fName + ".mp4");
			var file:File = new File("c:\\gdaplayer\\" + fName);
			
			//var file:File = File.applicationStorageDirectory.resolvePath("vid.mp4");
			var fileStream:FileStream = new FileStream();
			try{
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeBytes(fileData, 0, fileData.length);
				fileStream.close();
			}catch (e:Error) {
			
			}
			
			
			curDownload++;
			if (curDownload < pendingVideos.length) {
				doNextDownload();
			}else {
				pendingVideos = [];
				curDownload = 0;
				status.text = "complete. waiting...";
				min.text = String(refreshTime);
				checkTimer.start();//calls checkTime()
			}			
		}
		
		
		
	}
	
}