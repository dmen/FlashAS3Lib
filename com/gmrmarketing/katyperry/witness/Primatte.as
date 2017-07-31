package com.gmrmarketing.katyperry.witness
{
	import flash.events.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.media.*;	
	import flash.filters.*;
	import flash.utils.*;
	
	public class Primatte extends EventDispatcher
	{
		private var myContainer:DisplayObjectContainer;
		
		private var camImage:BitmapData;
		
		private var maskImage:BitmapData;
		private var maskTemp:BitmapData;
		private var resultImage:BitmapData;
		private var resultDisplay:Bitmap;
		
		private var cam:Camera;
		private var theVideo:Video;
		private var camTimer:Timer;
		
		private var mBlur:BlurFilter;
		private var eroder:GlowFilter;
		
		private var zeroPoint:Point;
		private var rect:Rectangle;
		
		private const imWidth:int = 960;
		private const imHeight:int = 540;		
		
		private var hueMin:Number;
		private var hueMax:Number;
		
		private var satMin:Number;
		private var satMax:Number;
		
		private var lumMin:Number;
		private var lumMax:Number;
		
		private var useMask:Boolean = true;		
		
		
		public function Primatte()
		{
			cam = Camera.getCamera();
			cam.setMode(imWidth, imHeight, 24);	
			theVideo = new Video(imWidth, imHeight);
			
			mBlur = new BlurFilter(3, 3, 2);
			eroder = new GlowFilter(0x000000, 1, 3, 3, 3, 2, true, false);
			
			zeroPoint = new Point(0, 0);
			rect = new Rectangle(0, 0, imWidth, 540);
			
			//fill mask with solid white to start - createMask() fills in transparent pixels
			maskImage = new BitmapData(imWidth, 540, true, 0xffffffff);
			maskTemp = new BitmapData(imWidth, 540, true, 0x00000000);
			
			camImage = new BitmapData(imWidth, 540, false);
			
			resultImage = new BitmapData(imWidth, 540, true, 0x00000000);
			resultDisplay = new Bitmap(resultImage);
			
			camTimer = new Timer(1000 / 24); //24 fps cam update
			camTimer.addEventListener(TimerEvent.TIMER, camUpdate);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			theVideo.attachCamera(cam);
			camTimer.start();//call camUpdate()
			
			if (!myContainer.contains(resultDisplay)){
				myContainer.addChild(resultDisplay);
			}
		}
		
		
		public function toggleCam():Boolean
		{
			useMask = !useMask;
			return useMask;
		}
		
		
		private function camUpdate(e:TimerEvent):void
		{	
			camImage.draw(theVideo);
			
			maskImage.fillRect(rect, 0xffffffff);
			var u:Number;
			var v:Number;
			var x:int;
			var y:int;
			var r:Number;
			var g:Number;
			var b:Number;
			var col:uint;//rgb color from getPixel
			var hue:Number;//computed hue from the rgb value			
			var cMax:Number;//color max - whatever channel has the highest value
			var cMin:Number;//color min - channel with lowest value
			var cDelta:Number;//color delta - cMax - cMin
			var saturation:Number;			
			var luminance:Number;
		
			for(y = 0; y < imHeight; y++)
			{
				for(x = 0; x < imWidth; x++)
				{					
					col = camImage.getPixel(x, y);
					
					//r,g,b in range 0-1
					r = (( col >> 16 ) & 0xFF) * 0.003921568627451; //(1/255)
					g = ((col >> 8) & 0xFF) * 0.003921568627451;
					b = (col & 0xFF) * 0.003921568627451;					
					
					cMax = r > g ? r : g;
					cMax = cMax > b ? cMax : b;
					
					cMin = r < g ? r : g;
					cMin = cMin < b ? cMin : b;
					
					cDelta = cMax - cMin;
					
					//Hue Calc
					if (cMax == r){
						hue = 60 * (((g - b) / cDelta) % 6);
					}else if (cMax == g){
						hue = 60 * (((b - r) / cDelta) + 2);
					}else{
						hue = 60 * (((r - g) / cDelta) + 4);
					}
					
					//Saturation
					saturation = cMax == 0 ? 0 : cDelta / cMax;					
					
					//Luminance
					luminance = (.299 * r) + (.587 * g) + (.114 * b);					
					
					if (((hue >= hueMin) && (hue <= hueMax)) && ((saturation >= satMin) && (saturation <= satMax)) && ((luminance >= lumMin) && (luminance <= lumMax))){
					
						maskImage.setPixel32(x, y, 0x00000000);
					}										
				}
			}	
			
			//inner black glow
			maskImage.applyFilter(maskImage, rect, zeroPoint, eroder);		
			
			//threshold the inner glow image to get only the white pixels - which effectively erodes the edges
			maskTemp.fillRect(rect, 0x000000);
			maskTemp.threshold(maskImage, rect, zeroPoint, ">", 0x00EEEEEE, 0xFFFFFFFF, 0x00FFFFFF, false);
			
			//blur the edges a little
			maskTemp.applyFilter(maskTemp, rect, zeroPoint, mBlur);			
			
			resultImage.fillRect(rect, 0x000000);
			
			if (useMask){
				resultImage.copyPixels(camImage, rect, zeroPoint, maskTemp, zeroPoint, true);
			}else{
				resultImage.copyPixels(camImage, rect, zeroPoint, null, null, true);
			}			
		}
		
		
		public function get pic():BitmapData
		{
			return resultImage;
		}
		
		
		public function setKeyValue(newHue:Number, newThresh:Number, newSat:Number, newSatThresh:Number, newLum:Number, newLumThresh:Number):void
		{			
			hueMin = newHue - newThresh;
			hueMax = newHue + newThresh;
			
			satMin = newSat - newSatThresh;
			satMax = newSat + newSatThresh;			
			
			lumMin = newLum - newLumThresh;
			lumMax = newLum + newLumThresh;
			
			trace(hueMin, hueMax, satMin, satMax, lumMin, lumMax);
		}
		
		
		/**
		 * Returns hue,sat,lum as a 3 element array
		 * @param	pt
		 * @return Array hue,sat,lum
		 */
		public function hueValueAtPoint(pt:Point):Array
		{
			var colr:uint = camImage.getPixel(pt.x, pt.y);
			return hueValueFromRGB(colr);
		}		
		
		
		private function hueValueFromRGB(colr:uint):Array
		{
			var lr:Number = ((colr >> 16 ) & 0xFF) / 255;
			var lg:Number = ((colr >> 8) & 0xFF) / 255;
			var lb:Number = (colr & 0xFF) / 255;					
			
			var cmx:Number = Math.max(lr, lg, lb);
			var cmn:Number = Math.min(lr, lg, lb);
			var cdel:Number = cmx - cmn;
			
			var h:Number;
			if (cmx == lr){
				h = 60 * (((lg - lb) / cdel) % 6);
			}else if (cmx == lg){
				h = 60 * (((lb - lr) / cdel) + 2);
			}else{
				h = 60 * (((lr - lg) / cdel) + 4);
			}
			
			//Saturation
			var s:Number = cmx == 0 ? 0 : cdel / cmx;
			
			//luminance
			var l:Number = (.299 * lr) + (.587 * lg) + (.114 * lb);
					
			return [h,s,l];
		}
				
	}
	
}