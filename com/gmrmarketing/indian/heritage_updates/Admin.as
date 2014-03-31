/**
 * Admin menu at upper right
 * Updated 11/2012
 * 		removed road ahead
 */
package com.gmrmarketing.indian.heritage_updates
{		
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.*;
	
	public class Admin extends EventDispatcher
	{
		public static const ITEM_SELECTED:String = "menuItemSelected";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var items:Array;
		private var selectedIndex:int;
		
		
		public function Admin()
		{
			clip = new adminMenu();
			clip.x = 1554;
			clip.y = 32;
			
			items = new Array("heritage", "innovation", "racing", "scout", "war", "faithful", "all");
		}
		
		
		public function show($container:DisplayObjectContainer):void
		{
			container = $container;
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.b1.addEventListener(MouseEvent.MOUSE_DOWN, itemPicked, false, 0, true);
			clip.b2.addEventListener(MouseEvent.MOUSE_DOWN, itemPicked, false, 0, true);
			clip.b3.addEventListener(MouseEvent.MOUSE_DOWN, itemPicked, false, 0, true);
			clip.b4.addEventListener(MouseEvent.MOUSE_DOWN, itemPicked, false, 0, true);
			clip.b5.addEventListener(MouseEvent.MOUSE_DOWN, itemPicked, false, 0, true);
			clip.b6.addEventListener(MouseEvent.MOUSE_DOWN, itemPicked, false, 0, true);
			
			clip.b7.addEventListener(MouseEvent.MOUSE_DOWN, itemPicked, false, 0, true);
			clip.b8.addEventListener(MouseEvent.MOUSE_DOWN, itemPicked, false, 0, true);
		}
	
		
		public function hide():void
		{
			if (container) {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}
			clip.b1.removeEventListener(MouseEvent.MOUSE_DOWN, itemPicked);
			clip.b2.removeEventListener(MouseEvent.MOUSE_DOWN, itemPicked);
			clip.b3.removeEventListener(MouseEvent.MOUSE_DOWN, itemPicked);
			clip.b4.removeEventListener(MouseEvent.MOUSE_DOWN, itemPicked);
			clip.b5.removeEventListener(MouseEvent.MOUSE_DOWN, itemPicked);
			clip.b6.removeEventListener(MouseEvent.MOUSE_DOWN, itemPicked);
			
			clip.b7.removeEventListener(MouseEvent.MOUSE_DOWN, itemPicked);
			clip.b8.removeEventListener(MouseEvent.MOUSE_DOWN, itemPicked);
		}
		
		public function getSection():String
		{
			return items[selectedIndex];
		}
		
		
		private function itemPicked(e:MouseEvent):void
		{
			var m:MovieClip;
			m = MovieClip(e.currentTarget);
			var selInd:int = parseInt(String(m.name).substr(1, 1)); //1 - 8
			
			//turn off currently selected button
			for (var i:int = 1; i < 9; i++) {
				clip["b" + i].alpha = 0;
			}			
			
			if (selInd == 8) {
				//save and exit button picked
				dispatchEvent(new Event(ITEM_SELECTED));
			}else {
				m.alpha = .2; //set current button to 20% alpha
				selectedIndex = selInd - 1; //0 - 6
			}
			
			
		}
		
	}
	
}