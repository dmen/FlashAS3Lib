/**
 * Replicates Time Magazines logo matching game:
 * http://time.com/3743739/company-logo-quiz/
 * 
 * 
 */
package com.gmrmarketing.testing
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	public class Draw extends MovieClip
	{
		private var logo:BitmapData;//image to be traced
		private var canvasData:BitmapData;
		private var canvas:Bitmap;
		private var lastX:int;
		private var lastY:int;		
		private var debugData:BitmapData;//debug image
		private var debug:Bitmap;//bitmap of debugData
		private var gridSize:int = 20;//sampling size when image is broken into grid
		
		
		public function Draw()
		{
			logo = new batman();
			
			debugData = new BitmapData(logo.width, logo.height, true, 0x00000000);
			debug = new Bitmap(debugData);
			
			canvasData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000);
			canvas = new Bitmap(canvasData);			
			addChild(canvas);			
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, beginDrawing);
			
			btnDebug.theText.text = "show/hide debug";
			btnDebug.addEventListener(MouseEvent.MOUSE_DOWN, showHideDebug);
			btn.addEventListener(MouseEvent.MOUSE_DOWN, doCheck);
			theGrade.visible = false;
		}
		
		
		private function showHideDebug(e:MouseEvent):void
		{
			if (contains(debug)) {
				removeChild(debug);
				debugText.visible = false;
			}else {
				addChild(debug);
				debugText.visible = true;
			}
		}
		
		
		private function beginDrawing(e:MouseEvent):void
		{			
			lastX = mouseX;
			lastY = mouseY;
			addEventListener(Event.ENTER_FRAME, updateDrawing);
			stage.addEventListener(MouseEvent.MOUSE_UP, endDrawing);
		}
		
		
		private function updateDrawing(e:Event):void
		{			
			efla(lastX, lastY, mouseX, mouseY, 0x000000, 4);
			lastX = mouseX;
			lastY = mouseY;
		}
		
		
		private function endDrawing(e:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, updateDrawing);
		}
		
		
		private function doCheck(e:MouseEvent):void
		{		
			//remove unscaled user drawing
			removeChild(canvas);
			
			//get the bounds of the drawing within the canvas
			var uRect:Rectangle = canvasData.getColorBoundsRect(0xFFFFFFFF, 0xFF20c0f0);
			//just the users drawing extracted from the full canvas image
			var userDrawing:BitmapData = new BitmapData(uRect.width, uRect.height, true, 0x00000000);
			userDrawing.copyPixels(canvasData, uRect, new Point(0, 0), null, null, true);			
			
			//scale the extracted user drawing to match the logo's size
			var userToLogo:BitmapData = new BitmapData(logo.width, logo.height, true, 0x00000000);			
			
			var hs:Number = logo.width / userDrawing.width;			
			var vs:Number = logo.height / userDrawing.height;
			var m:Matrix = new Matrix();
			m.scale(hs, vs);
			userToLogo.draw(userDrawing, m, null, null, null, true);			
			
			//place logo and user drawing on screen
			var lx:int = Math.floor((stage.stageWidth - logo.width) * .5);
			var ly:int = Math.floor((stage.stageHeight - logo.height) * .5);
			var l:Bitmap = new Bitmap(logo);
			l.x = lx; l.y = ly;
			addChild(l);
			var u:Bitmap = new Bitmap(userToLogo);
			u.x = lx; u.y = ly;
			addChild(u);			
			
			var ug:Array = imageGrid(userToLogo, gridSize);			
				
			var dbT:String = "=====DEBUG=====\n";
			var logoBlack:int = 0;
			var logoWhite:int = 0;
			var blackMatches:int = 0;
			var whiteMatches:int = 0;
			var isBlack:Boolean;
			var totalBlocks:int = 0;
			
			for (var i:int = 0; i < ug.length; i++) {
				for (var j:int = 0; j < ug[i].length; j++) {
					
					totalBlocks++;
					isBlack = checkRect(j * gridSize, i * gridSize, gridSize, gridSize);
					if (isBlack) {
						logoBlack++;
					}else {
						logoWhite++;
					}
					if (ug[i][j] == "*") {
						if (isBlack) {
							blackMatches++;
							//debug - user line matches logo
							debugData.fillRect(new Rectangle(j * gridSize, i * gridSize, gridSize, gridSize), 0x6600ff00);
						}						
					}else {
						//ug[i][j] = " "
						if (!isBlack) {
							whiteMatches++;
						}
					}					
				}
			}
			
			dbT += "grid size: " + gridSize + "\n";
			dbT += "total blocks: " + totalBlocks + "\n";
			dbT += "logo black: " + logoBlack + "\n";
			dbT += "black matches: " + blackMatches + "\n";
			dbT += "logo white: " + logoWhite + "\n";
			dbT += "white matches: " + whiteMatches + "\n";			
			
			debug.x = lx; debug.y = ly;
			addChild(debug);			

			var grade:Number = Math.floor((((blackMatches / logoBlack) + (whiteMatches / logoWhite)) / 2) * 100);
			dbT += "grade: " + grade;
			
			debugText.text = dbT;
			
			var g:String;
			if(grade > 92){
				g = "A+";
			}else if (grade > 88) {
				g = "A";
			}else if (grade > 84) {
				g = "A-";
			}else if (grade > 80) {
				g = "B+";
			}else if (grade > 76) {
				g = "B";
			}else if (grade > 72) {
				g = "B-";
			}else if (grade > 68) {
				g = "C+";
			}else if (grade > 64) {
				g = "C";
			}else if (grade > 60) {
				g = "C-";
			}else if (grade > 56) {
				g = "D+";
			}else if (grade > 52) {
				g = "D";
			}else if (grade > 48) {
				g = "D-";
			}else {
				g = "F";
			}
			
			theGrade.theText.text = g;
			theGrade.visible = true;
		}
		
		
		/**
		 * Checks a rect in the logo image for black pixels
		 * @param	x
		 * @param	y
		 * @param	w
		 * @param	h
		 * @return
		 */
		private function checkRect(x:int, y:int, w:int, h:int):Boolean
		{
			for (var i:int = y; i <= y + h; i++) {
				for (var j:int = x; j <= x + w; j++) {
					var pix:uint = logo.getPixel32(j, i) >> 24 & 0xFF;
					if (pix > 80) {
						return true;
					}
				}
			}
			return false;
		}
		
		
		/**
		 * extremely fast line algorithm
		 * @param	x
		 * @param	y
		 * @param	x2
		 * @param	y2
		 * @param	color
		 * @param	size
		 */
		private function efla(x:int, y:int, x2:int, y2:int, color:uint, size:int = 4):void
		{
		  var shortLen:int = y2-y;
		  var longLen:int = x2-x;
		  if((shortLen ^ (shortLen >> 31)) - (shortLen >> 31) > (longLen ^ (longLen >> 31)) - (longLen >> 31)){
			  shortLen ^= longLen;
			  longLen ^= shortLen;
			  shortLen ^= longLen;

			  var yLonger:Boolean = true;
		  }else {
			  yLonger = false;
			}

		  var inc:int = longLen < 0 ? -1 : 1;

		  var multDiff:Number = longLen == 0 ? shortLen : shortLen / longLen;

		  if (yLonger) 
		  {
			for (var i:int = 0; i != longLen; i += inc) 
			{
			  //canvasData.setPixel(x + i * multDiff, y + i, color);
			 // canvasData.copyPixels(brush, brushRect, new Point(x + i * multDiff, y + i), null, null, true);
			  canvasData.fillRect(new Rectangle(x + i * multDiff, y + i, size, size), 0xff20c0f0);
			}
		  } 
		  else 
		  {
			for (i = 0; i != longLen; i += inc) 
			{
			  //canvasData.setPixel(x + i, y + i * multDiff, color);
			  //canvasData.copyPixels(brush, brushRect, new Point(x + i, y + i * multDiff), null, null, true);
			  canvasData.fillRect(new Rectangle(x + i, y + i * multDiff, size, size), 0xff20c0f0);
			}
		  }
		}
		
		
		/**
		 * Produces a 2d array of *'s from the input image
		 * Number of rows (arrays) in the array = image.height / sampleSize
		 * Number of columns in each sub-array = image.width / sampleSize
		 * @param	image
		 * @param	sampleSize
		 * @return
		 */
		private function imageGrid(image:BitmapData, sampleSize:int = 2):Array
		{
			var grid:Array = [];
			var row:Array = [];		
			var curX:int = 0;
			var curY:int = 0;
			var pixAlpha:uint;
			var p:String;
			while (true) {
				
				//sample all pixels in the current grid square
				p = " ";
				for (var i:int = curY; i < curY + sampleSize; i++) {
					for (var j:int = curX; j < curX + sampleSize; j++) {
						pixAlpha = image.getPixel32(j, i) >> 24 & 0xFF;
						if (pixAlpha > 80) {
							p = "*";
							break;
						}
					}
				}
				row.push(p);
				
				curX += sampleSize;
				
				if (curX >= image.width) {
					curX = 0;
					curY += sampleSize;					
					grid.push(row);
					//trace(row);
					row = [];
					if (curY >= image.height) {
						break;
					}
				}
			}
			
			return grid;
		}
	}	
}