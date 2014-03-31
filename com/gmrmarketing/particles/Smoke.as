package com.gmrmarketing.particles
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.utils.getTimer;
	import com.gmrmarketing.particles.Puff;
	import flash.utils.Timer;
	
	public class Smoke extends MovieClip
	{		
		private var smokeTimer:Timer;
		
		public function Smoke()
		{
			smokeTimer = new Timer(80);
			smokeTimer.addEventListener(TimerEvent.TIMER, addPuff);
			smokeTimer.start();
		}
		
		private function addPuff(e:TimerEvent):void
		{
			var p:Puff = new Puff(this, 340, 300);
		}		
		
	}	
}