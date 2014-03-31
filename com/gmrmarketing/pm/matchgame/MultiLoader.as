/**
 * Loads a bunch of items into the local cache * 
 * Dispatches a multiComplete event when complete
 */

package com.gmrmarketing.pm.matchgame
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	
	
	public class MultiLoader extends EventDispatcher
	{
		private var myItems:Array;
		private var myLoader:Loader;
		
		public static const MULTI_COMPLETE:String = "MultiLoaderComplete";
		
		
		/**
		 * Constructor
		 */
		public function MultiLoader()
		{
			myItems = new Array();
			myLoader = new Loader();
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, itemLoaded);			
		}
		
		
		/**
		 * Call to begin the loading process
		 */
		public function beginLoading(items:Array = null):void
		{
			myItems = items;
			if(myItems.length){
				loadItem();
			}else {
				throw new Error("No items to load."); 
			}
		}
		
		
		/**
		 * Loads the first item in the myItems array
		 */
		private function loadItem():void
		{					
			myLoader.load(new URLRequest(myItems.splice(0, 1)[0]));
		}
		
		
		/**
		 * Called on Event.COMPLETE when an item is finished loading
		 * Calls loadItem if there are more items remaining in myItems
		 * 
		 * @param	e Event
		 */
		private function itemLoaded(e:Event):void
		{			
			if (myItems.length > 0) {
				loadItem();
			}else {
				myLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, itemLoaded);
				dispatchEvent(new Event(MULTI_COMPLETE));
			}
		}
	}	
}