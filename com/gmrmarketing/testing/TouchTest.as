package com.gmrmarketing.testing
{	
	
	import flash.display.*;	
	import flash.ui.*;
	import com.gestureworks.core.GestureWorks;
	

    public class TouchTest extends GestureWorks 
	{
        private var touchPoints:Array;
		private var offX:int;
		private var offY:int;
		
		
        public function TouchTest() 
		{
			super();
		}
		
		override protected function gestureworksInit():void
		{
			trace("init");
		}
		
		
    }
	
}