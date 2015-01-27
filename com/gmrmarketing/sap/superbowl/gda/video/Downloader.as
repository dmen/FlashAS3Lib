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
		private var lastFileName:String;//name of last loaded video - used to the same video isn't loaded twice
		private var checkTimer:Timer;
		private var refreshTime:int;//number of minutes between calls
		private var so:SharedObject;
		
		public function Downloader()
		{
			so = SharedObject.getLocal("downloaderTime");
			if (so.data.time == null) {
				so.data.time = "5";
			}
			numSet.text = so.data.time;
			
			lastFileName = "";
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
		 * @param	e
		 */
		private function getLatestVideo():void
		{
			status.text = "calling service";
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("https://sapsuperbowl49service.thesocialtab.net/api/video?count=1&onlySocial=true");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}		
		
		
		/**
		 * callback from service
		 * begins loading the video
		 * @param	e
		 */
		private function dataLoaded(e:Event = null):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);
			if(j.Videos.length > 0){
				var vidURL:String = j.Videos[0].VideoPath;
				if (vidURL != lastFileName) {
					status.text = "downloading latest video...";
					lastFileName = vidURL;
					urlReq = new URLRequest(vidURL);
					urlStream = new URLStream();
					fileData = new ByteArray();
					urlStream.addEventListener(Event.COMPLETE, loaded);
					urlStream.addEventListener(ProgressEvent.PROGRESS, dlProgress);
					urlStream.load(urlReq);
				}else {					
					status.text = "video already downloaded. waiting";
					min.text = String(refreshTime);
					checkTimer.start();
				}
			}else {
				status.text = "service returned empty. waiting";
				min.text = String(refreshTime);
				checkTimer.start();
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void	
		{
			status.text = "error calling service";
			min.text = String(refreshTime);
			checkTimer.start();
		}
		
		
		private function loaded(event:Event):void
		{
			urlStream.readBytes(fileData, 0, urlStream.bytesAvailable);
			urlStream.removeEventListener(Event.COMPLETE, loaded);
			urlStream.removeEventListener(ProgressEvent.PROGRESS, dlProgress);
			
			status.text = "complete. waiting...";
			min.text = String(refreshTime);
			checkTimer.start();
			
			var fName:String = GUID.create();
			//var file:File = File.userDirectory.resolvePath(fName + ".mp4");
			var file:File =new File("c:\\gdaplayer\\" + fName + ".mp4");
			//var file:File = File.applicationStorageDirectory.resolvePath("vid.mp4");
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(fileData, 0, fileData.length);
			fileStream.close();
		}
		
		
		private function dlProgress(e:ProgressEvent):void
		{
			fileInfo.text = e.bytesLoaded + " of " + e.bytesTotal;
			progBar.scaleX = e.bytesLoaded / e.bytesTotal;
		}
		
	}
	
}