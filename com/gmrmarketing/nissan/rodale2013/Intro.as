package com.gmrmarketing.nissan.rodale2013
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class Intro extends EventDispatcher
	{
		public static const INTRO_BEGIN:String = "introBegin";
		
		private var container:DisplayObjectContainer;
		private var clip:MovieClip;
		private var btnBegin:Button;
		
		
		public function Intro()
		{
			clip = new mcIntro();
			btnBegin = new Button(clip, "red", "Press to Begin", 132, 661);			
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
			
			btnBegin.addEventListener(Button.PRESSED, begin, false, 0, true);
			
			TweenMax.from(clip.title, 1, { alpha:0, x:"100" } );
			TweenMax.from(clip.sub, 1, { alpha:0, x:"-100" } );
		}
		
		
		public function hide():void
		{
			btnBegin.removeEventListener(Button.PRESSED, begin);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		public function numPrints(num:int):void
		{
			clip.numPrints.text = String(num);
		}
		
		private function begin(e:Event):void
		{
			btnBegin.removeEventListener(Button.PRESSED, begin);
			dispatchEvent(new Event(INTRO_BEGIN));
		}
		
	}
	
}