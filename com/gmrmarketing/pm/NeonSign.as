package com.gmrmarketing.pm
{
	import flash.display.MovieClip;
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	
	public class NeonSign extends MovieClip
	{			
		public function NeonSign()
		{
			TweenPlugin.activate([GlowFilterPlugin]);
			nextGlow();			
		}		
		private function nextGlow():void
		{			
			TweenLite.to(this, 1 + Math.random() * 2, { glowFilter: { color:0xFF0000, alpha:.8, blurX:12, blurY:12, quality:2, strength:1 + Math.random()}, onComplete:nextGlow } );
		}		
	}	
}