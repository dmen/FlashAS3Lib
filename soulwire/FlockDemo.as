
/**		
 * 
 *	FlockDemo
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
	 * FlockDemo
	 */
	public class FlockDemo extends AbstractDemo 
	{
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
			boid.flock(_boids);
			
			boid.update();
			boid.render();
		}
	}
}
