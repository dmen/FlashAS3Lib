package com.rimv.utils
{
	/**
   @author  		RimV	
					www.mymedia-art.com
   @class  			Reflection
					create reflection for displayobject return reflection bitmapdata
   @package			utilities
	*/
   
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.geom.*;
	

	public class Reflection extends Sprite
	{
		// Parameters
		private var refIn1:Number = 0.5;	// Reflection Intensity 1
		private var refIn2:Number = 0;		// Reflection Intensity 2
		private var refDen1:Number = 0;		// Reflection Density 1
		private var refDen2:Number = 180;	// Reflection Density 2
		private var transparent:Boolean = false;
		private var color:uint = 0x000000;
				
		public function get reflectionIntensity1():Number
		{
				return refIn1;
		}
		
		public function set reflectionIntensity1(num:Number):void
		{
				refIn1 = num;
		}
		
		public function get reflectionIntensity2():Number
		{
				return refIn2;
		}
		
		public function set reflectionIntensity2(num:Number):void
		{
				refIn2 = num;
		}
		
		public function get reflectionDensity1():Number
		{
				return refDen1;
		}
		
		public function set reflectionDensity1(num:Number):void
		{
				refDen1 = num;
		}
		
		public function get reflectionDensity2():Number
		{
				return refDen2;
		}
		
		public function set reflectionDensity2(num:Number):void
		{
				refDen2 = num;
		}
		
		// Constructor
		public function Reflection(refIn1:Number, refIn2:Number, refDen1:Number, refDen2:Number, transparent:Boolean = false, color:uint = 0x000000):void
		{
			this.refIn1 = refIn1;
			this.refIn2 = refIn2;
			this.refDen1 = refDen1;
			this.refDen2 = refDen2;
			this.transparent = transparent;
			this.color = color;
		}
		
		// Create Reflection return bitmap data of the reflection
		public function createReflection(ob:DisplayObject):BitmapData
		{
			// Create new reflection Bitmap Data 
			var bmp:BitmapData = new BitmapData( ob.width, ob.height, transparent, color);
			bmp.draw( ob, m );
			
			// Flip bitmap data
			var m:Matrix = new Matrix();
			m.createBox(1, -1, 0, 0, ob.height);
			var b:Bitmap = new Bitmap(bmp);
			b.cacheAsBitmap = true;
			
			// gradient field
			var matrix_grad:Matrix = new Matrix();
			matrix_grad.createGradientBox(ob.width, ob.height, Math.PI/2, 0, 0)
			var grad:Sprite = new Sprite();
			if (transparent) 
				grad.graphics.beginGradientFill(GradientType.LINEAR,[color, color],[refIn1, 1 - refIn2],[refDen1, refDen2], matrix_grad)
			else
				grad.graphics.beginGradientFill(GradientType.LINEAR,[color, color],[refIn1, refIn2],[refDen1, refDen2], matrix_grad)
			grad.graphics.drawRect(0, 0, ob.width, ob.height)
			grad.graphics.endFill();
			//Reflection Bitmap data
			var refbmpData:BitmapData = new BitmapData(ob.width, ob.height, transparent, color);
			refbmpData.draw(b, m);
			// not transparent
			if (!transparent) refbmpData.draw(grad, new Matrix());
			// transparent
			else
			{
				var bitmap:Bitmap = new Bitmap(refbmpData);
				// apply masking - has to add to stage
				addChild(bitmap); 	addChild(grad);
				bitmap.cacheAsBitmap = grad.cacheAsBitmap = true;
				bitmap.mask = grad;
				// final bmp copy reflection data 
				var finalBmp:BitmapData = new BitmapData(ob.width, ob.height, true, 0x000000);
				finalBmp.draw(bitmap);
				// free up memory
				removeChild(bitmap); removeChild(grad);
				refbmpData.dispose();
				bmp.dispose();
				bitmap = null; grad = null;
				return finalBmp;
			}
			// free up memory
			bmp.dispose();
			grad = null;
			
			return refbmpData;
			
		}
	}
	
}