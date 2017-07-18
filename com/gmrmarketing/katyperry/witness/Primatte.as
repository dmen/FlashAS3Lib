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
		
		//used in createMask()
		private var r:Number;
		private var g:Number;
		private var b:Number;
		private var col:uint;//rgb color from getPixel
		private var hue:Number;//computed hue from the rgb value		
		private var cMax:Number;//color max - whatever channel has the highest value
		private var cMin:Number;//color min - channel with lowest value
		private var cDelta:Number;//color delta - cMax - cMin
		
		private var imWidth:int = 960;
		private var imHeight:int = 540;
		private var u:Number;
		private var v:Number;
		private var x:int;
		private var y:int;
		
		private var delt:int;
		
		private var keyColor:Number = 209;//blue
		private var threshold:Number = 30;
		private var useMask:Boolean = true;
		
		private var saturation:Number;
		private var luminance:Number;
		
		
		
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
			
			for(y = 0; y < imHeight; y++)
			{
				for(x = 0; x < imWidth; x++)
				{					
					col = camImage.getPixel(x, y);
					
					//r,g,b in range 0-1
					r = (( col >> 16 ) & 0xFF) * 0.003921568627451; //(1/255)
					g = ((col >> 8) & 0xFF) * 0.003921568627451;
					b = (col & 0xFF) * 0.003921568627451;			
					
					//optimized math.max(r,g,b)
					cMax = r > g ? r : g;
					cMax = cMax > b ? cMax : b;
					
					//optimized math.min(r,g,b)
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
					
					if (((keyColor - threshold) < hue) && ((keyColor + threshold) > hue) && (saturation > .9) && (luminance > .1)){
						maskImage.setPixel32(x, y, 0x00000000);
					}										
				}
			}	
			
			//2 pixel inner black glow
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
		
		
		public function setKeyValue(newKey:Number, newThreshold:Number):void
		{			
			keyColor = newKey;
			threshold = newThreshold;
		}
		
		
		/**
		 * Returns the hue and saturation as a two element array
		 * @param	pt
		 * @return Array hue and saturation. Saturation is 0-1
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