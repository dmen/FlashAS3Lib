/**
 * Singleton interests manager
 * used by Main and Map
 */
package com.gmrmarketing.empirestate.ilny
{
	
	public class InterestsManager
	{
		private static var instance:InterestsManager;
		private static var myInterests:Array;
		
		
		public function InterestsManager(p_key:SingletonBlocker){}
		
		
		/**
		 * Returns the single instance
		 * @return
		 */
		public static function getInstance():InterestsManager 
		{
			myInterests = [];
			
			if (instance == null) {
				instance = new InterestsManager(new SingletonBlocker());
			}
			return instance;
		}
		
		
		public function add(newInterest:Object):void
		{
			myInterests.push(newInterest);
			
			trace("new interest", newInterest.name);
		}
		
		
		/**
		 * rerurns true if the the passed in interest is already in the list
		 * @param	interest
		 * @return
		 */
		public function hasInterest(interest):Boolean
		{
			if (myInterests.indexOf(interest) != -1) {
				return true;
			}else {
				return false;
			}
		}
		
		
		public function get interests(){}
	}
	
}

internal class SingletonBlocker {}