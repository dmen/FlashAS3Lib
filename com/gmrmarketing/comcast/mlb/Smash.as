package com.gmrmarketing.comcast.mlb
{
	import flash.display.MovieClip;
	import com.greensock.TweenLite;
	
	
	public class Smash extends MovieClip
	{
		private var frames:int = 3; //number of frames (different icons) in the clip
		private var engineRef:Engine;
		
		
		public function Smash(eRef:Engine):void
		{
			engineRef = eRef;
		}
		
		
		public function show():void
		{
			gotoAndStop(Math.ceil(Math.random() * frames));
			scaleX = scaleY = .25;	
			alpha = 1;
			TweenLite.to(this, .4, { scaleX:1, scaleY:1, onComplete:removeSelf } );
		}
		
		
		public function removeSelf() : void 
		{ 
			if (engineRef.contains(this)){
				engineRef.removeChild(this);
			}
		} 
	}
	
}