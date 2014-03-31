package gui 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class ZoneSelector extends Sprite
	{
		private var _tlpt:Point;
		private var _selectedArea:Rectangle;
		private var _scale:Number;
		
		public function ZoneSelector(scale:Number) 
		{
			_scale = scale;
		}
		
		// Public Methods
		public function getZone():Rectangle 
		{ 
			var rect:Rectangle = new Rectangle(_selectedArea.x * _scale, _selectedArea.y * _scale, _selectedArea.width * _scale, _selectedArea.height * _scale);
			return rect;
		}
		
		public function startSelect():void
		{
			_selectedArea = new Rectangle(mouseX, mouseY, 0, 0);
		}
		
		public function endSelect():void
		{
			graphics.clear();
		}
		
		public function update():void
		{
			_selectedArea.width = Math.max(0, mouseX - _selectedArea.x);
			_selectedArea.height = Math.max(0, mouseY - _selectedArea.y);
			drawArea();
		}
		
		// Private Methods
		
		private function drawArea():void
		{
			with (graphics)
			{
				clear();
				lineStyle(2, 0xFF0000);
				moveTo(_selectedArea.x, _selectedArea.y);
				lineTo(_selectedArea.x + _selectedArea.width, _selectedArea.y);
				lineTo(_selectedArea.x + _selectedArea.width, _selectedArea.y + _selectedArea.height);
				lineTo(_selectedArea.x, _selectedArea.y + _selectedArea.height);
				lineTo(_selectedArea.x, _selectedArea.y);
			}
			
		}
		
	}
	
}
