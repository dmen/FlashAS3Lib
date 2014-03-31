/**
 * The Player
 * 
 * Kleenex Achoo Game
 */

package com.gmrmarketing.achoo
{ 
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Stage;	
	
	
	public class Kleenex extends Sprite
	{ 
		private var gameRef:Sprite;
		private var ease:Number = 12;
		private var engine:Engine;
	
		
		/**
		 * CONSTRUCTOR
		 * 
		 * @param	gameRef Reference to the game sprite for mouse polling
		 * @param	engRef Reference to the Engine
		 */
		public function Kleenex(gameRef:Sprite, engRef:Engine) : void
		{			
			this.gameRef = gameRef;
			this.engine = engRef;					
		}
		
		public function center():void
		{
			x = Engine.GAME_WIDTH / 2;
			y = Engine.GAME_HEIGHT - 92;	
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
		
		public function removeSelf() : void 
		{
			if (gameRef.contains(this)){
				gameRef.removeChild(this);
			}
		}

		/**
		 * EnterFrame loop - positions the player according to the mouse x position
		 * 
		 * @param	e EnterFrame event
		 */
		private function loop(e:Event) : void
		{ 			
			var delta:Number = gameRef.mouseX - x;		 
			x += delta / ease;
			
			//limit movement to game sprite edges
			if (x < 0) { x = 0; }
			if (x > Engine.GAME_WIDTH ) { x = Engine.GAME_WIDTH; }
			
			
			//hit Test against all bugs on stage - if a hit is detected call incGets, play
			//the player animation, and remove the bug from the game
			var b:Array = engine.getBugs();
			for (var i = 0; i < b.length; i++){
				if (hitTestObject(b[i].getHit()))
				{					
					engine.incGets();					
					b[i].removeSelf();
					break;
				}
			}
			
			//hit test against bonus
			if (engine.isBonusActive()) {
				var bo:Bonus = engine.getBonus();
				if (hitTestObject(bo.getHit())) {
					engine.incBonus();					
					bo.removeSelf();
				}
			}
		} 
	} 
}