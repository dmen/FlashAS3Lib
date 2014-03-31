/**
 * Instantiated by Main
 * Ambient sound
 * Waves, seagulls
 */

package com.sagecollective.corona.atp
{	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.events.*;
	import flash.utils.Timer;
	
	public class AmbientSound
	{
		private var wavesPlaying:Boolean = false;		
		private var waves:Sound;
		private var waveChannel:SoundChannel;
		private var waveVolume:SoundTransform;
		private var waveTimer:Timer;
		
		private var gullTimer:Timer;
		private var gullSound1:Sound;
		private var gullSound2:Sound;
		private var gullSound3:Sound;
		private var gullVolume:SoundTransform;
		
		
		public function AmbientSound()
		{
			gullSound1 = new gull1();//lib clips
			gullSound2 = new gull2();
			gullSound3 = new gull3();
			gullVolume = new SoundTransform(.4);
			
			waveVolume = new SoundTransform(.85);
			waves = new the_waves();//lib clip
			
			waveTimer = new Timer(5000);
			waveTimer.addEventListener(TimerEvent.TIMER, playWaves, false, 0, true);
			waveTimer.start();
			
			gullTimer = new Timer(10000);
			gullTimer.addEventListener(TimerEvent.TIMER, playGull, false, 0, true);
			gullTimer.start();
		}
		
		
		private function playWaves(e:TimerEvent):void
		{		
			if(!wavesPlaying){
				wavesPlaying = true;
				waveChannel = waves.play(0, 1, waveVolume);
				waveChannel.addEventListener(Event.SOUND_COMPLETE, wavesDone, false, 0, true);
			}
		}
		
		
		private function wavesDone(e:Event):void
		{
			wavesPlaying = false;
		}
		
		
		
		private function playGull(e:TimerEvent):void
		{
			var r:Number = Math.random();
			
			if (r < .33) {
				gullSound1.play(0, 0, gullVolume);
			}else if ( r < .66) {
				gullSound2.play(0, 0, gullVolume);
			}else {
				gullSound3.play(0, 0, gullVolume);
			}
		}
	}
	
}