package com.gmrmarketing.comcast.university.matchup
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	
	public class Bonus
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Bonus()
		{
			clip = new clipBonus(); //library clip
			clip.theText.mouseEnabled = false;
			clip.mouseEnabled = false;
		}
		
		
		public function show($container:DisplayObjectContainer, message:String):void
		{
			container = $container;
			container.mouseEnabled = false;
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			//center clip
			clip.x = clip.stage.stageWidth * .5;
			clip.y = clip.stage.stageHeight * .5;
			
			clip.theText.text = message;
			clip.scaleX = clip.scaleY = .5;
			clip.alpha = 1;
			
			TweenLite.to(clip, 1, { scaleX:2, scaleY:2, ease:Elastic.easeOut} );
			TweenLite.to(clip, 1, { alpha:0, delay:.25, overwrite:0, onComplete:kill  } );
		}
		
		
		private function kill():void
		{
			if (container) {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}
		}
	}
	
}