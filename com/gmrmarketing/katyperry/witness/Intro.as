package com.gmrmarketing.katyperry.witness
{
	import flash.events.*;
	import flash.display.*;
	
	
	public class Intro extends EventDispatcher  
	{
		public static const COMPLETE:String = "introComplete";
		
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		private var perlin:PerlinNoise;//for animating the bg
		
		
		public function Intro()
		{
			clip = new intro();
			perlin = new PerlinNoise();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			perlin.show(clip.bg);			
			enableRemote();
		}
		
		
		public function disableRemote():void
		{
			clip.stage.removeEventListener(KeyboardEvent.KEY_DOWN, introCheck);
		}
		
		
		public function enableRemote():void
		{
			clip.stage.addEventListener(KeyboardEvent.KEY_DOWN, introCheck, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			perlin.hide();
		}
		
		
		private function introCheck(e:KeyboardEvent):void
		{
			if (e.charCode == 32){
				clip.stage.removeEventListener(KeyboardEvent.KEY_DOWN, introCheck);
				dispatchEvent(new Event(COMPLETE));
			}
		}
	}
	
}