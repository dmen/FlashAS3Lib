package com.gmrmarketing.comcast.university.ipad2013
{
	import flash.display.*;	
	import flash.events.*;
	import com.greensock.TweenMax;
	import flash.media.*;
	
	public class Congrats extends EventDispatcher
	{
		public static const CONGRATS_SHOWING:String = "congratsShowing";
		public static const CONGRATS_COMPLETE:String = "congratsComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var prize:String;
		private var cheer:Sound;
		
		public function Congrats()
		{
			clip = new mcCongrats();
			cheer = new audCheer();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show($prize:String):void
		{
			prize = $prize;
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.theText.text = "You won a " + prize;
			clip.btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, playClicked, false, 0, true);
			
			clip.y = clip.height;//put at screen bottom
			TweenMax.to(clip, 1, { y:0, onComplete:showing } );//tween up to show
			
			cheer.play();
		}
		
		
		public function getPrize():String
		{
			return prize;
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(CONGRATS_SHOWING));
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function playClicked(e:Event):void
		{
			clip.btnPlay.removeEventListener(MouseEvent.MOUSE_DOWN, playClicked);
			TweenMax.from(clip.btnPlay, .2, { alpha:1 } );
			dispatchEvent(new Event(CONGRATS_COMPLETE));
		}
	}
	
}