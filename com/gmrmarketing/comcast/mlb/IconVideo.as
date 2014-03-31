package com.gmrmarketing.comcast.mlb
{
	
	import flash.display.MovieClip;	
	import flash.events.Event;
	import com.gmrmarketing.comcast.mlb.Engine;
	import com.greensock.TweenLite;
	
	public class IconVideo extends MovieClip
	{
		private var engineRef:Engine;
		private var mySpeed:int;
		
		
		public function IconVideo(eRef:Engine)
		{	
			x = -10;
			y = 250 + Math.random() * 400;
			engineRef = eRef;
			mySpeed = engineRef.getLevel() + 2 + (Math.random() * 8);
			//blur.scaleX = engineRef.getLevel() / 4;
			addEventListener(Event.ENTER_FRAME, move, false, 0, true);
		}
		
		public function kill():void
		{
			removeEventListener(Event.ENTER_FRAME, move);
		}
				
		
		private function move(e:Event):void
		{
			x += mySpeed;
			
			if (x > Engine.GAME_WIDTH + 50) {			
				removeEventListener(Event.ENTER_FRAME, move);				
				remove();
			}
		}
		
		
		
		private function remove():void
		{
			engineRef.removeIcon(this);
		}		

	}	
}