package com.gmrmarketing.microsoft.bing
{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.external.ExternalInterface;	
	import fl.video.*;	
	
	public class Main extends MovieClip
	{
		private var isMuted:Boolean = false;
		
		public function Main() 
		{			
			ExternalInterface.addCallback("muteSound", muteSound);
			vid.addEventListener(VideoEvent.COMPLETE, loopVideo);			
		}
		
		
		private function muteSound():void
		{
			isMuted = !isMuted;
			
			if (isMuted) {
				vid.volume = 0;
			}else{
				vid.volume = 1;
			}
		}
		
		
		private function loopVideo(e:VideoEvent):void
		{
			vid.play();
		}
	}
	
}