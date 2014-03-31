/**
 * Represents a falling good item to be caught by Morris
 */

package com.gmrmarketing.morris
{ 
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;

	public class NeutralItem extends Item
	{	
		private const GLOW_COLOR:Number = 0xFFFF00;
		
		private var items:Array = new Array("univshirt", "sunglasses", "gas", "backpack");
	
		public function NeutralItem(gameRef:Sprite, xPos:int, isAttract:Boolean = false)
		{			
			var index:uint = Math.floor(Math.random() * items.length);
			var ClassRef:Class = getDefinitionByName(items[index]) as Class;           
			var item:MovieClip = new ClassRef();	
			
			super(gameRef, item, GLOW_COLOR, xPos, isAttract);
		}
	} 
}