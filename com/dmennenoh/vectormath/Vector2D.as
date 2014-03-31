/**
 * Vector Math support functions
 */
package com.dmennenoh.vectormath
{	
	
	public class Vector2D 
	{
		private var _x:Number;
		private var _y:Number;
		
		
		public function Vector2D(x:Number = 0, y:Number = 0) 
		{
			_x = x;
			_y = y;
		}
		
		
		/**
		 * Returns a clone of this vector
		 * @return
		 */
		public function cloneVector():Vector2D 
		{
			return new Vector2D(x, y);
		}
		
		
		/**
		 * Returns true if the vector's length = 1
		 * @return
		 */
		public function isNormalized():Boolean 
		{
			return length == 1.0;
		}		
		
		
		/**
		 * sets the length of the vector
		 * can change x and y but angle remains the same
		 */
		public function set length(len:Number):void 
		{
			var _angle:Number = angle;
			_x = Math.cos(_angle) * len;
			_y = Math.sin(_angle) * len;
			if(Math.abs(_x) < 0.00000001) _x = 0;
			if(Math.abs(_y) < 0.00000001) _y = 0;
		}
		
		
		/**
		 * Uses pythagorean theorem to return the length
		 **/
		public function get length():Number 
		{
			return Math.sqrt(_x * _x + _y * _y);
		}		
		
		
		/**
		 * sets the angle of the vector
		 * x and y can change but length remains the same
		 */
		public function set angle(ang:Number):void 
		{
			var len:Number = length;
			_x = Math.cos(ang) * len;
			_y = Math.sin(ang) * len;
		}
		
		
		/**
		 * returns the angle
		 **/
		public function get angle():Number 
		{
			return Math.atan2(_y, _x);
		}
		
		
		/**
		 * sets length = 1
		 * @return the normalized vector
		 */
		public function normalize():Vector2D 
		{
			if(length == 0){
				_x = 1;
				return this;
			}
			var len:Number = length;
			_x /= len;
			_y /= len;
			return this;
		}		
		
		
		/**
		 * Sets the max length of the vector
		 * @param max maximu length of  the vector
		 * @return the truncated vector
		 */
		public function truncate(max:Number):Vector2D 
		{
			length = length < max ? length : max;			
			return this;
		}
		
		
		/**
		 * calculates the dot product of two vectors
		 * @param v2 Vector2D
		 * @return Number The dot product
		 */
		public function dotProduct(v2:Vector2D):Number 
		{
			return x * v2.x + y * v2.y;
		}
		
		
		/**
		 * returns the distance between two vectors
		 * @param v2 Vector2D
		 * @return Number the distance
		 */
		public function distance(v2:Vector2D):Number 
		{
			return Math.sqrt(distSQ(v2));
		}
	
		
		/**
		 * returns the distance squared
		 * @param v2 the other vector
		 * @return Number the distance squared
		 */
		public function distSQ(v2:Vector2D):Number 
		{
			var dx:Number = x - v2.x;
			var dy:Number = y - v2.y;
			return dx * dx + dy * dy;
		}
		
		
		/**
		 * adds a vector to this one
		 * @param v2 the vector to add
		 * @return this vector
		 */
		public function add(v2:Vector2D):Vector2D 
		{
			x += v2.x;
			y += v2.y
			return this;
		}
		
		
		/**
		 * subtract a vector from this one
		 * @param v2 Vector2D
		 * @return this vector
		 */
		public function subtract(v2:Vector2D):Vector2D
		{
			x -= v2.x;
			y -= v2.y
			return this;
		}
		
		
		/**
		 * multiply the vector by a scalar
		 * @param scalar Number to multiply by
		 * @return this vector
		 */
		public function multiply(scalar:Number):Vector2D 
		{
			x *= scalar;
			y *= scalar;
			return this;
		}
		
		
		/**
		 * divide the vector by a scalar
		 * @param scalar Number to divide by
		 * @return this vector
		 */
		public function divide(scalar:Number):Vector2D 
		{
			x /= scalar;
			y /= scalar;
			return this;
		}
		
		
		//Getters and Setters for x and y
		public function set y(value:Number):void 
		{
			_y = value;
		}
		
		
		public function get y():Number 
		{
			return _y;
		}
		
		
		public function set x(value:Number):void 
		{
			_x = value;
		}
		
		
		public function get x():Number 
		{
			return _x;
		}
		
	}
}