package com.gmrmarketing.holiday2016.tablePlayer
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.ui.*;
	import flash.media.Video;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main extends MovieClip
	{
		public function Main()
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, playAVideo);
		}
		
		private function playAVideo(e:MouseEvent):void
		{
			var v:VideoPlayer = new VideoPlayer("assets/t.mov", e.stageX, e.stageY);
			addChild(v);
		}
	}
	
}