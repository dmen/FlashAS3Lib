package com.gmrmarketing.testing
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import net.hires.debug.Stats;
	
	public class MarchingSquares extends MovieClip
	{
		private var gridSize:int = 80;
		private var gridColumns:int;
		private var gridRows:int;		
		private var grid:Graphics;
		private var points:Graphics;
		private var lines:Graphics;
		private var circles:Array;		
		private var corners:Vector.<String>;		
		private var debug:Boolean = true;
		private var vecInit:Array;
		private var stats:Stats;
		
		
		public function MarchingSquares()
		{
			var gridSprite:Sprite = new Sprite();
			grid = gridSprite.graphics;
			
			var pointsSprite:Sprite = new Sprite();
			points = pointsSprite.graphics;
			
			var linesSprite:Sprite = new Sprite();
			lines = linesSprite.graphics;
			
			addChild(gridSprite);
			addChild(pointsSprite);
			addChild(linesSprite);
			
			//lines.filters = [new BlurFilter(8,8,1),new GlowFilter(0xaadd00, .6, 14, 14, 6, 1)];
			
			circles = [];
			for (var i:int = 0; i < 18; i++){
				var c:Circle = new Circle(debug);
				c.x = stage.stageWidth * Math.random();
				c.y = stage.stageHeight * Math.random();
				addChild(c);
				circles.push(c);
			}
			
			gridColumns = Math.floor(stage.stageWidth / gridSize);
			gridRows = Math.floor(stage.stageHeight / gridSize);
			
			if(debug){
				drawGrid();
			}
			
			vecInit = [];
			for (i = 0; i < gridColumns * gridRows; i++) {
				vecInit[i] = "0";
			}
			stats = new Stats();
			addChild(stats);
			
			trace("Grid: columns:", gridColumns, "rows:", gridRows, "size:", vecInit.length);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, pausePlay);
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function update(e:Event):void
		{
			markCornersFast();
			iterateCells();
		}


		//debug method
		private function drawGrid():void
		{
			grid.lineStyle(1, 0x333333);			
			
			for (var i:int = 0; i <= gridColumns; i++) {				
				grid.moveTo(i * gridSize, 0);
				grid.lineTo(i * gridSize, gridRows * gridSize);
			}
			for (i = 0; i <= gridRows; i++) {
				grid.moveTo(0, i * gridSize);
				grid.lineTo(gridColumns * gridSize, i * gridSize);			
			}
		}

		
		private function markCornersFast():void
		{
			points.clear();
			corners = Vector.<String>(vecInit);
			var gridX:int;
			var gridY:int;
			for (var i:int = 0; i < circles.length; i++) {
				gridX = Math.floor(circles[i].x / gridSize);
				gridY = Math.floor(circles[i].y / gridSize);
				
				corners[gridX + gridY * (gridColumns + 1)] = "1";
				
				if (debug) {					
					points.beginFill(0xffff00,1);
					points.drawCircle(gridX * gridSize, gridY * gridSize, 2);
					points.endFill();
				}
			}
		}
		
		
		private function pausePlay(e:MouseEvent):void
		{
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, update);
				for (var i:int = 0; i < circles.length; i++) {
					circles[i].stop();
				}
				iterateCells();
			}else {
				addEventListener(Event.ENTER_FRAME, update);
				for (i = 0; i < circles.length; i++) {
					circles[i].startMoving();
				}
			}
		}
		
		
		private function iterateCells():void
		{			
			var n:int = corners.length - gridColumns - 2;
			var cell:String;
			
			lines.clear();
			lines.lineStyle(2, 0x009900);
			
			var cellIndex = 0;
			var row:int = 0;
			
			for (var i:int = 0; i < n; i++) {
				
				//cell = [corners[i], corners[i + 1], corners[i + cellsPerRow], corners[i + cellsPerRow + 1]];
				cell = corners[i] + corners[i + 1] + corners[i + gridColumns + 2] + corners[i + gridColumns + 1];
				
				switch(cell) {
					case "0001":
						lines.moveTo(cellIndex * gridSize, (row * gridSize) + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						break;
					
					case "1110":
						lines.moveTo(cellIndex * gridSize, (row * gridSize) + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						break;
						
					case "0011":
						lines.moveTo(cellIndex * gridSize, (row * gridSize) + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "1100":
						lines.moveTo(cellIndex * gridSize, (row * gridSize) + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "0110":
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						break;
						
					case "1001":
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						break;
								
					case "0010":
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "1101":
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "0100":
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "1011":
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "0111":
						lines.moveTo(cellIndex * gridSize, row * gridSize + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						break;
						
					case "1000":
						lines.moveTo(cellIndex * gridSize, row * gridSize + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						break;
						
					case "0101":
						lines.moveTo(cellIndex * gridSize, row * gridSize + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "1010":
						lines.moveTo(cellIndex * gridSize, (row * gridSize) + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;						
				}				
				
				if (cellIndex + 1 == gridColumns) {
					i++;
					cellIndex = 0;
					row++;
				}else{
					cellIndex++;
				}
			}
		}
		
	}
	
}