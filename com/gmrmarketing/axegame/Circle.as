package com.gmrmarketing.axegame
{	
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	public class Circle
	{		
		private var game:Sprite;
		
		private var myX:uint;
		private var myY:uint;
		private var myRadius:uint;
		private var curAng:Number;
		private var myTimer:Timer;
		
		private var thisCircle:Sprite; //container for all the dots
		
		
		/**
		 * Draws a circle of dots at x,y with the given radius
		 * 
		 * @param	gameRef
		 * @param	theX
		 * @param	theY
		 * @param	theRadius
		 */
		public function Circle(gameRef:Sprite, theX:uint, theY:uint, theRadius:uint = 25)
		{
			game = gameRef;
			thisCircle = new Sprite();
			
			gameRef.addChildAt(thisCircle, 1);
			
			myX = theX;
			myY = theY;
			myRadius = theRadius;			
			
			curAng = 0;
			
			myTimer = new Timer(30);
			myTimer.addEventListener(TimerEvent.TIMER, draw);
			myTimer.start();
		}
		
		
		/**
		 * Removes circle sprite from game reference and then sets it to null so that the
		 * dot instances are gc'd
		 */
		public function remove():void
		{
			if (game.contains(thisCircle)) {
				game.removeChild(thisCircle);
			}
			thisCircle = null;
		}
		
		
		/**
		 * Gets this circle - the sprite containing dots
		 * 
		 * @return Sprite reference
		 */
		public function getCircle():Sprite
		{
			return thisCircle;
		}
		
		
		/**
		 * Called by timer to animate the circle being drawn
		 * Relies on a library clip with a class linkage name of Dot
		 * 
		 * @param	e TimerEvent.TIMER
		 */
		private function draw(e:TimerEvent):void
		{
			var xLoc = myX + Math.cos(curAng) * myRadius;
			var yLoc = myY + Math.sin(curAng) * myRadius;
			
			var myDot = new Dot(); //library clip
			myDot.x = xLoc;
			myDot.y = yLoc;			
			thisCircle.addChild(myDot);
			
			curAng += .3;
			
			if (curAng > 6.28) {
				myTimer.stop();
				myTimer.removeEventListener(TimerEvent.TIMER, draw);
			}
		}
	}	
}