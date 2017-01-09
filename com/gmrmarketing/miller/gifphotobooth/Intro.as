package com.gmrmarketing.miller.gifphotobooth
{
	import flash.ui.*;
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	
	
	public class Intro extends EventDispatcher
	{
		public static const SHOWING:String = "introShowing";
		public static const BEGIN:String = "introBegin";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Intro()
		{
			clip = new mcIntro();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		public function get bg():MovieClip
		{
			return clip;
		}
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			//clip.alpha = 0;
			//TweenMax.to(clip, 1, { alpha:1, delay:.5, onComplete:showing } );
			
			clip.addEventListener(MouseEvent.MOUSE_DOWN, begin);
			//clip.stage.addEventListener(KeyboardEvent.KEY_DOWN, beginKey);
			dispatchEvent(new Event(SHOWING));
		}
		
		
		public function hide():void
		{
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, begin);
			if(myContainer){
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
		}
		
		
		private function showing():void
		{
			clip.addEventListener(MouseEvent.MOUSE_DOWN, begin);
			dispatchEvent(new Event(SHOWING));
		}
		
		
		private function begin(e:MouseEvent):void
		{
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, begin);
			//clip.stage.removeEventListener(KeyboardEvent.KEY_DOWN, beginKey);
			dispatchEvent(new Event(BEGIN));
		}
		
		private function beginKey(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.ENTER){
				clip.removeEventListener(MouseEvent.MOUSE_DOWN, begin);
				//clip.stage.removeEventListener(KeyboardEvent.KEY_DOWN, beginKey);
				dispatchEvent(new Event(BEGIN));
			}
		}
		
	}
	
}