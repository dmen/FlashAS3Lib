package com.gmrmarketing.metrx.photobooth2017
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class SlideReveal extends Sprite
	{
		public static const HIDDEN:String = "hidden";
		public static const SHOWING:String = "showing";
		private var imageHeight:int;
		
		
		public function SlideReveal(image:BitmapData, numSlices:int)
		{
			var sliceWidth:int = image.width / numSlices;
			imageHeight = image.height;
			
			for (var i:int = 0; i < numSlices; i++){
				var b:BitmapData = new BitmapData(sliceWidth, image.height);
				b.copyPixels(image, new Rectangle(i * sliceWidth, 0, sliceWidth, image.height), new Point(0, 0));
				var bm:Bitmap = new Bitmap(b, "auto", true);
				addChild(bm);
				bm.x = i * sliceWidth;
				bm.y = imageHeight;
			}
		}
		
		
		/**
		 * Moves all the slices off screen top
		 * Dispatches HIDDEN whcn complete
		 */
		public function hide():void
		{
			var n:int = numChildren;
			
			for (var i:int = 0; i < n; i++){
				TweenMax.to(getChildAt(i), .6 + Math.random() * .5, {y:-imageHeight, ease:Expo.easeOut, delay:.2 + Math.random() * .25});				
			}
			TweenMax.delayedCall(1.5, hidden);
		}
		
		
		private function hidden():void
		{
			dispatchEvent(new Event(HIDDEN));
		}
		
		
		/**
		 * Moves all the slices to the bottom and then slides them up to show them
		 * Dispatches SHOWING when complete
		 */
		public function reveal():void
		{
			var n:int = numChildren;
			
			for (var i:int = 0; i < n; i++){
				getChildAt(i).y = imageHeight;			
			}
			
			for (i = 0; i < n; i++){
				TweenMax.to(getChildAt(i), .6 + Math.random() * .5, {y:0, ease:Expo.easeOut, delay:.2 + Math.random() * .25});				
			}
			TweenMax.delayedCall(1.5, showing);
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		public function kill():void
		{
			TweenMax.killDelayedCallsTo(showing);
			TweenMax.killDelayedCallsTo(hidden);
		}
	}
	
}