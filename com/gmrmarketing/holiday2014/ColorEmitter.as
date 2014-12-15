package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import flash.utils.Timer;
	import flash.events.*;
	import com.gmrmarketing.holiday2014.Particle2;
	
	
	public class ColorEmitter 
	{
		private var myContainer:DisplayObjectContainer;
		private var pRotation:Number;//for rotating each particle as it's emitted
		private var particles:Array;
		private var releaseTimer:Timer;
		private var particleTimer:Timer;//for iterating the particles array
		private var particleIndex:int;//index in particles array
		
		public function ColorEmitter(c:DisplayObjectContainer)
		{
			myContainer = c;
			
			pRotation = 0;
			
			//cyan,blue,bright pink/purple,red,purple
			particles = new Array(new p1(), new p2(), new p3(), new p4(), new p5());
			particleIndex = 0;
			
			particleTimer = new Timer(8000);
			particleTimer.addEventListener(TimerEvent.TIMER, changeParticle);
			particleTimer.start();
			
			releaseTimer = new Timer(350);
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
				tx = 1300 + 580 * Math.random();
				ty= 100 + 800 * Math.random();
			}else{		
				tx = 50 + 600 * Math.random();//first 650
				ty = 100 + 800 * Math.random();
			}	
			
			//add 3 particles to make one drop
			for(var i:int = 0; i < 2; i++){
				addParticle(tx, ty, particles[particleIndex]);
			}
		}

		
		private function addParticle(tx:int, ty:int, part:BitmapData):void
		{
			var p:Particle2 = new Particle2(part);	
			p.x = tx;// + 20 * Math.random();
			p.y = ty;// + 20 * Math.random();
			p.scaleX = p.scaleY = 1 + Math.random() * 2;
			//p.alpha = .1 ;
			p.rotation = pRotation;
			pRotation += 30;
			if(pRotation >= 180){
				pRotation = 0;
			}
			myContainer.addChildAt(p, 0);
		}
	}
	
}