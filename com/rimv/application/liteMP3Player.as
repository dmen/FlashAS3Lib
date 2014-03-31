package com.rimv.application 
{
	
	import gs.TweenMax;
	import gs.easing.*;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;
	import flash.net.*;
	import flash.filters.*;
	import flash.text.TextField;
	
	
	/**
	 * @author Rimmon Trieu
	 * RV Compact MP3 Player
	 * www.mymedia-art.com - trieuduchien@gmail.com
	 */
	
	public class liteMP3Player extends MovieClip
	{
		
		// parameter
		public var playerWidth:Number = 478;
		public var playerHeight:Number = 226;
		public var source:String;
		public var length:Number;
		public var SpectrumLineWidth:Number = 1;
		public var SpectrumLineColor:Number = 0xFFFFFF;
		public var bufferTime:Number = 5;
		
		// Main sounds object
		private var _sound:Sound = new Sound();
		private var _soundChannel:SoundChannel;
		private var _soundTransform:SoundTransform;
		private var _soundLoaderContext:SoundLoaderContext = new SoundLoaderContext();
		private var currentSoundProgress:Number = 0;
		private var currentVolume:Number = 1;
		private var soundMute:Boolean = false;
		
		// component reference
		private var playBtn, pauseBtn, playerBack, progress, soundBtn, volumeControl:MovieClip = new MovieClip();
		private var lastMP3:String;
		private var progressChecking:Timer = new Timer(40);
		// sound spectrum array
		private var ss:ByteArray = new ByteArray();
		private var ssUpdate:Timer = new Timer(20);
		
		// to draw line spectrum
		private var lsp:Sprite = new Sprite();
		
		// initialize
		public function liteMP3Player() 
		{
			// reposition
			spectrumArea.y = playerHeight * .5 - 77;
			mp3Control.y = playerHeight - 26;
			
			// movie clip reference
			playBtn = mp3Control.playBtn;
			pauseBtn = mp3Control.pauseBtn;
			playerBack = mp3Control.playerBack;
			soundBtn = mp3Control.soundBtn;
			volumeControl = mp3Control.volumeControl;
			progress = mp3Control.progress;
			pauseBtn.visible = false;
			progress.progressBar.scaleX = 0;
			
			spectrumArea.specArea.addChild(lsp);
									
			// add interactive
			playBtn.buttonMode = pauseBtn.buttonMode = soundBtn.buttonMode = progress.trans.buttonMode = true;
			playBtn.addEventListener(MouseEvent.CLICK, playMP3);
			pauseBtn.addEventListener(MouseEvent.CLICK, pauseMP3);
			soundBtn.addEventListener(MouseEvent.CLICK, soundBtnClick);
			progressChecking.addEventListener(TimerEvent.TIMER, progressUpdate);
			ssUpdate.addEventListener(TimerEvent.TIMER, ssUpdateHandler);
			progress.trans.addEventListener(MouseEvent.CLICK, progressClick);
			volumeControl.trans.addEventListener(MouseEvent.MOUSE_DOWN, volumeClick);
			volumeControl.trans.buttonMode = true;
		}
		
		// play new souce mp3
		public function playMP3(e:MouseEvent = null):void
		{
			// Play new song
			if (lastMP3!= source)
			{
				// update id
				lastMP3 = source;
				// load new sound
				_sound = new Sound();
				_soundLoaderContext = new SoundLoaderContext(bufferTime);
				_sound.load(new URLRequest(source), _soundLoaderContext);
				_soundChannel = _sound.play(0);
				//_sound.addEventListener(Event.COMPLETE, loadComplete);
				// add event for playing finish
				_soundChannel.addEventListener(Event.SOUND_COMPLETE, playingComplete);
				resumeVolume();
				TweenMax.to(soundBtn, 0, { tint:0xFFFFFF } );
			}
			// or resume current playing
			else
			{
				_soundChannel = _sound.play(currentSoundProgress);
				_soundChannel.addEventListener(Event.SOUND_COMPLETE, playingComplete);
				resumeVolume();
				TweenMax.to(soundBtn, 0, { tint:0xFFFFFF } );
			}
			if (!progressChecking.running) progressChecking.start();
			if (!ssUpdate.running) ssUpdate.start();
			playBtn.visible = false;
			pauseBtn.visible = true;
		}
		
		// playing complete - rewind
		private function playingComplete(e:Event):void
		{
			currentSoundProgress =  0;
			_soundChannel.stop();
			_soundChannel = _sound.play(currentSoundProgress);
		}
		
		public function pauseMP3(e:MouseEvent = null):void
		{
			currentSoundProgress = _soundChannel.position;
			_soundChannel.stop();
			playBtn.visible = true;
			pauseBtn.visible = false;
		}
		
		public function stopMP3(e:MouseEvent = null):void
		{
			currentSoundProgress = 0;
			_soundChannel.stop();
			playBtn.visible = true;
			pauseBtn.visible = false;
		}
		
		// mute sound
		private function soundBtnClick(e:MouseEvent = null):void
		{
			if (!soundMute)
			{
				_soundTransform = _soundChannel.soundTransform;
				_soundTransform.volume = 0;
				_soundChannel.soundTransform = _soundTransform;
				TweenMax.to(e.target, 0, { tint:0x666666 } );
			}
			else
			{
				resumeVolume();
				TweenMax.to(e.target, 0, { tint:0xFFFFFF } );
			}
			soundMute = !soundMute;
		}
		
		// progress update
		private function progressUpdate(e:Event):void
		{
			// buffering 
			if (_sound.isBuffering)
			{
				info.text = "BUFFERING...";
			}
			// playing progress
			else
			{
				progress.progressBar.scaleX = _soundChannel.position / length;
				// time
				var sec = Math.floor(_soundChannel.position * .001);
				info.text = mp3Format(sec) + " | " + mp3Format(length * .001);
			}
		}
		
		private function mp3Format(sec:Number):String
		{
			return Math.floor(sec / 60 / 10).toString() + Math.floor(sec / 60 % 10) + ":" + Math.floor(sec % 60 / 10) + Math.floor(sec % 60 % 10);	
		}
		
		private function resumeVolume():void
		{
			_soundTransform = _soundChannel.soundTransform;
			_soundTransform.volume = currentVolume;
			_soundChannel.soundTransform = _soundTransform;
		}
		
		// control volume
		private function volumeClick(e:MouseEvent = null):void
		{
			var index:Number = Math.round(e.target.mouseX / 39 * 6);
			currentVolume = index / 6;
			resumeVolume();
			TweenMax.to(soundBtn, 0, { tint:0xFFFFFF } );
			for (var i:uint = index + 1; i <= 6; i++)
				TweenMax.to(volumeControl["sb" + i], 0, { tint:0x666666 } );
			for (i = 1; i <= index ; i++)
				TweenMax.to(volumeControl["sb" + i], 0, { tint:0xFFFFFF } );
		}
		
		// click on bar seeking
		private function progressClick(e:MouseEvent = null):void
		{
			var cP:Number = e.target.mouseX / 380 * length;
			if (cP <= _sound.length)
			{
				currentSoundProgress =  cP;
				_soundChannel.stop();
				_soundChannel = _sound.play(currentSoundProgress);
				_soundChannel.addEventListener(Event.SOUND_COMPLETE, playingComplete);
				resumeVolume();
				playBtn.visible = false;
				pauseBtn.visible = true;
				TweenMax.to(soundBtn, 0, { tint:0xFFFFFF } );
			}
		}
		
		// Sound spectrum control
		private function ssUpdateHandler(e:TimerEvent):void
		{
			lsp.graphics.clear();
			lsp.graphics.lineStyle(SpectrumLineWidth, SpectrumLineColor);
			lsp.graphics.moveTo(-1, 75);
			SoundMixer.computeSpectrum(ss);
			for(var i:uint = 0; i < 478; i++)
			{
				var num:Number = -ss.readFloat() * 50 + 75;
				lsp.graphics.lineTo(i, num);
			}
		}
				
	}
	
}