/**
 * Shows the recommended activites... uses mcRecommended movieClip in the library
 * This is a sprite that is placed by Main.as
 */
package com.gmrmarketing.stryker.mako2016
{
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class RecommendedItems extends Sprite
	{		
		public function RecommendedItems(){}
	
		
		/**
		 * 
		 * @param	items array of item objets from Map.recommendations
		 * @param	appointments array of objects from Map.appointments
		 */
		public function populate(items:Array, appointments:Array):void
		{
			var newItem:MovieClip;
			var i:int;
			var itemCount:int;
			
			while (numChildren){
				removeChildAt(0);
			}
			
			addChild(new mcWhereNext());//title text at 0,0
			
			//appointments is only those demos in the next hour... shouldn't be more than 2?
			itemCount = Math.min(2, appointments.length);
			for (i = 0; i < itemCount; i++){	
				newItem = new mcReminder();
				newItem.theText.text = appointments[i].time + " " + appointments[i].prettyName;
				newItem.x = -newItem.width;
				newItem.y = 65 + (i * 86);//65 is bump down for the title text
				addChild(newItem);
				TweenMax.to(newItem, .5, {x:0, delay:.1 * i});
			}
			var start:int = 65 + (i * 86);
			
			//limit recommended items to 2
			itemCount = Math.min(2, items.length);
			for (i = 0; i < itemCount; i++){				
				
				newItem = new mcRecommended();
				//prettyName is hardcoded into the gates array in the Orchestrate class
				newItem.theText.text = items[i].prettyName;
				newItem.y = start + (i * 86);
				newItem.x = -newItem.width;
				addChild(newItem);
				TweenMax.to(newItem, .5, {x:0, delay:.1 * i});
			}
		}
		
		
		public function hide():void
		{
			while (numChildren){
				removeChildAt(0);
			}
		}
		
	}
	
}