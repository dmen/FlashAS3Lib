package com.gmrmarketing.humana.gifbooth
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import flash.geom.Matrix;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Review extends EventDispatcher
	{
		public static const SHOWING:String = "reviewShowing";
		public static const RETAKE:String = "reviewRetake";
		public static const NEXT:String = "reviewNext";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var frames:Array;
		private var animTimer:Timer;
		private var curFrame:int;
		private var bmp:Bitmap;
		private var over:Bitmap;//overlay
		
		private var tim:TimeoutHelper;
		
		
		public function Review()
		{
			clip = new mcReview();
			
			animTimer = new Timer(150);//150ms per frame - 
			animTimer.addEventListener(TimerEvent.TIMER, advanceFrame);			
			
			over = new Bitmap(new overlayLarge());//library
			over.x = 575;
			over.y = 214;
			
			
			bmp = new Bitmap();			
			bmp.x = 575;
			bmp.y = 214;			
			
			tim = TimeoutHelper.getInstance();			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function get bg():MovieClip
		{
			return clip;
		}
		
		
		public function show(f:Array):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.addChildAt(bmp, 0);
			clip.addChild(over);//commented for puffs kiss cry
			
			frames = f;
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1, onComplete:showing } );			
			
			curFrame = 0;
			animTimer.start();
			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, doRetake, false, 0, true);
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, doNext, false, 0, true);
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		public function hide():void
		{
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, doRetake);
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, doNext);
			
			animTimer.stop();
			if(clip){
				if(myContainer){
					if(myContainer){
						if (myContainer.contains(clip)) {
							myContainer.removeChild(clip);
						}
					}
				}
				if(clip.contains(bmp)){
					clip.removeChild(bmp);
				}
				
				if(clip.contains(over)){
					clip.removeChild(over);
				}		
			}
		}
		
		
		/**
		 * called by animTimer
		 * @param	e
		 */
		private function advanceFrame(e:TimerEvent):void
		{
			bmp.bitmapData = frames[curFrame];
			
			curFrame++;
			if (curFrame >= frames.length) {
				curFrame = 0;
			}
		}
		
		
		private function doRetake(e:MouseEvent):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(RETAKE));
		}
		
		
		private function doNext(e:MouseEvent):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(NEXT));
		}
		
	}
	
}