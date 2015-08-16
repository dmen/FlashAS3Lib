package com.gmrmarketing.comcast.book3d
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	public class Instructions extends EventDispatcher
	{
		public static const INST_COMPLETE:String = "instructionsComplete";
		
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		
		
		public function Instructions()
		{
			clip = new mcInstructions();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			clip.alpha = 1;
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, finish, false, 0, true);
			
			clip.title.alpha = 0;
			clip.title.y -= 50;
			clip.in1.alpha = 0;
			clip.in1.scaleX = clip.in1.scaleY = 0;
			clip.in2.alpha = 0;
			clip.in2.scaleX = clip.in2.scaleY = 0;
			clip.in3.alpha = 0;
			clip.in3.scaleX = clip.in3.scaleY = 0;
			clip.t1.alpha = 0;
			clip.t2.alpha = 0;
			clip.t3.alpha = 0;
			clip.t1.y += 30;
			clip.t2.y += 30;
			clip.t3.y += 30;
			clip.btnPlay.scaleX = 0;
			
			TweenMax.to(clip.title, .5, { alpha:1, y:"50", ease:Back.easeOut } );
			TweenMax.to(clip.in1, .5, { alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, delay:.2 } );
			TweenMax.to(clip.in2, .5, { alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, delay:.3 } );
			TweenMax.to(clip.in3, .5, { alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, delay:.4 } );
			TweenMax.to(clip.t1, .5, { alpha:1, y:"-30", delay:.3 } );
			TweenMax.to(clip.t2, .5, { alpha:1, y:"-30", delay:.4 } );
			TweenMax.to(clip.t3, .5, { alpha:1, y:"-30", delay:.5 } );
			TweenMax.to(clip.btnPlay, .5, { scaleX:1, ease:Back.easeOut, delay:.7 } );
		}
		
		
		private function finish(e:MouseEvent):void
		{
			clip.btnPlay.removeEventListener(MouseEvent.MOUSE_DOWN, finish);
			dispatchEvent(new Event(INST_COMPLETE));
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
	
	}
	
}