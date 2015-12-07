package com.gmrmarketing.holiday2015
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class ButtonBar extends EventDispatcher 
	{
		public static const TAKE:String = "takePhotoPressed";
		public static const COUNT:String = "countdownComplete";
		public static const RETAKE:String = "retakePressed";
		public static const CONT:String = "continuePressed";
		public static const EMAIL:String = "emailPressed";
		public static const CANCEL:String = "cancelPressed";
		
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
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			hide();
			
			clip.count.the1.scaleX = clip.count.the1.scaleY = 1;
			clip.count.the1.alpha = 1;
			
			clip.count.the2.scaleX = clip.count.the2.scaleY = 1;
			clip.count.the2.alpha = 1;
			
			clip.count.the3.scaleX = clip.count.the3.scaleY = 1;
			clip.count.the3.alpha = 1;
			
			TweenMax.to(clip.choose, .5, { y:0, ease:Back.easeOut, delay:1 } );
			TweenMax.to(clip.pose, .5, { y:0, ease:Back.easeOut, delay:1.1 } );
			TweenMax.to(clip.take, .5, { y:0, ease:Back.easeOut, delay:1.2 } );
			
			clip.take.addEventListener(MouseEvent.MOUSE_DOWN, takePressed, false, 0, true);
		}
		
		public function hide():void
		{
			clip.count.y = 100;
			clip.retake.y = 100;
			clip.cont.y = 100;
			clip.email.y = 100;
			clip.cancel.y = 100;
			clip.choose.y = 100;
			clip.pose.y = 100;
			clip.take.y = 100;
		}
		
		
		public function hideEmail():void
		{
			TweenMax.to(clip.cancel, .5, { y:100, ease:Back.easeIn } );
			TweenMax.to(clip.email, .5, { y:100, ease:Back.easeIn } );
		}
		
		
		private function takePressed(e:MouseEvent):void
		{
			dispatchEvent(new Event(TAKE));
		}
		
		
		public function startCountdown():void
		{
			TweenMax.to(clip.pose, .5, { y:100, ease:Back.easeIn } );
			TweenMax.to(clip.count, .5, { y:0, ease:Back.easeOut, delay:.5 } );
			
			TweenMax.to(clip.count.the3, .3, { scaleX:1.2, scaleY:1.2, ease:Back.easeOut, delay:1.2 } );
			TweenMax.to(clip.count.the3, 1, { scaleX:.5, scaleY:.5, alpha:0, delay:1.5 } );
			
			TweenMax.to(clip.count.the2, .3, { scaleX:1.2, scaleY:1.2, ease:Back.easeOut, delay:2.5 } );
			TweenMax.to(clip.count.the2, 1, { scaleX:.5, scaleY:.5, alpha:0, delay:2.8 } );
			
			TweenMax.to(clip.count.the1, .3, { scaleX:1.2, scaleY:1.2, ease:Back.easeOut, delay:3.8 } );
			TweenMax.to(clip.count.the1, 1, { scaleX:.5, scaleY:.5, alpha:0, delay:4.1, onComplete:dispatchCount } );
		}
		
		
		private function dispatchCount():void
		{
			dispatchEvent(new Event(COUNT));
		}
		
		
		public function showRetake():void
		{
			TweenMax.to(clip.count, .5, { y:100, ease:Back.easeIn } );
			TweenMax.to(clip.take, .5, { y:100, ease:Back.easeIn, delay:.1 } );
			
			TweenMax.to(clip.retake, .5, { y:0, ease:Back.easeOut, delay:.5 } );
			TweenMax.to(clip.cont, .5, { y:0, ease:Back.easeOut, delay:.6 } );
			
			clip.retake.addEventListener(MouseEvent.MOUSE_DOWN, retakePressed, false, 0, true);
			clip.cont.addEventListener(MouseEvent.MOUSE_DOWN, continuePressed, false, 0, true);
		}
		
		
		public function reset():void
		{
			TweenMax.to(clip.retake, .5, { y:100, ease:Back.easeIn } );
			TweenMax.to(clip.cont, .5, { y:100, ease:Back.easeIn, delay:.1 } );
			
			TweenMax.to(clip.pose, .5, { y:0, ease:Back.easeOut, delay:.5 } );
			TweenMax.to(clip.take, .5, { y:0, ease:Back.easeOut, delay:.6 } );
			
			clip.count.the1.scaleX = clip.count.the1.scaleY = 1;
			clip.count.the1.alpha = 1;
			
			clip.count.the2.scaleX = clip.count.the2.scaleY = 1;
			clip.count.the2.alpha = 1;
			
			clip.count.the3.scaleX = clip.count.the3.scaleY = 1;
			clip.count.the3.alpha = 1;
		}
		
		
		public function showEmail():void
		{
			TweenMax.to(clip.choose, .5, { y:100, ease:Back.easeIn } );
			TweenMax.to(clip.retake, .5, { y:100, ease:Back.easeIn, delay:.1 } );
			TweenMax.to(clip.cont, .5, { y:100, ease:Back.easeIn, delay:.2 } );
			
			TweenMax.to(clip.cancel, .5, { y:0, ease:Back.easeOut, delay:.9 } );
			TweenMax.to(clip.email, .5, { y:0, ease:Back.easeOut, delay:.8 } );
			
			clip.cancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelPressed, false, 0, true);
			clip.email.addEventListener(MouseEvent.MOUSE_DOWN, emailPressed, false, 0, true);
		}
		
		
		private function retakePressed(e:MouseEvent):void
		{
			dispatchEvent(new Event(RETAKE));
		}
		
		
		private function continuePressed(e:MouseEvent):void
		{
			dispatchEvent(new Event(CONT));
		}
		
		
		private function emailPressed(e:MouseEvent):void
		{
			dispatchEvent(new Event(EMAIL));
		}
		
		
		private function cancelPressed(e:Event):void
		{
			dispatchEvent(new Event(CANCEL));
		}
		
	}
	
}