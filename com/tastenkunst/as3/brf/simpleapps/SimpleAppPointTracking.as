package com.tastenkunst.as3.brf.simpleapps {
	import com.tastenkunst.as3.brf.examples.ExamplePointTracking;

	import flash.display.Sprite;
	
	/**
	 * This is just a layout wrapper for the point tracking examples.
	 * 
	 * @author Marcel Klammer, 2012
	 */
	public class SimpleAppPointTracking extends ExamplePointTracking {
		
		public var _layout : BRFLayoutPT;
		public var _container3DHolder : Sprite;		

		public function SimpleAppPointTracking() {			
			super();
		}
		//I know, it's just a TextField
		override public function initGUI() : void {
			super.initGUI();
			
			_layout = new BRFLayoutPT();
			addChild(_layout);
		}
	}
}