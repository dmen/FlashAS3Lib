package com.gmrmarketing.comcast.streamgame2017
{
	import flash.display.*;
	import flash.events.Event;
	
	
	public class Main extends MovieClip
	{
		private var clip:MovieClip;
		private var top:MovieClip;
		private var middle:MovieClip;
		private var bottom:MovieClip;
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;

			clip = new MovieClip();
			top = new mcTop();
			middle = new mcMiddle();
			bottom = new mcBottom();
			
			clip.addChild(top);
			clip.addChild(middle);
			clip.addChild(bottom);
			
			addChild(clip);
			clip.y = 1920; //off bottom
			
			middle.y = top.height;
			bottom.y = top.height + middle.height;			
			
			addEventListener(Event.ENTER_FRAME, scrollUp);
		}
		
		
		private function scrollUp(e:Event):void
		{
			clip.y -= 4;
		}
	}
	
}