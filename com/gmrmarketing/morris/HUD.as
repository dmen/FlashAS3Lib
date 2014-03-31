package com.gmrmarketing.morris
{ 	
	import flash.display.Sprite;
	import flash.text.TextField;
	import gs.TweenLite;
	import gs.easing.*;
	
	
	public class HUD extends Sprite
	{		
		private var me:hud;
		
		/**
		 * Constructor - instantiated by Engine
		 */
		public function HUD() : void 
		{
			me = new hud(); //hud instance in library
			addChild(me);
			me.y = 20;
		}		
		
		
		/**
		 * Resets the hud - 0 score, no checks
		 * Shows the hud graphic on screen - moves it off stage right then slides it on
		 */
		public function resetHud():void
		{	
			showScore(0);
			showStrikes(0);
			showLevel(Engine.getLevel());			
			me.x = 1600;
			TweenLite.to(me, 1.25, { x:Engine.GAME_WIDTH - 15, ease:Bounce.easeOut } );
		}			
		
		
		/**
		 * Displays the score in the HUD
		 * 
		 * @param	score integer score
		 */
		public function showScore(score:int)
		{
			me.theScore.text = String(score);			
		}
		
		
		
		/**
		 * Displays the number of strikes
		 * 
		 * @param	numStrikes 1-3
		 */
		public function showStrikes(numStrikes:int)
		{			
			var xs:String = "";
			for (var i:int = 0; i < numStrikes; i++) {
				xs += "X";
			}
			me.theStrikes.text = xs;
		}
		
		
		
		/**
		 * Shows the level indicator coins
		 * 
		 * @param	level int 1-4
		 */
		public function showLevel(level:int)
		{
			var i:int;
			for (i = 1; i <= 4; i++) {
				me["l" + i].alpha = 0;
			}
			for (i = 1; i <= level; i++) {
				me["l" + i].alpha = 1;
			}
		}
	} 
}