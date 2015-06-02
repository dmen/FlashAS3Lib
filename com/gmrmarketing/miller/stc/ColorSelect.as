package com.gmrmarketing.miller.stc
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class ColorSelect extends EventDispatcher
	{	
		public static const COMPLETE:String = "complete";
		public static const BACK:String = "colorBack";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function ColorSelect()
		{
			clip = new mcColor();
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
			clip.aboveAll.alpha = 0;
			clip.ellipsis.alpha = 0;
			clip.quality.alpha = 0;
			
			clip.finest.alpha = 0;
			clip.plus.alpha = 0;
			clip.richest.alpha = 0;
			clip.equal.alpha = 0;
			clip.bestTaste.alpha = 0;
			
			clip.beerL.x = -1050;
			clip.beerR.x = 2160;
			
			TweenMax.to(clip.beerL, .5, { x:40, ease:Back.easeOut, delay:.5 } );
			TweenMax.to(clip.beerR, .5, { x:1083, ease:Back.easeOut, delay:.5 } );
			
			TweenMax.to(clip.aboveAll, .4, { alpha:1, delay:1 } );
			TweenMax.to(clip.ellipsis, .4, { alpha:1, delay:1.2 } );
			TweenMax.to(clip.quality, .4, { alpha:1, delay:1.6 } );
			
			TweenMax.to(clip.finest, 0, {alpha:1, scaleX:1.5, scaleY:1.5, delay:2});
			TweenMax.to(clip.finest, .5, { scaleX:1, scaleY:1, delay:2, ease:Elastic.easeInOut } );
			TweenMax.to(clip.plus, 0, {alpha:1, scaleX:1.5, scaleY:1.5, delay:2.3});
			TweenMax.to(clip.plus, .5, { scaleX:1, scaleY:1, delay:2.3, ease:Elastic.easeInOut } );
			TweenMax.to(clip.richest, 0, {alpha:1, scaleX:1.5, scaleY:1.5, delay:2.5});
			TweenMax.to(clip.richest, .5, { scaleX:1, scaleY:1, delay:2.5, ease:Elastic.easeInOut } );
			TweenMax.to(clip.equal, 0, {alpha:1, scaleX:1.5, scaleY:1.5, delay:2.8});
			TweenMax.to(clip.equal, .5, { scaleX:1, scaleY:1, delay:2.8, ease:Elastic.easeInOut } );
			TweenMax.to(clip.bestTaste, 0, {alpha:1, scaleX:1.5, scaleY:1.5, delay:3});
			TweenMax.to(clip.bestTaste, .5, { scaleX:1, scaleY:1, delay:3, ease:Elastic.easeInOut } );
			
			clip.beerL.addEventListener(MouseEvent.MOUSE_DOWN, beerSelect);
			clip.beerR.addEventListener(MouseEvent.MOUSE_DOWN, beerSelect);
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, goBack);
			
			myContainer.addEventListener(Event.ENTER_FRAME, rotateCap);
		}
		
		
		public function hide():void
		{
			clip.beerL.removeEventListener(MouseEvent.MOUSE_DOWN, beerSelect);
			clip.beerR.removeEventListener(MouseEvent.MOUSE_DOWN, beerSelect);
			myContainer.removeEventListener(Event.ENTER_FRAME, rotateCap);
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, goBack);
			
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		private function goBack(e:MouseEvent):void
		{			
			dispatchEvent(new Event(BACK));
		}
		
		private function rotateCap(e:Event):void
		{
			clip.cap.rotation += .3;
		}
		
		
		private function beerSelect(e:MouseEvent):void
		{	
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}