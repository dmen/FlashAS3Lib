package com.gmrmarketing.puma.startbelieving
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	
	
	public class Admin extends EventDispatcher
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var showing:Boolean;
		
		public function Admin() 
		{
			showing = false;
			clip = new mcAdmin();
		}
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		public function show():void
		{			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}else {
				//move to top
				container.removeChild(clip);
				container.addChild(clip);
			}
			showing = true;
			clip.progressBar.scaleX = 0;
			clip.per.text = "0%";
			clip.theText.text = "";
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, hide, false, 0, true);
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1 } );
		}
		
		public function moveToTop():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
				container.addChild(clip);
			}
		}
		
		public function displayDebug(mess:String):void
		{
			if (mess.substr(0, 9) == "progress_") {
				var num:Number = parseFloat(mess.substr(9));
				clip.per.text = String(Math.round(num * 100)) + "%";
				clip.progressBar.scaleX = Math.min(1, num);
			}else{
				clip.theText.appendText(mess + "\n");
				clip.theText.scrollV = clip.theText.numLines;
			}
		}
		
		public function hide(e:MouseEvent = null):void
		{
			showing = false;
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		public function isShowing():Boolean
		{
			return showing;
		}
		
	}
	
}