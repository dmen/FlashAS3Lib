/**
 * Single image on the social wall
 * Instantiated by Social.as
 */
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
			
			myImages = [];
			currentIndex = 0;
		}
		
		
		public function addImage(i:Bitmap):void
		{
			myImages.push(i);
		}
		
		
		public function hide():void
		{	
			//move the current pic into place - killAll was called on tweenMax by social.hide
			getChildAt(numChildren-1).x = 0;
			getChildAt(numChildren-1).y = 0;
			
			myImages = [];
			currentIndex = 0;			
		
			TweenMax.to(this, 1, { alpha:0, delay:Math.random(), onComplete:kill } );
		}
		
		
		private function kill():void
		{
			alpha = 1;
			while (numChildren) {
				removeChildAt(0);
			}
		}
		
		private function transition():void
		{	
			//remove possible 2nd image behind the one being displayed
			if (numChildren > 2) {
				removeChildAt(0);
			}
			TweenMax.delayedCall(6 + (4 * Math.random()), doTransition);
		}
		
		
		/**
		 * called from social to show the images
		 */
		public function doTransition():void
		{
			if (!contains(theMask)) {				
				addChild(theMask);
			}
			var b:Bitmap = myImages[currentIndex];
			b.alpha = 1;
			b.cacheAsBitmap = true;
			addChildAt(b, numChildren - 1);	//add behind mask
			b.mask = theMask;			
			b.x = Math.floor((245 - b.width) * .5);
			b.y = Math.floor((245 - b.height) * .5);
			
			currentIndex++;
			if (currentIndex >= myImages.length) {
				currentIndex = 0;
			}
			
			var r:Number = Math.random();
			if(r < .25){
				b.x += 245;
				TweenMax.to(b, 1, { x:"-245", onComplete: transition } );
			}else if (r < .5) {
				b.x -= 245;
				TweenMax.to(b, 1, { x:"245", onComplete: transition } );
			}else if (r < .75) {
				b.y -= 245;
				TweenMax.to(b, 1, { y:"245", onComplete: transition } );
			}else {
				b.y += 245;
				TweenMax.to(b, 1, { y:"-245", onComplete: transition } );
			}
		}
		
	}
	
}