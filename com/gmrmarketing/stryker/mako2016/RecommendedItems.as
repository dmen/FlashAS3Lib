/**
 * Shows the recommended activites... uses mcRecommended movieClip in the library
 * This is a sprite that is placed by Main.as
 */
package com.gmrmarketing.stryker.mako2016
{
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	public class RecommendedItems extends Sprite
	{		
		public static const ITEM_CLICK:String = "itemClicked";
		private var clickName:String;
		
		
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
				
				//need to color the bg of the reminder to match the demo type
				var bgColor:Number;
				switch(appointments[i].name){
					case "Demo 1":
						bgColor = 0x87438C;
						break;
					case "Demo 3":
						bgColor = 0x4C7D7A;
						break;
					case "Demo 2":
					case "Demo 4":
					case "Demo 5":
					case "Demo 6":
					case "Demo 7":
						bgColor = 0xFDB515;
						break;
				}
				TweenMax.to(newItem.bg, 0, {colorTransform:{tint:bgColor, tintAmount:1}});
				
				newItem.name = appointments[i].name;
				newItem.theText.text = appointments[i].time + " " + appointments[i].prettyName;
				newItem.x = -newItem.width;
				newItem.y = 65 + (i * 86);//65 is bump down for the title text
				newItem.addEventListener(MouseEvent.MOUSE_DOWN, itemClick, false, 0, true);
				addChild(newItem);
				TweenMax.to(newItem, .5, {x:0, delay:.1 * i});
			}
			
			var start:int = 65 + (i * 86);
			
			//add one or two more - max three tota
			if(itemCount == 2){			
				itemCount = Math.min(1, items.length);
			}else if(itemCount == 1){
				itemCount = Math.min(2, items.length);
			}else{
				//no appointments
				itemCount = Math.min(3, items.length);
			}
			
			for (i = 0; i < itemCount; i++){				
				
				newItem = new mcRecommended();
				
				//prettyName is hardcoded into the gates array in the Orchestrate class
				newItem.theText.text = items[i].prettyName;
				newItem.name = items[i].name;
				newItem.addEventListener(MouseEvent.MOUSE_DOWN, itemClick, false, 0, true);
				newItem.y = start + (i * 86);
				newItem.x = -newItem.width;
				addChild(newItem);
				TweenMax.to(newItem, .5, {x:0, delay:.1 * i});
			}
		}
		
		
		private function itemClick(e:MouseEvent):void
		{
			clickName = MovieClip(e.currentTarget).name;			
			dispatchEvent(new Event(ITEM_CLICK));
		}
		
		
		public function get clickItem():String
		{
			return clickName;
		}
		
		
		public function hide():void
		{
			while (numChildren){
				removeChildAt(0);
			}
		}
		
	}
	
}