package com.gmrmarketing.katyperry.witness
{
	import flash.display.*;
	import flash.events.*;
	
	public class Selector extends EventDispatcher
	{
		public static const COMPLETE:String = "selectorComplete";
		
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		
		private var soloGroup:String = "solo";
		
		
		public function Selector()
		{
			clip = new selector();			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function get selection():String
		{
			return soloGroup;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			clip.btnSolo.addEventListener(MouseEvent.MOUSE_DOWN, selectSolo, false, 0, true);
			clip.btnGroup.addEventListener(MouseEvent.MOUSE_DOWN, selectGroup, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			
			clip.btnSolo.removeEventListener(MouseEvent.MOUSE_DOWN, selectSolo);
			clip.btnGroup.removeEventListener(MouseEvent.MOUSE_DOWN, selectGroup);
		}
		
		
		private function selectSolo(e:MouseEvent):void
		{
			soloGroup = "solo";
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function selectGroup(e:MouseEvent):void
		{
			soloGroup = "group";
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}