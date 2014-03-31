/**
 * downloads items to the local cache so they are immediately available when requested
 */
package com.gmrmarketing.utilities
{
	import flash.display.Loader;
	import flash.events.*;	
	import flash.net.URLRequest;

	public class Cacher
	{		
		private var items:Array;
		private var curIndex:int;
		private var loader:Loader;
		private var doneCaching:Boolean;
		private var isPaused:Boolean;
		private static var instance:Cacher;

		
		
		public static function getInstance():Cacher {
         if (instance == null) {
            instance = new Cacher(new SingletonBlocker());
          }
         return instance;
       }

		public function Cacher(p_key:SingletonBlocker)
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, itemCached, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, cacheError, false, 0, true);
		}
		
		
		public function begin($items:Array):void
		{
			items = $items;
			curIndex = 0;
			doneCaching = false;
			cacheNextItem();
		}
		
		
		public function pause():void
		{
			if(!isPaused){
				isPaused = true;
				loader.close();
			}
		}
		
		
		public function resume():void
		{
			cacheNextItem();
		}
		
		
		public function isComplete():Boolean
		{
			return doneCaching;
		}
		
		
		private function cacheNextItem():void
		{
			if (curIndex < items.length) {
				isPaused = false;
				var thisItem = items[curIndex];
				loader.load(new URLRequest(thisItem));
			}else {
				//done
				doneCaching = true;
			}
		}
		
		
		private function itemCached(e:Event = null):void
		{
			curIndex++;
			cacheNextItem();
		}
		
		private function cacheError(e:IOErrorEvent):void
		{
			//url not found - move on to the next item
			itemCached();
		}
		
	}
	
}

internal class SingletonBlocker {}