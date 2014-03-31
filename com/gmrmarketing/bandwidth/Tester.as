package com.gmrmarketing.bandwidth
{
	import flash.display.LoaderInfo; //for flashvars
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLStream;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import com.dynamicflash.util.Base64;
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;


	public class Tester extends MovieClip
	{
		private var loader:Loader;
		private var uploader:URLLoader;
		private var startTime:Number;
		private var totalBytes:Number;
		
		private var updatePeriod:Number;
		private var curTime:Number;
		
		private var ulImage:BitmapData;
		
		private var dlURL:String;
		
		private const SERVICE_URL:String = "http://infocenter/bandwidth/upload.aspx";		
		
		private var streamTimer:Timer;
		private var ulBytes:int;
		
		
		
		public function Tester()
		{			
			dlURL = loaderInfo.parameters.dlurl;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, downloadComplete, false, 0, true);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, downloading, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);	
			
			uploader = new URLLoader();
			uploader.addEventListener(Event.COMPLETE, imageUploaded, false, 0, true);
			uploader.addEventListener(IOErrorEvent.IO_ERROR, uploadError, false, 0, true);
			//uploader.addEventListener(ProgressEvent.PROGRESS, uploading, false, 0, true);			

			btnBegin.addEventListener(MouseEvent.CLICK, beginDownload, false, 0, true);
			
			mask1.scaleX = 0;
			maskz.scaleX = 0;
		}
		
		
		
		private function beginDownload(e:MouseEvent):void
		{
			startTime = getTimer();
			//loader.load(new URLRequest("http://design.gmrmarketing.com/bandwidth/dl.jpg?r=" + String(getTimer())));
			//loader.load(new URLRequest("http://dbingdev.radweblive.com/dl.jpg?r=" + String(getTimer())));
			loader.load(new URLRequest(dlURL + "?r=" + String(getTimer())));
			
			mask1.scaleX = 0;
			maskz.scaleX = 0;
			
			updatePeriod = 0;
			theSize.text = "bytes: 0";
			theTime.text = "time: 0.00";
			ulTime.text = "time: 0.00";
			current.text = "Current Mbps: 0";
			finalDL.text = "Download Mbps: 0";
			finalUP.text = "Upload Mbps: 0";
			ulSize.text = "ul bytes: 0";
			
			status.text = "-downloading-";
		}
		
		
		
		private function downloading(e:ProgressEvent):void
		{
			curTime = getTimer();
			
			totalBytes = e.bytesTotal;
			theSize.text = "tot bytes: " + String(totalBytes);
			var loaded:Number = e.bytesLoaded;
			theBytes.text = "cur bytes: " + String(loaded);
			
			var percentDownloaded:Number = loaded / totalBytes;
			mask1.scaleX = percentDownloaded;
			
			var elapsed:Number = (getTimer() - startTime) / 1000; //elapsed seconds
			var t:String = String(elapsed);
			var tind:int = t.indexOf(".");
			theTime.text = "time: " + t.substring(0, tind + 3);
			
			var curMbps:String = String(((loaded  * 8) / 1048576) / elapsed);
			var disp:int = curMbps.indexOf(".");
			
			current.text = "Current Mbps: " + curMbps.substring(0, disp + 3);
		}
		
		
		
		private function downloadComplete(e:Event):void
		{
			var elapsed:Number = (getTimer() - startTime) / 1000; //elapsed seconds			
			
			theTime.text = "time: " + elapsed;
			
			var megabits:Number = (totalBytes * 8) / 1048576; // 1024 x 1024 = 1048576
			
			var avgMbps:String = String(megabits / elapsed);
			var disp:int = avgMbps.indexOf(".");
			finalDL.text = "Download Mbps: " + avgMbps.substring(0, disp + 3);
			
			beginUpload();
		}
		
		
		
		private function ioErrorHandler(e:IOErrorEvent):void {
			status.text = "-dl error-";
        }

		
		
		
		private function beginUpload():void
		{
			var bmd:BitmapData = new uploadImage(1000, 1000);
			var ba:ByteArray = getJpeg(bmd);
			ulBytes = ba.length;
			
			ulSize.text = "ul bytes: " + String(ulBytes);
			var b64:String = getBase64(ba);
			status.text = "uploading...";
			
			streamTimer = new Timer(100);
			streamTimer.addEventListener(TimerEvent.TIMER, uploading, false, 0, true);
			streamTimer.start();
			
			postImage(b64);
		}
		
		
		
		/**
		 * Returns a ByteArray from the jpegEncoder of the passed in bitmapData object
		 * @param	bmpd
		 * @param	q - JPEG Quality
		 * @return
		 */
		public function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			//var encoder:PNGEncoder = new PNGEncoder();
			//var encoder:JPGEncoder = new JPGEncoder(q);
			//var ba:ByteArray = encoder.encode(bmpd);
			var ba:ByteArray = PNGEncoder.encode(bmpd);
			return ba;
		}
		
		
		
		private function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		
		
		/**
		 * Posts to the service
		 * @param	encoded Base64 encoded ByteArray - JPEG
		 */
		public function postImage(encoded:String):void
		{
			startTime = getTimer();
			
			var request:URLRequest = new URLRequest(SERVICE_URL + "?r=" + String(getTimer()));
			
			uploader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			var variables:URLVariables = new URLVariables();			
			variables.imageData = encoded;
			
			request.data = variables;
			request.method = URLRequestMethod.POST;
			
			uploader.load(request);		
		}

		
		
		private function uploading(e:TimerEvent):void
		{			
			//trace(uploader.bytesLoaded);
			//var percentDownloaded:Number = uploader.bytesLoaded / uploader.bytesTotal;
			maskz.scaleX = 1 / streamTimer.currentCount;
			//currentUP.text = String(uploader.bytesLoaded);
			
			var elapsed:Number = (getTimer() - startTime) / 1000; //elapsed seconds
			var t:String = String(elapsed);
			var tind:int = t.indexOf(".");
			ulTime.text = "time: " + t.substring(0, tind + 3);
		}
		
		
		
		private function imageUploaded(e:Event):void
		{
			status.text = "complete";
			maskz.scaleX = 1;
			
			streamTimer.reset();
			
			var elapsed:Number = (getTimer() - startTime) / 1000; //elapsed seconds
			var t:String = String(elapsed);
			var tind:int = t.indexOf(".");
			ulTime.text = "time: " + t.substring(0, tind + 3);
			
			var megabits:Number = (ulBytes * 8) / 1048576; // 1024 x 1024 = 1048576
			
			var avgMbps:String = String(megabits / elapsed);
			var disp:int = avgMbps.indexOf(".");
			finalUP.text = "Upload Mbps: " + avgMbps.substring(0, disp + 3);
		}
		
		
			
		private function uploadError(e:IOErrorEvent):void {
            status.text = "-ul error-";
        }
	}
	
}