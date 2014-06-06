package com.gmrmarketing.testing
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;	
	import flash.utils.getTimer;
	import flash.text.TextFieldAutoSize;	
	
	public class RectFinder2 extends EventDispatcher
	{
		private var image:BitmapData; //passed in image data
		private var newImage:BitmapData;//returned image with text		
		private const GRID_SQUARE:int = 4;//sample size		
		private var hText:MovieClip;//lib clips used for drawing text into
		private var vText:MovieClip;		
		private var dict:WordCloud;//dictionary of text		
		private var textColors:Array; //for coloring the words		
		private const BGCOLOR:int = 0xFFFFFF; //background color
		
		private var debugColors = new Array(0x66000055,0x66000033,0x660000AA,0x66003399,0x66000022,0x66005500,0x66003300,0x6600AA00,0x66009933,0x66002200);
		private var debugIndex:int = 0;
		
		public function RectFinder2()
		{			
			hText = new mcHText();//lib
			vText = new mcVText();//lib			
			textColors = new Array(0xff5959, 0xff9088, 0xd55151, 0xb24444, 0x8d3636, 0x2f86e0, 0x187fe0, 0x639ee0, 0x6188c8, 0x415685);					
			dict = new WordCloud();
		}
		
		
		public function createRects(bmd:BitmapData):BitmapData
		{			
			image = new bit();// bmd;//original data			
			newImage = new BitmapData(image.width, image.height, false, BGCOLOR);//blank for drawing into
			findRects();			
			return newImage;
		}		
		
		
		private function findRects():void
		{
			var rows:int = image.height;
			var cols:int = image.width;		
			trace(rows, cols);
			
			var sw:int = 120;//start width,height
			var sh:int = 250;
			
			var ew:int = 12;//end width,height
			var eh:int = 20;
			
			var widthReduce:int = 10;
			var heightReduce:int = 20;			
			
			var swap:Boolean = true;
			
			while (sw >= ew) {		
				
				trace("finding:", sw, "x", sh);
				
				for (var r:int = 1; r < rows - 1; r++) {//y
					for (var c:int = 1; c < cols - 1; c++) {//x	
						
						if (image.getPixel(r, c) != 0xffffff) {
							
							var h1:int = getHLength(new Point(r, c));
							var v1:int = getVLength(new Point(r, c));
							trace("rect len", h1, v1);
							
							if(swap){
								if (h1 >= sw && v1 >= sh) {
									//if (isValidRect(r, c, sw, sh)) {
										trace("valid h");
										drawText(r, c, sw, sh);
									//}
								}
							}else {
								if (h1 >= sh && v1 >= sw) {
									//if (isValidRect(r, c, sh, sw)) {
										trace("valid v");
										drawText(r, c, sh, sw);
									//}
								}
								
							}
							swap = !swap;
						}
					}
				}
				
				sw -= widthReduce;
				sh -= heightReduce;
			}
		}
		
		
		private function drawText(r:int, c:int, w:int, h:int):void
		{			
			var bmd:BitmapData = bmdFromText(w, h, dict.getWord(w, h));			
			
			//colored rect for debugging
			var bmd2:BitmapData = new BitmapData(w, h, true, debugColors[debugIndex]);
			debugIndex++;
			if (debugIndex >= debugColors.length) {
				debugIndex = 0;
			}
			newImage.copyPixels(bmd2, new Rectangle(0, 0, w, h), new Point(c, r), null, null, true);
			newImage.copyPixels(bmd, new Rectangle(0, 0, w, h), new Point(c, r), null, null, true);	
		}
		
		
		/**
		 * Tests the array rect found in findRects - false is returned if any 0's are found		
		 */
		private function isValidRect(row:int,col:int,width:int,height:int):Boolean
		{	
			for (var r:int = row; r <= row + height; r++) {
				for (var c:int = col; c <= col + width; c++) {					
					if (image.getPixel(c,r) == BGCOLOR) {
						return false;
					}
				}
			}
			return true;
		}
		
		
		/**
		 * Returns the array length of the horizontal from x,y to x+n,y		
		 */
		private function getHLength(point:Point):int
		{			
			var curX:int = point.x;
			var len:int = 0;
			while (image.getPixel(curX, point.y) != BGCOLOR) {
				curX++;
				len++;
			}
			return len;
		}
		
		
		/**
		 * Returns the length of the vertical from x,y to x,y+n
		*/
		private function getVLength(point:Point):int
		{
			var curY:int = point.y;
			var len:int = 0;			
			while (image.getPixel(point.x, curY) != BGCOLOR) {
				curY++;
				if (curY >= image.height) {
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