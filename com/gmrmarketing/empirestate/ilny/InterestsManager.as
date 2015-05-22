/**
 * Singleton interests manager
 * used by Main, Map & BucketList
 * 
 * Keeps track of the users bucket list
 */
package com.gmrmarketing.empirestate.ilny
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class InterestsManager extends EventDispatcher
	{
		public static const CHANGED:String = "ListChages";
		
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
		}
		
		
		/**
		 * rerurns true if the the passed in interest is already in the list
		 * @param	interest
		 * @return
		 */
		public function hasInterest(interest:Object):Boolean
		{
			if (myInterests.indexOf(interest) != -1) {
				return true;
			}else {
				return false;
			}
		}
		
		
		/**
		 * returns an array of interest objects
		 */
		public function get interests():Array
		{
			return myInterests;
		}
		
		
		public function remove(i:int):void
		{
			myInterests.splice(i, 1);
			dispatchEvent(new Event(CHANGED));
		}
		
		
		public function clear():void
		{
			myInterests = [];
		}
		
	}
	
}

internal class SingletonBlocker {}