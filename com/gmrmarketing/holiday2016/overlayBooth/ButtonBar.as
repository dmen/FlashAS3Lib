package com.gmrmarketing.holiday2016.overlayBooth
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.events.*;
	import flash.display.*;

	
	public class ButtonBar extends EventDispatcher
	{
		public static const COUNT_COMPLETE:String = "counterDoneCounting";
		public static const RETAKE:String = "retakePhoto";
		public static const EMAIL:String = "photoDone";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function ButtonBar()
		{
			clip = new mcButtonBar();
			clip.x = 0;
			clip.y = 980;
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
			clip.choose.y = 100;
			clip.pose.y = 100;
			clip.btnTake.y = 100;
			clip.btnRetake.y = 100;
			clip.counter.y = 100;
			clip.btnEmail.y = 100;
			clip.counter.c5.scaleX = clip.counter.c5.scaleY = 1;
			clip.counter.c4.scaleX = clip.counter.c4.scaleY = 1;
			clip.counter.c3.scaleX = clip.counter.c3.scaleY = 1;
			clip.counter.c2.scaleX = clip.counter.c2.scaleY = 1;
			clip.counter.c1.scaleX = clip.counter.c1.scaleY = 1;
			clip.counter.c5.gotoAndStop(1);
			clip.counter.c4.gotoAndStop(1);
			clip.counter.c3.gotoAndStop(1);
			clip.counter.c2.gotoAndStop(1);
			clip.counter.c1.gotoAndStop(1);
			
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, startCountdown, false, 0, true);
			
			clip.y = 980;
			TweenMax.to(clip.choose, .4, {y:0});
			TweenMax.to(clip.pose, .4, {y:0, delay:.1});
			TweenMax.to(clip.btnTake, .4, {y:0, delay:.2});
		}
		
		public function hide():void
		{
			TweenMax.to(clip.btnRetake, .4, {y:100});
			TweenMax.to(clip.counter, .4, {y:100, delay:.2});
			TweenMax.to(clip.btnEmail, .4, {y:100, delay:.4, onComplete:killBar});
		}
		
		
		public function killBar():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
		}
		
		
		private function startCountdown(e:MouseEvent):void
		{
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, startCountdown);
			clip.counter.c5.scaleX = clip.counter.c5.scaleY = 1;
			clip.counter.c4.scaleX = clip.counter.c4.scaleY = 1;
			clip.counter.c3.scaleX = clip.counter.c3.scaleY = 1;
			clip.counter.c2.scaleX = clip.counter.c2.scaleY = 1;
			clip.counter.c1.scaleX = clip.counter.c1.scaleY = 1;
			TweenMax.to(clip.pose, .4, {y:100});
			TweenMax.to(clip.counter, .4, {y:0, delay:.3, onComplete:showFive});
		}
		
		
		private function showFive():void
		{
			clip.counter.c5.gotoAndStop(2);
			clip.counter.c5.scaleX = clip.counter.c5.scaleY = 2;
			TweenMax.to(clip.counter.c5, 1, {scaleX:0, scaleY:0, onComplete:showFour});
		}
		
		
		private function showFour():void
		{
			clip.counter.c5.gotoAndStop(1);
			clip.counter.c4.gotoAndStop(2);
			clip.counter.c4.scaleX = clip.counter.c4.scaleY = 2;
			TweenMax.to(clip.counter.c4, 1, {scaleX:0, scaleY:0, onComplete:showThree});
		}
		
		
		private function showThree():void
		{
			clip.counter.c4.gotoAndStop(1);
			clip.counter.c3.gotoAndStop(2);
			clip.counter.c3.scaleX = clip.counter.c3.scaleY = 2;
			TweenMax.to(clip.counter.c3, 1, {scaleX:0, scaleY:0, onComplete:showTwo});
		}
		
		
		private function showTwo():void
		{
			clip.counter.c3.gotoAndStop(1);
			clip.counter.c2.gotoAndStop(2);
			clip.counter.c2.scaleX = clip.counter.c2.scaleY = 2;
			TweenMax.to(clip.counter.c2, 1, {scaleX:0, scaleY:0, onComplete:showOne});
		}
		
		
		private function showOne():void
		{
			clip.counter.c2.gotoAndStop(1);
			clip.counter.c1.gotoAndStop(2);
			clip.counter.c1.scaleX = clip.counter.c1.scaleY = 2;
			TweenMax.to(clip.counter.c1, 1, {scaleX:0, scaleY:0, onComplete:countComplete});
		}
		
		
		private function countComplete():void
		{
			clip.counter.c1.gotoAndStop(1);
			
			//will call showWhite() in Main
			dispatchEvent(new Event(COUNT_COMPLETE));
		}
		
		
		/**
		 * called from takePhoto.showReview()
		 */
		public function showRetake():void
		{
			TweenMax.to(clip.choose, .4, {y:100});
			TweenMax.to(clip.btnTake, .4, {y:100, delay:.1});
			
			TweenMax.to(clip.btnRetake, .4, {y:0, delay:.3});
			TweenMax.to(clip.btnEmail, .4, {y:0, delay:.4});
			
			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, doRetake, false, 0, true);
			clip.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, doEmail, false, 0, true);
		}
		
		
		public function hideRetake():void
		{
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, doRetake);
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, doEmail);
			
			TweenMax.to(clip.btnRetake, .4, {y:100});
			TweenMax.to(clip.btnEmail, .4, {y:100, delay:.2});
			TweenMax.to(clip.counter, .4, {y:100, delay:.1});
			
			TweenMax.to(clip.choose, .4, {y:0, delay:.3});
			TweenMax.to(clip.btnTake, .4, {y:0, delay:.5});	
			TweenMax.to(clip.pose, .4, {y:0, delay:.5});	
			
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, startCountdown, false, 0, true);			
		}
		
		
		private function doRetake(e:MouseEvent):void
		{
			dispatchEvent(new Event(RETAKE));
		}
		
		private function doEmail(e:MouseEvent):void
		{
			dispatchEvent(new Event(EMAIL));
		}
	}
	
}