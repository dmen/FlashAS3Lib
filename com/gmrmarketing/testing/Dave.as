package com.gmrmarketing.testing
{
	import flash.display.*;
	import flash.events.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Dave extends MovieClip
	{
		
		private var s1:Screen1;
		
		public function Dave()
		{			
			s1 = new Screen1();
			s1.setContainer(this);
			s1.addEventListener(Screen1.SHOWING, doneShowing, flase, 0, true);
			s1.show();
		}
		
		private function doneShowing(e:Event):void
		{
			trace("done");
		}
	}
	
}