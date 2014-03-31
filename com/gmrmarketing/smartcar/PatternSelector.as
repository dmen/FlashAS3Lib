/**
 * Instantiated from Main by menuClick()
 * 
 * Pattern Tool - placed inside of Main movies toolContainer
 */
package com.gmrmarketing.smartcar
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import com.gmrmarketing.smartcar.Kaleidoscope;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.display.BitmapData;
	import com.greensock.TweenMax;
	
	//library images
	import kal1;
	import kal2;
	import kal3;
	import kal4;
	import plaid1;
	import plaid2;
	import plaid3;
	import plaid4;
	
	
	public class PatternSelector extends MovieClip
	{
		private var kaleid:Kaleidoscope;
		private var thePattern:String;
		
		private var kaleidData:BitmapData; //the current kaleidoscope image - set in update()
		private var tileData:BitmapData;
		private var tilingMatrix:Matrix;
		private var tiling:int = 1; //changed by slider: 1 - 6
		
		private var xTiling:int;
		private var yTiling:int;
		
		//for showing the kaleidoscope image in the kHolder
		private var kImageData:BitmapData;
		private var kImage:Bitmap;
		private var kMatrix:Matrix; //for resizing the kaleid image to the rect in the tool
		
		private var isKaleid:Boolean;
		
		private var plaidImage:BitmapData;
		private var curBGColor:Number; //set in changeBG()
		
		
		
		public function PatternSelector()
		{			
			tileData = new BitmapData(1500, 1500, false, 0xff000000);
			
			plaidImage = new BitmapData(761, 714, false, 0xff000000);
			
			kImageData = new BitmapData(kHolder.width, kHolder.height);
			kImage = new Bitmap(kImageData);
			
			kMatrix = new Matrix();
			
			kHolder.addChild(kImage);
		}
		
		public function init(curPat:String, curTiling:int = 1, curBGC:Number = 0xffeeeeee, kPoint:Point = null, sliderPos:int = 35 ):void
		{		
			kaleid = new Kaleidoscope();
			kaleid.setContainer(this);
			kaleid.setControlArea(new Rectangle(kHolder.x, kHolder.y, kHolder.width, kHolder.height));			
			kaleid.addEventListener(Kaleidoscope.KALEID_CHANGED, updateKaleidTile, false, 0, true);
			kaleid.setPoint(kPoint);
			
			
			tiling = curTiling;
			tileSlider.x = sliderPos;
			//TweenMax.to(this["t" + tiling].bg, .5, { rotation:180 } );
			
			kMatrix.scale(kHolder.width / 400, kHolder.height / 346);
			
			addEventListener(Event.REMOVED_FROM_STAGE, cleanUp, false, 0, true);
			
			btnKal1.addEventListener(MouseEvent.CLICK, patternSelected, false, 0, true);
			btnKal2.addEventListener(MouseEvent.CLICK, patternSelected, false, 0, true);
			btnKal3.addEventListener(MouseEvent.CLICK, patternSelected, false, 0, true);
			btnKal4.addEventListener(MouseEvent.CLICK, patternSelected, false, 0, true);
			
			btnPlaid1.addEventListener(MouseEvent.CLICK, plaidSelected, false, 0, true);
			btnPlaid2.addEventListener(MouseEvent.CLICK, plaidSelected, false, 0, true);
			btnPlaid3.addEventListener(MouseEvent.CLICK, plaidSelected, false, 0, true);
			btnPlaid4.addEventListener(MouseEvent.CLICK, plaidSelected, false, 0, true);
			
			btnBgBlack.addEventListener(MouseEvent.CLICK, changeBG, false, 0, true);
			btnBgWhite.addEventListener(MouseEvent.CLICK, changeBG, false, 0, true);
			btnBgBlue.addEventListener(MouseEvent.CLICK, changeBG, false, 0, true);
			btnBgRed.addEventListener(MouseEvent.CLICK, changeBG, false, 0, true);
			
			if (curPat.indexOf("Plaid") != -1) {
				plaidSelected(null, curPat);
			}else{
				patternSelected(null, curPat);
				//trace("setting kaleid bgColor from patternSelector constructor", curBGC);
				kaleid.setBGColor(curBGC);
				curBGColor = curBGC;
				kaleid.start();
			}
			
			//slider
			tileSlider.addEventListener(MouseEvent.MOUSE_DOWN, beginSlide, false, 0, true);
			
			//btnBit.addEventListener(MouseEvent.CLICK, outputBitmap, false, 0, true);
		}
		
		
		private function beginSlide(e:MouseEvent):void
		{
			addEventListener(Event.ENTER_FRAME, updateSlider, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, endSlide, false, 0, true);
		}
		
		
		private function endSlide(e:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, updateSlider);
		}
		
		
		private function updateSlider(e:Event):void
		{
			tileSlider.x = mouseX;
			tiling = Math.round((tileSlider.x - tileTrack.x) / 40);
			if (tiling < 1) {
				tiling = 1;
			}
			updateKaleidTile();
			
			if (tileSlider.x <= tileTrack.x) {
				tileSlider.x = tileTrack.x;
			}
			
			if (tileSlider.x >= tileTrack.x + tileTrack.width) {
				tileSlider.x = tileTrack.x + tileTrack.width;
			}			
		}
		
		
		private function outputBitmap(e:MouseEvent):void
		{
			dispatchEvent(new Event("makeBit"));
		}
		
		
		/**
		 * Returns the current pattern name
		 * btnKal1 - btnKal4
		 * btnPlaid1 - btnPlaid4
		 * 
		 * @return String pattern name
		 */
		public function getCurrentPattern():String
		{
			return thePattern;
		}
		
		/**
		 * Returns the current tiling
		 * @return integer 1-4
		 */
		public function getTiling():int
		{
			return tiling;
		}
		
		public function getKPoint():Point
		{
			return kaleid.getTilePoint();
		}
		
		public function getBGColor():Number
		{
			return curBGColor;
		}
		
		public function getSliderPosition():int
		{
			return tileSlider.x;
		}
		
		/**
		 * returns the 1500x1500 tiled image
		 * @return BitmapData
		 */
		public function getTileImage():BitmapData
		{
			return tileData;
		}
		
		public function setKaleidoscopeImage(newImage:BitmapData):void
		{
			kaleid.setImage(newImage);
		}	
		
		private function changeBG(e:MouseEvent):void
		{
			var col:String = e.currentTarget.name.substr(5);
			switch(col) {
				case "Black":
					curBGColor = 0xff222222;					
					break;
				case "White":
					curBGColor = 0xffeeeeee;					
					break;
				case "Blue":
					curBGColor = 0xff5c8ec5;					
					break;
				case "Red":
					curBGColor = 0xff990000;					
					break;
			}
			//trace("patternSelector.changeBG - curBGColor stored", curBGColor);
			kaleid.setBGColor(curBGColor);
		}
		
		/**
		 * Called by clicking one of the kaleidoscope pattern buttons
		 * @param	e
		 * @param	pat
		 */
		private function patternSelected(e:MouseEvent = null, pat:String = "btnKal1"):void
		{
			isKaleid = true;
			if (!kaleid.isRunning()) {
				kaleid.start();
			}
			TweenMax.to(pressDrag, 1, { alpha:1 } );
			
			if (e == null) {
				thePattern = pat;
			}else{
				thePattern = e.currentTarget.name; //btnKal1 - btnKal4
			}
			switch(thePattern) {
				case "btnKal1":
					kaleid.setImage(new kal1());
					//kaleid.setBGColor(0xffeeeeee);
					break;
				case "btnKal2":
					kaleid.setImage(new kal2());
					//kaleid.setBGColor(0xffeeeeee);
					break;
				case "btnKal3":
					kaleid.setImage(new kal3());
					//kaleid.setBGColor(0xffeeeeee);
					break;
				case "btnKal4":
					kaleid.setImage(new kal4());
					//kaleid.setBGColor(0xffeeeeee);
					break;
			}			
			dispatchEvent(new Event("toolChange"));
		}	
		
		
		/**
		 * Called by clicking one of the plaid buttons
		 * @param	e
		 * @param	pat
		 */
		private function plaidSelected(e:MouseEvent = null, pat:String = "btnPlaid1"):void
		{
			isKaleid = false;
			TweenMax.to(pressDrag, 1, { alpha:0 } );
			
			if (e == null) {
				thePattern = pat;
			}else{
				thePattern = e.currentTarget.name; //btnPlaid1 - btnPlaid4
			}
			
			switch(thePattern) {
				case "btnPlaid1":
					plaidImage = new plaid1();
					break;
				case "btnPlaid2":
					plaidImage = new plaid2();
					break;
				case "btnPlaid3":
					plaidImage = new plaid3();
					break;
				case "btnPlaid4":
					plaidImage = new plaid4();
					break;
			}
			updateKaleidTile();
			dispatchEvent(new Event("toolChange"));
		}
		
		
		/**
		 * Called by listener on kaleidoscope
		 * updates tileData
		 * @param	e Kaleidoscope.KALEID_CHANGED
		 */
		private function updateKaleidTile(e:Event = null):void
		{
			//get 400x346 kaliedoscope image
			if(isKaleid){
				kaleidData = kaleid.getTile();
			}else {
				kaleidData = plaidImage;
			}
			kImageData.draw(kaleidData, kMatrix);
			
			xTiling = Math.round(400 / tiling);
			yTiling = Math.round(346 / tiling);
			
			tilingMatrix = new Matrix();
			tilingMatrix.scale(xTiling / kaleidData.width, yTiling / kaleidData.height);
			
			var theTile:BitmapData = new BitmapData(xTiling, yTiling);
			theTile.draw(kaleidData, tilingMatrix, null, null, null, true);
			
			for (var row:int = 0; row < 1500 / yTiling; row++) {
				for (var col:int = 0; col < 1500 / xTiling; col++) {
					tileData.copyPixels(theTile, theTile.rect, new Point(xTiling * col, yTiling * row));
				}
			}
			//forces update on car
			dispatchEvent(new Event("toolChange"));
		}
		
		
		
		/**
		 * Called on REMOVED FROM STAGE event
		 * @param	e
		 */
		private function cleanUp(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
			
			btnKal1.removeEventListener(MouseEvent.CLICK, patternSelected);
			btnKal2.removeEventListener(MouseEvent.CLICK, patternSelected);
			btnKal3.removeEventListener(MouseEvent.CLICK, patternSelected);
			btnKal4.removeEventListener(MouseEvent.CLICK, patternSelected);
			
			btnPlaid1.removeEventListener(MouseEvent.CLICK, plaidSelected);
			btnPlaid2.removeEventListener(MouseEvent.CLICK, plaidSelected);
			btnPlaid3.removeEventListener(MouseEvent.CLICK, plaidSelected);
			btnPlaid4.removeEventListener(MouseEvent.CLICK, plaidSelected);
			
			//btnBit.removeEventListener(MouseEvent.CLICK, outputBitmap);
			
			kaleid.stop(); //removes the enterFrame listener
		}
	}
	
}