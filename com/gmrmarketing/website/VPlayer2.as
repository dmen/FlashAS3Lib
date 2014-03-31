/**
 * Video Player 2 - attempt at StageVideo - NOT WORKING
 * 
 * useage:
 * 
 * var vid:VPlayer = new VPlayer();
 * vid.showVideo(this);
 * vid.playVideo("coronaatp.mp4");
 * 
 * To make the video loop:
 *
 * vid.addEventListener(VPlayer.STATUS_RECEIVED, checkStatus, false, 0, true);
 * function checkStatus(e:Event):void
 * {
 * 		if(vid.getStatus() == "NetStream.Play.Stop")
 * 		{
 * 			vid.playVideo("coronaatp.mp4");
 * 		}
 * }
 */
package com.gmrmarketing.website
{
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.*;
	import flash.display.Sprite;
	import flash.utils.Timer;
	   import flash.media.StageVideo; 
           import flash.media.StageVideoAvailability; 
		    import flash.events.StageVideoAvailabilityEvent; 
	
	public class VPlayer2 extends EventDispatcher
	{
		public static const META_RECEIVED:String = "MetaDataReceived";
		public static const CUE_RECEIVED:String = "CuePointReceived";
		public static const STATUS_RECEIVED:String = "NetStatusReceived";
		
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;
		private var vidContainer:Sprite;
		private var theVideo:Video;
		private var sv:StageVideo;		
		
		private var vidWidth:int = 0;
		private var vidHeight:int = 0;
		
		private var dur:Number; //video duration set in metaDataHandler
		
		private var cueName:String = "";
		private var statusCode:String = "";
		
		private var container:DisplayObjectContainer;
		
		private var autoSize:Boolean = true;
		
		private var vidPaused:Boolean = true;
		private var vidMuted:Boolean = false;
		
		private var msTimer:Timer;		
		
		
		/**
		 * CONSTRUCTOR
		 * Create theVideo and attach the stream object
		 * 
		 * @param	bt video buffer time - default is 3 sec
		 */
		public function VPlayer2(bt:int = 3, $container:DisplayObjectContainer = null, $useStageVideo:Boolean = true)
		{			
			vidConnection = new NetConnection();
			vidConnection.connect(null);
			vidStream = new NetStream(vidConnection);
			vidStream.bufferTime = bt;
			
			vidStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			vidStream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);			
			vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };			
			
			theVideo = new Video();
			container = $container;			
			
			if (!$useStageVideo) {
				theVideo.attachNetStream(vidStream);
				container.addChild(theVideo);
				//theVideo.visible = false;
			}else {
				//use stage video				
				container.stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState, false, 0, true);
			}
           // 
		}
		
		
		private function onStageVideoState(e:StageVideoAvailabilityEvent):void       
		{	 
			container.stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState);
			
			if (e.availability == StageVideoAvailability.AVAILABLE) {
				useStageVideo();
				MovieClip(container.parent).theText.text = "USING STAGE VIDEO";
			}else {
				theVideo.attachNetStream(vidStream);
				container.addChild(theVideo);
				MovieClip(container.parent).theText.text = "USING STANDARD VIDEO OBJECT";
			}
		}
		
		
		private function useStageVideo():void       
		{    
			if ( sv == null )       
			{       
				// retrieve the first StageVideo object       
				sv = container.stage.stageVideos[0];       
				//sv.addEventListener(StageVideoEvent.RENDER_STATE, stageVideoStateChange);       
			}       
			sv.attachNetStream(vidStream);
		}
		
		
		/**
		 * Allows setting the NET_STATUS callback listener to a custom method
		 * @param	f
		 */
		public function setStatusCallback(f:Function):void
		{
			vidStream.removeEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			vidStream.addEventListener(NetStatusEvent.NET_STATUS, f);
		}
		
		
		/**
		 * Sets the buffer time in seconds
		 * @param	nb
		 */
		public function setBuffer(nb:int):void
		{
			vidStream.bufferTime = nb;
		}
		
		
		/**
		 * 
		 */
		public function showVideo():void
		{
			msTimer = new Timer(200, 1);
			msTimer.addEventListener(TimerEvent.TIMER, showVid);
			msTimer.start();
		}
		
		
		/**
		 * Called from showVideo after 200 ms
		 * makes the video visible 
		 * @param	e
		 */
		private function showVid(e:TimerEvent):void
		{
			msTimer.removeEventListener(TimerEvent.TIMER, showVid);
			theVideo.visible = true;
		}
		
		
		
		/**
		 * Sets the index of the video within the container
		 * @param	ind
		 */
		public function setIndex(ind:int):void
		{
			container.setChildIndex(theVideo, ind);
		}
		
		
		
		/**
		 * Hides the video
		 */
		public function hideVideo():void
		{
			if(container){
				if (container.contains(theVideo)) {
					container.removeChild(theVideo);
					theVideo.clear();
					vidStream.close();
				}
			}
			container = null;
		}
		
		
		public function simpleHide():void
		{
			if(container){
				if (container.contains(theVideo)) {
					container.removeChild(theVideo);
				}
			}
		}
		
		public function simpleShow():void
		{
			if(container){
				if (!container.contains(theVideo)) {
					container.addChild(theVideo);
				}
			}
		}
		
		/**
		 * Returns the paused state of the video
		 * 
		 * @return Boolean
		 */
		public function isPaused():Boolean
		{
			return vidPaused;			
		}
		
		
		public function isMuted():Boolean
		{
			return vidMuted;
		}
		
		
		/**
		 * Plays the video at the passed in url
		 * @param	vid
		 */
		public function playVideo(vid:String):void
		{			
			vidStream.play(vid);			
			vidPaused = false;			
		}
		
		public function replay():void
		{
			vidStream.seek(0);
		}
		
		/**
		 * Returns an object with width and height properties containing
		 * the size of the video, in pixels
		 * 
		 * @return Object
		 */
		public function getVidSize():Object
		{
			return { width:vidWidth, height:vidHeight };
		}
		
		
		
		/**
		 * Centers the video inside the passed in width and height space
		 * 
		 * @param	w Width in pixels
		 * @param	h Height in pixels
		 */
		public function centerVideo(w:int = 0, h:int = 0):void
		{
			if(w != 0){
				theVideo.x = Math.floor((w - getVidSize().width) * .5);
			}
			if(h != 0){
				theVideo.y = Math.floor((h - getVidSize().height) * .5);
			}
		}
		
		
		/**
		 * Returns the current time of the playhead, in seconds
		 * @return
		 */
		public function getPlayheadTime():Number
		{
			return vidStream.time;
		}
		
		
		
		/**
		 * Sets the size of the video
		 * Be sure to call autoSizeOff() when using this method
		 * 
		 * @param	s Object with width and height properties
		 */
		public function setVidSize(s:Object):void
		{			
			vidWidth = s.width;
			vidHeight = s.height;
			theVideo.width = s.width;
			theVideo.height = s.height;
		}
		
		
		
		/**
		 * Sets smoothing for when the video is scaled
		 * 
		 * @param	s Boolean
		 */
		public function setSmoothing(s:Boolean = true):void
		{
			theVideo.smoothing = s;
		}
		
		
		
		/**
		 * Returns the name of the last cue point passed
		 * Set in cuePointHandler()
		 * 
		 * @return String name of the last cue point
		 */
		public function getCueName():String
		{
			return cueName;
		}
		
		
		/**
		 * Returns the last status code from statusHandler()
		 * 
		 * @return String status code
		 */
		public function getStatus():String
		{
			return statusCode;
		}
		
		
		/**
		 * Returns the videos NetStream object
		 * @return
		 */
		public function getStream():NetStream
		{
			return vidStream;
		}
		
		/**
		 * Mutes the video sound
		 */
		public function mute():void
		{
			var s:SoundTransform = new SoundTransform(0);
			vidStream.soundTransform = s;
			vidMuted = true;
		}
		
		
		/**
		 * Unmutes the video sound
		 */
		public function unMute():void
		{
			var s:SoundTransform = new SoundTransform(1);
			vidStream.soundTransform = s;
			vidMuted = false;
		}
		
		
		/**
		 * Pauses the currently playing stream
		 * @param	e
		 */
		public function pauseVideo(e:MouseEvent = null):void
		{
			vidPaused = true;
			vidStream.pause();
		}
		
		
		/**
		 * Forwards the stream two seconds
		 */
		public function forward():void
		{
			vidStream.seek(vidStream.time + 2);
		}
		
		
		/**
		 * Rewinds the stream three seconds
		 */
		public function rewind():void
		{
			vidStream.seek(vidStream.time - 3);
		}
		
		
		
		/**
		 * Resumes playing of a paused video
		 * @param	e
		 */
		public function resumeVideo(e:MouseEvent = null):void
		{
			vidPaused = false;
			vidStream.resume();
		}
		
		
		/**
		 * Stops the stream and seeks to the beginning
		 * @param	e
		 */
		public function stopVideo(e:MouseEvent = null):void
		{
			vidStream.seek(0);
			vidStream.pause();
			vidPaused = true;
		}
		
		
		public function autoSizeOff():void
		{
			autoSize = false;
		}
		
		
		public function autoSizeOn():void
		{
			autoSize = true;
		}			
		
		
		/**
		 * Returns the total duration of the video, in seconds
		 * 
		 * @return Duration, in seconds
		 */
		public function getDuration():Number
		{
			return dur;
		}
		
		
		/**
		 * Returns an object containing video data
		 * bufferLength: Number of seconds of data currently in the buffer
		 * bufferTime: How long to buffer before displaying the stream
		 * bytesLoaded: Number of bytes loaded
		 * bytesTotal: Total size of the video in bytes
		 * time: Position of the playhead in seconds
		 * 
		 * @return Object
		 */
		public function getVideoInfo():Object
		{
			var o:Object = new Object();
			o.bufferLength = vidStream.bufferLength;
			o.bufferTime = vidStream.bufferTime;
			o.bytesLoaded = vidStream.bytesLoaded;
			o.bytestTotal = vidStream.bytesTotal;
			o.time = vidStream.time;
			return o;
		}
		
		
		private function metaDataHandler(infoObject:Object):void 
		{	
			dur = infoObject.duration;
			
			vidWidth = infoObject.width;
			vidHeight = infoObject.height;
			
			if(autoSize){
				theVideo.width = vidWidth;
				theVideo.height = vidHeight;
			}
			
			dispatchEvent(new Event(META_RECEIVED));
		}
		
		
		/**
		 * Call getCueName() to retrieve the name after receiving the event
		 * @param	infoObject
		 */
		private function cuePointHandler(infoObject:Object):void 
		{
			cueName = infoObject.name;			
			dispatchEvent(new Event(CUE_RECEIVED));
		}
		
		
		/**
		 * Call getStatus() to retrieve the status code after receiving the event
		 * @param	e
		 */
		private function statusHandler(e:NetStatusEvent):void 
		{ 			
			statusCode = e.info.code;			
			dispatchEvent(new Event(STATUS_RECEIVED));
		}
		
		
		private function asyncErrorHandler(e:AsyncErrorEvent):void 	
		{
			trace("asynch:", e); 
		}
		
	}
	
}