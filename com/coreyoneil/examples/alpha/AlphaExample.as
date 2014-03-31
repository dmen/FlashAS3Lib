package
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.Event;
	
	import com.coreyoneil.collision.CollisionList;
	
	public class AlphaExample extends Sprite
	{
		private var _balls			:Array;
		private var _collisionList	:CollisionList;
		
		private const GRAVITY		:Number = 1.5;
		private const FRICTION		:Number = .95;
		
		public function AlphaExample():void
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
			_collisionList = new CollisionList(red);
			_balls = [];
		
			for(var i:uint = 0; i < 20; i++)
			{
				var ball:Ball = new Ball(8, 0x0000FF);
				ball.x = Math.random() * stage.stageWidth;
				ball.vx = ball.vy = 0;
				_balls.push(ball);
				addChild(ball);
				_collisionList.addItem(ball);
			}

			
			addEventListener(Event.ENTER_FRAME, updateScene);
			alphaThreshold.addEventListener(Event.CHANGE, updateAlpha, false, 0, true);
		}
		
		private function updateScene(e:Event):void
		{
			var collisions:Array = _collisionList.checkCollisions();
			
			for(i = 0; i < collisions.length; i++)
			{
				var collision:Object = collisions[i];
			
				var angle:Number = collision.angle;
				var overlap:int = collision.overlapping.length;
				var ball:Ball = collision.object1;
		
				var sin:Number = Math.sin(angle);
				var cos:Number = Math.cos(angle);
					
				var vx0:Number = ball.vx * cos + ball.vy * sin;
				var vy0:Number = ball.vy * cos - ball.vx * sin;
		
				vx0 = .4;
				ball.vx = vx0 * cos - vy0 * sin;
				ball.vy = vy0 * cos + vx0 * sin;
				
				ball.vx -= cos * overlap / ball.radius;
				ball.vy -= sin * overlap / ball.radius;
			}
			
			for(var i:uint = 0; i < 20; i++)
			{
				_balls[i].vy += GRAVITY;
				_balls[i].vy *= FRICTION;
				_balls[i].vx *= FRICTION
				_balls[i].y += _balls[i].vy;
				_balls[i].x += _balls[i].vx;
			}
			
			for(i = 0; i < _balls.length; i++)
			{
				if(_balls[i].y > stage.stageHeight)
				{
					_balls[i].y = 0;
					_balls[i].vy = _balls[i].vx = 0;
					_balls[i].x = Math.random() * stage.stageWidth;
				}
			}
		}
		
		private function updateAlpha(e:Event):void
		{
			_collisionList.alphaThreshold = e.currentTarget.value;
		}
		
		private function clean(e:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, updateScene);
			alphaThreshold.removeEventListener(Event.CHANGE, updateAlpha);
		}
	}
}