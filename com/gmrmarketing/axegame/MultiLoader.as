/**
 * Loads a bunch of items into the local cache
 * 
 * Dispatches a multiComplete event when complete
 */

package com.gmrmarketing.axegame
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	
	
	public class MultiLoader extends EventDispatcher
	{
		private var myItems:Array;
		private var myLoader:Loader;
		
		
		/**
		 * Constructor
		 * 
		 * @param	items Array of items to load
		 */
		public function MultiLoader(items:Array)
		{
			myItems = items;
			myLoader = new Loader();
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, itemLoaded);			
			loadItem();
		}
		
		
		/**
		 * Loads the first item in the myItems array
		 */
		private function loadItem()
		{					
			myLoader.load(new URLRequest(myItems.splice(0, 1)[0]));
		}
		
		
		/**
		 * Called on Event.COMPLETE when an item is finished loading
		 * Calls loadItem if there are more items remaining in myItems
		 * 
		 * @param	e Event
		 */
		private function itemLoaded(e:Event)
		{			
			if (myItems.length > 0) {
				loadItem();
			}else {
				done();
			}
		}
		
		
		/**
		 * Called by itemLoaded when the myItems array is empty
		 */
		private function done()
		{
			myLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, itemLoaded);
			dispatchEvent(new Event("multiComplete"));
		}
	}	
}