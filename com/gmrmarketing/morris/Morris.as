
package com.gmrmarketing.morris
{ 
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	
	public class Morris extends MovieClip
	{ 
		private var theGame:Sprite;
		private var theEngine:Engine;
		private var ease:Number = 12;
		
		private var lastX:int;
		private var isStopped:Boolean = false;
		private var animTimer:int;
		
		private var invincible:Boolean = false;
		private var invinceTicker:int = 0; 
		
		public function Morris(gameRef:Sprite, engRef:Engine) : void
		{
			theGame = gameRef;
			theEngine = engRef;				
		}
		
		
		public function center():void
		{			
			x = Engine.GAME_WIDTH / 2;
			lastX = x;
			y = Engine.GAME_HEIGHT - 110;		
		}
		
	
		public function listen():void
		{
			addEventListener(Event.ENTER_FRAME, loop); 
		}
		
		
		public function quiet():void
		{
			removeEventListener(Event.ENTER_FRAME, loop);
			gotoAndStop(15);//morris facing you frame
			isStopped = true;
		}
		
		
		/**
		 * turns on invincible mode for 3 seconds
		 */
		public function invincibleOn()
		{
			invincible = true;
			var iTimer:Timer = new Timer(3000, 1);
			iTimer.addEventListener(TimerEvent.TIMER, invincibleOff, false, 0, true);
			iTimer.start();
			invinceTicker = 0;
			alpha = .4;
		}
		
		
		/**
		 * Called by iTimer after 2 seconds
		 * Turns off invincible mode
		 * @param	e TIMER TimerEvent
		 */
		private function invincibleOff(e:TimerEvent)
		{
			invincible = false;
			alpha = 1;
		}
		
		
		public function removeSelf() : void 
		{
			quiet();
			if (theGame.contains(this)) {				
				theGame.removeChild(this);
			}
		}

		
		private function loop(e:Event) : void
		{		
			
			var gX = theGame.mouseX;
			var delta:Number = gX - x;		 
			x += delta / ease;
			
			if (lastX < gX - 20) {
				//moving the mouse to the right
				lastX = gX;
				scaleX = -1;
				if(isStopped){
					gotoAndPlay(1);
					isStopped = false;
					animTimer = getTimer();
				}
			}else if (lastX > gX + 20) {
				//moving to the left
				lastX = gX;
				scaleX = 1;
				if(isStopped){
					gotoAndPlay(1);
					isStopped = false;
					animTimer = getTimer();
				}
			}else {
				//if not moving for more than 1/2 sec, turn front on
				if(getTimer() - animTimer > 500){
					gotoAndStop(15);
					isStopped = true;
				}
			}
			
			//limit movement to game sprite edges
			if (x < 46) { x = 46; }
			if (x > 950 ) { x = 950; }			
			
				
			//hit Test against all items on stage - if a hit is detected call incGets, play
			//the player animation, and remove the bug from the game
			var i:int;
			var a:Array = theEngine.getGoodItems();			
			for (i = 0; i < a.length; i++){
				if (hitTestObject(a[i].getHit()))
				{					
					theEngine.incGets();					
					a[i].removeSelf();
					break;
				}
			}
			var b:Array = theEngine.getNeutralItems();
			for (i = 0; i < b.length; i++){
				if (hitTestObject(b[i].getHit()))
				{					
					//theEngine.incGets(); //nothing for neutral		
					b[i].removeSelf();
					break;
				}
			}
			
			//Don't check for bad item collisions when invincible
			if(!invincible){	
				var c:Array = theEngine.getBadItems();
				for (i = 0; i < c.length; i++){
					if (hitTestObject(c[i].getHit()))
					{					
						theEngine.incStrikes();					
						c[i].removeSelf();
						break;
					}
				}
			}else {
				//invincible -- flash every n frames
				invinceTicker++;
				if (invinceTicker % 7 == 0) {
					if (alpha < 1) {
						alpha = 1;
					}else {
						alpha = .4;
					}
				}
			}
			
			
			//hit test against bonus
			if (theEngine.isBonusActive()) {
				trace("morris - bonus is active");
				var bo:Bonus = theEngine.getBonus();
				if (hitTestObject(bo.getHit())) {
					trace("Morris hit bonus");
					theEngine.incBonus();					
					//bo.removeSelf();
				}
			}
			
		} 
	} 
}