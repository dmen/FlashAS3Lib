package com.gmrmarketing.nissan
{
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	
	
	public class BaseButton extends MovieClip
	{
		public function BaseButton(label:String)
		{
			theText.text = label;
		}
		
		public function highlight():void
		{
			yellow.alpha = 1;
			TweenMax.to(yellow, .5, { alpha:0 } );
		}
	}
	
}