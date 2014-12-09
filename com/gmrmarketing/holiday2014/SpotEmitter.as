package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import flash.utils.Timer;
	import flash.events.*;
	import com.gmrmarketing.holiday2014.Particle2;
	
	
	public class SpotEmitter 
	{
		private var myContainer:DisplayObjectContainer;
		private var pRotation:Number;//for rotating each particle as it's emitted
		private var particles:Array;
		private var releaseTimer:Timer;
		private var particleTimer:Timer;//for iterating the particles array
		private var particleIndex:int;//index in particles array
		
		public function SpotEmitter(c:DisplayObjectContainer)
		{
			myContainer = c;
			
			pRotation = 0;
			
			particles = new Array(new p7(), new p7(), new p6(), new p8(), new p9());
			particleIndex = 0;
			
			particleTimer = new Timer(8000);
			particleTimer.addEventListener(TimerEvent.TIMER, changeParticle);
			particleTimer.start();
			
			releaseTimer = new Timer(300);
			releaseTimer.addEventListener(TimerEvent.TIMER, addDrop);
			releaseTimer.start();
		}
		
		
		/**
		 * called every n sec by particleTimer
		 * changes the particleIndex to iterate the particles array
		 * @param	e
		 */
		private function changeParticle(e:TimerEvent):void
		{
			particleIndex++;
			if(particleIndex >= particles.length){
				particleIndex = 0;
			}
		}

		
		/**
		 * called every n msec to add a 'drop' of color
		 * picks left or right side of the screen
		 * a drop comprises 3 particles
		 * @param	e
		 */
		private function addDrop(e:TimerEvent):void
		{			
			var r:Number = Math.random();
			var tx:int;
			var ty:int;
			
			if(r < .5){		
				tx = 1400 + 400 * Math.random();
				ty= 100 + 800 * Math.random();
			}else{		
				tx = 100 + 500 * Math.random();
				ty = 100 + 800 * Math.random();
			}	
			
			//add 3 particles to make one drop
			//for(var i:int = 0; i < 3; i++){
				addParticle(tx, ty, particles[particleIndex]);
			//}
		}

		
		private function addParticle(tx:int, ty:int, part:BitmapData):void
		{
			var p:Spot = new Spot(part);	
			p.x = tx;// + 20 * Math.random();
			p.y = ty;// + 20 * Math.random();
			p.scaleX = p.scaleY = .25 + Math.random();
			//p.alpha = .1 ;
			p.rotation = pRotation;
			pRotation += 12;
			if(pRotation >= 180){
				pRotation = 0;
			}
			myContainer.addChildAt(p, 0);
		}
	}
	
}