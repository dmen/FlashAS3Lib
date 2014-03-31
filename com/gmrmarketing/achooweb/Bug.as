/**
 * Bug Class
 * 
 * Kleenex Achoo Game
 */

package com.gmrmarketing.achooweb
{ 
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;

 
	public class Bug extends Sprite
	{ 
		private var gameRef:Sprite;
		private var vy:Number = 1; //y velocity
		private var ay:Number = .1; //y acceleration
		
		private var engine:Engine;
		
		private var bug:Bitmap;
		private var chute:Bitmap;
		private var hit:MovieClip;		
		
		private var rot:Number = 1.8;
		
		/**
		 * CONSTRUCTOR
		 */
		public function Bug(which:String) : void
		{		
			chute = new Bitmap(new Parachute(60, 60), "auto", true);
			addChild(chute);
			chute.x = -30;
			chute.y = -20;
			
			hit = new Hit(); //for collision detection
			
			if(which == "A"){
				bug = new Bitmap(new BugA(50, 56), "auto", true);
				bug.x = -20;
				bug.y = 22;
				hit.x = -12;				
			}else {
				bug = new Bitmap(new BugB(50, 62), "auto", true);
				bug.x = -15;
				bug.y = 12;
				hit.x = -5;				
			}			
			addChild(bug);
			
			hit.y = 36;
			hit.alpha = 0;
			addChild(hit);			
		}
		
		public function getHit():MovieClip
		{
			return MovieClip(hit);
		}
	
		
		/**
		 * Inititalize variables and positions bug
		 * @param	gRef Reference to the game sprite	
		 * @param	eng Engine ref - so incMisses can be called
		 */
		public function init(gRef:Sprite, eng:Engine):void
		{
			this.gameRef = gRef;			
			this.engine = eng;
 
			//50 pixel buffer on left and right edges
			x = Math.max(50, Math.random() * (Engine.GAME_WIDTH - 50));
			y = -35;
			
			scaleX = scaleY = Math.random() * .6 + .75;
			
			gameRef.addChild(this);
			
			listen();
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
		 * Enter Frame loop
		 * Animates bug and checks if bug has gone off stage
		 * @param	e EnterFrame event
		 */
		public function loop(e:Event) : void
		{
			rotation += rot;
			if(rot > 0){
				if(rotation > 25){rot *= -1;}
			}else{
				if(rotation < -25){ rot *=-1;}
			}
	
			vy += ay;
			y += vy;
			
			if (y > Engine.GAME_HEIGHT) {
				//got past the player
				removeSelf();
				engine.incMisses();
			}			
		}
 
		
		/**
		 * Called when bug goes off stage, removes clip from the game sprite
		 * Triggers REMOVED_FROM_STAGE listener in engine to remove bug from 
		 * the engines bug list
		 * 
		 * Called from Kleenex when a bug is caught
		 */
		public function removeSelf() : void {
 
			removeEventListener(Event.ENTER_FRAME, loop);
			
			removeChild(hit);
			removeChild(bug);
			removeChild(chute);
			
			if (gameRef.contains(this)){
				gameRef.removeChild(this);
			}
		}
 
	}
 
}