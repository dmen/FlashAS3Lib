package com.gmrmarketing.magnet
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	
	public class Repulsor
	{
		private const RADTODEG:Number = 180 / Math.PI;
		
		private var mass:int;
		private var thePoint:Point;
		private var theObject:DisplayObject;
		
		/**
		 * 
		 * @param	$thePoint
		 * @param	$theObject
		 * @param	$mass Values between 200 and 5000 or so - bigger numbers = heavier = slower to respond
		 */
		public function Repulsor($thePoint:Point, $theObject:DisplayObject, $mass:int)
		{
			thePoint = $thePoint;
			theObject = $theObject;
			mass = $mass;
		}


		public function calculateForces():Array
		{
			var ang:Number = Math.atan2(thePoint.y - theObject.y, thePoint.x - theObject.x) * RADTODEG;			
			
			var dist:Number = Math.sqrt(Math.pow(Math.abs(thePoint.x - theObject.x), 2) + Math.pow(Math.abs(thePoint.y - theObject.y), 2));			
			
			var force:Number = 60 / dist;			
			
			var xForce:Number = Math.abs(thePoint.x - theObject.x) * force / mass;
			var yForce:Number = Math.abs(thePoint.y - theObject.y) * force / mass;
			
			var ret:Array = [];
			if(ang >= 0 && ang <= 90){
				ret = [xForce * -1, yForce * -1];
			}else if(ang > 90){
				ret = [xForce, yForce * -1];
			}else if(ang < 0 && ang >= -90){
				ret = [xForce * -1, yForce];
			}else if(ang < -90){
				ret = [xForce, yForce];
			}
			
			return ret;
		}	
	
	}

}