package com.gmrmarketing.katyperry.witness
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	
	public class PerlinNoise
	{
		private var gradMat:Matrix;
		private var display:Bitmap;
		private var masker:BitmapData;

		private var _perlinBitmapData : BitmapData;
		
		private var _n:Number;
		private var myContainer:DisplayObjectContainer;
		private var seed:Number;

		
		public function PerlinNoise() 
		{			
			gradMat = new Matrix();
			gradMat.scale(3, 3);	
			
			_perlinBitmapData = new BitmapData(640, 360, false);
			
			masker = new BitmapData(1920, 1080, true, 0x00000000);
			
			display = new Bitmap(masker);
			display.blendMode = BlendMode.ADD;
		}
		
		
		public function show(container:DisplayObjectContainer):void
		{
			_n = 0;
			seed = 5000 * Math.random();
			
			myContainer = container;
			myContainer.addChildAt(display, 1);			
			myContainer.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(display)){
				myContainer.removeChild(display);
			}
			myContainer.removeEventListener(Event.ENTER_FRAME, update);
		}
		

		private function update(e:Event):void
		{ 
			_n += 2;
			_perlinBitmapData.perlinNoise(500, 500, 2, seed, false, false, BitmapDataChannel.ALPHA, true, [new Point(-_n, -_n), new Point(-_n, _n*.5)]);			
			masker.draw(_perlinBitmapData, gradMat, null, null, null, true);//640x360 mask to 1920x1080
		}
	}
}