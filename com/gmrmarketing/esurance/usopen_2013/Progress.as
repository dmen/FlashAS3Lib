package com.gmrmarketing.esurance.usopen_2013
{
	import flash.display.*;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import flash.events.*;
	
	
	public class Progress
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var rotValue:int;
		
		public function Progress()
		{
			clip = new mcProgress();
			rotValue = 3;
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			clip.x = 42;
			clip.y = -50;			
			clip.alpha = 0;			
			clip.theText.text = "";
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			TweenLite.to(clip, 1, { alpha:1, y:37, ease:Back.easeOut } );
			clip.addEventListener(Event.ENTER_FRAME, updateBall, false, 0, true);
		}
		
		
		public function setMessage(message:String):void
		{
			clip.theText.text = message;
			rotValue *= -1;
		}
		
		
		public function hide():void		
		{
			clip.removeEventListener(Event.ENTER_FRAME, updateBall);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function updateBall(e:Event):void
		{
			clip.ball.rotation += rotValue;
		}
	}
	
}