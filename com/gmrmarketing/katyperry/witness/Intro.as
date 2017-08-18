package com.gmrmarketing.katyperry.witness
{
	import flash.events.*;
	import flash.display.*;
	import flash.utils.Timer;
	
	
	public class Intro extends EventDispatcher  
	{
		public static const COMPLETE:String = "introComplete";
		
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		private var perlin:PerlinNoise;//for animating the bg
		private var circleTimer:Timer;
		
		
		public function Intro()
		{
			clip = new intro();
			perlin = new PerlinNoise();
			circleTimer = new Timer(1200);			
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
			addCircle();
			circleTimer.addEventListener(TimerEvent.TIMER, addCircle, false, 0, true);
			circleTimer.start();
		}
		
		
		private function addCircle(e:TimerEvent = null):void
		{			
			var c:AnimatedCircle = new AnimatedCircle();
			c.x = 289;
			c.y = 325;
			clip.addChild(c);
		}
		
		/**
		 * these are called from main if the config dialog is opened - so that space bar doesn't start the app
		 */
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
			circleTimer.removeEventListener(TimerEvent.TIMER, addCircle);
			circleTimer.reset();
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