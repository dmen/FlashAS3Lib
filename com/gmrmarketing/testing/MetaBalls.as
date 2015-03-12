package com.gmrmarketing.testing
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import net.hires.debug.Stats;
	
	public class MetaBalls extends MovieClip
	{
		private var gridSize:int = 10;
		private var gridColumns:int;
		private var gridRows:int;		
		private var debugGrid:Graphics;
		private var debugPoints:Graphics;
		private var lines:Graphics;
		private var circles:Array;		
		private var corners:Vector.<String>;
		private var grid:Vector.<uint>;
		private var debug:Boolean = false;
		private var vecInit:Array;
		private var stats:Stats;
		
		
		public function MetaBalls()
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
			
			linesSprite.filters = [new GlowFilter(0xaa0088,1,8,8,1,2)];
			
			circles = [];
			for (var i:int = 0; i < 60; i++){
				var c:Circle = new Circle(debug);
				c.x = stage.stageWidth * Math.random();
				c.y = stage.stageHeight * Math.random();
				addChild(c);
				circles.push(c);
			}
			
			gridColumns = Math.floor(stage.stageWidth / gridSize);
			gridRows = Math.floor(stage.stageHeight / gridSize);
			
			//if(debug){
				drawGrid();
			//}
			
			vecInit = [];
			for (i = 0; i < gridColumns * gridRows; i++) {
				vecInit[i] = "0";
			}
			//stats = new Stats();
			//addChild(stats);
			
			trace("Grid size:",gridSize, "columns:", gridColumns, "rows:", gridRows, "size:", vecInit.length);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, pausePlay);
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function update(e:Event):void
		{
			markCorners();
			marchingSquares();
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

		
		private function markCorners():void
		{
			debugPoints.clear();
			corners = Vector.<String>(vecInit);
			
			var gridX:int;
			var gridY:int;
			
			var circX:int;
			var circY:int;
			var circR:int;
			
			var tx:Number;
			var ty:Number;
			
			for (var i:int = 0; i < circles.length; i++) {
				
				circX = circles[i].x;
				circY = circles[i].y;
				circR = circles[i].radius;
				
				//for (var r:Number = 0; r <= circR; r += 1) {
					
					
					for (var j:Number = 0; j < 6.28; j += .03) {
						tx = circX + Math.cos(j) * circR;
						ty = circY + Math.sin(j) * circR;
						
						gridX = Math.floor(tx / gridSize);
						gridY = Math.floor(ty / gridSize);
						
						try{
							corners[gridX + gridY * (gridColumns + 1)] = "1";
						}catch(e:Error) {
							
						}
						
						if (debug) {					
							debugPoints.beginFill(0xaaaa00,1);
							debugPoints.drawCircle(gridX * gridSize, gridY * gridSize, 1);
							debugPoints.endFill();
						}
					}
				//}				
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
		
		
		private function marchingSquares():void
		{			
			var n:int = corners.length - gridColumns - 2;
			var cell:String;
			var thickness:int = 2;
			lines.clear();		
			
			var cellIndex = 0;
			var row:int = 0;
			var col:Number = 0x009900;
			
			for (var i:int = 0; i < n; i++) {				
				
				cell = corners[i] + corners[i + 1] + corners[i + gridColumns + 2] + corners[i + gridColumns + 1];
				
				switch(cell) {
					case "0001":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize, (row * gridSize) + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						break;
					
					case "1110":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize, (row * gridSize) + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						break;
						
					case "0011":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize, (row * gridSize) + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "1100":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize, (row * gridSize) + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "0110":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						break;
						
					case "1001":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						break;
								
					case "0010":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "1101":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "0100":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "1011":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "0111":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize, row * gridSize + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						break;
						
					case "1000":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize, row * gridSize + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						break;
						
					case "0101":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize, row * gridSize + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
						
					case "1010":
						lines.lineStyle(thickness, col);
						lines.moveTo(cellIndex * gridSize, (row * gridSize) + (gridSize * .5));
						lines.lineTo(cellIndex * gridSize + (gridSize * .5), row * gridSize + gridSize);
						
						lines.moveTo(cellIndex * gridSize + (gridSize * .5), row * gridSize);
						lines.lineTo(cellIndex * gridSize + gridSize, (row * gridSize) + (gridSize * .5));
						break;
					
					case "1111":
						lines.lineStyle();
						lines.beginFill(0x006666, .3);
						lines.drawRect(cellIndex * gridSize, row * gridSize, gridSize, gridSize);
						break;
						//lines.endFill();
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