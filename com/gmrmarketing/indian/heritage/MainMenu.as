/**
 * Bottom nav controller
 */
package com.gmrmarketing.indian.heritage
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class MainMenu extends EventDispatcher	
	{
		public static const ITEM_PICKED:String = "menuItemPicked";
		
		private var clip:MovieClip;
		private var bgClip:MovieClip;
		private var items:Array;
		private var btns:Array;
		private var container:DisplayObjectContainer;
		private var selectedIndex:int;
		private var bgShowing:Boolean;
		
		public function MainMenu()
		{
			items = new Array("heritage", "innovation", "racing", "scout", "war", "faithful", "ahead");
			
			clip = new bottomMenu(); //lib clip
			clip.x = 0;
			clip.y = 1080 - clip.height;
			
			bgClip = new menuScreen(); //lib clip
			
			btns = new Array(clip.heritage, clip.innovation, clip.racing, clip.scout, clip.war, clip.faithful, clip.ahead);
			
			bgShowing = true;
		}
		
		
		
		public function show($container:DisplayObjectContainer):void
		{
			container = $container;
			
			if (!container.contains(clip)) {
				container.addChild(bgClip);
				container.addChild(clip);
			}
			
			bgShowing = true;
			
			clip.b1.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			clip.b2.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			clip.b3.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			clip.b4.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			clip.b5.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			clip.b6.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			clip.b7.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			
			bgClip.b1.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			bgClip.b2.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			bgClip.b3.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			bgClip.b4.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			bgClip.b5.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			bgClip.b6.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			bgClip.b7.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
		}
		
		
		
		public function hide():void
		{
			if(container){
				if (container.contains(clip)) {
					container.removeChild(clip);
					container.removeChild(bgClip);
				}
			}
			
			bgShowing = false;
			
			clip.b1.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			clip.b2.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			clip.b3.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			clip.b4.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			clip.b5.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			clip.b6.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			clip.b7.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			
			bgClip.b1.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b2.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b3.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b4.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b5.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b6.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b7.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
		}
		
		
		public function hideBG():void
		{
			if(container){
				if (container.contains(bgClip)) {
					container.removeChild(bgClip);
				}
			}
			
			bgShowing = false;
			
			bgClip.b1.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b2.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b3.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b4.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b5.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b6.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b7.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
		}
		
		public function isBGShowing():Boolean
		{
			return bgShowing;
		}
		
		public function reset():void
		{			
			for (var i:int = 0; i < btns.length; i++) {				
				TweenMax.to(btns[i], 0, { removeTint:true } );				
			}
		}
		
		
		public function getSelection():String
		{
			return items[selectedIndex];
		}
		
		
		private function itemClicked(e:MouseEvent):void
		{
			var m:MovieClip = MovieClip(e.currentTarget);
			selectedIndex = parseInt(String(m.name).substr(1, 1)); //1 - 9
			selectedIndex--; //for array index
			
			reset();
			
			//highlight new one
			TweenMax.to(btns[selectedIndex], 1, { tint:0xffffff } );
			
			dispatchEvent(new Event(ITEM_PICKED));//calls mainMenuSelection() in Main
		}
		
		
	}
	
}