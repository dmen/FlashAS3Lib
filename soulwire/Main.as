
/**		
 * 
 *	Main
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
	import flash.display.Sprite;

	/**
	 * Main
	 */
	[SWF(width="800", height="500", backgroundColor="#FFFFFF", frameRate="31")]
	public class Main extends Sprite 
	{
		private const CHASE : Class = ChaseDemo;		private const FLOCK : Class = FlockDemo;		private const SEEK : Class = SeekDemo;		private const WANDER : Class = WanderDemo;		private const GRAPHICS : Class = GraphicsDemo;

		public function Main()
		{
			var DemoType : Class = GRAPHICS;
			addChild(new DemoType() as AbstractDemo);
		}
	}
}
