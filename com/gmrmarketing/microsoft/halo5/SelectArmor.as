
package com.gmrmarketing.microsoft.halo5
{	
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class SelectArmor extends EventDispatcher
	{
		public static const COMPLETE:String = "TakePhotoComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var armorChoice:String;
		private var dustContainer:Sprite;
		
		
		public function SelectArmor()
		{
			clip = new mcSelectArmor();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
				
			}			
			
			clip.b1.addEventListener(MouseEvent.MOUSE_DOWN, selectBlue1, false, 0, true);
			clip.b2.addEventListener(MouseEvent.MOUSE_DOWN, selectBlue2, false, 0, true);
			clip.r1.addEventListener(MouseEvent.MOUSE_DOWN, selectRed1, false, 0, true);
			clip.r2.addEventListener(MouseEvent.MOUSE_DOWN, selectRed2, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}				
			}
			
			clip.b1.removeEventListener(MouseEvent.MOUSE_DOWN, selectBlue1);
			clip.b2.removeEventListener(MouseEvent.MOUSE_DOWN, selectBlue2);
			clip.r1.removeEventListener(MouseEvent.MOUSE_DOWN, selectRed1);
			clip.r2.removeEventListener(MouseEvent.MOUSE_DOWN, selectRed2);
		}
		
		
		/**
		 * Returns a string armor choice. One of:
		 * b1, b2, r1, r2
		 */
		public function get armor():String
		{
			return armorChoice;
		}
		
		
		private function selectBlue1(e:MouseEvent):void
		{
			armorChoice = "b1";
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function selectBlue2(e:MouseEvent):void
		{
			armorChoice = "b2";
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function selectRed1(e:MouseEvent):void
		{
			armorChoice = "r1";
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function selectRed2(e:MouseEvent):void
		{
			armorChoice = "r2";
			dispatchEvent(new Event(COMPLETE));
			
		}
		
	}
	
}