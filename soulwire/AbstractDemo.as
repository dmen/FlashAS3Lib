
/**		
 * 
 *	AbstractDemo
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
 
package soulwire
{
	import soulwire.ai.Boid;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;

	/**
	 * Demo
	 */

	//[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="31")]
	public class AbstractDemo extends Sprite 
	{
		protected var _boids : Vector.<Boid> = new Vector.<Boid>();
		protected var _boidHolder : Sprite;

		protected var _config : Object = {
											minForce:1.0,
											maxForce:6.0,
											minSpeed:3.0,
											maxSpeed:10.0,
											minWanderDistance:10.0,
											maxWanderDistance:100.0,
											minWanderRadius:5.0,
											maxWanderRadius:20.0,
											minWanderStep:0.1,
											maxWanderStep:0.9,
											boundsRadius:550,
											numBoids:120
											};

		public function AbstractDemo()
		{
			_boidHolder = addChild(new Sprite()) as Sprite;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function init():void
		{
			// Init
		}

		protected function createBoid() : Boid
		{
			var boid : Boid = new Boid();
			
			setProperties(boid);
			boid.renderData = boid.createDebugShape(0x999999, 4.0, 2.0);
			
			_boids.push(boid);
			_boidHolder.addChild(boid.renderData);
			
			return boid;
		}

		protected function createBoids(count : int):void
		{
			for (var i : int = 0;i < count; i++)
			{
				createBoid();
			}
		}

		protected function setProperties(boid : Boid) : void
		{
			boid.edgeBehavior = Boid.EDGE_BOUNCE;
			boid.maxForce = random(_config.minForce, _config.maxForce);
			boid.maxSpeed = random(_config.minSpeed, _config.maxSpeed);
			boid.wanderDistance = random(_config.minWanderDistance, _config.maxWanderDistance);
			boid.wanderRadius = random(_config.minWanderRadius, _config.maxWanderRadius);
			boid.wanderStep = random(_config.minWanderStep, _config.maxWanderStep);
			boid.boundsRadius = stage.stageWidth * 0.6;
			boid.boundsCentre = new Vector3D(stage.stageWidth >> 1, stage.stageHeight >> 1, 0.0);
			
			if(boid.x == 0 && boid.y == 0)
			{
				boid.x = boid.boundsCentre.x + random(-100, 100);
				boid.y = boid.boundsCentre.y + random(-100, 100);
				boid.z = random(-100, 100);
				
				var vel : Vector3D = new Vector3D(random(-2, 2), random(-2, 2), random(-2, 2));
				boid.velocity.incrementBy(vel);
			}
		}

		protected function random( min : Number, max : Number = NaN ) : Number
		{
			if ( isNaN(max) )
			{
				max = min;
				min = 0;
			}
			
			return Math.random() * ( max - min ) + min;
		}

		protected function updateBoid(boid : Boid, index : int) : void
		{
			// Override
		}

		protected function step(event : Event = null) : void
		{
			for (var i : int = 0;i < _boids.length; i++)
			{
				updateBoid(_boids[i], i);
			}
		}

		protected function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.ENTER_FRAME, step);
			init();
		}
	}
}
