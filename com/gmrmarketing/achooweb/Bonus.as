/**
 * Floating Kleenex Box bonus
 * 
 */

package com.gmrmarketing.achooweb
{ 
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
 
	public class Bonus extends Sprite
	{ 
		private var gameRef:Sprite;
		
		private var vy:Number = 1; //y velocity
		private var ay:Number = .05; //y acceleration
		private var target:Kleenex;		
		
		private var chute:Bitmap;
		private var bonus:Bitmap;
		private var hit:MovieClip;	
		
		private var rot:Number = 1.8;

		/**
		 * CONSTRUCTOR
		 */
		public function Bonus(gameRef:Sprite) : void
		{			
			this.gameRef = gameRef;			
			
			hit = new Hit(); //for collision detection			
			
			bonus = new Bitmap(new BonusA(45, 78), "auto", true);
			addChild(bonus);
			bonus.x = -52;
			bonus.y = 25;
			bonus.rotation = -35;
			
			chute = new Bitmap(new Parachute(60, 60), "auto", true);
			addChild(chute);
			chute.x = -30;
			chute.y = -20;
			
			hit.x = -20;
			hit.y = 37;
			hit.alpha = 0;
			addChild(hit);
			
			//buffer on left and right edges
			x = Math.max(50, Math.random() * (Engine.GAME_WIDTH - 50));
			y = -35;
			
			gameRef.addChild(this);
			
			listen();
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
			rotation += rot;
			if(rot > 0){
				if(rotation > 25){rot *= -1;}
			}else{
				if(rotation < -25){rot *=-1;}
			}	
			
			vy += ay;
			y += vy;			
			if (y > Engine.GAME_HEIGHT) {
				//got past the player
				removeSelf();				
			}			
		}
 
		/**
		 * Adds the EnterFrame listener so loop method is called
		 */
		public function listen():void
		{
			addEventListener(Event.ENTER_FRAME, loop); 
		}
		
		
		/**
		 * Removes EnterFrame listener
		 */
		public function quiet():void
		{
			removeEventListener(Event.ENTER_FRAME, loop); 
		}
		
		/**
		 * Called when bug goes off stage, removes clip from the game sprite
		 * Triggers REMOVED_FROM_STAGE listener in engine to remove bug from 
		 * the engines bug list
		 */
		public function removeSelf() : void
		{
			removeChild(hit);
			removeChild(bonus);
			removeChild(chute);
			
			removeEventListener(Event.ENTER_FRAME, loop); 
			if (gameRef.contains(this)){
				gameRef.removeChild(this);
			}
			
		}
 
	} 
}