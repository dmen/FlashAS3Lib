package com.gmrmarketing.digitalmerch
{
	import com.greensock.TweenLite;
	import com.greensock.TimelineLite;
	import com.greensock.easing.*;
	import flash.display.MovieClip;
	
	public class JukeAnim
	{
		private var glowTimeline:TimelineLite;
		
		public function JukeAnim(glow:MovieClip)
		{
			glowTimeline = new TimelineLite( { onComplete:jukeAnim } );
			glowTimeline.append(new TweenLite(glow, 1, { alpha:0 } ));
			glowTimeline.append(new TweenLite(glow, 1, { alpha:.4, delay:1 } ));
		}
		
		
		private function jukeAnim():void
		{
			glowTimeline.gotoAndPlay(0);
		}
	}	
}