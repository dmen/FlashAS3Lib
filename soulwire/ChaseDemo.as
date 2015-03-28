
/**		
 * 
 *	ChaseDemo
 *	
 *	@version 1.00 | Jul 2, 2009
 *	@author Justin Windle | soulwire ltd
 *	@see http://blog.soulwire.co.uk
 *	
 *	Released under the Creative Commons 3.0 license
 *	@see http://creativecommons.org/licenses/by/3.0/
 *	
 *	You can modify this script in any way you choose 
 *	and use it for any purpose providing this header 
 *	remains intact and the original author is credited
 *  
 **/
 
package  
{
	import soulwire.ai.Boid;
	/**
	 * ChaseDemo
	 */
	public class ChaseDemo extends AbstractDemo 
	{
		override protected function init() : void
		{
			createBoids(100);
		}

		override protected function updateBoid(boid : Boid, index : int) : void
		{
			if(index > 0) // All Boids but the first
			{
				// Seek the previous Boid

				boid.arrive(_boids[index - 1].position, 20);
							
				if(index < _boids.length - 1)
				{
					// Flee from the next

					boid.flee(_boids[index + 1].position, 10);
				}
			}
			else // The first Boid
			{
				boid.wander(0.5);
				boid.arrive(boid.boundsCentre, 100, 0.5);
			}
			
			boid.update();
			boid.render();
		}
	}
}
