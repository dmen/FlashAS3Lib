package com.rimv.utils
{
	/**
   @author    	RimV 
				www.mymedia-art.com
   @class     	Dynamic Scroller Event
   @package   	Utilities
	*/
   
    import flash.events.Event;
   
	public class  DynamicScrollerEvent extends Event
	{
		// Static event
		public static const ONCHANGE:String = "onChange";
		
		// private property
		private var _value:Number;
		
		public function get value():Number
		{
			return _value;
		}
		
		public function DynamicScrollerEvent(type:String, _value:Number)
		{
			super(type, true);
			this._value = _value;
		}
		
		public override function clone():Event
		{
			return new DynamicScrollerEvent(type, _value);
		}
	}
	
}