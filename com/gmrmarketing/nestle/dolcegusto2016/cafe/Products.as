package com.gmrmarketing.nestle.dolcegusto2016.cafe
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Products extends EventDispatcher
	{
		public static const COMPLETE:String = "productComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Products()
		{
			clip = new mcProducts();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			clip.wb1.alpha = 1;
			clip.wb2.alpha = 1;
			clip.wb3.alpha = 1;
			clip.wb4.alpha = 1;
			clip.wb5.alpha = 1;
			clip.wb6.alpha = 1;
			clip.wb7.alpha = 1;
			clip.wb8.alpha = 1;
			
			clip.p1.scaleY = 0;
			clip.p2.scaleY = 0;			
			
			TweenMax.to(clip.wb1, .5, {alpha:0, delay:.5});
			
			TweenMax.to(clip.p1, .4, {scaleY:1, ease:Back.easeOut, delay:.5});
			TweenMax.to(clip.wb2, .5, {alpha:0, delay:.6});
			
			TweenMax.to(clip.p2, .4, {scaleY:1, ease:Back.easeOut, delay:.8});
			TweenMax.to(clip.wb3, .5, {alpha:0, delay:1});
			
			TweenMax.to(clip.wb4, .4, {alpha:0, delay:1.2});
			TweenMax.to(clip.wb5, .4, {alpha:0, delay:1.3});
			TweenMax.to(clip.wb6, .4, {alpha:0, delay:1.4});
			TweenMax.to(clip.wb7, .4, {alpha:0, delay:1.5});
			TweenMax.to(clip.wb8, .4, {alpha:0, delay:1.6});
			
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, productsComplete, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, productsComplete);
		}
		
		
		private function productsComplete(e:MouseEvent):void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}