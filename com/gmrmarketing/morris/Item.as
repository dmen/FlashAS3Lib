/**
 * Super class of BadItem, NeutralItem and GoodItem
 */

package com.gmrmarketing.morris
{ 
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import gs.TweenLite;
	import gs.plugins.*;
	
	
	public class Item extends MovieClip
	{ 
		private var theGame:Sprite;	
		private var vy:Number = 1; //y velocity
		private var ay:Number = .08; //y acceleration	
		
		private var theItem:MovieClip;
		
		
		/**
		 * CONSTRUCTOR
		 */
		public function Item(gameRef:Sprite, item:MovieClip, glowColor:Number, xPos:int, isAttract:Boolean) : void
		{		
			theGame = gameRef;			
			theItem = item;
			
			TweenPlugin.activate([GlowFilterPlugin]);
			
			theItem.x = xPos;// Math.max(50, Math.random() * (Engine.GAME_WIDTH - 120));
			theItem.y = -35;
			
			addChild(theItem);
			//theItem.smoothing = true;
			if (isAttract) {
				theGame.addChild(this);
			}else{
				theGame.addChildAt(this, 2); //add items behind game frame and foreground element
			}
			
			TweenLite.to(theItem, 0, { glowFilter: { color:glowColor, alpha:1, blurX:15, blurY:15, strength:2} } );
			
			listen();	
		}
		
		
		
		public function getHit():MovieClip
		{
			return theItem.hit;
		}
 
		
		/**
		 * Adds the EnterFrame listener so loop method is called
		 */
		public function listen():void
		{
			theItem.addEventListener(Event.ENTER_FRAME, loop, false, 0, true); 
		}
		
		
		/**
		 * Removes EnterFrame listener
		 */
		public function quiet():void
		{
			theItem.removeEventListener(Event.ENTER_FRAME, loop); 
		}
		
		
		/**
		 * Enter Frame loop
		 * 
		 * @param	e EnterFrame event
		 */
		private function loop(e:Event) : void
		{
			vy += ay * Engine.getLevel();
			theItem.y += vy;
			
			if (theItem.y > Engine.GAME_HEIGHT + 70) {
				//got past the player
				removeSelf();				
			}	
		} 
		
		
		/**
		 * Remove item from stage - triggers removedFromStage listener in engine
		 * that removes item from the items list
		 */
		public function removeSelf() : void 
		{ 			
			quiet();
			removeChild(theItem);
			theItem = null;
			
			if (theGame.contains(this)) {
				trace("Item: removeSelf - game contains");
				theGame.removeChild(this);
			}
		} 
		
	} 
}