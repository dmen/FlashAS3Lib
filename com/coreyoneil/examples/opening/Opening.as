package
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import com.coreyoneil.collision.CollisionList;
	
	public class Opening extends Sprite
	{
		private var _balls			:Array;
		private var _collisionList	:CollisionList;
		
		private const GRAVITY		:Number = .5;
		private const FRICTION		:Number = .95;
		
		public function Opening():void
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
			// Made our list, assigning the 'words' MC as our target
			_collisionList = new CollisionList(words);
			_balls = [];
		
			// Creating a bunch of balls and adding them to the collision list
			for(var i:uint = 0; i < 30; i++)
			{
				var ball:Ball = new Ball(Math.random() * 4 + 2, 0xFF9900);
				ball.x = Math.random() * stage.stageWidth;
				ball.vx = ball.vy = 0;
				_balls.push(ball);
				addChild(ball);
				_collisionList.addItem(ball);
			}
			
			// Since these are just quick examples, they update in enter frame listeners.
			// Depending on your project needs, you're likely better off using a timer.
			// For best results, I prefer a timer along with tracking the intervals between
			// calls to the handler to account for any inconsistencies.
			addEventListener(Event.ENTER_FRAME, updateScene);
		}
		
		private function updateScene(e:Event):void
		{
			// Rotate the words
			words.circle.rotation += .25;
			words.circle1.rotation += .5;
			words.circle2.rotation += .75;
			words.circle3.rotation += 1;
			words.circle4.rotation += 1.25;
			words.gear.rotation += 1.5;
			
			// Check for collisions
			var collisions:Array = _collisionList.checkCollisions();
			
			// Handle any collisions detected
			for(i = 0; i < collisions.length; i++)
			{
				// Grab the next collision in the array
				var collision:Object = collisions[i];
			
				// Extract the information I need.
				// Note that I know that object1 is the ball (and not the words) because
				// object1 is always the smaller of the two objects involved in the collision.
				var angle:Number = collision.angle;
				var overlap:int = collision.overlapping.length;
				var ball:Ball = collision.object1;
		 
				/*
					Here's the simplest method I'll use for quick physics incorporation.
					This approach is discussed in detail in the book ActionScript 3.0 Animation - Making Things Move!
					by Keith Peters.  It is an excellent book for those looking to get their feet wet in all
					things scripted animation.  In fact, it was a passage in that book that inspired me to
					write up the CDK.  So all in all, I highly recommend it.  :)
				*/
				var sin:Number = Math.sin(angle);
				var cos:Number = Math.cos(angle);
					
				var vx0:Number = ball.vx * cos + ball.vy * sin;
				var vy0:Number = ball.vy * cos - ball.vx * sin;
				
				// I'm reassigning vx0 here because I know the amount of bounce
				// I want in the collision regardless of mass.  I did this in most of the
				// examples because they use the same size ball.  
				vx0 = .4;
				
				// Otherwise, vx0 would have been further calculated using both objects' masses and velocities, like so:
				// var vx1:Number = object2.vx * cos + object2.vy * sin;
				// vx0 = ((ball.mass - object2.mass) * vx0 + 2 * object2.mass * vx1) / (ball.mass + object2.mass);
				
				ball.vx = vx0 * cos - vy0 * sin;
				ball.vy = vy0 * cos + vx0 * sin;
				
				ball.vx -= cos * overlap / ball.radius;
				ball.vy -= sin * overlap / ball.radius;
			}
			
			// Apply new vectors, along w/ gravity and friction
			for(var i:uint = 0; i < 30; i++)
			{
				_balls[i].vy += GRAVITY;
				_balls[i].vy *= FRICTION;
				_balls[i].vx *= FRICTION
				_balls[i].y += _balls[i].vy;
				_balls[i].x += _balls[i].vx;
			}
			
			// Quick bounds check on the stage
			for(i = 0; i < _balls.length; i++)
			{
				if(_balls[i].y > stage.stageHeight || _balls[i].x > stage.stageWidth || _balls[i].x < 0)
				{
					_balls[i].y = 0;
					_balls[i].vy = _balls[i].vx = 0;
					_balls[i].x = Math.random() * stage.stageWidth;
				}
			}
		}
		
		private function clean(e:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, updateScene);
		}
	}
}