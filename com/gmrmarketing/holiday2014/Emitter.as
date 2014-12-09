package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	public class Emitter
	{
		private var myContainer:DisplayObjectContainer;
		private var loc:Point;
		private var myParticle:BitmapData;
		private var myTimer:Timer;
		private var vel:Point;
		private var life:int;
		private var myCount:int;
		private var pCount:int;
		
		public function Emitter()
		{
			vel = new Point(0, 0);
			myCount = 0;
			pCount = 0;
			myTimer = new Timer(50);
			myTimer.addEventListener(TimerEvent.TIMER, emitParticle);			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function set position(p:Point):void
		{
			loc = p;
		}
		
		
		public function set particle(p:BitmapData):void
		{
			myParticle = p;
		}
		
		
		public function set frequency(f:int):void
		{	
			myTimer.delay = f;
		}
		
		
		public function set lifeTime(l:int):void
		{
			life = l;
		}
		
		public function set count(c:int):void
		{
			myCount = c;
		}
		
		
		public function run():void
		{
			myTimer.start();
		}
		
		
		public function stop():void
		{
			myTimer.reset();
		}
		
		
		
		private function emitParticle(e:TimerEvent=null):void
		{			
			vel.x = .03 + Math.random() * .5;
			vel.y = -.85 - Math.random() * .5;
			
			var p:Particle = new Particle(myParticle, vel, life);
			
			p.x = loc.x;
			p.y = loc.y;
			myContainer.addChild(p);
			
			pCount++;
			if (pCount != 0 && pCount >= myCount) {
				stop();
			}
		}
		
	}
	
}