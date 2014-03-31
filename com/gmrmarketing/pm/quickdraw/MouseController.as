package com.gmrmarketing.pm.quickdraw
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;	
	import flash.events.EventDispatcher;
	import flash.geom.Point;	
	import flash.events.*;
	
	
	public class MouseController extends Sprite implements IController
	{
		private const TRIGGER:String = "mouseControllerTrigger";
		
		//private var myWiimote:Wiimote;
		private var theX:Number = 0;
		private var theY:Number = 0;
		private var theTilt:Number = 0;
		private var container:DisplayObjectContainer;
		private var mouseInterceptor:Sprite;
		
		public function MouseController()
		{
			addEventListener(Event.ENTER_FRAME, onUpdated, false, 0, true);
		}
		
		
		// -- INTERFACE IMPLEMENTATION --
		
		public function get trigger():String { return TRIGGER; }
		
		public function getPosition():Point
		{
			return new Point(theX, theY);
		}
		
		public function getTilt():Number
		{
			return theTilt;
		}
		
		public function set containerToListenOn(c:DisplayObjectContainer):void
		{
			if (container != null) {
				container.removeEventListener(MouseEvent.MOUSE_DOWN, onBPressed);
			}
			
			container = c;
			container.addEventListener(MouseEvent.MOUSE_DOWN, onBPressed, false, 0, true);
		}
		
		public function getIR():*
		{		
			return null;
		}
		
		// -- INTERFACE IMPLEMENTATION --
		
				
	
		private function onUpdated (e:Event):void
		{			
			theX =  mouseX;
			theY = mouseY;
			theTilt = mouseY / 500;
		}


		private function onBPressed (e:MouseEvent):void 
		{			
			dispatchEvent(new Event(TRIGGER));
		}
	}
	
}