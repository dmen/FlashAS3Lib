/**
 * Heads Up Display
 * 
 * For updating score, level, achoo meter
 * 
 * Kleenex Achoo Game
 */

package com.gmrmarketing.achoo
{ 
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class HUD extends Sprite
	{
		private var startY:uint;
		
		/**
		 * CONSTRUCTOR
		 * Positions the HUD on the far right side
		 */
		public function HUD() : void
		{	
		}		
		
		
		public function reset():void
		{
			startY = 389; //arrow position in the clip
			x = Engine.GAME_WIDTH;
			addEventListener(Event.ENTER_FRAME, eyeLoop);
		}
		
		/**
		 * Displays the level
		 * Uses a mask to color the text
		 * 
		 * @param	lvl Integer
		 */	
		public function showLevel(lvl:uint)
		{
			levelText.text = String(lvl);
			levelGradient.mask = levelText;
		}		
		
		
		/**
		 * Displays the player's score
		 * Uses a mask to color the text
		 * 
		 * @param	score integer score
		 */
		public function showScore(score:uint)
		{
			scoreText.text = String(score);
			scoreGradient.mask = scoreText;
		}

		
		/**
		 * Sets the meter position
		 * 
		 * @param	misses integer number of misses
		 * @param	maxMisses integer maximum misses before sneezing
		 */
		public function updateMeter(misses:uint, maxMisses:uint)
		{			
			arrow.y = startY - Math.min(280, misses / maxMisses * 280);			
		}
		
		
		/**
		 * Called from Engine when the HUD is removed
		 */
		public function kill()
		{
			this.removeEventListener(Event.ENTER_FRAME, eyeLoop);			
		}
		
		
		/**
		 * Event Listener called on enter frame
		 * @param	e Enter Frame event
		 */
		private function eyeLoop(e:Event)
		{
			var reyeX = 102; //starting x pos of eyes in the hud
			var leyeX = 139;
			
			var eyeX:Number;
			
			if (stage.mouseX < 530) {
				eyeX = (530 - stage.mouseX) / 100;
				reye.x = reyeX - eyeX;
				leye.x = leyeX - eyeX;				
			}else {
				eyeX = (stage.mouseX - 530) / 100;
				reye.x = reyeX + eyeX;
				leye.x = leyeX + eyeX;	
			}
			//trace(eyeX);
		}
		
	} 
}