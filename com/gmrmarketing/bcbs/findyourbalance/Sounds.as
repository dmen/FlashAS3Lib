package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class Sounds
	{
		private var iconFall:Sound;
		private var iconFall2:Sound;
		private var iconFall3:Sound;
		private var bonus1:Sound;
		private var bonus2:Sound;
		private var bonus3:Sound;
		private var bonusDone:Sound; 
		private var hitShield:Sound;
		private var endLevel:Sound;
		private var avSound:Sound;
		private var countSound:Sound;
		private var iconPlank:Sound;
		private var lightn1:Sound;
		private var lightn2:Sound;
		private var pi:Sound;//player icon
		
		private var musicChannel:SoundChannel;
		private var effectChannel:SoundChannel;
		private var introMusic:Sound;
		private var l1Music:Sound;
		private var l2Music:Sound;
		private var l3Music:Sound;
		private var vol:SoundTransform;
		
		private var r:Number;
		
		
		public function Sounds()
		{
			iconFall = new soundIconFall();
			iconFall2 = new soundIconFall2();
			iconFall3 = new soundIconFall3();
			bonus1 = new bonusHorizon();
			bonus2 = new bonusCross();
			bonus3 = new bonusSkull();
			bonusDone = new bonusEnd();
			hitShield = new shieldHit();
			endLevel = new levelEnd();
			avSound = new avPick();
			countSound = new count();
			iconPlank = new icPlank();
			lightn1 = new light1();
			lightn2 = new light2();
			pi = new playerIconSound();
			
			musicChannel = new SoundChannel();
			effectChannel = new SoundChannel();
			introMusic = new musicIntro();
			l1Music = new musicL1();
			l2Music = new musicL2();
			l3Music = new musicL3();
		}
		public function plankHit():void
		{
			iconPlank.play();
		}
		public function playIntroMusic():void
		{
			stopMusic();
			//vol = new SoundTransform(.5);
			musicChannel = introMusic.play(0, 50000);
			//musicChannel.soundTransform = vol;
		}
		public function playL1Music():void
		{
			stopMusic();
			//vol = new SoundTransform(1);
			musicChannel = l1Music.play(0, 50000);
			//musicChannel.soundTransform = vol;
		}
		public function playL2Music():void
		{
			stopMusic();
			//vol = new SoundTransform(1);
			musicChannel = l2Music.play(0, 50000);
			//musicChannel.soundTransform = vol;
		}
		public function playL3Music():void
		{
			stopMusic();
			//vol = new SoundTransform(1);
			musicChannel = l3Music.play(0, 50000);
			//musicChannel.soundTransform = vol;
		}
		public function stopMusic():void
		{
			musicChannel.stop();
		}
		
		public function dropIcon():void
		{
			r = Math.random();
			if(r < .6){
				iconFall.play();
			}else if (r < .3) {
				iconFall2.play();
			}else {
				//> .6
				iconFall3.play();
			}
		}
		
		public function iconHitPlayer():void
		{
			pi.play();
		}
		
		public function playThunder():void
		{
			vol = new SoundTransform(.6);			
			if (Math.random() < .5) {
				effectChannel = lightn1.play();
			}else {
				effectChannel = lightn2.play();
			}
			effectChannel.soundTransform = vol;
		}
		
		public function playBonus(lvl:int):void
		{
			switch(lvl) {
				case 1:
					bonus1.play();
					break;
				case 2:
					bonus2.play();
					break;
				case 3:
					bonus3.play();
					break;
			}
		}
		
		public function bonusOver():void
		{
			bonusDone.play();
		}
		
		public function shieldSound():void
		{
			hitShield.play();
		}
		
		public function playerDead():void
		{
			endLevel.play();
		}
		
		public function pickAvatar():void
		{
			avSound.play();
		}
		
		public function countBeep():void
		{
			countSound.play();
		}
		
	}
	
}