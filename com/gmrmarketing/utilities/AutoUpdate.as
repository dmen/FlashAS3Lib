/**
 * AIR AutoUpdate Framework wrapper
 * 
 * Requires mcAutoUpdate movieClip in the library
 * 
 * 
 * 
 */
package com.gmrmarketing.utilities
{
	import air.update.ApplicationUpdater;
	import air.update.events.*;
	import flash.events.*;
	import flash.display.*;
	
	public class AutoUpdate extends EventDispatcher
	{
		public static const UPDATE_ERROR:String = "autoUpdateError";
		
		private var appUpdater:ApplicationUpdater;
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var lastError:String;
	
		
		public function AutoUpdate() 
		{
			appUpdater = new ApplicationUpdater();
			lastError = "";
			
			clip = new mcAutoUpdate();
			clip.x = 552;
			clip.y = 312;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function get error():String
		{
			return lastError;
		}
		
		/**
		 * Initializes the framework
		 * 
		 * @param	url The URL of the updater descriptor xml file
		 */
		public function init(url:String):void
		{
			appUpdater.updateURL = url;
			
			appUpdater.addEventListener(UpdateEvent.INITIALIZED, onUpdate, false, 0, true);
			appUpdater.addEventListener(ErrorEvent.ERROR, onError, false, 0, true);
			   
			appUpdater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, statusUpdate);
			appUpdater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, statusUpdateError);
			
			appUpdater.initialize();
		}
		
		
		/**
		 * Called once appUpdated has been initialized and is ready
		 * Checks the updateURL for the descriptor file
		 * @param	e
		 */
		private function onUpdate(e:Event):void
		{
			appUpdater.checkNow();
		}
		
		
		private function onError(e:ErrorEvent):void
		{
			lastError = "Error initializing framework: " + e.toString();
			dispatchEvent(new Event(UPDATE_ERROR));
		}
		
		
		/**
		 * Called after the descriptor was downloaded and interpreted successfuly 
		 * @param	e
		 */
		private function statusUpdate(e:StatusUpdateEvent):void {
			
			//prevent the default, which is to start downloading the new version
			e.preventDefault();			
			
			if (e.available) {
				
				clip.infoText.text = e.details[0][1];//description in XML
				
				clip.btn1.theText.text = "cancel";
				clip.btn2.theText.text = "update";
				clip.btn2.alpha = 1;
				clip.btn1.addEventListener(MouseEvent.MOUSE_DOWN, closeUpdater, false, 0, true);
				clip.btn2.addEventListener(MouseEvent.MOUSE_DOWN, startDownload, false, 0, true);
				clip.progBar.bar.scaleX = 0;
				
				if (myContainer) {
					if (!myContainer.contains(clip)) {
						myContainer.addChild(clip);
					}
				}
			}else {
				lastError = "No update";
				dispatchEvent(new Event(UPDATE_ERROR));
			}
		}
		
		
		private function statusUpdateError(e:StatusUpdateErrorEvent):void
		{
			lastError = "Status Update Error\n" + e;
			clip.infoText.text = lastError;
			dispatchEvent(new Event(UPDATE_ERROR));
		}
		
		
		private function closeUpdater(e:MouseEvent = null):void
		{
			clip.btn1.removeEventListener(MouseEvent.MOUSE_DOWN, closeUpdater);
			clip.btn2.removeEventListener(MouseEvent.MOUSE_DOWN, startDownload);	
			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
		}
		
		
		private function startDownload(e:MouseEvent):void
		{
			clip.btn1.removeEventListener(MouseEvent.MOUSE_DOWN, closeUpdater);
			clip.btn1.addEventListener(MouseEvent.MOUSE_DOWN, cancelUpdate, false, 0, true);
			clip.btn2.alpha = .4;
			clip.btn2.removeEventListener(MouseEvent.MOUSE_DOWN, startDownload);
			
			appUpdater.addEventListener(ProgressEvent.PROGRESS, downloadProgress);		   
			appUpdater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, downloadComplete);
			appUpdater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, downloadError);
			
			appUpdater.downloadUpdate();
		}
		
		
		private function cancelUpdate(e:MouseEvent):void
		{
			appUpdater.cancelUpdate();
			clip.infoText.text = "Update cancelled by user";
			clip.btn1.removeEventListener(MouseEvent.MOUSE_DOWN, cancelUpdate);
			clip.btn1.addEventListener(MouseEvent.MOUSE_DOWN, closeUpdater, false, 0, true);
		}

		
		private function downloadProgress(e:ProgressEvent):void
		{
			clip.progBar.bar.scaleX = e.bytesLoaded / e.bytesTotal;
		}
		
		
		/**
		 * just close the window; 
		 * the downloaded version will be automatically installed, and then the application gets restarted
		 * @param	e
		 */
		private function downloadComplete(e:UpdateEvent):void
		{
			closeUpdater();
		}
		
		
		private function downloadError(e:DownloadErrorEvent):void
		{
			lastError = "Download Error:\n" + e;
			clip.infoText.text = lastError;
			dispatchEvent(new Event(UPDATE_ERROR));
		}
   

	}
	
}