package com.gmrmarketing.holiday2012
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.*;
	import com.gmrmarketing.holiday2012.SnowFlake;
	
	public class Intro extends EventDispatcher
	{
		public static const CLICKED:String = "SCREEN_CLICKED";
		
		private var container:DisplayObjectContainer;
		private var snowContainer:Sprite;
		private var clip:MovieClip;
		
		public function Intro() 
		{
			clip = new mc_intro();
			snowContainer = new Sprite();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
				container.addChild(snowContainer);
				
				clip.alpha = 0;
				TweenMax.to(clip, 1, { alpha:1 } );
			}
			
			clip.addEventListener(MouseEvent.MOUSE_DOWN, clicked, false, 0, true);
			snowContainer.addEventListener(Event.ENTER_FRAME, addSnow, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
				container.removeChild(snowContainer);
			}
			while (snowContainer.numChildren) {
				SnowFlake(snowContainer.getChildAt(0)).kill();
			}
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, clicked);
			snowContainer.removeEventListener(Event.ENTER_FRAME, addSnow);
		}
		
		
		private function clicked(e:MouseEvent):void
		{			
			dispatchEvent(new Event(CLICKED));
		}
		
		
		private function addSnow(e:Event):void
		{	
			if (Math.random() < .3) {
				
				var a:SnowFlake = new SnowFlake();
				
				if(Math.random() < .5){
					a.x = 20 + Math.random() * 350;
				}else {
					a.x = 1310 + Math.random() * 340;
				}
				
				snowContainer.addChild(a);
			}
		}
		
	}
	
}