package com.gmrmarketing.crest
{
	import flash.geom.Point;
	
	public class TilePoints
	{
		private var pointArray:Array;
		
		public function TilePoints()
		{
			pointArray = new Array();
		}
		
		public function init(xPixels:int, yPixels:int, tileWidth:int, tileHeight:int):Array
		{
			var curX:int = 0;
			var curY:int = 0;
			
			var rows:int = Math.ceil(yPixels / tileHeight);
			var cols:int = Math.ceil(xPixels / tileWidth);
			
			for (var i:int = 0; i < rows; i++) {
				for (var j:int = 0; j < cols; j++) {
					pointArray.push(new Point(j * tileWidth, i * tileHeight));
				}
			}
			
			//randomize the array
			var n:Array = new Array();			
			while(pointArray.length > 0){
				n.push(pointArray.splice(Math.floor(Math.random() * pointArray.length), 1)[0]);
			}
			
			return n;
		}
		
	}
	
}