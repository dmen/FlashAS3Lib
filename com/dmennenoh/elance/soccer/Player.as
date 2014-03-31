package com.dmennenoh.elance.soccer
{	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	
	
	public class Player extends EventDispatcher 
	{
		private var clip:MovieClip;
		
		public function Player()
		{
			clip = new player(); //lib clip	
			clip.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		
		private function init(e:Event):void
		{
			clip.removeEventListener(Event.ADDED_TO_STAGE, init);
			clip.addEventListener(MouseEvent.MOUSE_DOWN, mDown, false, 0, true);			
			clip.stage.addEventListener(MouseEvent.MOUSE_UP, mUp, false, 0, true);
		}
		
		
		private function mDown(e:MouseEvent):void
		{
			clip.startDrag();
		}
		
		
		private function mUp(e:MouseEvent):void
		{
			stopDrag();
		}
		
		
	}
	
}