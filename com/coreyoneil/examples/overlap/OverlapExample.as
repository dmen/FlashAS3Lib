package
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.coreyoneil.collision.CollisionList;
	
	public class OverlapExample extends Sprite
	{
		private var _collisionList	:CollisionList;
		
		private var _puffinShadow	:MovieClip;
		private var _puffinBMP		:Bitmap;
		private var _puffinBMD		:BitmapData;
		
		private var _vy				:Number;
		
		private var _dragging		:Boolean;
		
		private const GRAVITY		:Number = 1;
		private const BUOYANCY		:Number = 3.5;
		private const FRICTION		:Number = .98;
		
		public function OverlapExample():void
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
			puffin.x = stage.stageWidth * .5;
			puffin.useHandCursor = true;
			puffin.buttonMode = true;
			waves.mouseEnabled = false;
			_vy = 0;
			_dragging = false;
			
			_collisionList = new CollisionList(waves, puffin);
			_collisionList.returnAngle = false;
			
			_puffinShadow = new PuffinShadow();
			_puffinBMD = new BitmapData(_puffinShadow.width, _puffinShadow.height, true, 0xFFFFFFFF);
			_puffinBMD.draw(_puffinShadow);
			_puffinBMP = new Bitmap(_puffinBMD);
			addChild(_puffinBMP);
			_puffinBMP.x = _puffinBMP.y = 4;
			
			addEventListener(Event.ENTER_FRAME, updateScene);
			puffin.addEventListener(MouseEvent.MOUSE_DOWN, startDragging, false, 0, true);
		}
		
		private function startDragging(e:MouseEvent):void
		{
			puffin.startDrag();
			_dragging = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
		
		private function dragPuffin(e:MouseEvent):void
		{
			puffin.x = stage.mouseX;
			puffin.y = stage.mouseY;
		}
		
		private function stopDragging(e:MouseEvent):void
		{
			puffin.stopDrag();
			_dragging = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
		
		private function updateScene(e:Event):void
		{
			var collision:Array = _collisionList.checkCollisions();
			
			if(collision.length)
			{
				var pixels:Array = collision[0].overlapping;
				var percentage:Number = pixels.length / (puffin.width * puffin.height);
				_vy -= percentage * BUOYANCY;
				
				_puffinBMD.lock();
				_puffinBMD.fillRect(new Rectangle(0, 0, _puffinBMD.width, _puffinBMD.height), 0xFFFFFFFF);
				_puffinBMD.draw(_puffinShadow);
				var bounds:Rectangle = puffin.getBounds(stage);
				var pixelPos:Point = new Point();
				for(var i:int = 0; i < pixels.length; i++)
				{
					pixelPos.x = pixels[i].x - bounds.left;
					pixelPos.y = pixels[i].y - bounds.top;

					_puffinBMD.setPixel32(pixelPos.x, pixelPos.y, 0xFFFF0000);
				}
				_puffinBMP.bitmapData = _puffinBMD;
				_puffinBMD.unlock();
			}
			else
			{
				_puffinBMD.fillRect(new Rectangle(0, 0, _puffinBMD.width, _puffinBMD.height), 0xFFFFFFFF);
				_puffinBMD.draw(_puffinShadow);
				_puffinBMP.bitmapData = _puffinBMD;
			}
			
			if(!_dragging)
			{
				_vy += GRAVITY;
				_vy *= FRICTION;
				puffin.y += _vy;
			}
			else
			{
				_vy = 0;
			}
			
			if((puffin.y + puffin.height) > stage.stageHeight) puffin.y = stage.stageHeight - puffin.height;
			if(puffin.x < 0) puffin.x = 0;
			if(puffin.x > stage.stageWidth) puffin.x = stage.stageWidth;
		}
		
		private function clean(e:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, updateScene);
		}
	}
}