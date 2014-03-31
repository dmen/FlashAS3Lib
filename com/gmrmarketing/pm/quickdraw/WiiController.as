package com.gmrmarketing.pm.quickdraw
{
	import flash.display.DisplayObjectContainer;
	import flash.display.SWFVersion;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import org.wiiflash.Wiimote;
	import org.wiiflash.events.ButtonEvent;
	import org.wiiflash.events.WiimoteEvent;
	import flash.events.*;
	
	public class WiiController extends EventDispatcher implements IController
	{
		private const TRIGGER:String = "controllerTrigger";
		
		private var myWiimote:Wiimote;
		private var theX:Number = 0;
		private var theY:Number = 0;
		private var theTilt:Number = 0;
		private var theIR:*;
		
		public function WiiController()
		{
			myWiimote = new Wiimote();
			// connect wiimote to WiiFlash Server
			myWiimote.connect ();			
			
			//B button is the trigger
			myWiimote.addEventListener( ButtonEvent.B_PRESS, onBPressed );
			myWiimote.addEventListener( ButtonEvent.B_RELEASE, onBReleased);

			myWiimote.addEventListener( Event.CONNECT, onWiimoteConnect );
			myWiimote.addEventListener( IOErrorEvent.IO_ERROR, onWiimoteConnectError );
			myWiimote.addEventListener( Event.CLOSE, onCloseConnection );

			myWiimote.addEventListener( WiimoteEvent.UPDATE, onUpdated );			
			
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
		
		public function getIR():*
		{
			return theIR;
		}
		
		public function set containerToListenOn(c:DisplayObjectContainer):void
		{
			//only for mouse controller
		}
		
		// -- INTERFACE IMPLEMENTATION --
		
		
		
		/**
		 * For 700 x 580 screen res
		 * @param	pEvt
		 */
		private function onUpdated ( pEvt:WiimoteEvent ):void
		{			
			theX =  1024 - (myWiimote.ir.x2 * 1024);
			theY = myWiimote.ir.y2 * 550;
			theTilt = myWiimote.pitch;
			theIR = myWiimote.ir;
		}
		
		
		
		private function onCloseConnection ( pEvent:Event ):void
		{	
			//connection closed, WiiFlash Server has been closed				
		}

		private function onWiimoteConnectError ( pEvent:IOErrorEvent ):void
		{	
			//Couldn't connect, make sure WiiFlash Server is running	
		}

		private function onWiimoteConnect ( pEvent:Event ):void
		{				
			//Wiimote successfully connected	
		}


		private function onBPressed ( pEvt:ButtonEvent ):void 
		{
			
			dispatchEvent(new Event(TRIGGER));
		}

		private function onBReleased ( pEvt:ButtonEvent ):void
		{			
		}
	}
	
}