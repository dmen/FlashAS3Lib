package com.gmrmarketing.comcast.mlb
{
	
	import flash.display.MovieClip;	
	import flash.events.Event;
	import com.gmrmarketing.comcast.mlb.Engine;
	import com.greensock.TweenLite;
	
	public class Baseball extends MovieClip
	{
		private var engineRef:Engine;
		private var mySpeed:int;
		private var myRotation:int;
		
		
		
		public function Baseball(eRef:Engine)
		{	
			x = -10;
			y = 430 + Math.random() * 20;  //* 100 for phillies mascot to move balls a little lower
			//y = 470 + Math.random() * 100;  //* 100 for phillies mascot to move balls a little lower
			engineRef = eRef;
			mySpeed = engineRef.getLevel() * 13;
			blur.scaleX = engineRef.getLevel() / 3;
			myRotation = engineRef.getLevel() * 6;			
			addEventListener(Event.ENTER_FRAME, move, false, 0, true);
		}
		
		public function kill():void
		{
			removeEventListener(Event.ENTER_FRAME, move);
		}
		
		/**
		 * Called from engine when the ball is hit by the batter
		 */
		public function hit():void
		{
			removeEventListener(Event.ENTER_FRAME, move);
			
			var theY:Number = Math.random() * 350;
			rotation = 180 + ((350 - theY) * .06);
			
			TweenLite.to(this, 1, { x: -150, y:theY, onComplete:remove } );
		}
		
		
		
		private function move(e:Event):void
		{
			x += mySpeed;
			ball.rotation += myRotation;
			
			if (x > Engine.GAME_WIDTH) {
				//miss				
				engineRef.incrementMisses();
				removeEventListener(Event.ENTER_FRAME, move);
				remove();
			}
		}
		
		
		
		private function remove():void
		{
			engineRef.removeBall(this);
		}		

	}	
}