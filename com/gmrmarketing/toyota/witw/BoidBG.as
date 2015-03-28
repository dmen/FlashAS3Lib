package com.gmrmarketing.toyota.witw
{
	import soulwire.ai.Boid;
	import soulwire.AbstractDemo;
	
	public class BoidBG extends AbstractDemo
	{
		public function BoidBG() { }
		
		override protected function init() : void
		{
			createBoids(50);
		}

		override protected function updateBoid(boid : Boid, index : int) : void
		{
			// Add some wander to keep things interesting
			boid.wander(0.3);
			
			// Add a mild attraction to the centre to keep them on screen
			boid.seek(boid.boundsCentre, 0.1);
			
			// Flock
			//boid.flock(_boids);
			
			boid.update();
			boid.render();
		}
	}
	
}