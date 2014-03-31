package {
	import flash.display.Sprite;
	
	public class Wheel extends Sprite {
		public var radius:Number;
		public var vx:Number = 0;
		public var vy:Number = 0;
		public var mass:Number;
		
		public function Wheel(radius:Number=40) {
			this.radius = radius;
			mass = radius * 4;
			init();
		}
		public function init():void {
			graphics.beginFill(0x000000);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
			graphics.beginFill(0xffffff);
			graphics.drawCircle(0, 0, radius-3);
			graphics.endFill();
		}
	}
}