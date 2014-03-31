package com.gmrmarketing.nissan.canada.ridedrive2013
{
	import flash.display.*;	
	import flash.events.*;
	
	
	public class Admin extends EventDispatcher 
	{
		public static const ADMIN_CLOSED:String = "adminClosed";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var showCar:Boolean;
		private var numSpins:int;
		private var numFails:int;
		
		public function Admin()
		{
			clip = new mcAdmin();
			clip.addEventListener(Event.ADDED_TO_STAGE, updateAdmin);
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show($showCar:Boolean, $numSpins:int, $numFails:int):void
		{
			showCar = $showCar;
			numSpins = $numSpins;
			numFails = $numFails;
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeAdmin, false, 0, true);
			clip.btnCar.addEventListener(MouseEvent.MOUSE_DOWN, toggleCar, false, 0, true);
		}
		
		public function hide():void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeAdmin);
			clip.btnCar.removeEventListener(MouseEvent.MOUSE_DOWN, toggleCar);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		public function doShowCar():Boolean
		{
			return clip.redCheck.alpha == 1 ? true : false;
		}
		
		
		private function updateAdmin(e:Event):void
		{
			clip.redCheck.alpha = showCar == true ? 1 : 0;
			clip.numSpins.text = String(numSpins);
			clip.numFails.text = String(numFails);
		}
		
		
		private function closeAdmin(e:MouseEvent):void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeAdmin);
			dispatchEvent(new Event(ADMIN_CLOSED));
		}
		
		
		private function toggleCar(e:MouseEvent):void
		{
			clip.redCheck.alpha = clip.redCheck.alpha == 0 ? 1 : 0;
		}
	}
	
}