package com.gmrmarketing.sap.levisstadium.tagcloud
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import flash.text.TextFieldAutoSize;	
	
	public class RectFinder extends EventDispatcher
	{
		public static const DICT_READY:String = "dictionaryReady"; 
		
		private var image:BitmapData; //passed in image data
		private var newImage:BitmapData;//returned image with text		
		private var sampleSize:int = 5;//sample size		
		private var grid:Array; //2d array of 1's and 0's created from image		
		private var hText:MovieClip;//lib clips used for drawing text into
		private var vText:MovieClip;		
		private var dict:TagCloud;//tags from the service		
		private var textColors:Array; //for coloring the words
		private var startScale:Number = 4;
		private var scaleDec:Number; //startScale / number of tags
		
		
		public function RectFinder()
		{			
			hText = new mcHText();//lib
			vText = new mcVText();//lib	
			
			dict = new TagCloud(sampleSize);
			dict.addEventListener(TagCloud.TAGS_READY, tagsReady, false, 0, true);
			dict.refreshTags();
		}
				
		
		private function tagsReady(e:Event):void
		{
			dispatchEvent(new Event(DICT_READY));
		}
		
		
		public function createRects($image:BitmapData, bgCol:int):BitmapData
		{			
			image = $image;			
			
			//Base image for drawing into
			newImage = new BitmapData(image.width, image.height, false, bgCol);			
			createGridArray();	//creates 2D array from image bitmapData			
				
			for (var i:int = 0; i < dict.getNumTags()*20; i++) {
				var t:Object = dict.getNextTag();
				//addTagToImage(t);
				ad2(t);
			}			
			return newImage;
		}
		
		
		/**
		 * Creates the grid array variable
		 * grid is a 2D array containing 1's where the image is black
		 * and 0's elsewhere. Number of rows is the image height divided by
		 * the GRID_SQUARE setting. Number of columns in each row array is the image
		 * width divided by the GRID_SQUARE setting. 
		 * 
		 * at sampleSize = 5 this takes ~65ms
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
				var p5:uint = image.getPixel(curX + Math.floor(sampleSize * .5), curY + Math.floor(sampleSize * .5));//center
				
				//if there's black anywhere mark the square
				if (p1 <= 0x111111 || p2 <= 0x111111 || p3 <= 0x111111 || p4 <= 0x111111 || p5 <= 0x111111) {					
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
		 * 
		 * @param	tag Object from tagCloud.getNextTag() - each tag contains these properties:
		 *          name,value,fontSize,imageh,imagev,widthh,heighth,widthv,heightv
		 */
		private function addTagToImage(tag:Object ):void
		{
			var rows:int = grid.length;
			var cols:int = grid[0].length;	
			
			for (var r:int = 0; r < rows; r++) {//y
				for (var c:int = 0; c < cols; c++) {//x	
					if (grid[r][c] == 1) {
						
						//ray cast
						var h1:int = getHLength([r, c]);//array length - multiply by sampleSize to get pixels
						var v1:int = getVLength([r, c]);
						
						if(Math.random() < .5){
							if (h1 >= tag.widthh && v1 >= tag.heighth) {
								if (isValidRect(r, c, tag.widthh, tag.heighth)) {
									drawText(r, c, tag, "h");										
									removeRectFromArray(r, c, tag.widthh - 1, tag.heighth - 1);									
									return;
								}
							}
						}else {
							if (h1 >= tag.widthv && v1 >= tag.heightv) {
								if (isValidRect(r, c, tag.widthv, tag.heightv)) {
									drawText(r, c, tag, "v");
									removeRectFromArray(r, c, tag.widthv - 1, tag.heightv - 1);									
									return;
								}
							}					
						}	
					}
				}
			}						
		}
		
		
		private function ad2(tag:Object):void
		{
			var rows:int = grid.length;
			var cols:int = grid[0].length;	
			
			// (di, dj) is a vector - direction in which we move right now
			var di:int = 1;
			var dj:int = 0;

			// length of current segment
			var segment_length:int = 1;

			// current position (i, j) and how much of current segment we passed
			var i:int = Math.floor(cols * .5);//x pos
			var j:int = Math.floor(rows * .5); //y pos
			var segment_passed:int = 0;

			for (var n:int = 0; n < 40000; n++){	
				// make a step, add 'direction' vector (di, dj) to current position (i, j)
				i += di;
				j += dj;
				if (grid[j][i] == 1) {
						
					//ray cast
					var h1:int = getHLength([j, i]);//array length - multiply by sampleSize to get pixels
					var v1:int = getVLength([j, i]);
					
					if(Math.random() < .5){
						if (h1 >= tag.widthh && v1 >= tag.heighth) {
							if (isValidRect(j, i, tag.widthh, tag.heighth)) {
								drawText(j, i, tag, "h");										
								removeRectFromArray(j, i, tag.widthh - 1, tag.heighth - 1);									
								return;
							}
						}
					}else {
						if (h1 >= tag.widthv && v1 >= tag.heightv) {
							if (isValidRect(j, i, tag.widthv, tag.heightv)) {
								drawText(j, i, tag, "v");
								removeRectFromArray(j, i, tag.widthv - 1, tag.heightv - 1);									
								return;
							}
						}					
					}	
				}
				
				
				segment_passed++;	

				if (segment_passed == segment_length) {
					// done with current segment
					segment_passed = 0;

					// 'rotate' directions
					var buffer:int = di;
					di = -dj;
					dj = buffer;

					// increase segment length if necessary
					if (dj == 0) {
						segment_length++;
					}
				}	
			}
		}
		
	
		/**
		 * Draws the image in b into the newImage bitmapData object
		 * units are in grid units
		 * 
		 * @param	r row
		 * @param	c column
		 * @param	b Object - contains width,height,image properties - width,height are grid units - returned from measure()
		 */
		private function drawText(r:int, c:int, b:Object, hv:String):void
		{		
			var bmd2:BitmapData;
			
			if(hv == "h"){
				newImage.copyPixels(b.imageh, new Rectangle(0, 0, b.widthh * sampleSize, b.heighth * sampleSize), new Point(c * sampleSize, r * sampleSize), null, null, true);
				//bmd2 = new BitmapData( b.widthh * sampleSize, b.heighth * sampleSize, true, 0x66ff0000 * Math.random());
			}else {
				newImage.copyPixels(b.imagev, new Rectangle(0, 0, b.widthv * sampleSize, b.heightv * sampleSize), new Point(c * sampleSize, r * sampleSize), null, null, true);
				//bmd2 = new BitmapData( b.widthv * sampleSize, b.heightv * sampleSize, true, 0x66ff0000*Math.random());
			}
			
			//newImage.copyPixels(bmd2, new Rectangle(0, 0, bmd2.width, bmd2.height), new Point(c * sampleSize, r * sampleSize), null, null, true);
		}
		
		
		/**
		 * Tests the array rect found in findRects - false is returned if any 0's
		 * are found in the search rectangle
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
		
	}	
}