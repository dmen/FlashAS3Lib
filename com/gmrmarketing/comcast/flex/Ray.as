package com.gmrmarketing.comcast.flex
{
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.plugins.*;
	
	public class Ray extends MovieClip
	{
		private var xVel:Number;
		private var yVel:Number;		
		private var col:Number;
		
		public function Ray() 
		{				
			if(Math.random() < .5){
				col = 0xFF0000;
			}else {
				col = 0x0000FF;
			}
				
		}
		
		public function doStart():void
		{
			TweenMax.to(this, 0, { glowFilter: { color:col, alpha:1, blurX:8, blurY:8, quality:2, strength:10 }} );
			animRay();	
		}
		
		public function doStop():void
		{
			TweenMax.killAll();
		}
		
		private function animRay():void
		{			
			TweenMax.to(this, 2 + Math.random() * 2, {bezier:[{x:Math.random() * 1366, y:Math.random() * 768}, {x:Math.random() * 1366, y:Math.random() * 768}, {x:Math.random() * 1366, y:Math.random() * 768}], orientToBezier:true, onComplete:animRay });			
		}
		
	}
	
}