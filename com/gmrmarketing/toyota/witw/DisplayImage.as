package com.gmrmarketing.toyota.witw
{
	import flash.display.*;
	import flash.events.*;	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class DisplayImage extends Sprite 
	{
		private var myImages:Array;
		private var currentIndex:int;
		private var theMask:Shape;
		
		
		public function DisplayImage($x:int, $y:int ):void
		{
			x = $x;
			y = $y;
			
			theMask = new Shape();
			theMask.graphics.beginFill(0x00ff00, 1);
			theMask.graphics.drawRect(0, 0, 245, 245);
			theMask.graphics.endFill();
			theMask.visible = false;
			theMask.cacheAsBitmap = true;
			addChild(theMask);
			
			myImages = [];
			currentIndex = 0;
		}
		
		
		public function addImage(i:Bitmap):void
		{
			myImages.push(i);
		}
		
		
		public function hide():void
		{		
			if (numChildren > 2) {
				removeChildAt(0);
			}
			getChildAt(0).x = 0;
			getChildAt(0).y = 0;
			
			if(numChildren > 1){			
				TweenMax.to(getChildAt(0), 1, { alpha:0, delay:Math.random(), onComplete:reset } );
			}
		}
		
		
		private function reset():void
		{
			myImages = [];
			currentIndex = 0;
			
			while (numChildren > 1) {
				removeChildAt(0);
			}
		}
		
		
		public function transition():void
		{			
			TweenMax.delayedCall(5 + (3 * Math.random()), doTransition);
		}
		
		
		public function doTransition():void
		{			
			var b:Bitmap = myImages[currentIndex];
			b.alpha = 1;
			b.cacheAsBitmap = true;
			addChildAt(b, numChildren - 1);	
			b.mask = theMask;			
			b.x = Math.floor((245 - b.width) * .5);
			b.y = Math.floor((245 - b.height) * .5);
			
			var r:Number = Math.random();
			if(r < .25){
				b.x += 245;
				TweenMax.to(b, 1, { x:"-245", onComplete: removeOldImage } );
			}else if (r < .5) {
				b.x -= 245;
				TweenMax.to(b, 1, { x:"245", onComplete: removeOldImage } );
			}else if (r < .75) {
				b.y -= 245;
				TweenMax.to(b, 1, { y:"245", onComplete: removeOldImage } );
			}else {
				b.y += 245;
				TweenMax.to(b, 1, { y:"-245", onComplete: removeOldImage } );
			}
			
			currentIndex++;
			if (currentIndex >= myImages.length) {
				currentIndex = 0;
			}
		}
		
		
		private function removeOldImage():void
		{
			if (numChildren > 2) {
				TweenMax.to(getChildAt(0), .3, { alpha:0, onComplete:killOld } );
			}else {
				transition();
			}
		}
		
		
		private function killOld():void
		{
			if (numChildren > 2) {
				removeChildAt(0);
			}
			transition();
		}
		
	}
	
}