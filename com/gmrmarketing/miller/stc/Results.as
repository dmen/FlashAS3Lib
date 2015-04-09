package com.gmrmarketing.miller.stc
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Results extends EventDispatcher
	{	
		public static const COMPLETE:String = "complete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
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
		 * @param	selection String l or r
		 * @param	passion String sports,music
		 */
		public function show(selection:String, passion:String):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			clip.miller.scaleY = 0;
			clip.phone.scaleY = 0;
			clip.watchFor.scaleX = 0;
			
			clip.theTitle.scaleY = 0;
			if (selection == "l") {
				clip.theTitle.gotoAndStop(2);
			}else {
				//win
				clip.theTitle.gotoAndStop(1);
				if (passion == "sports") {
					clip.theTitle.theText.text = "10 MORE ENTRIES FOR\nFANTASY FOOTBALL SUITE";
				}else {
					clip.theTitle.theText.text = "10 MORE ENTRIES FOR\nLUKE BRYAN ALL ACCESS";
				}
			}
			
			TweenMax.to(clip.miller, .5, { scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.phone, .5, { scaleY:1, ease:Back.easeOut, delay:.25 } );
			TweenMax.to(clip.watchFor, .5, { scaleX:1, ease:Back.easeOut, delay:.5 } );
			TweenMax.to(clip.theTitle, .5, { scaleY:1, ease:Back.easeOut, delay:.75 } );
			
			myContainer.stage.addEventListener(MouseEvent.MOUSE_DOWN, restart);
		}
		
		
		public function hide():void
		{
			myContainer.stage.removeEventListener(MouseEvent.MOUSE_DOWN, restart);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function restart(e:MouseEvent):void
		{	
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}