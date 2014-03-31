package
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import com.coreyoneil.collision.CollisionList;
	
	public class TerrainExample extends Sprite
	{
		private var _wheel			:Wheel;
		private var _collisionList	:CollisionList;
		private var _speed			:Number;
		
		private const GRAVITY		:Number = .75;
		private const FRICTION		:Number = .98;
		private const IMMOVABLE		:Number = 10000;
		
		public function TerrainExample():void
		{
			if(stage == null)
			{
				addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
				addEventListener(Event.REMOVED_FROM_STAGE, clean, false, 0, true);
			}
			else
			{
				init();
			}
		}
		
		private function init(e:Event = null):void
		{
			_collisionList = new CollisionList(terrain);
			
			_wheel = new Wheel(10);
			_wheel.mass = IMMOVABLE * 2;
			addChild(_wheel);
			_collisionList.addItem(_wheel);
			_wheel.x = 30;
			_wheel.y = 10;
			
			_speed = 0;
			
			terrain.graphics.lineStyle(15);
			
			addEventListener(Event.ENTER_FRAME, updateScene);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
			btn.addEventListener(MouseEvent.CLICK, clearCanvas);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
		}
		
		private function keyPressed(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.LEFT) _speed = -.5;
			if(e.keyCode == Keyboard.RIGHT) _speed = .5;
		}
		
		private function keyReleased(e:KeyboardEvent):void
		{
			_speed = 0;
		}
		
		private function clearCanvas(e:MouseEvent):void
		{
			terrain.graphics.clear();
				
			terrain.graphics.lineStyle(15);
			while(terrain.numChildren > 0)
			{
				terrain.removeChildAt(0);
			}
		}
		
		private function startDrawing(e:MouseEvent):void
		{
			terrain.graphics.moveTo(stage.mouseX, stage.mouseY);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, drawLine);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDrawing);
		}
		
		private function drawLine(e:MouseEvent):void
		{
			terrain.graphics.lineTo(stage.mouseX, stage.mouseY);
		}
		
		private function stopDrawing(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, drawLine);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDrawing);
		}
		
		private function updateScene(e:Event):void
		{			
			var collisions:Array = _collisionList.checkCollisions();
			
			if(collisions.length)
			{
				var collision:Object = collisions[0];
				var angle:Number = collision.angle;
				var overlap:int = collision.overlapping.length;
				
				var sin:Number = Math.sin(angle);
				var cos:Number = Math.cos(angle);
					
				var vx0:Number = _wheel.vx * cos + _wheel.vy * sin;
				var vy0:Number = _wheel.vy * cos - _wheel.vx * sin;
				
				// Unlike the other examples, here I'm choosing to calculate the amount
				// of bounce based on the objects' masses, with a default mass of 10000 (IMMOVABLE)
				// being used for the drawing the wheel is colliding with.  As such, the only
				// real variable in play here is the current vector of the wheel.
				vx0 = ((_wheel.mass - IMMOVABLE) * vx0) / (_wheel.mass + IMMOVABLE);
				_wheel.vx = vx0 * cos - vy0 * sin;
				_wheel.vy = vy0 * cos + vx0 * sin;
				
				_wheel.vx -= cos * overlap /_wheel.radius;
				_wheel.vy -= sin * overlap / _wheel.radius;
				
				_wheel.vx += _speed;
			}
			
			_wheel.vy += GRAVITY;
			_wheel.vy *= FRICTION;
			_wheel.vx *= FRICTION;
			
			_wheel.x += _wheel.vx;
			_wheel.y += _wheel.vy;
			
			if(_wheel.x > stage.stageWidth) _wheel.x = stage.stageWidth;	
			if(_wheel.x < 0) _wheel.x = 0;									
			if(_wheel.y > stage.stageHeight - (_wheel.height >> 1)) 
			{
				_wheel.y = 10;	
				_wheel.x = 30;
				_wheel.vx = _wheel.vy = 0;
			}
			
		}
		
		private function clean(e:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, updateScene);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, drawLine);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDrawing);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyReleased);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
		}
	}
}