package com.gmrmarketing.jimbeam.devilscut
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenLite;
	
	
	public class Dialog extends MovieClip
	{
		private var container:DisplayObjectContainer;
		private var funcToCall:Function;
		
		public function Dialog($container:DisplayObjectContainer)
		{
			container = $container;
		}
		
		
		public function show(mess:String, func:Function = null):void
		{
			funcToCall = func;
			
			container.addChild(this);
			x = 231;
			y = 454;
			
			theText.text = mess;
			theText.y = (116 - theText.textHeight) * .5;
			
			alpha = 1;
			TweenLite.to(this, 1, { alpha:0, delay:2, onComplete:killMe } );
		}
		
		
		private function killMe():void
		{
			container.removeChild(this);
			if(funcToCall != null){
				funcToCall();
			}
		}
	}
	
}