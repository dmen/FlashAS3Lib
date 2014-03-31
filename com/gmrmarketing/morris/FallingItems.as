/**
 * Used for the falling items in the attract loop only
 */

package com.gmrmarketing.morris
{	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class FallingItems extends Sprite
	{
		private var items:Array;
		private var theGame:Sprite;
		
		public function FallingItems(gameRef:Sprite)
		{
			theGame = gameRef;
			items = new Array();			
		}
		
		public function listen():void
		{			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function quiet():void
		{
			removeEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function loop(e:Event) : void
		{			
			if (Math.random() < .08) {
				
				var theX:int = Math.floor(Engine.FULL_WIDTH * Math.random());
				var it:Item;
				
				var i = Math.random();
				if(i < .33){
					it = new GoodItem(theGame, theX, true);			
					items.push(it);	
				}else if (i < .66) {
					it = new NeutralItem(theGame, theX, true);			
					items.push(it);	
				}else {
					it = new BadItem(theGame, theX, true);			
					items.push(it);	
				}
			}	
		}
		
		public function removeItems() {
			trace("FallingItems:removeItems");
			var it:Item;
			while(items.length) {
				it = items.shift();				
				it.removeSelf();
			}
		}		
	}	
}