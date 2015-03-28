
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
	import flash.geom.Vector3D;

	import soulwire.ai.Boid;
	/**
	 * ChaseDemo
	 */
	public class SeekDemo extends AbstractDemo 
	{
		private var _target : Vector3D = new Vector3D();

		override protected function init() : void
		{
			createBoids(100);
		}

		override protected function updateBoid(boid : Boid, index : int) : void
		{
			// Set the target to the mouse
			_target.x = mouseX;
			_target.y = mouseY;
			
			// Seek and arrive are similar, though arrive
			// will cause the boid to slow down as it reaches it's target
			boid.arrive(_target, 100, 0.8);
			
			// Add some wander to keep it interesting
			boid.wander();
			
			boid.update();
			boid.render();
		}
	}
}
