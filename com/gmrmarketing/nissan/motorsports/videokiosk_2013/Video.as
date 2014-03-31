package com.gmrmarketing.nissan.motorsports.videokiosk_2013
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
		
		private var isRecording:Boolean;
		private var currentVideo:int; //1 or 2
		
		
		public function Video()
		{
			clip = new mcVideo();
			
			cam = Camera.getCamera();
			cam.setQuality(0, 85);//bandwidth, quality
			cam.setMode(768, 432, 24, false);//width, height, fps, favorArea
			cam.setKeyFrameInterval(15);
			
			mic = Microphone.getMicrophone();	
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{			
			isRecording = false;
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			vidConnection = new NetConnection();
			vidConnection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);	
			vidConnection.connect("rtmp://localhost/nissanCap");			
			
			//show video on stage
			clip.vid.attachCamera(cam);
			
			clip.alpha = 0;
			clip.blinky.alpha = 0; //red recording indicator
			
			clip.step1.alpha = 1;
			clip.step2.alpha = .2;
			clip.btnRecord.gotoAndStop(1); //show red circle
			currentVideo = 1;
			
			TweenMax.to(clip, 1, {delay:.4, alpha:1, onComplete:vidShowing } );
		}
		
		
		public function hide():void
		{
			clip.btnRecord.removeEventListener(MouseEvent.MOUSE_DOWN, beginRecording);
			//clip.btnStop.removeEventListener(MouseEvent.MOUSE_DOWN, stopRecording);
			//clip.btnRestart.removeEventListener(MouseEvent.MOUSE_DOWN, doReset);
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function vidShowing():void
		{
			dispatchEvent(new Event(VID_SHOWING));
		}
		
		
		private function statusHandler(e:NetStatusEvent):void
		{
			if (e.info.code == "NetConnection.Connect.Success")
			{		
				vidStream = new NetStream(vidConnection);
				vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };	
				
				clip.btnRecord.addEventListener(MouseEvent.MOUSE_DOWN, beginRecording, false, 0, true);				
				//clip.btnRestart.addEventListener(MouseEvent.MOUSE_DOWN, doReset, false, 0, true);
			}
		}
		
		
		/**
		 * Called by clicking the record button
		 * @param	e
		 */
		private function beginRecording(e:MouseEvent):void
		{	
			clip.btnRecord.removeEventListener(MouseEvent.MOUSE_DOWN, beginRecording);			
			
			clip.btnRecord.addEventListener(MouseEvent.MOUSE_DOWN, stopRecording, false, 0, true);
			clip.btnRecord.gotoAndStop(2); //show green square
			
			mic.setSilenceLevel(0);			
			mic.rate = 44; //KHz
			
			vidStream.attachCamera(cam);
			vidStream.attachAudio(mic);
						
			
			var vName:String = "user" + String(currentVideo); //user1 or user2			
			vidStream.publish(vName, "record"); //flv
			
			//vidStream.publish("mp4:" + vName + ".f4v", "record");
			
			isRecording = true;
			
			clip.blinky.alpha = 1;
			clip.blinky.blink.alpha = 0;
			showRedBlink();
		}
		
		
		private function showRedBlink():void
		{			
			TweenMax.to(clip.blinky.blink, .75, { alpha:1, onComplete:hideRedBlink } );
		}
		
		
		private function hideRedBlink():void
		{
			TweenMax.to(clip.blinky.blink, .75, { alpha:.1, onComplete:showRedBlink } );
		}
		
		
		/**
		 * Called by clicking the stop button
		 * 
		 * @param	e
		 */
		private function stopRecording(e:MouseEvent = null):void
		{			
			clip.btnRecord.gotoAndStop(1); //show red circle
			clip.btnRecord.removeEventListener(MouseEvent.MOUSE_DOWN, stopRecording);
			
			TweenMax.killTweensOf(clip.blinky.blink);
			clip.blinky.alpha = 0;
			
			if(currentVideo == 2){
				clip.vid.attachCamera(null);
				vidStream.attachCamera(null);
				vidStream.attachAudio(null);			
				vidStream.close();
				//close the connection to FMS - fixes problem with 10 connection max
				vidConnection.close();
				dispatchEvent(new Event(DONE_RECORDING));
			}else {
				clip.step1.alpha = .2;
				clip.step2.alpha = 1;
				clip.btnRecord.addEventListener(MouseEvent.MOUSE_DOWN, beginRecording, false, 0, true);
				currentVideo = 2;
			}			
			
			isRecording = false;			
		}		
		
		
		private function metaDataHandler(infoObject:Object):void
		{}

		
		private function cuePointHandler(infoObject:Object):void
		{}
		
		
		/**
		 * Called by pressing the restart button
		 * @param	e
		 */
		private function doReset(e:MouseEvent):void
		{
			if(isRecording){
				stopRecording();
			}
			
			//clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, beginRecording);
			//clip.btnStop.removeEventListener(MouseEvent.MOUSE_DOWN, stopRecording);
			//clip.btnRestart.removeEventListener(MouseEvent.MOUSE_DOWN, doReset);
			
			dispatchEvent(new Event(VID_RESET));
		}
	}
	
}