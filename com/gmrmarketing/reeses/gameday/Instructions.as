package  com.gmrmarketing.reeses.gameday
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	public class Instructions extends EventDispatcher
	{
		public static const COMPLETE:String = "instructionsComplete";
		public static const CANCEL:String = "instructionsCancel";
		private var clip:MovieClip;		
		private var myContainer:DisplayObjectContainer;
		
		
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
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.s1.scaleX = clip.s1.scaleY = 0;
			clip.s2.scaleX = clip.s2.scaleY = 0;
			clip.s3.scaleX = clip.s3.scaleY = 0;
			clip.title.alpha = 0;//main title after perfect pick header
			clip.title1.alpha = 0;
			clip.title2.alpha = 0;
			clip.title3.alpha = 0;
			clip.sub1.alpha = 0;
			clip.sub2.alpha = 0;
			clip.sub3.alpha = 0;
			
			TweenMax.to(clip.s1, .4, { scaleX:1, scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.s2, .4, { scaleX:1, scaleY:1, delay:.1, ease:Back.easeOut } );
			TweenMax.to(clip.s3, .4, { scaleX:1, scaleY:1, delay:.2, ease:Back.easeOut } );
			
			TweenMax.to(clip.title1, .4, { alpha:1, delay:.2 } );
			TweenMax.to(clip.title2, .4, { alpha:1, delay:.3 } );
			TweenMax.to(clip.title3, .4, { alpha:1, delay:.4 } );
			
			TweenMax.to(clip.sub1, .4, { alpha:1, delay:.3 } );
			TweenMax.to(clip.sub2, .4, { alpha:1, delay:.4 } );
			TweenMax.to(clip.sub3, .4, { alpha:1, delay:.5 } );
			
			TweenMax.to(clip.title, .5, { alpha:1, delay:.7 } );
			
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextClicked, false, 0, true);
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, backClicked, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function nextClicked(e:MouseEvent):void
		{
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextClicked);
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backClicked);
			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function backClicked(e:MouseEvent):void
		{
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextClicked);
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backClicked);
			
			dispatchEvent(new Event(CANCEL));
		}
		
	}
	
}