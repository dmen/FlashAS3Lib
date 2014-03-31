package com.gmrmarketing.comcast.scratchnew
{
	import flash.display.*;
	import flash.events.*;
	
	public class Dialog extends EventDispatcher
	{
		private var clip:MovieClip;
		
		public function Dialog()
		{
			 clip = new winLose(); //lib clip
		}
	}
	
}