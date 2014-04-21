package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.media.Sound;
	
	public class Sounds
	{
		private var iconFall:Sound;
		private var bonus1:Sound;
		private var bonus2:Sound;
		private var bonus3:Sound;
		private var bonusDone:Sound; 
		private var hitShield:Sound;
		private var endLevel:Sound;
		private var avSound:Sound;
		private var countSound:Sound;
		
		
		public function Sounds()
		{
			iconFall = new soundIconFall();
			bonus1 = new bonusHorizon();
			bonus2 = new bonusCross();
			bonus3 = new bonusSkull();
			bonusDone = new bonusEnd();
			hitShield = new shieldHit();
			endLevel = new levelEnd();
			avSound = new avPick();
			countSound = new count();
		}
		
		
		public function dropIcon():void
		{
			iconFall.play();
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