package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class Intro extends EventDispatcher
	{		
		public static const BEGIN:String = "startPressed";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Intro()
		{
			clip = new mcIntro();			
		}
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.alpha = 0;
			clip.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, doBegin, false, 0, true);
			TweenMax.to(clip, 1, { alpha:1 } );
		}
		
		public function hide():void
		{
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, doBegin);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function doBegin(e:MouseEvent):void
		{			
			dispatchEvent(new Event(BEGIN));
		}
	}
	
}