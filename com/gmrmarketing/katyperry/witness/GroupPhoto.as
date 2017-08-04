package com.gmrmarketing.katyperry.witness
{
	import flash.events.*;
	import flash.display.*;
	
	
	public class GroupPhoto extends EventDispatcher
	{
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		
		
		public function GroupPhoto()
		{
			clip = new groupPhoto();
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
			
			clip.btnFilter.addEventListener(MouseEvent.MOUSE_DOWN, addFilter, false, 0, true);
			clip.btnNoFilter.addEventListener(MouseEvent.MOUSE_DOWN, removeFilter, false, 0, true);
		}
		
		
		private function addFilter(e:MouseEvent):void
		{
			
		}
		
		
		private function removeFilter(e:MouseEvent):void
		{
			
		}
		
	}
	
}z