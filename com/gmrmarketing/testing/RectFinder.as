package com.gmrmarketing.testing
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.text.TextFieldAutoSize;	
	
	public class RectFinder extends EventDispatcher
	{
		private var image:BitmapData; //passed in image data
		private var newImage:BitmapData;//returned image with text		
		private var sampleSize:int;//sample size		
		private var grid:Array; //2d array of 1's and 0's created from image		
		private var hText:MovieClip;//lib clips used for drawing text into
		private var vText:MovieClip;		
		private var dict:WordCloud;//dictionary of text		
		private var textColors:Array; //for coloring the words
		
		//rect colors - use only when DEBUG = true
		private var debugColors = new Array(0x66000055,0x66000033,0x660000AA,0x66003399,0x66000022,0x66005500,0x66003300,0x6600AA00,0x66009933,0x66002200);
		private var debugIndex:int = 0;
		private var showGrid:Boolean;
		private var showRects:Boolean;
		private var showText:Boolean;
		
		
		public function RectFinder()
		{			
			hText = new mcHText();//lib
			vText = new mcVText();//lib	
			dict = new WordCloud();
		}
		
		
		public function createRects($image:BitmapData, $showGrid:Boolean, $showRects:Boolean, $showText:Boolean, $sampleSize:int, bgCol:int, txtCol:Array):BitmapData
		{			
			image = $image;
			showGrid = $showGrid;
			showRects = $showRects;
			showText = $showText;
			sampleSize = $sampleSize;
			textColors = txtCol;
			if (textColors.length == 0) {
				textColors = [0x000000];
			}
			//Base image for drawing into
			newImage = new BitmapData(image.width, image.height, false, bgCol);			
			createGridArray();	//creates 2D array from image bitmapData			
			findRects();			
			return newImage;
		}
		
		
		/**
		 * Creates the grid array variable
		 * grid is a 2D array containing 1's where the image is black
		 * and 0's elsewhere. Number of rows is the image height divided by
		 * the GRID_SQUARE setting. Number of columns in each row array is the image
		 * width divided by the GRID_SQUARE setting. 
		 */
		private function createGridArray():void
		{
			grid = new Array();
			var row:Array = [];			
			var curX:int = 0;
			var curY:int = 0;
			
			while (curX < image.width && curY < image.height) {
				
				//sample the four corners and center of the current grid square
				var p1:uint = image.getPixel(curX, curY);
				var p2:uint = image.getPixel(curX + sampleSize - 1, curY);
				var p3:uint = image.getPixel(curX, curY + sampleSize - 1);
				var p4:uint = image.getPixel(curX + sampleSize - 1, curY + sampleSize - 1);
				var p5:uint = image.getPixel(curX + 1, curY + 1);
				
				//if there's black anywhere mark the square
				if (p1 <= 0x111111 || p2 <= 0x111111 || p3 <= 0x111111 || p4 <= 0x111111 || p5 <= 0x111111) {
					if (showGrid) {
						markImage(curX, curY);				
					}
					row.push(1);
				}else {
					row.push(0);
				}
				
				curX += sampleSize;
				
				if (curX >= image.width) {
					curX = 0;
					curY += sampleSize;
					grid.push(row);
					row = [];
				}
			}
		}
		
		
		/**
		 * Used when showGrid = true
		 * marks a found grid square gray - so that the square can be seen
		 * @param	tx
		 * @param	ty
		 */
		private function markImage(tx:int, ty:int):void
		{
			for (var i:int = tx; i < tx + sampleSize; i++) {
				for (var j:int = ty; j < ty + sampleSize; j++) {
					newImage.setPixel(i, j, 0x888888);
				}
			}
			
		}
		
		
		private function findRects():void
		{
			var rows:int = grid.length;
			var cols:int = grid[0].length;
			
			var sw:int = 20;//start width,height
			var sh:int = 70;
			
			var ew:int = 3;//end width,height
			var eh:int =  2;
			
			var widthReduce:int = 1;
			var heightReduce:int = 4;			
			
			var swap:Boolean = true;
			
			while(sw >= ew){
				
				for (var r:int = 0; r < rows; r++) {//y
					for (var c:int = 0; c < cols; c++) {//x	
						
						if (grid[r][c] == 1) {
							
							var h1:int = getHLength([r,c]);
							var v1:int = getVLength([r, c]);
							
							if(swap){
								if (h1 >= sw && v1 >= sh) {
									if (isValidRect(r, c, sw, sh)) {
										drawText(r, c, sw, sh);
										removeRectFromArray(r, c, sw - 1, sh - 1);
										swap = !swap;
									}
								}
							}else {
								if (h1 >= sh && v1 >= sw) {
									if (isValidRect(r, c, sh, sw)) {
										drawText(r, c, sh, sw);										
										removeRectFromArray(r, c, sh - 1, sw - 1);
										swap = !swap;
									}
								}								
							}							
						}
					}
				}
				
				sw -= widthReduce;
				sh -= heightReduce;
			}
		}
		
		
		private function drawText(r:int, c:int, w:int, h:int):void
		{			
			var bmd:BitmapData = bmdFromText(w * sampleSize, h * sampleSize, dict.getWord(w, h));
			
			if(showRects){
				//colored rect for debugging
				var bmd2:BitmapData = new BitmapData(w * sampleSize, h * sampleSize, true, debugColors[debugIndex]);
				debugIndex++;
				if (debugIndex >= debugColors.length) {
					debugIndex = 0;
				}
				newImage.copyPixels(bmd2, new Rectangle(0, 0, w * sampleSize, h * sampleSize), new Point(c * sampleSize, r * sampleSize), null, null, true);									
			}
			if(showText){
				newImage.copyPixels(bmd, new Rectangle(0, 0, w * sampleSize, h * sampleSize), new Point(c * sampleSize, r * sampleSize), null, null, true);	
			}
		}
		
		
		/**
		 * Tests the array rect found in findRects - false is returned if any 0's are found		
		 */
		private function isValidRect(row:int,col:int,width:int,height:int):Boolean
		{	
			for (var r:int = row; r <= row + height; r++) {
				for (var c:int = col; c <= col + width; c++) {					
					if (grid[r][c] == 0) {
						return false;
					}
				}
			}
			return true;
		}
		
		
		/**
		 * Removes all 1's from the grid array within the specified rect
		 */
		private function removeRectFromArray(row:int,col:int,width:int,height:int):void
		{	
			for (var r:int = row; r <= row + height; r++) {
				for (var c:int = col; c <= col + width; c++) {					
					grid[r][c] = 0;
				}
			}
		}
	
		
		/**
		 * Returns the array length of the horizontal from x,y to x+n,y
		 * @param	point Array with row,col
		 * @return length in array items
		 */
		private function getHLength(point:Array):int
		{			
			var curCol:int = point[1];
			var len:int = 0;
			while (grid[point[0]][curCol] == 1) {
				curCol++;
				len++;
			}
			return len;
		}
		
		
		/**
		 * Returns the length of the vertical from x,y to x,y+n
		 * @param	point Array with row,col
		 * @return length in array items
		 */
		private function getVLength(point:Array):int
		{
			var curRow:int = point[0];
			var len:int = 0;			
			while (grid[curRow][point[1]] == 1) {
				curRow++;
				if (curRow >= grid.length) {
					break;
				}
				len++;
			}
			return len;
		}
		
		
		/**
		 * Returns a BitmapData object fit to the width and height - containing a word
		 * w and h are width and height of the destination rect		
		 */
		private function bmdFromText(w, h, mess):BitmapData
		{			
			var bmd:BitmapData = new BitmapData(w, h, true, 0x00000000);
			var m:Matrix = new Matrix();
			var a:BitmapData;
			var rect:Rectangle;
			var n:BitmapData;
			var myText:MovieClip;
			
			if (w >= h) {				
				hText.theText.autoSize = TextFieldAutoSize.LEFT;
				if(Math.random() > .3){
					hText.theText.text = mess;
				}else {
					hText.theText.htmlText = "<b>" + mess + "</b>";
				}
				myText = hText;
			}else {				
				vText.theText.autoSize = TextFieldAutoSize.RIGHT;
				if(Math.random() > .3){
					vText.theText.text = mess;
				}else {
					vText.theText.htmlText = "<b>" + mess + "</b>";
				}			
				myText = vText;
			}
			
			myText.theText.textColor = textColors[Math.floor(Math.random() * textColors.length)];
			
			//draw text into transparent bitmap
			a = new BitmapData(myText.width, myText.height, true, 0x00FFFFFF);
			a.draw(myText, null, null, null, null, true);
			
			//get a rect containing all nontransparent pixels - this is the actual text
			rect = a.getColorBoundsRect(0xff000000, 0x00000000, false);
			
			//new bitmap at rect size - actual text size
			n = new BitmapData(rect.width, rect.height, true, 0x00000000);
			n.copyPixels(a, rect, new Point(0, 0));
			
			//scale the text bitmap to fit the requested rect size
			m.scale(bmd.width / n.width, bmd.height / n.height);
			bmd.draw(n, m, null, null, null, true);			
			
			return bmd;
		}
		
	}	
}