package com.gmrmarketing.comcast.mlb
{
	import adobe.utils.CustomActions;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class Batter extends MovieClip
	{
		private var engineRef:Engine;
		private var balls:Array;
		private var swinging:Boolean = false;
	
		
		
		public function Batter(eRef:Engine)
		{
			engineRef = eRef;
			
			//southpaw
			x = 981;
			y = 240;
			width = 293;
			height = 1078;
			
			//philly fanatic
			//x = 931;
			//y = 310;
			//width = 292;
			//height = 881;
			
			//pirates
			//x = 938;
			//y = 261;
			//width = 295;
			//height = 787;
		}
		
		
		
		/**
		 * Called from Engine
		 */
		public function swing():void
		{			
			swinging = true;
			gotoAndPlay(2);
			addEventListener(Event.ENTER_FRAME, checkForHit, false, 0, true);
		}
		
		
		
		/**
		 * Called from frame 1 script on batter
		 */
		public function swingDone():void
		{			
			swinging = false;
			removeEventListener(Event.ENTER_FRAME, checkForHit);			
		}
		
		
		
		/**
		 * Called from Engine
		 * @return
		 */
		public function isSwinging():Boolean
		{
			return swinging;
		}
		
		
		
		/**
		 * Called from EnterFrame event when the batter is swinging
		 * @param	e
		 */
		private function checkForHit(e:Event):void
		{			
			balls = engineRef.getBalls();
			var l:int = balls.length;
			for (var i = 0; i < l; i++) {
				if (hit.hitTestObject(balls[i])) {
					engineRef.ballHit(i);
					//remove listener so only one ball per swing is hit
					removeEventListener(Event.ENTER_FRAME, checkForHit);					
					break;
				}
			}			
		}
		
	}
	
}