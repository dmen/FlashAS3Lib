package com.gmrmarketing.goldenOne.cheerBooth2016
{
	import flash.events.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;	
	import flash.filters.BlurFilter;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.GUID;
	import flash.utils.ByteArray;
	import flash.filesystem.*; 
	import com.adobe.images.JPEGEncoder;
	
	
	public class VideoBG extends EventDispatcher
	{
		private var cam:Camera;
		private var mic:Microphone;
		private var theVideo:Video;	
		private var displayData:BitmapData;
		private var display:Bitmap;
		private var camTimer:Timer;
		private var grid:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var scaler:Matrix;
		
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;		
		
		private var guidName:String;//created in beginRecording()
		private var snapshot:BitmapData;
		
		private var encoder:Encode;
		private var lastFullPath:String;
		
		
		public function VideoBG()
		{
			grid = new mcGrid();			
			
			camTimer = new Timer(1000 / 24); //24 fps cam update
			camTimer.addEventListener(TimerEvent.TIMER, camUpdate);
			
			cam = Camera.getCamera();
			cam.setMode(960, 540, 24, false);
			cam.setKeyFrameInterval(15);
			cam.setQuality(0, 100);//bandwidth, quality
			theVideo = new Video(960, 540);
			mic = Microphone.getMicrophone();	
			
			snapshot = new BitmapData(960, 540, false, 0);
			
			scaler = new Matrix();//640x360 to 1920x1080
			scaler.scale(2,2);
			
			displayData = new BitmapData(1920, 1080, false, 0);//camera draws into here in camUpdate()
			display = new Bitmap(displayData, "auto", true);
			
			encoder = new Encode();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(display)){
				myContainer.addChild(display);
			}
			if (!myContainer.contains(grid)){
				myContainer.addChild(grid);
			}
			TweenMax.to(display, 1, {blurFilter:{blurX:20, blurY:20}});
			grid.alpha = 0;
			TweenMax.to(grid, 1, {alpha:1});
			
			theVideo.attachCamera(cam);
			
			vidConnection = new NetConnection();
			vidConnection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);	
			vidConnection.connect("rtmp://localhost/goldenOne");
			vidConnection.client = this;
			
			camTimer.start();
		}		
		
		
		/**
		 * Returns the guid string of the last video or photo file created
		 */
		public function get lastGUIDName():String
		{
			return guidName;
		}
		
		
		/**
		 * Returns the full path and file name of the last video or photo
		 */
		public function get lastFileName():String
		{
			return lastFullPath;
		}
		
		
		/**
		 * called from Main.showStartRecord()
		 * removes the grid overlay and blur filter on the camera display
		 */
		public function removeGrid():void
		{
			TweenMax.to(grid, 2, {alpha:0});
			TweenMax.to(display, 2, {blurFilter:{blurX:0, blurY:0}});
		}
		
		
		public function showGrid():void
		{
			TweenMax.to(grid, 2, {alpha:1});
			TweenMax.to(display, 2, {blurFilter:{blurX:20, blurY:20}});
		}	
		
		
		/**
		 * draws the video/camera into the 1920x1080 displayData using the scaler matrix
		 * @param	e
		 */
		private function camUpdate(e:TimerEvent):void
		{
			displayData.draw(theVideo, scaler, null, null, null, true);				
		}
		
		
		private function statusHandler(e:NetStatusEvent):void
		{
			if (e.info.code == "NetConnection.Connect.Success")
			{		
				vidStream = new NetStream(vidConnection);
				vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };	
			}
		}
		
		/**
		 * stops calling camUpdate()
		 */
		public function pause():void
		{
			camTimer.reset();
		}
		
		/**
		 * starts calling camUpdate()
		 */
		public function unPause():void
		{
			camTimer.start();
		}
		
		/**
		 * saves the current camera image to snapshot
		 * @return
		 */
		public function takeSnapshot():void
		{			
			snapshot.draw(theVideo);
		}
		
		
		public function getSnapshot():BitmapData
		{
			return snapshot;
		}
		
		
		/**
		 * Called from Main.saveCapture() once the user decides to keep the photo
		 * Saves the user photo to a guid named jpg in the application storage folder
		 * 
		 */
		public function saveSnapshot():void
		{
			var encoder:JPEGEncoder = new JPEGEncoder(94); //quality 1-100
			var ba:ByteArray = encoder.encode(snapshot);
			
			guidName = GUID.create();//create a unique filename
			var fileName:String = guidName + ".jpg";			
			
			try{
				var file:File = File.applicationStorageDirectory.resolvePath( fileName );
				lastFullPath = file.nativePath;
				
				//var file:File = File.documentsDirectory.resolvePath( fileName );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.APPEND );
				stream.writeBytes (ba, 0, ba.length );
				stream.close();
				file = null;
				stream = null;
			}catch (e:Error) {
			
			}
		}
		
		
		/**
		 * Publishes the camera stream to the media server
		 */
		public function beginRecording():void
		{	
			mic.setSilenceLevel(0);			
			mic.rate = 44; //KHz			
			
			//publish vidstream to media server
			vidStream.attachCamera(cam);
			vidStream.attachAudio(mic);
			
			vidStream.publish("user", "record"); //flv			
		}
		
		
		/**
		 * stops publishing the camera to the server
		 * called from Main.stopit()
		 */
		public function stopRecording():void
		{
			guidName = GUID.create();//create a unique filename
			
			vidStream.attachCamera(null);
			vidStream.attachAudio(null);			
			vidStream.close();
			
			//close the connection to FMS - fixes problem with 10 connection max
			vidConnection.close();
			
			encoder.doEncode(guidName);
			
			var fileName:String = guidName + ".mp4";			
			var file:File = File.applicationStorageDirectory.resolvePath( fileName );
			lastFullPath = file.nativePath;
		}		
		
		
		private function metaDataHandler(infoObject:Object):void
		{}

		
		private function cuePointHandler(infoObject:Object):void
		{}
	}
	
}