package com.gmrmarketing.reeses.gameday
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Intro extends EventDispatcher
	{		
		public static const BEGIN:String = "userTouchedScreen";		
		private var clip:MovieClip;		
		private var myContainer:DisplayObjectContainer;
		
		
		public function Intro()
		{
			clip = new mcIntro();
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
			
			clip.rece.alpha = 0;
			clip.cgd.alpha = 0;
			clip.touch.scaleY = 0;
			clip.getReady.scaleY = 0;
			clip.tline.scaleX = 0;
			clip.bline.scaleX = 0;
			clip.perfectPick.scaleX = clip.perfectPick.scaleY = 0;
			clip.perfectPick.alpha = 0;
			clip.rCup.scaleX = clip.rCup.scaleY = 0;
			
			TweenMax.to(clip.rCup, .4, { scaleX:1, scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.perfectPick, .5, { alpha:1,  scaleX:1, scaleY:1, delay:.3, ease:Back.easeOut } );
			TweenMax.to(clip.tline, .4, { scaleX:1, delay:1.2, ease:Back.easeOut } );
			TweenMax.to(clip.bline, .4, { scaleX:1, delay:1.2, ease:Back.easeOut } );
			TweenMax.to(clip.getReady, .4, { scaleY:1, delay:1.6, ease:Back.easeOut } );
			TweenMax.to(clip.touch, .4, { scaleY:1, delay:1.6, ease:Back.easeOut } );
			TweenMax.to(clip.rece, .5, { alpha:1, delay:2} );			
			TweenMax.to(clip.cgd, 1, { alpha:1, delay:3, onComplete:growShort} );
			
			clip.addEventListener(MouseEvent.MOUSE_DOWN, begin, false, 0, true);	
			
		}
		
		
		private function growShort():void
		{
			TweenMax.to(clip.touch, 1, { scaleY:.8, onComplete:growTall } );
		}
		
		
		private function growTall():void
		{
			TweenMax.to(clip.touch, 1, { scaleY:1, onComplete:growShort } );
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			TweenMax.killTweensOf(clip.touch);
		}
		
		
		private function begin(e:MouseEvent):void
		{
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, begin);
			dispatchEvent(new Event(BEGIN));
		}
		
		
	}
	
}