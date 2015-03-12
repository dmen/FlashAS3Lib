package com.gmrmarketing.testing
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import net.hires.debug.Stats;
	
	public class MetaBalls2 extends MovieClip
	{
		private var gridSize:int = 3;
		private var gridColumns:int;
		private var gridRows:int;		
		private var debugGrid:Graphics;
		private var debugPoints:Graphics;
		private var lines:Graphics;
		private var circles:Array;		
		//private var corners:Vector.<String>;
		private var grid:Array;
		private var debug:Boolean = false;
		private var stats:Stats;
		
		
		public function MetaBalls2()
		{
			var debugGridSprite:Sprite = new Sprite();
			debugGrid = debugGridSprite.graphics;
			
			var debugPointsSprite:Sprite = new Sprite();
			debugPoints = debugPointsSprite.graphics;
			
			var linesSprite:Sprite = new Sprite();
			lines = linesSprite.graphics;
			
			addChild(debugGridSprite);
			addChild(debugPointsSprite);
			addChild(linesSprite);
			
			linesSprite.filters = [new DropShadowFilter(2, 30, 0, 1, 5, 5, 1, 2)];
			
			circles = [];
			for (var i:int = 0; i < 50; i++){
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
			
			//if(debug){
			  //stats = new Stats();
			  //addChild(stats);
			//}
			
			trace("Grid size:",gridSize, "columns:", gridColumns, "rows:", gridRows);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, pausePlay);
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		//debug method
		private function drawGrid():void
		{
			debugGrid.clear();
			debugGrid.lineStyle(1, 0x222200);			
			
			for (var i:int = 0; i <= gridColumns; i++) {				
				debugGrid.moveTo(i * gridSize, 0);
				debugGrid.lineTo(i * gridSize, gridRows * gridSize);
			}
			for (i = 0; i <= gridRows; i++) {
				debugGrid.moveTo(0, i * gridSize);
				debugGrid.lineTo(gridColumns * gridSize, i * gridSize);			
			}
		}		
		
		
		private function pausePlay(e:MouseEvent):void
		{
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, update);
				for (var i:int = 0; i < circles.length; i++) {
					circles[i].stop();
				}
				marchingSquares();
			}else {
				addEventListener(Event.ENTER_FRAME, update);
				for (i = 0; i < circles.length; i++) {
					circles[i].startMoving();
				}
			}
		}
		
		
		private function update(e:Event):void
		{
			markCorners();
			marchingSquares();
		}
		
		
		private function markCorners():void
		{
			debugPoints.clear();
			
			grid = [];
			for (i = 0; i <= gridRows; i++) {
				var aRow:Array = [];
				for (var j:int = 0; j <= gridColumns; j++) {
					aRow.push(0);
				}
				grid.push(aRow);
			}
			
			var gridUC:int;
			var gridLC:int;
			var gridUR:int;
			var gridLR:int;
			
			var circX:int;
			var circY:int;
			var circR:int;
			
			for (var i:int = 0; i < circles.length; i++) {
				
				circX = circles[i].x;
				circY = circles[i].y < 0 ? 0 : circles[i].y;
				circR = circles[i].radius;
				
				//upper left corner & lower right
				gridUC = Math.floor((circX - circR) / gridSize);
				gridLC = Math.floor((circX + circR) / gridSize);
				gridUR = Math.floor((circY - circR) / gridSize);
				gridLR = Math.floor((circY + circR) / gridSize);
				
				//gridCol = Math.floor(circX / gridSize);//round?
				//gridRow = Math.floor(circY / gridSize);
				
				for (var r:int = gridUR; r <= gridLR; r++) {
					for (var c:int = gridUC; c <= gridLC; c++) {
						try{
							grid[r][c] = 1;//center of circle					
						}catch (e:Error) {
							//trace("Error marking at row:", gridRow, "col:", gridCol,"circle x,y:",circX,",",circY);
						}
					}
				}
				/*
				try{
					grid[gridRow][gridCol] = 1;//center of circle					
				}catch (e:Error) {
					trace("Error marking at row:", gridRow, "col:", gridCol,"circle x,y:",circX,",",circY);
				}
					*/
				//draw a dot at circle x,y
				if (debug) {					
					//debugPoints.beginFill(0xaaaa00,1);
					//debugPoints.drawCircle(gridCol * gridSize, gridRow * gridSize, 2);
					//debugPoints.endFill();
				}
			}
		}
		
		
		private function marchingSquares():void
		{	
			var cell:String;
			
			lines.clear();		
			lines.lineStyle(2, 0x009900);
			
			for (var r:int = 0; r < gridRows; r++) {
				
				for (var c:int = 0; c < gridColumns; c++) {				
					
					try{
						cell = String(grid[r][c]) + String(grid[r][c + 1]) + String(grid[r + 1][c + 1]) + String(grid[r + 1][c]);
						//trace(cell);
					}catch (e:Error) {
						trace("Error at r,c:", r, c);
					}
					
					//cell = corners[i] + corners[i + 1] + corners[i + gridColumns + 2] + corners[i + gridColumns + 1];
					
					switch(cell) {
						case "0001":							
							lines.moveTo(c * gridSize, (r * gridSize) + (gridSize * .5));
							lines.lineTo(c * gridSize + (gridSize * .5), r * gridSize + gridSize);
							break;
						
						case "1110":
							lines.moveTo(c * gridSize, (r * gridSize) + (gridSize * .5));
							lines.lineTo(c * gridSize + (gridSize * .5), r * gridSize + gridSize);
							break;
							
						case "0011":
							lines.moveTo(c * gridSize, (r * gridSize) + (gridSize * .5));
							lines.lineTo(c * gridSize + gridSize, (r * gridSize) + (gridSize * .5));
							break;
							
						case "1100":
							lines.moveTo(c * gridSize, (r * gridSize) + (gridSize * .5));
							lines.lineTo(c * gridSize + gridSize, (r * gridSize) + (gridSize * .5));
							break;
							
						case "0110":
							lines.moveTo(c * gridSize + (gridSize * .5), r * gridSize);
							lines.lineTo(c * gridSize + (gridSize * .5), r * gridSize + gridSize);
							break;
							
						case "1001":
							lines.moveTo(c * gridSize + (gridSize * .5), r * gridSize);
							lines.lineTo(c * gridSize + (gridSize * .5), r * gridSize + gridSize);
							break;
									
						case "0010":
							lines.moveTo(c * gridSize + (gridSize * .5), r * gridSize + gridSize);
							lines.lineTo(c * gridSize + gridSize, (r * gridSize) + (gridSize * .5));
							break;
							
						case "1101":
							lines.moveTo(c * gridSize + (gridSize * .5), r * gridSize + gridSize);
							lines.lineTo(c * gridSize + gridSize, (r * gridSize) + (gridSize * .5));
							break;
							
						case "0100":
							lines.moveTo(c * gridSize + (gridSize * .5), r * gridSize);
							lines.lineTo(c * gridSize + gridSize, (r * gridSize) + (gridSize * .5));
							break;
							
						case "1011":
							lines.moveTo(c * gridSize + (gridSize * .5), r * gridSize);
							lines.lineTo(c * gridSize + gridSize, (r * gridSize) + (gridSize * .5));
							break;
							
						case "0111":
							lines.moveTo(c * gridSize, r * gridSize + (gridSize * .5));
							lines.lineTo(c * gridSize + (gridSize * .5), r * gridSize);
							break;
							
						case "1000":
							lines.moveTo(c * gridSize, r * gridSize + (gridSize * .5));
							lines.lineTo(c * gridSize + (gridSize * .5), r * gridSize);
							break;
							
						case "0101":
							lines.moveTo(c * gridSize, r * gridSize + (gridSize * .5));
							lines.lineTo(c * gridSize + (gridSize * .5), r * gridSize);
							
							lines.moveTo(c * gridSize + (gridSize * .5), r * gridSize + gridSize);
							lines.lineTo(c * gridSize + gridSize, (r * gridSize) + (gridSize * .5));
							break;
							
						case "1010":
							lines.moveTo(c * gridSize, (r * gridSize) + (gridSize * .5));
							lines.lineTo(c * gridSize + (gridSize * .5), r * gridSize + gridSize);
							
							lines.moveTo(c * gridSize + (gridSize * .5), r * gridSize);
							lines.lineTo(c * gridSize + gridSize, (r * gridSize) + (gridSize * .5));
							break;
						
					}
					
				}
			}
		}
		
	}
	
}