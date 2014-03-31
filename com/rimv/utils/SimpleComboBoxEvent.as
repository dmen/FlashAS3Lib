package com.rimv.utils
{
	/**
   @author    	RimV 
				www.mymedia-art.com
   @class     	SimpleBoxScroller Event
   @package   	Utilities
	*/
   
    import flash.events.Event;
   
	public class  SimpleComboBoxEvent extends Event
	{
		// Static event
		public static const ON_CLICK:String = "onClick";
		public static const ON_OVER:String = "onOver";
		public static const ON_OUT:String = "onOut";
		
		// misc var
		private var idx:Number;
		
		public function get index():Number
		{
			return idx;
		}
		
		public function set index(idx:Number):void
		{
			this.idx = idx;
		}
	
		public function SimpleComboBoxEvent(type:String, index:Number)
		{
			super(type, true);
			this.index = index;
		}
		
		public override function clone():Event
		{
			return new SimpleComboBoxEvent(type, index);
		}
	}
	
}