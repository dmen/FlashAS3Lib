package com.gmrmarketing.pm
{
	import flash.events.Event;

	public class MenuEvent extends Event
	{
		public static const MENU_EVENT:String = "PM_menu_event";
		public var params:Object;		
		
		
		public function MenuEvent($type:String, $params:Object, $bubbles:Boolean = false, $cancelable:Boolean = false)
		{
            super($type, $bubbles, $cancelable);
            this.params = $params;
		}		
		
		
		public override function clone():Event
        {
            return new MenuEvent(type, this.params, bubbles, cancelable);
        }        
		
		
		public override function toString():String
        {
            return formatToString("MenuEvent", "params", "type", "bubbles", "cancelable");
        }
		
	}
	
}