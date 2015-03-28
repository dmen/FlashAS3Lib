
/**		
 * 
 *	WanderDemo
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
	 * WanderDemo
	 */
	public class WanderDemo extends AbstractDemo 
	{

		override protected function init() : void
		{
			createBoids(80);
		}

		override protected function updateBoid(boid : Boid, index : int) : void
		{
			// Tell the Boid to wander randomly
			boid.wander();
			
			// Update and render
			boid.update();
			boid.render();
		}
	}
}
