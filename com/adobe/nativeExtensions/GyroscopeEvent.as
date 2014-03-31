////////////////////////////////////////////////////////////////////////////////////////////////////////	
//	ADOBE SYSTEMS INCORPORATED																		  //
//	Copyright 2011 Adobe Systems Incorporated														  //
//	All Rights Reserved.																			  //
//																									  //
//	NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the		  //
//	terms of the Adobe license agreement accompanying it.  If you have received this file from a	  //
//	source other than Adobe, then your use, modification, or distribution of it requires the prior	  //
//	written permission of Adobe.																	  //
////////////////////////////////////////////////////////////////////////////////////////////////////////

package com.adobe.nativeExtensions
{
	import flash.events.Event;
	
	public class GyroscopeEvent extends Event
	{
		public static const UPDATE:String = "GyroscopeEventUpdateEvent";
		private var _x:Number;
		private var _y:Number;
		private var _z:Number; 
		
		public function GyroscopeEvent(type:String, xVal:Number, yVal:Number, zVal:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_x = xVal;
			_y = yVal;
			_z = zVal;
		}
		
		public function get x():Number{
			return _x;
		}
		
		public function get y():Number{
			return _y;
		}
		
		public function get z():Number{
			return _z;
		}
		
		public override function clone():Event{
			return new GyroscopeEvent(type, _x, _y, _z, bubbles,cancelable);
		};
	}
}