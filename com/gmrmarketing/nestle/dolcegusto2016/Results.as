package com.gmrmarketing.nestle.dolcegusto2016
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	import flash.text.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Results extends EventDispatcher 
	{
		public static const COMPLETE:String = "resultsComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var bigCounter:int;
		private var myResult:Object;
		private var mugBitmap:Bitmap;
		
		
		public function Results()
		{
			clip = new mcResults();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * 
		 * @param	result Object with value,title,exp,image properties
		 * from the Key section of the JSON
		 */
		public function show(result:Object):void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			myResult = result;
			
			clip.resultTitle.autoSize = TextFieldAutoSize.LEFT;
			clip.resultTitle.text = result.title;
			clip.resultExp.autoSize = TextFieldAutoSize.LEFT;
			clip.resultExp.text = result.exp;			
			var tHeight:int = clip.resultTitle.textHeight + 15 + clip.resultExp.textHeight;
			//box height is 730
			var startY:int = Math.floor(((730 - tHeight) * .5) * .8);
			clip.resultTitle.y = 550 + startY;
			clip.resultExp.y = clip.resultTitle.y + clip.resultTitle.textHeight + 15;
			
			clip.resultImage.alpha = 0;
			clip.resultTitle.alpha = 0;
			clip.resultExp.alpha = 0;
			
			clip.theTitle.alpha = 0;
			clip.theTitle.y = 320;
			
			clip.whiteBox.height = 0;
			clip.whiteBox2.height = 0;
			clip.specialOffer.x = 2800;//off right
			clip.btnNext.alpha = 0;
			
			TweenMax.to(clip.whiteBox, .3, {height:730, ease:Bounce.easeOut});
			TweenMax.to(clip.whiteBox2, .3, {height:430, ease:Bounce.easeOut, delay:.2});
			TweenMax.to(clip.specialOffer, .3, {x:1713, ease:Back.easeOut, delay:.4});
			
			TweenMax.to(clip.theTitle, .4, {y:370, alpha:1, delay:.5, ease:Back.easeOut});
			TweenMax.to(clip.resultTitle, .5, {alpha:1, delay:.5});
			TweenMax.to(clip.resultExp, .75, {alpha:1, delay:1});
			
			TweenMax.to(clip.btnNext, 1, {alpha:1, delay:1});
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextPressed, false, 0, true);
			
			//load image			
			var im:String = "assets/" + result.image;				
			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
			l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageError, false, 0, true);
			l.load(new URLRequest(im));			
		}
		
		
		private function animateArrow():void
		{
			clip.btnNext.arrow.x = -80;
			TweenMax.to(clip.btnNext.arrow, .75, {x:0, ease:Elastic.easeOut, onComplete:arrowWait});
		}
		private function arrowWait():void
		{
			TweenMax.delayedCall(2, animateArrow);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			if(mugBitmap){
				if (clip.resultImage.contains(mugBitmap)){
					clip.resultImage.removeChild(mugBitmap);
				}
			}
			TweenMax.killDelayedCallsTo(animateArrow);
			TweenMax.killTweensOf(clip.btnNext.arrow);
		}
		
		
		private function imageLoaded(e:Event):void
		{	
			mugBitmap = new Bitmap(e.target.content.bitmapData);
			mugBitmap.smoothing = true;
			mugBitmap.width = 700;
			mugBitmap.height = 700;
			
			clip.resultImage.addChild(mugBitmap);
			TweenMax.to(clip.resultImage, .5, {alpha:1});
			
			animateArrow();
		}
		
		
		private function imageError(e:IOErrorEvent):void
		{
			trace("image error",e.toString());
		}
		
		
		private function nextPressed(e:MouseEvent):void
		{
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextPressed);
			dispatchEvent(new Event(COMPLETE));
		}
			
	}
}