package com.gmrmarketing.testing
{
	import flash.display.MovieClip;
	import com.gmrmarketing.testing.Cap;
	import com.gmrmarketing.testing.PowerMeter;
	import com.coreyoneil.collision.CollisionList;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.ui.Mouse;
	
	public class BCHockey extends MovieClip
	{
		private var cap:Cap;
		private var col:CollisionList;
		private var meter:PowerMeter;
		
		
		public function BCHockey()
		{
			meter = new PowerMeter();
			
			cap = new Cap();
			cap.addEventListener(Cap.CAP_MOVED, checkCollisions, false, 0, true);
			cap.addEventListener(MouseEvent.MOUSE_DOWN, addPowerMeter, false, 0, true);
			addChild(cap);
			cap.moveCap(); //adds enterFrame listener - which dispatches CAP_MOVED events
			
			col = new CollisionList(cap);
			col.returnAngle = true;
			col.addItem(w1);
			col.addItem(w2);
			col.addItem(w3);
			col.addItem(w4);
			col.addItem(w5);
			col.addItem(goal);
		}
		
		private function addPowerMeter(e:MouseEvent):void
		{
			cap.vx = 0;
			cap.vy = 0;
			
			addChild(meter);
			meter.x = cap.x;
			meter.y = cap.y;
			meter.init();					
			
			stage.addEventListener(MouseEvent.MOUSE_UP, removePowerMeter, false, 0, true);
		}
		
		
		private function removePowerMeter(e:MouseEvent):void
		{
			removeChild(meter);
			var meterData:Object = meter.getMeterData();
			meter.stopMeter();			
			cap.vx = meterData.vx;
			cap.vy = meterData.vy;
			stage.removeEventListener(MouseEvent.MOUSE_UP, removePowerMeter);
		}
		
		
		
		private function checkCollisions(e:Event):void
		{
			var collisions:Array = col.checkCollisions();
			
			if (collisions.length) {
				
				var collision:Object = collisions[0];
				
				if (collision.object1.name == "goal" || collision.object2.name == "goal") {
					cap.stopCap(); //removes enterFrame - sets vx,vy = 0					
				}else{
					
					var angle:Number = collision.angle; //default - radians	
					var overlap:int = collision.overlapping.length;
					
					var sin:Number = Math.sin(angle);
					var cos:Number = Math.cos(angle);
						
					var vx0:Number = cap.vx * cos + cap.vy * sin;
					var vy0:Number = cap.vy * cos - cap.vx * sin;
					
					//vx0 = ((20 - 10000) * vx0) / (20 + 10000);
					cap.vx = vx0 * cos - vy0 * sin;
					cap.vy = vy0 * cos + vx0 * sin;
					
					cap.vx -= cos * overlap / (cap.width * .5);
					cap.vy -= sin * overlap / (cap.width * .5);
				}
			}			
			
		}
	}
	
}