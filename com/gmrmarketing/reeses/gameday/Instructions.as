package  com.gmrmarketing.reeses.gameday
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	public class Instructions extends EventDispatcher
	{
		public static const COMPLETE:String = "instructionsComplete";
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
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextClicked, false, 0, true);
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
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}