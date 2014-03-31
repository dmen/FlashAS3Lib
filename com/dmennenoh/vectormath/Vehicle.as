/**
 * Simple Vector vehicle class
 */
package com.dmennenoh.vectormath
{
	import com.gmrmarketing.math.Vector2D;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class Vehicle 
	{
		private const RAD:Number = 180 / Math.PI;
		
		private var _mass:Number;
		private var _position:Vector2D;
		private var _velocity:Vector2D;
		private var _maxForce:Number;
		private var _maxSpeed:Number;
		private var clip:MovieClip;
		
		
		public function Vehicle($clip:MovieClip)
		{
			_mass = 50;
			_position = new Vector2D($clip.x, $clip.y);
			_velocity = new Vector2D();
			_maxForce = 2;
			_maxSpeed = 7;
			clip = $clip;
		}
		
		
		/**
		 * updates the position and rotation
		 * call this within the update loop
		 */
		public function update():void {
			
			_velocity.truncate(_maxSpeed);			
			_position = _position.add(_velocity);			
			
			clip.x = _position.x;
			clip.y = _position.y;			
			
			clip.rotation = _velocity.angle * RAD;
		}
		
		
		public function set velocity(v:Vector2D):void
		{
			_velocity = v;
		}
		
		
		public function set position(v:Vector2D):void
		{
			_position = v;
		}
		
		
		public function get position():Vector2D
		{
			return _position;
		}
		
		
		/**
		 * Basic vector seek method:
		 * step 1: subtract the current position from the target to get the vector from the vehicles position to the target and then normalize it
		 * 		   then multiply by max speed to get the maximum velocity from your position to the target.
		 * step 2: subtract velocity from the desired velocity to get the steering force vector
		 * step 3: divide the steeringForce by the mass(which makes it the acceleration), then add it to velocity to get the new velocity
		 * 
		 * @param	target Vector2D position
		 */
		public function seek(target:Vector2D):void {
			var desiredVelocity:Vector2D = target.subtract(_position).normalize().multiply(_maxSpeed); 
			var steeringForce:Vector2D = desiredVelocity.subtract(_velocity); 
			_velocity.add(steeringForce.divide(_mass)); 			
		}
		
		
		
	}
}