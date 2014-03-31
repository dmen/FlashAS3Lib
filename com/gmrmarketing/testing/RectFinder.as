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
		private var image:BitmapData;		
		private var newImage:BitmapData;
		
		private const GRID_SQUARE:int = 5;//sample size		
		
		private var curX:int;
		private var curY:int;
		
		private var rect_max:int = 200;
		
		private var grid:Array;
		
		private var hText:MovieClip;
		private var vText:MovieClip;
		
		private var dict:WordCloud;
		
		
		public function RectFinder()
		{			
			hText = new mcHText();//lib
			vText = new mcVText();//lib
			
			dict = new WordCloud();
		}
		
		
		public function createRects(bmd:BitmapData):BitmapData
		{			
			image = bmd;
			
			//solid white image for drawing into
			newImage = new BitmapData(image.width, image.height, false, 0xffffff);
			
			createGridArray();	//creates array from image bitmapData
			
			findRect(10, 48);//width, height
			findRect(20,8);
			findRect(10, 5);
			findRect(5, 10);
			findRect(2, 4);
			findRect(2,2);
			
			return newImage;
		}
		
		
		private function findRect(wantedWidth:int, wantedHeight:int):void
		{
			var rows:int = grid.length;
			var cols:int = grid[0].length;
			var bmd:BitmapData;
			
			for (var r:int = 0; r < rows; r++) {
				for (var c:int = 0; c < cols; c++) {					
					
					if (grid[r][c] == 1) {
						
						var h1:int = getHLength([r,c]);
						var v1:int = getVLength([r,c]);
						
						if (h1 >= wantedWidth && v1 >= wantedHeight) {
							var h2:int = getHLength([r + wantedHeight, c]);
							var v2:int = getVLength([r, c + wantedWidth]);
							
							if (h2 >= wantedWidth && v2 >= wantedHeight) {
								
								//only remove center 1's since edges will be shared
								removeRectFromArray(r + 1, c + 1, wantedWidth - 2, wantedHeight - 2);
								
								bmd = bmdFromText(wantedWidth * GRID_SQUARE, wantedHeight * GRID_SQUARE, dict.getWord(wantedWidth, wantedHeight));
								newImage.copyPixels(bmd, new Rectangle(0,0, wantedWidth * GRID_SQUARE, wantedHeight * GRID_SQUARE), new Point(c * GRID_SQUARE, r * GRID_SQUARE), null, null, true);								
							}					
						}
					}
				}
			}
		}
		
		
		/**
		 * Removes all 1's from the grid array within the specified rect
		 */
		private function removeRectFromArray(row:int,col:int,width:int,height:int)
		{	
			for (var r:int = row; r <= row + height; r++) {
				for (var c:int = col; c <= col + width; c++) {					
					grid[r][c] = 0;
				}
			}
		}
		
		
		/**
		 * Creates the 2D grid array containing 1's where the image is black
		 * and 0's elsewhere. Number of rows is the image height divided by
		 * the GRID_SQUARE setting. Number of columns in each row array is the image
		 * width divided by the GRID_SQUARE setting. 
		 */
		private function createGridArray():void
		{
			grid = new Array();
			var row:Array = [];
			
			curX = 0;
			curY = 0;
			
			while (curX < image.width && curY < image.height) {
				
				//sample the four corners of the current grid square
				var p1:uint = image.getPixel(curX, curY);
				var p2:uint = image.getPixel(curX + GRID_SQUARE - 1, curY);
				var p3:uint = image.getPixel(curX, curY + GRID_SQUARE - 1);
				var p4:uint = image.getPixel(curX + GRID_SQUARE - 1, curY + GRID_SQUARE - 1);
				
				//if there's black in any corner mark the square
				if (p1 <= 0x111111 || p2 <= 0x111111 || p3 <= 0x111111 || p4 <= 0x111111) {
					//display.bitmapData.setPixel(curX, curY, 0xff0000);					
					row.push(1);
				}else {
					//display.bitmapData.setPixel(curX, curY, 0x999999);
					row.push(0);
				}
				
				curX += GRID_SQUARE;
				
				if (curX >= image.width) {
					curX = 0;
					curY += GRID_SQUARE;
					grid.push(row);
					row = [];
				}
			}
		}
		
		
		/**
		 * returns an array containing the 2d index of the first 1 in the grid
		 * @return row, column array (aka y,x)
		 */
		private function getPoint():Array
		{			
			var rows:int = grid.length;
			var cols:int = grid[0].length;			
			
			for (var r:int = 0; r < rows; r++) {
				for (var c:int = 0; c < cols; c++) {					
					if (grid[r][c] == 1) {						
						return [r, c];	
					}
				}
			}
			return [-1, -1];
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
				len += 1;
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
				len += 1;
			}
			return len;
		}
		
		
		
		private function bmdFromText(w, h, mess):BitmapData
		{			
			var bmd:BitmapData = new BitmapData(w, h, true, 0x00000000);
			var m:Matrix = new Matrix();
			
			if(w >= h){
				hText.theText.autoSize = TextFieldAutoSize.LEFT;
				hText.theText.text = mess;
				m.scale(bmd.width / (hText.theText.width + 15), bmd.height / hText.theText.textHeight);
				bmd.draw(hText, m);
			}else {
				vText.theText.autoSize = TextFieldAutoSize.RIGHT;
				vText.theText.text = mess;
				m.scale(bmd.width / vText.theText.width, bmd.height / vText.theText.height);
				bmd.draw(vText, m);
			}			
			
			return bmd;
		}
		
	}
	
}