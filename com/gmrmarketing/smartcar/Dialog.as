package com.gmrmarketing.smartcar
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	
	
	public class Dialog extends MovieClip
	{
		private var container:DisplayObjectContainer;
		
		public function Dialog($container:DisplayObjectContainer)
		{
			container = $container;
		}
		
		public function show(message:String, keep:Boolean = false):void
		{
			theText.text = message;
			if(!container.contains(this)){
				container.addChild(this);
			}
			x = 590;
			y = 330;
			
			if(!keep){
				TweenMax.to(this, .5, { y: -300, delay:2, onComplete:kill } );
			}
		}
		
		private function kill():void
		{
			container.removeChild(this);
		}
	}
	
}