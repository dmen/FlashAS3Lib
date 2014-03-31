package com.gmrmarketing.intel.girls20
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	import flash.text.TextFieldAutoSize;
	
	public class Dialog extends MovieClip
	{
		private var container:DisplayObjectContainer;
		
		public function Dialog($container:DisplayObjectContainer)
		{
			container = $container;
		}
		
		public function show(message:String, keep:Boolean = false):void
		{
			theText.text = message.toUpperCase();
			
			theText.autoSize = TextFieldAutoSize.CENTER;
			
			//center text vertically
			var topGap:int = Math.round((105 - theText.textHeight) / 2);
			theText.y = topGap;
			
			if(!container.contains(this)){
				container.addChild(this);
			}
			x = 572;
			y = 280;
			alpha = 1;
			
			if(!keep){
				TweenMax.to(this, .5, { y: -300, alpha:0, delay:2, onComplete:kill } );
			}
		}
		
		private function kill():void
		{
			container.removeChild(this);
		}
	}
	
}