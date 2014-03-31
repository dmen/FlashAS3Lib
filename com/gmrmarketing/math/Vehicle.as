package com.gmrmarketing.math
{
	import com.gmrmarketing.math.Vector2D;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class Vehicle {
		private var _mass:Number;
		private var _position:Vector2D;
		private var _velocity:Vector2D;
		private var _maxForce:Number;
		private var _maxSpeed:Number;
		private var clip:MovieClip;
		
		
		public function Vehicle($clip:MovieClip){
			_mass = 50;
			_position = new Vector2D($clip.x, $clip.y);
			_velocity = new Vector2D();
			_maxForce = 2;
			_maxSpeed = 5;
			clip = $clip;
		}
		
		/**
		* Updates the vehicle based on velocity
		*/
		public function update():void {
			// keep it witin its max speed
			_velocity.truncate(_maxSpeed);
			
			// move it
			_position = _position.add(_velocity);
			
			// set the x and y, using the super call to avoid this class's implementation
			clip.x = position.x;
			clip.y = position.y;
			
			// rotation = the velocity's angle converted to degrees
			clip.rotation = _velocity.angle * 180 / Math.PI;
			
		}
		
		/**
		 * Gets and sets the vehicle's mass
		 */
		public function set mass(value:Number):void {
			_mass = value;
		}
		
		public function get mass():Number {
			return _mass;
		}
		
		/**
		 * Gets and sets the max speed of the vehicle
		 */
		public function set maxSpeed(value:Number):void {
			_maxSpeed = value;
		}
		
		public function get maxSpeed():Number {
			return _maxSpeed;
		}
		
		/**
		 *Gets and sets the position of the vehicle
		 */
		public function set position(value:Vector2D):void {
			_position = value;
			clip.x = _position.x;
			clip.y = _position.y;
		}
		
		public function get position():Vector2D {
			return _position;
		}
		
		/**
		 * Gets and sets the velocity of the vehicle
		 */
		public function set velocity(value:Vector2D):void {
			_velocity = value;
		}
		
		public function get velocity():Vector2D {
			return _velocity;
		}
		
		public function seek(target:Vector2D):void {
			var desiredVelocity:Vector2D = target.subtract(position).normalize().multiply(maxSpeed); //subtract the position from the target to get the vector from the vehicles position to the target. Normalize it then multiply by max speed to get the maximum velocity from your position to the target. 
			var steeringForce:Vector2D = desiredVelocity.subtract(velocity); //subtract velocity from the desired velocity to get the force vector 
			velocity.add(steeringForce.divide(mass)); //divide the steeringForce by the mass(which makes it the acceleration), then add it to velocity to get the new velocity 			
		}
		
		
		
	}
}