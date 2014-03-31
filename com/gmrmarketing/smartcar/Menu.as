package com.gmrmarketing.smartcar
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenLite;
	import flash.events.*;
	
	

	public class Menu extends MovieClip
	{
		public static const MENU_ITEM_CLICKED:String = "MenuItemClicked";
		public static const READY_CLICKED:String = "ReadyButtonClicked";
		
		//the button clips
		private var buttons:Array;
		private var container:DisplayObjectContainer;
		private var theStep:int = 0;
		private var item:Array;
		
		
		public function Menu($container:DisplayObjectContainer)
		{
			container = $container;
			
			//button name, slider x pos, slider width, yellow pointer position
			buttons = new Array([btnScene, -10, 319, 94], [btnWrap, 357, 294, 459], [btnSound, 692, 408, 850], [btnReady, 1115, 354, 1243]);
		}		
		
		
		public function show():void
		{
			x = 30;
			y = 1002;
			
			if (!container.contains(this)) {
				container.addChild(this);
			}			
		
			
			var m:MovieClip;
			for (var i:int = 0; i < buttons.length; i++) {
				
				m = MovieClip(buttons[i][0]);
				m.step = i;			
				m.addEventListener(MouseEvent.CLICK, itemClicked, false, 0, true);				
			}
			
			itemClicked();
		}
		
		public function hide():void
		{
			if (container.contains(this)) {
				container.removeChild(this);
			}
		}
		
		
		private function itemClicked(e:MouseEvent = null):void
		{
			if (e == null) {
				theStep = 0;
				item = buttons[0];
				dispatchEvent(new Event(MENU_ITEM_CLICKED));
				moveSlider();
			}else {
				if (e.currentTarget.step == 3) {
					//ready button - special case					
					dispatchEvent(new Event(READY_CLICKED));
				}else{
					theStep = e.currentTarget.step;
					item = buttons[theStep];
					dispatchEvent(new Event(MENU_ITEM_CLICKED));
					moveSlider();
				}
			}
		}
		
		public function readyOK():void
		{			
			theStep = 3;
			item = buttons[3];
			moveSlider();
		}
		
		private function moveSlider():void
		{
			TweenLite.to(slider, .75, { x:item[1], width:item[2] } );
			TweenLite.to(pointer, .75, { x:item[3], delay:.1 } );			
		}	
			
		
		/**
		 * Returns the index of the last menu item clicked 0 - 3
		 * @return
		 */
		public function getStep():int
		{
			return theStep;
		}
		
	}
	
}