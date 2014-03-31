package com.gmrmarketing.testing
{
	import flash.display.*;
	import com.gmrmarketing.testing.*;	
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.getTimer;
	
	
	public class PacMan extends MovieClip
	{		
		private const TILE_SIZE:int = 19;
		private const TILE_SPEED:int = 100; //milliseconds to cover a full tile
		
		private var theMaze:Array;
		private var pac:Shape;
		
		private var speed:Array;
		private var pacX:int;
		private var pacY:int;
		private var targetX:int;
		private var targetY:int;
		private var startTime:int;
		private var waitFor:Number;
		private var elapsed:int;
		private var direction:String;
		
		
		
		public function PacMan()
		{		
			pac = new Shape();
			pac.graphics.beginFill(0xffff00, 1);
			pac.graphics.drawCircle(-5, -5, 10);
			pac.graphics.endFill();
			
			init();			
		}
		
		
		private function init():void
		{			
			speed = [0, 0];
			
			drawMaze(Mazes.getLevel1());
			
			pac.x = 260; 
			pac.y = 450;
			addChild(pac);
			
			targetX = pac.x;
			targetY = pac.y;
			waitFor = 0;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown, false, 0, true);
			
			addEventListener(Event.ENTER_FRAME, gameLoop, false, 0, true);
		}
		
		
		private function drawMaze(maze:Array):void
		{
			theMaze = maze.concat();
			
			var row:int = 0;			
			
			while (maze.length) {
				
				var mRow:String = maze.splice(0, 1)[0];
				for (var i:int = 0; i < mRow.length; i++) {
					var t:Tile = new Tile(mRow.substr(i, 1), TILE_SIZE);
					t.x = i * TILE_SIZE;
					t.y = row * TILE_SIZE;
					addChild(t);
				}
				row++;				
			}
		}
		
		
		private function isOK(x:int, y:int):Boolean
		{			
			var col:int = Math.floor(x / 19);
			var row:int = Math.floor(y / 19);			
			
			var s:String = String(theMaze[row]).substr(col, 1);
			
			return (s == ".") || (s == " ");
		}		
		
		
		private function keyDown(e:KeyboardEvent):void
		{
			//is pacMan moving?
			//if (speed[0] == 0 && speed[1] == 0) {				
				
				switch(e.keyCode) {
					case 37:
						direction = "l";						
						break;
					case 39:
						direction = "r";						
						break;
					case 38:
						direction = "u";						
						break;
					case 40:
						direction = "d";						
						break;					
				}
				moveTo();				
			//}			
		}
		
		
		private function moveTo():void
		{
			switch(direction) {
				case "l":
					targetX = pac.x - TILE_SIZE;
					speed = [ -TILE_SIZE / TILE_SPEED, 0];
					break;
				case "r":
					targetX = pac.x + TILE_SIZE;
					speed = [TILE_SIZE / TILE_SPEED, 0]; //.038
					break;
				case "u":
					targetY = pac.y - TILE_SIZE;
					speed = [0, -TILE_SIZE / TILE_SPEED];
					break;
				case "d":
					targetY = pac.y + TILE_SIZE;
					speed = [0, TILE_SIZE / TILE_SPEED];
					break;
			}
			
			if (isOK(targetX, targetY)) {					
				//ok to move to this target loc, calculate the speed
				pacX = pac.x;
				pacY = pac.y;
				startTime = getTimer();
				waitFor = startTime + TILE_SPEED;
				elapsed = 0;					
			}else {
				speed = [0, 0];
				targetX = pac.x;
				targetY = pac.y;
			}
		}
		
		
		
		
		
		private function gameLoop(e:Event):void
		{
			elapsed = getTimer() - startTime;
			
			if (getTimer() < waitFor) {				
				
				//pacMan is still moving
				pac.x = pacX + speed[0] * elapsed;
				pac.y = pacY + speed[1] * elapsed;
				
			}else {				
				pac.x = targetX;
				pac.y = targetY;
				moveTo();
			}
			
		}
		
	}	
	
}