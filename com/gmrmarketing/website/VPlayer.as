/**
 * Video Player
 * 
 * useage:
 * 
 * var vid:VPlayer = new VPlayer();
 * vid.showVideo(this);
 * vid.playVideo("coronaatp.mp4");
 * 
 * To make the video loop:
 *
	vid.addEventListener(VPlayer.STATUS_RECEIVED, checkStatus, false, 0, true);
	
	  function checkStatus(e:Event):void
	  {
			if(vid.getStatus() == "NetStream.Play.Stop")
			{
				vid.playVideo("coronaatp.mp4");
			}
	  }
	  
	 Note: using the above loop method, you might get a flash of black as the video ends and restarts. If this is
	 the case, the better way to loop is to place a cue point near the end of the video, and then listen for that.
	 Once received, call vid.replay()
 */
package com.gmrmarketing.website
{
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.*;
	import flash.display.Sprite;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class VPlayer extends MovieClip
	{
		public static const META_RECEIVED:String = "MetaDataReceived";
		public static const CUE_RECEIVED:String = "CuePointReceived";
		public static const STATUS_RECEIVED:String = "NetStatusReceived";
		
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;
		private var vidContainer:Sprite;
		private var theVideo:Video;
		
		private var vidWidth:int = 0;
		private var vidHeight:int = 0;
		
		private var dur:Number; //video duration set in metaDataHandler
		
		private var cueName:String = "";
		private var statusCode:String = "";
		
		private var container:DisplayObjectContainer;
		
		private var autoSize:Boolean = true;
		
		private var vidPaused:Boolean = true;
		private var vidMuted:Boolean = false;
		
		private var timeoutHelper:TimeoutHelper;
		private var msTimer:Timer;
		private var useTimeout:Boolean;
		private var timeoutTimer:Timer;
		
		private var isLooping:Boolean = false;
		
		
		/**
		 * CONSTRUCTOR
		 * Create theVideo and attach the stream object
		 * 
		 * @param	bt video buffer time - default is 3 sec
		 */
		public function VPlayer(bt:int = 3)
		{
			vidConnection = new NetConnection();
			vidConnection.connect(null);
			vidStream = new NetStream(vidConnection);
			vidStream.bufferTime = bt;
			
			vidStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			vidStream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);			
			vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };
			
			timeoutHelper = TimeoutHelper.getInstance();
			useTimeout = false;
			
			timeoutTimer = new Timer(8000);
			timeoutTimer.addEventListener(TimerEvent.TIMER, callTimeout, false, 0, true);
			
			theVideo = new Video();
			theVideo.smoothing = true;
            theVideo.attachNetStream(vidStream);
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
		 * Sets the container for the video
		 * @param	con
		 */
		public function showVideo($container:DisplayObjectContainer):void
		{
			container = $container;			
			container.addChild(theVideo);
			theVideo.visible = false;			
			
			msTimer = new Timer(200, 1);
			msTimer.addEventListener(TimerEvent.TIMER, showVid);
			msTimer.start();
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
			timeoutTimer.stop();
		}
		
		
		public function simpleHide():void
		{
			if(container){
				if (container.contains(theVideo)) {
					container.removeChild(theVideo);
				}
			}
			if (useTimeout) {
				timeoutTimer.start();
			}
		}
		
		public function simpleShow():void
		{
			if(container){
				if (!container.contains(theVideo)) {
					container.addChild(theVideo);
				}
			}
			if (useTimeout) {
				timeoutTimer.start();
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
		 * Call before calling playVideo
		 * Starts the timeoutTimer so that callTimeout is called while
		 * the video is playing
		 */
		public function useTimeoutHelper():void
		{
			useTimeout = true;			
		}
		
		private function callTimeout(e:TimerEvent):void
		{
			timeoutHelper.buttonClicked();
		}
		
		/**
		 * Plays the video at the passed in url
		 * @param	vid
		 */
		public function playVideo(vid:String):void
		{			
			vidStream.play(vid);			
			vidPaused = false;
			if (useTimeout) {
				timeoutTimer.start();
			}
		}
		
		public function replay():void
		{
			vidStream.seek(0);
			if (useTimeout) {
				timeoutTimer.start();
			}
		}
		
		
		/**
		 * Centers the video inside the passed in width and height space
		 * 
		 * Make sure MetaData from the video has been received before calling this
		 * or getVidSize() will return 0's for width and height
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
			theVideo.width = vidWidth;
			theVideo.height = vidHeight;
		}
		
		
		/**
		 * Set the video's width to a given size
		 * height is automatically set - keeping the proper aspect ratio
		 * @param	w
		 */
		public function setVidWidthProportional(w:int):void
		{
			vidWidth = w;			
			var ratio:Number = vidWidth / theVideo.width;			
			vidHeight = vidHeight * ratio;
			
			theVideo.width = vidWidth;
			theVideo.height = vidHeight;
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
		 * @return String status code
		 */
		public function getStatus():String
		{
			return statusCode;
		}
		
		
		/**
		 * Allows setting the video sound level
		 * @param	newLevel 0 - 1
		 */
		public function setSoundLevel(newLevel:Number):void
		{
			var newVol:SoundTransform = new SoundTransform();
			newVol.volume = newLevel;
			vidStream.soundTransform = newVol;
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
		
		
		public function seekZero():void
		{
			vidStream.seek(0);
		}
		
		public function setLooping(b:Boolean):void
		{
			isLooping = b;
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
			
			timeoutTimer.stop();
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
		 * Available once the metaDataHandler has executed
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
			
			if (isLooping && statusCode == "NetStream.Buffer.Empty") {
				replay();
			}
			//trace(statusCode);
			dispatchEvent(new Event(STATUS_RECEIVED));
		}
		
		
		private function asyncErrorHandler(e:AsyncErrorEvent):void 	
		{
			trace("asynch:", e); 
		}
		
	}
	
}