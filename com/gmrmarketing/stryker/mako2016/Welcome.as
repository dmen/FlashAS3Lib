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
		
		
		public function show(fName:String, greeting:String, message:String):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.greeting.text = greeting;
			clip.fname.text = fName;
			clip.message.text = message;
		}
	}
	
}