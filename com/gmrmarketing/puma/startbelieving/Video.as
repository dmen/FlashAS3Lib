package com.gmrmarketing.puma.startbelieving
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.net.*;	
	import flash.media.*;
	import flash.events.*;
	import flash.utils.Timer;	
	
	
	public class Video extends EventDispatcher  
	{
		public static const VID_SHOWING:String = "videoShowing";
		public static const VID_RESET:String = "vidReset";
		public static const DONE_RECORDING:String = "doneRecording";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;		
		private var cam:Camera;
		private var mic:Microphone;		
		private var curTime:int;
		
		private var guidName:String;
		private var isRecording:Boolean;
		
		
		public function Video()
		{
			clip = new mcVideo();
			cam = Camera.getCamera();
			cam.setQuality(0, 90);//bandwidth, quality
			cam.setMode(640, 400, 30, false);//width, height, fps, favorArea
			mic = Microphone.getMicrophone();	
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(guid:String):void
		{
			guidName = guid;//filename
			isRecording = false;
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			vidConnection = new NetConnection();
			vidConnection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);	
			vidConnection.connect("rtmp://localhost/puma");			
			
			//show video on stage
			clip.vid.attachCamera(cam);
			
			clip.alpha = 0;
			clip.vid.alpha = 0;
			clip.blink.alpha = 0; //red recording indicator
			TweenMax.to(clip, 1, {delay:.4, alpha:1, onComplete:vidShowing } );
		}
		
		
		public function hide():void
		{
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, beginRecording);
			clip.btnStop.removeEventListener(MouseEvent.MOUSE_DOWN, stopRecording);
			clip.btnRestart.removeEventListener(MouseEvent.MOUSE_DOWN, doReset);
			
			clip.vid.attachCamera(null);
			if(vidStream){
				vidStream.attachCamera(null);
				vidStream.attachAudio(null);			
				vidStream.close();
			}
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function vidShowing():void
		{
			dispatchEvent(new Event(VID_SHOWING));
			TweenMax.to(clip.vid, 1, { alpha:1, delay:2 } );
		}
		
		
		private function statusHandler(e:NetStatusEvent):void
		{
			if (e.info.code == "NetConnection.Connect.Success")
			{		
				vidStream = new NetStream(vidConnection);
				vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };	
				
				clip.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, beginRecording, false, 0, true);				
				clip.btnRestart.addEventListener(MouseEvent.MOUSE_DOWN, doReset, false, 0, true);
			}
		}
		
		
		private function beginRecording(e:MouseEvent):void
		{	
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, beginRecording);			
			clip.btnStop.addEventListener(MouseEvent.MOUSE_DOWN, stopRecording, false, 0, true);
			
			mic.setSilenceLevel(0);			
			mic.rate = 44; //KHz
			
			vidStream.attachCamera(cam);
			vidStream.attachAudio(mic);
						
			//vidStream.publish("mp4:" + guidName + ".f4v", "record");
			vidStream.publish(guidName, "record"); //flv
			
			isRecording = true;
			showRedBlink();
		}
		
		
		private function showRedBlink():void
		{
			TweenMax.to(clip.blink, 1, { alpha:1, onComplete:hideRedBlink } );
		}
		
		
		private function hideRedBlink():void
		{
			TweenMax.to(clip.blink, 1, { alpha:.1, onComplete:showRedBlink } );
		}
		
		
		/**
		 * Called by clicking the Finished button
		 * Called from decrementCount() when the 30 seconds is up
		 * @param	e
		 */
		private function stopRecording(e:MouseEvent = null):void
		{			
			clip.btnStop.removeEventListener(MouseEvent.MOUSE_DOWN, stopRecording);
			TweenMax.killTweensOf(clip.blink);
			clip.blink.alpha = 0;
			clip.vid.attachCamera(null);
			vidStream.attachCamera(null);
			vidStream.attachAudio(null);			
			vidStream.close();
			
			//close the connection to FMS - fixes problem with 10 connection max
			vidConnection.close();
			
			isRecording = false;
			
			if(e != null){
				dispatchEvent(new Event(DONE_RECORDING));
			}
		}		
		
		
		private function metaDataHandler(infoObject:Object):void
		{}

		
		private function cuePointHandler(infoObject:Object):void
		{}
		
		
		private function doReset(e:MouseEvent):void
		{
			if(isRecording){
				stopRecording();
			}
			
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, beginRecording);
			clip.btnStop.removeEventListener(MouseEvent.MOUSE_DOWN, stopRecording);
			clip.btnRestart.removeEventListener(MouseEvent.MOUSE_DOWN, doReset);
			
			dispatchEvent(new Event(VID_RESET));
		}
	}
	
}