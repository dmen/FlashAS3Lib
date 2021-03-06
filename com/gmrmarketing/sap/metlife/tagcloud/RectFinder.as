/**
 * Last update 10/22/14
 */
package com.gmrmarketing.sap.metlife.tagcloud
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.*;
	
	public class RectFinder extends EventDispatcher
	{			
		public static const FINISHED:String = "finished";//dispatched when no more tags can be added or time runs out
		
		private var image:BitmapData; //passed in image to create with words
		private var container:DisplayObjectContainer;//the container to fill with word sprites
		private var sampleSize:int;//sample size used for turning bitmap into an array of 1's and 0's
		private var grid:Array;//2d array of 1's and 0's created from image		
		private var hText:MovieClip;//lib clips used for drawing text into
		private var vText:MovieClip;		
		private var tags:Array; //array of tags	
		private var tagIndex:int; //current index in tags array
		private var textColors:Array; //for coloring the words
		private var startScale:Number = 4;
		private var scaleDec:Number; //startScale / number of tags		
		private var tagAddedCount:Number; //incremented in spiral
		private var tagCount:Number; //current tag count
		private var zeroCount:int;//number of times no tags areas were found to draw in - incremented in addTag()
		private var totalTags:int; //number of tags		
		private var shadow:DropShadowFilter;//set in create if used
		private var maxTime:int;//set in create -used by maxTimer to limit the time cloud will run
		private var maxTimer:Timer;//used to limit the time the cloud will run
		private var speed:int;//limits the return from spiral so that the tag sent in will be reused for successive iterations of the spiral
		private var doHoriz:Boolean;//set in create - if true horizontal tags will be drawn
		private var doVert:Boolean;//set in create - if true vertical tags will be drawn
		
		
		/**
		 * Constructor
		 * @param	ss The Sample Size - this must match the sample size used when creating a new
		 * TagCloud object
		 */
		public function RectFinder(ss:int)
		{	
			sampleSize = ss;			
			hText = new mcHText();//lib
			vText = new mcVText();//lib				
		}		
		
		
		/**
		 * Will remove all tags from the container defined in create()
		 * called from create() - called automatically from create()
		 */
		public function clear():void
		{
			while (container.numChildren) {
				container.removeChildAt(0);
			}
		}
		
		
		/**
		 * Creates the tag cloud image
		 * @param	$container DisplayObjectContainer in which to place the tag Bitmap objects
		 * @param	$image	Black and white image used to create the tag cloud image
		 * @param	$tags Array of tag objects retrieved from TagCloud.getTags()
		 * @param	$maxTime The max time, in milliseconds, tag cloud creation will run
		 * @param	$speed Speed multiplier - the higher the number the more the current tag will be reused, instead of getting a new tag
		 */
		public function create($container:DisplayObjectContainer, $image:BitmapData, $tags:Array, $doHoriz:Boolean = true, $doVert:Boolean = true, $maxTime:int = 120000, $speed:int = 0, $shadow:DropShadowFilter = null):void
		{			
			container = $container;
			image = $image;
			tags = $tags;	
			doHoriz = $doHoriz;
			doVert = $doVert;
			maxTime = $maxTime;
			speed = $speed;
			shadow = $shadow;
			
			clear();//removes anything in the container
			
			createGridArray();
			
			tagAddedCount = 0;
			tagCount = 0;
			zeroCount = 0;
			totalTags = tags.length;
			tagIndex = 0;
			
			container.addEventListener(Event.ENTER_FRAME, addTag);
			
			maxTimer = new Timer(maxTime, 1);
			maxTimer.addEventListener(TimerEvent.TIMER, maxTimeReached, false, 0, true);
			maxTimer.start();
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
			grid = [];
			var row:Array = [];		
			var curX:int = 0;
			var curY:int = 0;
			
			while (curX < image.width && curY < image.height) {
				
				//sample the four corners of the current grid square
				var p1:uint = image.getPixel(curX, curY);
				var p2:uint = image.getPixel(curX + sampleSize - 1, curY);
				var p3:uint = image.getPixel(curX, curY + sampleSize - 1);
				var p4:uint = image.getPixel(curX + sampleSize - 1, curY + sampleSize - 1);
				
				//if there's black anywhere mark the square
				if (p1 <= 0x111111 || p2 <= 0x111111 || p3 <= 0x111111 || p4 <= 0x111111) {					
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
		 * Called from addTag once zeroCount has reached 2
		 */
		private function stop():void
		{
			maxTimer.reset();
			maxTimer.removeEventListener(TimerEvent.TIMER, maxTimeReached);
			container.removeEventListener(Event.ENTER_FRAME, addTag);
			dispatchEvent(new Event(FINISHED));
		}
		
		
		/**
		 * Callback for maxTimer reaching its timeout
		 * @param	e
		 */
		private function maxTimeReached(e:TimerEvent):void
		{		
			stop();
		}
		
		
		/**
		 * called by enterFrame listener on container
		 * listener is added in create()
		 * @param	e ENTER_FRAME event
		 */
		private function addTag(e:Event):void
		{
			var t:Object = tags[tagIndex];
			tagIndex++;
			if (tagIndex >= tags.length) {
				tagIndex = 0;
			}
			spiral(t);
			tagCount++;
			if (tagCount >= totalTags) {
				tagCount = 0;
				var tagPercent:int = Math.floor((tagAddedCount / totalTags) * 100);				
				tagAddedCount = 0;
				if (tagPercent == 0) {
					zeroCount++;
					if (zeroCount == 2) {
						stop();
					}
				}
			}
		}
		
		
		/**
		 * Tries to insert the tag into the image
		 * Starts at image center and hunts in an outward spiral for
		 * unfilled spaces - When a rect is found the algorithm tries to move
		 * it up to 2 units up or left to tighten it against any other rects
		 * 
		 * @param	tag Tag object containing name,value,fontSize,imageh,imagev,widthh,heighth,widthv,heightv properties
		 */
		private function spiral(tag:Object):void
		{
			var w:int = grid[0].length;
			var h:int = grid.length;			
			var cx:int = Math.floor(w * .5);
			var cy:int = Math.floor(h * .5);
			var x:int = 0;
			var y:int = 0;
			var dx:int = 0;
			var dy:int = -1;
			var i:int;
			var j:int;
			
			var curRow:int;
			var curCol:int;
			var len:int;
			
			var h1:int;
			var v1:int;
			var tightenCount:int;
			var temp:int;
			
			var iterations:int = Math.max(w * w, h * h);
			var n:int = 0;
			var spiralCount:int = 0;
			var r:Boolean;
			
			
			while (n < iterations) {
				
				if ((x > -w/2 && x <= w/2) && (y > -h/2 && y <= h/2)){			
					
					i = cx + x;
					j = cy - y;
					
					if (grid[j][i] == 1) {							
						
						//ray cast - horizontal - getHLength is inlined here						
						curCol = i;
						len = 0;
						while (grid[j][curCol] == 1) {
							curCol++;
							if (curCol >= w) {
								break;
							}
							len++;
						}
						h1 = len;
						
						//ray cast - vertical - getVLength is inlined here						
						curRow = j;
						len = 0;
						while (grid[curRow][i] == 1) {
							curRow++;
							if (curRow >= h) {
								break;
							}
							len++;
						}
						v1 = len;
						
						tightenCount = 0;
						
						if(doHoriz && doVert){
							if (Math.random() < .5) {
								//Do a horizontal
								r = doHorizontal(h1, v1, j, i, tag);
								if (r) {
									spiralCount++;
									if(spiralCount >= speed){
										return;			
									}
								}
							}else {
								//do a vertical
								r = doVertical(h1, v1, j, i, tag);
								if (r) {
									spiralCount++;
									if(spiralCount >= speed){
										return;			
									}
								}			
							}
						}else if(doHoriz){
							//Do a horizontal
							r = doHorizontal(h1, v1, j, i, tag);
							if (r) {
								spiralCount++;
								if(spiralCount >= speed){
									return;			
								}
							}
						}else {
							//do a vertical
							r = doVertical(h1, v1, j, i, tag);
							if (r) {
								spiralCount++;
								if(spiralCount >= speed){
									return;			
								}
							}	
						}
					}					
				}
				
				if(x == y || (x < 0 && x == -y) || (x > 0 && x == 1-y)){
					temp = dx;
					dx = -dy;
					dy = temp;
				}
				x += dx;
				y += dy;
				n++;
			}//while
		}
	
		/**
		 * Adds a horizontal tag. Returns true if the tag was added, or false if not
		 * @param	h1
		 * @param	v1
		 * @param	j
		 * @param	i
		 * @param	tag
		 * @return
		 */
		private function doHorizontal(h1:int, v1:int, j:int, i:int, tag:Object):Boolean
		{			
			if (h1 >= tag.widthh && v1 >= tag.heighth) {
								
				if (isValidRect(j, i, tag.widthh, tag.heighth)) {
					
					//try and move rect up to tighten it against any others in the area
					//limit the tightening to 2 units
					
					var tightenCount:int = 0;
					while (isValidRect(j, i, tag.widthh, tag.heighth)) {
						j--;
						tightenCount++;
						if (tightenCount > 2) {
							break;
						}
					}
					j++;
					
					var b:BitmapData = new BitmapData(tag.widthh * sampleSize, tag.heighth * sampleSize, true, 0x00000000);
					b.copyPixels(tag.imageh, new Rectangle(0, 0, tag.widthh * sampleSize, tag.heighth * sampleSize), new Point(0, 0), null, null, true);
					var c:Bitmap = new Bitmap(b);
					container.addChildAt(c, 0);//as they get smaller add behind the bigger ones
					c.x = i * sampleSize;
					c.y = j * sampleSize;
					if(shadow){
						c.filters = [shadow];
					}
					
					removeRectFromArray(j, i, tag.widthh - 1, tag.heighth - 1);
					tagAddedCount++;
					return true;
				}								
			}
			return false;
		}
		
		
		/**
		 * Adds a vertical tag. Returns true if the tag was added, or false if not.
		 * @param	h1
		 * @param	v1
		 * @param	j
		 * @param	i
		 * @param	tag
		 * @return
		 */
		private function doVertical(h1:int, v1:int, j:int, i:int, tag:Object):Boolean
		{
			if (h1 >= tag.widthv && v1 >= tag.heightv) {
				if (isValidRect(j, i, tag.widthv, tag.heightv)) {
					
					//try and move rect left to tighten it against any others in the area
					//limit the tightening to 2 units
					var tightenCount:int = 0;
					while (isValidRect(j, i, tag.widthv, tag.heightv)) {
						i--;
						tightenCount++;
						if (tightenCount > 2) {
							break;
						}
					}
					i++;									
					
					var b:BitmapData = new BitmapData(tag.widthv * sampleSize, tag.heightv * sampleSize, true, 0x00000000);
					b.copyPixels(tag.imagev, new Rectangle(0, 0, tag.widthv * sampleSize, tag.heightv * sampleSize), new Point(0, 0), null, null, true);
					var c:Bitmap = new Bitmap(b);
					container.addChildAt(c,0);
					c.x = i * sampleSize;
					c.y = j * sampleSize;
					if(shadow){
						c.filters = [shadow];
					}
					
					removeRectFromArray(j, i, tag.widthv - 1, tag.heightv - 1);
					tagAddedCount++;									
					return true;
				}
			}
			return false;
		}
	
		
		/**
		 * Tests the array rect found in findRects - false is returned if any 0's
		 * are found in the search rectangle
		 */
		private function isValidRect(row:int, col:int, width:int, height:int):Boolean
		{	
			if (row < 0 || col < 0) {
				return false;
			}
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
		 * Sets all grid units within the specified rectangle to 0
		 * This removes the rect from the array so that further hunting will ignore this area
		 */
		private function removeRectFromArray(row:int, col:int, width:int, height:int):void
		{	
			for (var r:int = row; r <= row + height; r++) {
				for (var c:int = col; c <= col + width; c++) {					
					grid[r][c] = 0;
				}
			}
		}		
		
	}	
}