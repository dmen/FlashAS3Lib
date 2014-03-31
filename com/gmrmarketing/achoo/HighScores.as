/**
 * High Score Manager
 * 
 * Kleenex Achoo Game
 */

package com.gmrmarketing.achoo
{ 	
	import flash.events.Event;
	import flash.net.SharedObject;
		
	
	public class HighScores
	{
		private var theScores:Array;
		private var highScores:SharedObject;
		private var scoreInsert:Number;			
		
		//default scores
		private var defaultScores:Array = new Array( { name:"DWM", score:500 }, { name:"TIM", score:600 }, { name:"NIK", score:700 }, { name:"JAX", score:800 }, { name:"PPN", score:900 }, { name:"ARN", score:1000 }, { name:"LIZ", score:1100 }, { name:"JFK", score:1200 }, { name:"ABE", score:1300 }, { name:"ART", score:1400 } );
		
		
		/**
		* CONSTRUCTOR
		* 
		* @param	gameRef Container reference
		*/
		public function HighScores():void
		{					
			highScores = SharedObject.getLocal("kleenexSneeze");
			
			theScores = highScores.data.scores;			
			
			if (theScores == null) {
				//no score data saved in SO - use default
				theScores = defaultScores;				
			}			
		}
		
		
		/**
		 * Returns the current score list
		 * 
		 * @return Array of score objects with name,score properties
		 */
		public function getScores():Array
		{			
			return theScores;
		}
		
		
		/**
		 * Called from Engine
		 * 
		 * 
		 * @param	playerScore
		 * @return  Integer index in theScores where the players score should be inserted
		 * 			or -1 if the score isn't high enough to make the list
		 */
		public function checkScore(playerScore:uint):int
		{			
			var l:Number = theScores.length - 1;
			var ins:int = -1;
			for (var i:Number = l; i >= 0; i--) {
				
				if(playerScore > theScores[i].score){
					ins = i;
					break;
				}
			}	
			return ins;			
		}		
		
		
		
		
		/**
		 * Adds a high score and saves into the SO
		 * 
		 * Called from Engine
		 * 
		 * @param newScore Unsigned Int to save
		 */
		private function saveScore(initials:String, newScore:uint):void
		{			
			for(var j = 0; j < scoreInsert; j++){
				newScores.push(theScores[j]);
			}
			
			//newScores.push({name:inits.toUpperCase(), score:elapsed});
			
			for(var k = scoreInsert; k < l - 1; k++){
				newScores.push(theScores[k]);
			}
			
			theScores = newScores;
			
			highScores.data.scores = newScores;
			highScores.flush();
		}
		
	} 
}