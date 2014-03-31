package com.gmrmarketing.rbc
{
	import flash.display.Sprite;
	import flash.utils.Timer;
    import flash.events.TimerEvent;
	import flash.display.MovieClip;
	import com.gmrmarketing.Particle;
	import flash.geom.Point; 
		
	public class Ball extends MovieClip
	{
		private var position:Point;
        private var vector:Point;        
        private var gravity:Number;
        private var friction:Number;
        private var update:Timer;
		private var myContainer:Sprite;
		
		public function Ball(cont:Sprite, pos:Point, vec:Point, grav:Number, fric:Number)
		{ 
			myContainer = cont;
			
			position = pos;
            vector = vec;            
            gravity = grav;
            friction = fric;
			
			update = new Timer(25);
			update.addEventListener(TimerEvent.TIMER, setPosition, false, 0, true);
			update.start();
        }
        
		private function setPosition(e:TimerEvent):void
		{         
            //Apply The Vector To The Position
            position.x += vector.x;
            position.y += vector.y;
           
            //Apply gravity
            vector.y += gravity;
           
            //Apply Friction!
            //vector.x *= friction;
			
			x = position.x;
			y = position.y;
			
			if (y > 890) {
				kill();
			}
		}
		private function kill()
		{
			update.stop();
				update.removeEventListener(TimerEvent.TIMER, setPosition);
				myContainer.removeChild(this);
				position = null;
				vector = null;
				gravity = undefined;
				friction = undefined;
		}
		public function newVector(p:Point) {
			//kill();
			vector = p;
			position.x += p.x * 10;
			position.y += p.y * 5;
		}
		
	}
	
}