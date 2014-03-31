
package com.rimv.application 
{
	
	
	/**
	 * RimV
	 * Lite Video Player
	 * author Rimmon Trieu - trieuduchien@gmail.com - www.mymedia-art.com
	 */
	
	 
	// flash libs
	import flash.display.*;
	import flash.text.TextField;
	import flash.utils.Timer;
	import gs.TweenMax;
	import gs.easing.*;
	import flash.media.Video;
	import flash.net.*;
	import flash.events.*;
	import flash.media.SoundTransform;
	
	public class liteVideoPlayer extends MovieClip
	{
		
		// video vars
		private var netStream:NetStream;
		private var netConnection:NetConnection;
		private var videoLength:Number;
		private var isPlaying:Boolean;
		private var isStarted:Boolean;
		private var lastVid:String;
		private var progressChecking:Timer = new Timer(20);
		private var soundMute:Boolean = false;
		private var progressWidth:Number = 378;
		private var cVolume:Number = 1;
		private var cVolume2:Number = 1;
		private var isFlushed:Boolean = false;
		
		// video dimension
		public var _videoWidth:Number = 500;
		public var _videoHeight:Number = 390;
		public var bufferTime:Number = 5;
		// source
		public var source:String;
		
		public function set videoWidth(w:Number):void
		{
			this._videoWidth = w;
			videoDisplay.width = videoArea.width = this._videoWidth;
			videoControl.x = Math.round((this._videoWidth - videoControl.width) * .5);
		}
		
		public function get videoWidth():Number
		{
			return _videoWidth;
		}
		
		public function set videoHeight(h:Number):void
		{
			this._videoHeight = h;
			videoDisplay.height = videoArea.height = this._videoHeight;
			videoControl.y = this._videoHeight - 52;
		}
		
		public function get videoHeight():Number
		{
			return _videoHeight;
		}
		
		
		// component reference
		private var playBtn, pauseBtn, playerBack, progress, soundBtn, volumeControl:MovieClip = new MovieClip();
		
		public function liteVideoPlayer() 
		{
			initilaize();			
		}
		
		// Initialize
		private function initilaize():void
		{
			// video initialize
			// attach net stream to video display object
			videoDisplay.attachNetStream(netStream);
			videoDisplay.smoothing = true;
			
			// initialize Net connection and Net stream
			netConnection = new NetConnection();
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			netConnection.connect(null);
			
			// Net Stream
			netStream = new NetStream(netConnection);
			// Net Status Handler
			netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			
			// meta data to retrieve video length
			var metaListener:Object = new Object();
			metaListener.onMetaData = metaHandler;
			netStream.client = metaListener;
			netStream.soundTransform = new SoundTransform(-1);
			videoDisplay.attachNetStream(netStream);
			netStream.bufferTime = bufferTime;
			
			// movie clip reference
			playBtn = videoControl.playBtn;
			pauseBtn = videoControl.pauseBtn;
			playerBack = videoControl.playerBack;
			soundBtn = videoControl.soundBtn;
			volumeControl = videoControl.volumeControl;
			progress = videoControl.progress;
			
			// resize
			videoDisplay.width = videoArea.width = this._videoWidth;
			videoDisplay.height = videoArea.height = this._videoHeight;
			
			// reposition
			videoControl.y = videoHeight - 52;
			videoControl.x = Math.round((videoWidth - videoControl.width) * .5);
			pauseBtn.visible = false;
			progress.progressBar.width = 0.1;
			
			// add interactive
			playBtn.buttonMode = pauseBtn.buttonMode = soundBtn.buttonMode = progress.trans.buttonMode = true;
			playBtn.addEventListener(MouseEvent.CLICK, playVideo);
			pauseBtn.addEventListener(MouseEvent.CLICK, pauseVideo);
			soundBtn.addEventListener(MouseEvent.CLICK, soundBtnClick);
			progressChecking.addEventListener(TimerEvent.TIMER, progressUpdate);
			progress.trans.addEventListener(MouseEvent.CLICK, progressClick);
			progress.trans.addEventListener(MouseEvent.MOUSE_DOWN, progressDown);
			videoArea.addEventListener(MouseEvent.MOUSE_OUT, videoAreaOut);
			videoArea.addEventListener(MouseEvent.MOUSE_OVER, videoAreaOver);
			videoControl.addEventListener(MouseEvent.MOUSE_OVER, videoControlOver);
			volumeControl.trans.addEventListener(MouseEvent.MOUSE_DOWN, volumeClick);
			volumeControl.trans.buttonMode = true;
		}
		
		// Video status handler
		private function netStatusHandler(e:NetStatusEvent):void
		{
			// Check status
			switch (e.info.code) 
			{
				// video not found
				case "NetStream.Play.StreamNotFound": 
					trace("Video not found");
					break;
				case "NetStream.Play.Start":
					isStarted = true;
					progressChecking.start();
					break;
				// rewind video when finish playing
				case "NetStream.Play.Stop":
					//netStream.seek(0);
					dispatchEvent(new Event("videoIsDone"));
					break;
				// buffering flush
				case "NetStream.Buffer.Flush":
					isFlushed = true;
					break;
				// buffering full
				case "NetStream.Buffer.Full":
					info.text = videoFormat(Math.round(netStream.time)) + " | " + videoFormat(videoLength);
					break;
				// buffering empty
				case "NetStream.Buffer.Empty":
					if (!isFlushed)
					info.text = "BUFFERING...";
					break;
			}
		}
		
		// retrieve video length
		private function metaHandler(data:Object):void
		{
			videoLength = Math.round(data.duration);		
		}
		
		// Control
		// play video 
		public function playVideo(e:MouseEvent = null):void
		{
			if (lastVid != source)
			{
				lastVid = source;
				isFlushed = false;
				isStarted = false;
				progress.progressBar.width = 0;
				info.text = "BUFFERING...";
				netStream.play(source);
				// reset sound
				netStream.soundTransform = new SoundTransform(cVolume);
				TweenMax.to(soundBtn, 0, { tint:0xFFFFFF } );
			}
			else
			{
				netStream.resume();
			}
			isPlaying = true;
			// show / hide play - pause button
			playBtn.visible = false;
			pauseBtn.visible = true;
			if (isStarted) progressChecking.start();
		}
		
		// pause video
		public function pauseVideo(e:MouseEvent = null):void
		{
			isPlaying = false;
			netStream.pause();
			// show / hide play - pause button
			playBtn.visible = true;
			pauseBtn.visible = false;
			progressChecking.stop();
		}
		
		public function stopVideo():void
		{
			isPlaying = false;
			netStream.seek(0);
			netStream.pause();
			// show / hide play - pause button
			playBtn.visible = true;
			pauseBtn.visible = false;
			progressChecking.stop();
		}
		
		// mute sound
		private function soundBtnClick(e:MouseEvent = null):void
		{
			if (!soundMute)
			{
				cVolume = netStream.soundTransform.volume;
				netStream.soundTransform = new SoundTransform(0);
				TweenMax.to(e.target, 0, { tint:0x666666 } );
			}
			else
			{
				netStream.soundTransform = new SoundTransform(cVolume);
				TweenMax.to(e.target, 0, { tint:0xFFFFFF } );
			}
			soundMute = !soundMute;
		}
		
		// click on bar seeking
		private function progressClick(e:MouseEvent = null):void
		{
			var per:Number = e.target.mouseX / 380;
			netStream.seek(per * videoLength);
		}
		
		// mouse down to drag
		private function progressDown(e:MouseEvent = null):void
		{
			cVolume2 = netStream.soundTransform.volume;
			netStream.soundTransform = new SoundTransform(0);
			netStream.pause();
			stage.addEventListener(MouseEvent.MOUSE_MOVE, progressMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, progressUp);
			progressChecking.stop();
		}
		
		private function progressMove(e:MouseEvent):void
		{
			var per:Number = progress.trans.mouseX / 380;
			if (per <= 1) 
			{
				progress.progressBar.width = per * progressWidth;
				// seek 
				netStream.seek(progress.progressBar.width / progressWidth * videoLength);
				// Time 
				info.text = videoFormat(Math.round(netStream.time)) + " | " + videoFormat(videoLength);
			}
			e.updateAfterEvent();
		}
		
		private function progressUp(e:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, progressMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, progressUp);
			pauseBtn.visible = true;
			playBtn.visible = false;
			// unmute sound
			netStream.soundTransform = new SoundTransform(cVolume2);
			netStream.resume();
			progressChecking.start();
		}
		
		// progress update
		private function progressUpdate(e:Event):void
		{
			var cTime:Number = Math.round(netStream.time);
			if (cTime > 0)
			{
				// Time 
				info.text = videoFormat(cTime) + " | " + videoFormat(videoLength);
				// progress 
				progress.progressBar.width = netStream.time / videoLength * progressWidth;
			}
		}
		
		private function videoAreaOver(e:MouseEvent = null):void
		{
			//TweenMax.to(videoControl, 0.75, { alpha:1, ease: Quint.easeOut} );
		}
		
		private function videoAreaOut(e:MouseEvent = null):void
		{
			//TweenMax.to(videoControl, 0.75, { alpha:0, ease: Quint.easeOut} );
		}
		
		private function videoControlOver(e:MouseEvent = null):void
		{
			//TweenMax.to(videoControl, 0.75, { alpha:1, ease: Quint.easeOut, overwrite:1} );
		}
		
		//change milisec to video format number
		private function videoFormat(num:Number):String
		{
			var min:Number = Math.floor(num / 60);
			var sec:Number = num % 60;
			var minString:String; var secString:String;
			if (min < 10) minString = "0" + min.toString(); else minString = min.toString();
			if (sec < 10) secString = "0" + sec.toString(); else secString = sec.toString();
			return minString + ":" + secString;
		}
		
		private function volumeClick(e:MouseEvent = null):void
		{
			var index:Number = Math.round(e.target.mouseX / 39 * 6);
			cVolume = index / 6;
			netStream.soundTransform = new SoundTransform(cVolume);
			TweenMax.to(soundBtn, 0, { tint:0xFFFFFF } );
			for (var i:uint = index + 1; i <= 6; i++)
				TweenMax.to(volumeControl["sb" + i], 0, { tint:0x666666 } );
			for (i = 1; i <= index ; i++)
				TweenMax.to(volumeControl["sb" + i], 0, { tint:0xFFFFFF } );
		}	
		
	}
	
}