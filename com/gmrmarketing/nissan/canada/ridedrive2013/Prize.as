//Final Prize Screen

package com.gmrmarketing.nissan.canada.ridedrive2013
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextFieldAutoSize;
	
	public class Prize extends EventDispatcher 
	{
		public static const PRIZE_SHOWING:String = "prizeShowing";
		public static const PRIZE_COMPLETE:String = "prizeComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var curlang:String;
		
		public function Prize()
		{
			clip = new mcPrize();
		}
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		public function setLanguage(lang:String):void
		{
			curlang = lang;
			
			if (lang == "en") {
				clip.en.visible = 1;
				clip.fr.visible = 0;				
			}else {
				clip.en.visible = 0;
				clip.fr.visible = 1;
			}
		}
		
		public function show(prize:String):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			/*
			if(curlang == "en"){
				clip.en.thePrize.theText.text = prize;
				clip.en.tt.text = "21";
			}else {
				clip.fr.thePrize.theText.text = prize;
			}
			*/
			//prize comes in like $1,000 - need to put $ at end for french
			if (curlang == "fr") {
				clip.scPrize.thePrize.text = prize.substr(1) + " $";
			}else{
				clip.scPrize.thePrize.text = prize;
			}
			
			clip.btnFinish.addEventListener(MouseEvent.MOUSE_DOWN, finish, false, 0, true);
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, delay:.5, onComplete:prizeShowing } );
		}
		
		public function hide():void
		{
			clip.btnFinish.removeEventListener(MouseEvent.MOUSE_DOWN, finish);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		private function prizeShowing():void
		{
			dispatchEvent(new Event(PRIZE_SHOWING));
		}
		
		
		private function finish(e:MouseEvent):void
		{
			dispatchEvent(new Event(PRIZE_COMPLETE));
		}
	}
	
}