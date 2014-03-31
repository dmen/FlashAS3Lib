package com.gmrmarketing.hp.spinner
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.cove.ape.APEngine;
	import org.cove.ape.CircleParticle;
	import org.cove.ape.Group;
	import org.cove.ape.RectangleParticle;
	import org.cove.ape.VectorForce;
	

	public class Demo extends Sprite 
	{
		public function Demo():void 		
		{	
			initAPE();			
			initObjects();			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function initAPE():void
		{			
			APEngine.init();			
			APEngine.container = this;
			APEngine.addForce(new VectorForce(false, 0, 2));
		}
		
		private function initObjects():void
		{
			// Create a group to hold all the objects with collision
			var group:Group = new Group(true);
			
			// Create a rectangle for rhe floor
			var floor:RectangleParticle = new RectangleParticle(0, 400, 1200, 25, 0, true);
			
			// Create a circle 
			var circle:CircleParticle = new CircleParticle(225, -100, 25);
			
			// Add the floor to the group
			group.addParticle(floor);
			
			// Add the circle to the group
			group.addParticle(circle);
			
			// Add the group to the engine
			APEngine.addGroup(group);
		}
		
		private function onEnterFrame(e:Event):void 
		{			
			APEngine.step();
			APEngine.paint();
		}
		
	}
	
}