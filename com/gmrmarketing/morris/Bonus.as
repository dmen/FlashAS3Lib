
package com.gmrmarketing.morris
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import gs.TweenLite;
	import gs.plugins.*;

	
	public class Bonus extends MovieClip
	{ 
		private var theGame:Sprite;		
		private var vy:Number = 1; //y velocity
		private var ay:Number = .05; //y acceleration		
		

		/**
		 * CONSTRUCTOR
		 */
		public function Bonus(gameRef:Sprite) : void
		{			
			TweenPlugin.activate([GlowFilterPlugin]);
			theGame = gameRef;
			
			//50 pixel buffer on left and right edges
			x = Math.max(200, Math.random() * (Engine.GAME_WIDTH - 250));
			y = -35;
			
			theGame.addChildAt(this, 3);//add under frame
			TweenLite.to(this, 0, { glowFilter: { color:"0xFFFFFF", alpha:1, blurX:25, blurY:25, strength:3.5, quality:2} } );
			listen();
		}
	
		
		/**
		 * Adds the EnterFrame listener so loop method is called
		 */
		public function listen():void
		{
			addEventListener(Event.ENTER_FRAME, loop, false, 0, true); 
		}
		
		
		/**
		 * Removes EnterFrame listener
		 */
		public function quiet():void
		{
			removeEventListener(Event.ENTER_FRAME, loop); 
		}
		
		
		public function getHit():MovieClip
		{
			return hit;
		}
		
		
		/**
		 * Enter Frame loop, checks if bonus has gone off stage
		 * @param	e EnterFrame event
		 */
		public function loop(e:Event) : void
		{
			vy += ay;
			y += vy;			
			if (y > Engine.GAME_HEIGHT + 70) {
				//got past the player
				removeSelf();				
			}
		}
		
		
		/**
		 * Called when bug goes off stage, removes clip from the game sprite
		 * Triggers REMOVED_FROM_STAGE listener in engine
		 */
		public function removeSelf() : void
		{			
			quiet();
			if (theGame.contains(this)) {
				trace("bonus removed");
				theGame.removeChild(this);
			}			
		} 
	} 
}