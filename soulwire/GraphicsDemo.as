
/**		
 * 
 *	GraphicsDemo
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

	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * GraphicsDemo
	 */
	public class GraphicsDemo extends AbstractDemo 
	{
		// How to use custom graphics with the Boid class
		
		override protected function init() : void
		{
			var format:TextFormat = new TextFormat("Arial", 42, 0x000000, true);
			var boid:Boid;
			var tf:TextField;
			
			for( var i : int = 0;i < 78; i++ )
			{
				format.color = Math.random() * 0xFFFFFF;
				format.size = random(28, 48);
				
				tf = new TextField();
				tf.defaultTextFormat = format;
				tf.autoSize = TextFieldAutoSize.CENTER;
				tf.text = String.fromCharCode((i % 26) + 65);
				
				boid = createBoid();
				_boidHolder.removeChild(boid.renderData);
				
				// Set the Boid's renderData property
				boid.renderData = tf;
				
				// Add the renderData to the display list
				_boidHolder.addChild(boid.renderData);
			}
		}

		override protected function updateBoid(boid : Boid, index : int) : void
		{
			if(index > 0) // All Boids but the first
			{
				// Seek the previous Boid

				boid.arrive(_boids[index - 1].position, 40);
							
				if(index < _boids.length - 1)
				{
					// Flee from the next

					boid.flee(_boids[index + 1].position, 40);
				}
			}
			else // The first Boid
			{
				boid.wander(0.7);
				boid.arrive(boid.boundsCentre, 100, 0.5);
			}
			
			boid.update();
			boid.render();
		}
	}
}
