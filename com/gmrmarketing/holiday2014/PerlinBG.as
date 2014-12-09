package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import flash.filters.BevelFilter;
	import flash.geom.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	public class PerlinBG extends Bitmap
	{
		private var noiseBMD:BitmapData;
		private var screenBMD:BitmapData;		
		private var scaler:Matrix;
		private var speeds:Array;
		private var offsets:Array;
		
		public function PerlinBG()
		{
			noiseBMD = new BitmapData(480, 270);			
			screenBMD = new BitmapData(1920, 1080);
			
			scaler = new Matrix();
			scaler.scale(4,4);

			speeds = new Array(new Point(-0.3, 0), new Point(.7, 0), new Point(-.6, .1));
			offsets = new Array(new Point(0, 0), new Point(0, 0), new Point(0,0));
			
			bitmapData = screenBMD;
			
			addEventListener(Event.ENTER_FRAME, animate);
		}

		
		private function animate(e:Event):void 
		{			
			for(var i:int = 0; i < 3; i++){
				offsets[i].x += speeds[i].x;
				offsets[i].y += speeds[i].y;
			}
			
			noiseBMD.perlinNoise(160, 300, 3, 4, false, true, 15, false, offsets);
			screenBMD.draw(noiseBMD, scaler, null, null, null, true);
			//TweenMax.to(this, 0, {colorMatrixFilter:{threshold:220}});
		}
		
	}
	
}