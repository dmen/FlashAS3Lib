package com.gmrmarketing.katyperry.witness
{
	import flash.display.*;
	import flash.events.*;
	
	
	public class CurrentCustomer extends EventDispatcher
	{
		public static const COMPLETE:String = "currentComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var selection:Boolean;
		
		
		public function CurrentCustomer()
		{
			clip = new currentCust();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			clip.btnYes.addEventListener(MouseEvent.MOUSE_DOWN, selectedYes, false, 0, true);
			clip.btnNo.addEventListener(MouseEvent.MOUSE_DOWN, selectedNo, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
		}
		
		
		public function get customer():Boolean
		{
			return selection;
		}
		
		
		private function selectedYes(e:MouseEvent):void
		{
			selection = true;
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function selectedNo(e:MouseEvent):void
		{
			selection = false;
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}