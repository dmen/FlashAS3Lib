package com.gmrmarketing.stryker.mako2016
{
	import flash.events.*;
	import flash.display.*;
	
	
	public class Welcome extends EventDispatcher
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		
		public function Welcome()
		{
			clip = new mcWelcome();			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(user:Object):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.gotoAndStop(user.profileType);//frame 1,2,3,4
			clip.fname.text = user.firstName;
		}
	}
	
}