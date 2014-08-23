package com.gmrmarketing.sap.levisstadium.gallery
{
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.net.*;
	import flash.utils.Timer;
	
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const READY:String = "ready";
		
		private var imageURLs:Array; //array of url's -- all 50 returned by the service
		private var images:Array;//array of bitmapData objects - eight of them
		private var localCache:Array; //array of bitmapData for use when net is down or errors
		private var loadingIndex:int;
		
		private var displayIndex:int //index in images of last one on screen
		private var displayCheck:Timer;
		private var displayLocs:Array; //screen positions where avatars go
		private var avatarContainer:Sprite;
		
		private var notReadyCount:int;
		
		
		public function Main()
		{
			localCache = new Array();
			displayCheck = new Timer(500);
			avatarContainer = new Sprite();
			displayLocs = new Array([126, 158], [297, 158], [469, 158], [642, 158], [126, 335], [297, 335], [469, 335], [642, 335]);
			addChildAt(avatarContainer, 0);
			//init();
		}
		
		
		/**
		 * IScheduler Method
		 */
		public function init(initValue:String = ""):void
		{
			images = new Array();
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/registrant/getavatars?abc=" + String(new Date().valueOf()));
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			l.load(r);
		}
		
		
		private function dataLoaded(e:Event):void
		{					
			var json:Object = JSON.parse(e.currentTarget.data);			
			
			imageURLs = new Array();
			
			for (var i:int = 0; i < json.length; i++) {
				imageURLs.push( { url:json[i].ImageUrl } );
			}
			
			loadingIndex = 0;
			loadNextImage();
			//show();
			dispatchEvent(new Event(READY));//will cause show() to be called
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			if (localCache.length > 0) {//if there's any there's probably eight
				images = localCache.concat();
				dispatchEvent(new Event(READY));//will cause show() to be called
			}
		}
		
		
		private function loadNextImage():void
		{
			var a:Loader = new Loader();
			a.load(new URLRequest(imageURLs[loadingIndex].url));
			a.contentLoaderInfo.addEventListener(Event.COMPLETE, smoothIt);
		}
		
		
		private function smoothIt(e:Event):void
		{
			var n:BitmapData = new BitmapData(150, 176, false, 0x000000);
			var l:Bitmap = Bitmap(e.target.content);
			
			var m:Matrix = new Matrix();
			m.scale(150 / l.width, 176 / l.height);
			
			n.draw(l, m, null, null, null, true);
			
			images.push(n);
			localCache.push(n);
			
			//prune local cache to 8 most recent
			if (localCache.length > 8) {
				localCache.shift();
			}
			
			loadingIndex++;
			if (loadingIndex < 8) {
				loadNextImage();				
			}
		}
		
		
		/**
		 * IScheduler Method
		 * called once READY has been dispatched
		 * which is when the json has loaded - not necessarily
		 * when any images have loaded
		 */
		public function show():void
		{
			displayIndex = 0;
			notReadyCount = 0;
			displayCheck.addEventListener(TimerEvent.TIMER, isImageReady, false, 0, true);
			displayCheck.start();//call isImageReady every 1 sec
		}
		
		
		private function isImageReady(e:TimerEvent):void
		{
			if (images[displayIndex]) {
				var a:Avatar = new Avatar(avatarContainer, images[displayIndex], displayLocs[displayIndex]);
				displayIndex++;
				if (displayIndex > 7) {
					displayCheck.reset();
					displayCheck.removeEventListener(TimerEvent.TIMER, isImageReady);
				}
			}else {
				notReadyCount++;
				if (notReadyCount > 5) {
					//waited 5 seconds on this image... stop trying
					displayCheck.reset();
					displayCheck.removeEventListener(TimerEvent.TIMER, isImageReady);
				}
			}
		}
		
		/**
		 * IScheduler Method
		 */
		public function hide():void
		{
			
		}
		
		
		/**
		 * IScheduler Method
		 */
		public function doStop():void
		{
			displayCheck.reset();
			displayCheck.removeEventListener(TimerEvent.TIMER, isImageReady);
		}
		
		
		/**
		 * IScheduler Method
		 */
		public function kill():void
		{
			while (avatarContainer.numChildren) {
				avatarContainer.removeChildAt(0);
			}
		}
	}
	
}