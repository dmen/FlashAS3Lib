/**
 * Interface for all bottle clips
 * 
 * An interface is used so the target of
 * clicks can be cast to an IBottle
 * 
 * all bottles must implement this interface
 */

package com.gmrmarketing.angostura
{
	import flash.geom.Point;
	
	public interface IBottle
	{
		/**
		 * Returns the string name of the liquor bottle
		 * @return String label
		 */
		function getLabel():String;
		
		/**
		 * Returns a float 0 - 1 
		 * The closer to 1 the closer to 'full' fill rate
		 * such as a normal bottle of liquor
		 * For something with a dripper like bitters you might use .4
		 * 
		 * This can be thought of as ounces per second
		 * 
		 * @return 0 - 1
		 */
		function getFillRate():Number;	
		
		/**
		 * Returns the current location of the bottle
		 * @return Point
		 */
		function getLoc():Point;
		
		/**
		 * Returns the liquor color the bottle contains
		 * @return Color
		 */
		function getColor():Number;
		
		/**
		 * Returns the starting location of the bottle on the bar
		 * @return Point
		 */
		function getStartLoc():Point;
		
		
		/**
		 * Returns the location of the spout
		 * @return
		 */
		function getSpoutLoc():Point;
	}
	
}