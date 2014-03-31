package com.gmrmarketing.digitalmerch
{
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	
	public class BoltAnim
	{		
		public function BoltAnim(b:MovieClip)
		{
			TweenMax.to(b.bolt1, .86, {x:175, y:114, scaleX:.6, scaleY:.6, ease:Linear.easeNone, delay:Math.random()/ 4, repeat:-1});
			TweenMax.to(b.bolt2, .87, {x:175, y:114, scaleX:.6, scaleY:.6, ease:Linear.easeNone, delay:Math.random()/ 4, repeat:-1});
			TweenMax.to(b.bolt3, .88, {x:175, y:114, scaleX:.6, scaleY:.6, ease:Linear.easeNone, delay:Math.random()/ 6, repeat:-1});
		}
	}	
}