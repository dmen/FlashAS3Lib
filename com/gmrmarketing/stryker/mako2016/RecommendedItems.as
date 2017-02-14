/**
 * Shows the recommended activites... uses mcRecommended movieClip in the library
 */
package com.gmrmarketing.stryker.mako2016
{
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	public class RecommendedItems extends Sprite
	{		
		public function RecommendedItems(){}
	
		
		public function populate(items:Array):void
		{
			while (numChildren){
				removeChildAt(0);
			}
			
			var disp:String;
			
			for (var i:int = 0; i < items.length; i++){				
				
				var newItem:MovieClip = new mcRecommended();
				newItem.theText.text = items[i].prettyName;
				newItem.y = i * 86;
				addChild(newItem);				
			}
		}
		
		
		
	}
	
}