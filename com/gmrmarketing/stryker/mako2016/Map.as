package com.gmrmarketing.stryker.mako2016
{
	import flash.events.*;
	import flash.display.*;
	import flash.geom.Point;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Map extends EventDispatcher
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Map()
		{
			clip = new mcMap();
			clip.x = 620;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{			
			myContainer = c;
		}
		
		
		/**
		 * 
		 * @param	kioskLogin String Info Kiosk login name - like Kiosk2
		 */
		public function show(kioskLogin:String):void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			var pt:Point = new Point();			
			pt.x = clip[kioskLogin.toLowerCase()].x;
			pt.y = clip[kioskLogin.toLowerCase()].y;
			
			clip.youAreHere.x = pt.x + 8;//kiosk sprites are 16x18 so this gets the pt on center
			clip.youAreHere.y = pt.y + 9;
		}
		
		
		/**
		 * 
		 * @param	user
		 * @param	gates This is the gates array from Orchestrate class - the gates this app cares about
		 * for this method only the first 13 items of the array are used - the remainder are these kiosks
		 */
		public function setVisited(user:Object, gates:Array):void
		{
			var hist:Array = user.history;//if any object gateId matches
			
			clearIcons(gates);
			
			for (var i:int = 0; i < 13; i++){//gates[0 - 12]
				
				for (var j:int = 0; j < hist.length; j++){
					
					if (gates[i].id == hist[j].gateId){
						//user has already visited this poi
						TweenMax.to(clip[gates[i].clip], .5, {colorTransform:{tint:0xE4E5E3, tintAmount:1}});
						clip[gates[i].icon].addChild(new iconCheck());
						break;
					}
				}
			}
		}
		
		
		private function clearIcons(gates:Array):void
		{
			for (var i:int = 0; i < 13; i++){
				var mc:MovieClip = clip[gates[i].icon];
				while (mc.numChildren){
					mc.removeChildAt(0);
				}
			}
		}
		
	}
	
}