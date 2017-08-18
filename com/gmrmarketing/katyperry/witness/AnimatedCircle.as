package com.gmrmarketing.katyperry.witness
{
	import flash.display.*;
	import flash.events.Event;
	
	
	public class AnimatedCircle extends Sprite
	{
		private var g:Graphics;
		private var curAlpha:Number;
		private var curRadius:Number;
		private var myMask:MovieClip;
		private var useMask:Boolean;
		
		public function AnimatedCircle(um:Boolean = true)
		{
			useMask = um;
			
			g = graphics;
			curAlpha = 1;
			curRadius = 2;
			
			if(useMask){
				myMask = new introMask();
				myMask.cacheAsBitmap = true;
			}
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		private function init(e:Event):void
		{
			if(useMask){
				this.mask = myMask;
				this.cacheAsBitmap = true;
				
				parent.addChild(myMask);
			}
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function update(e:Event):void
		{			
			g.clear();
			g.lineStyle(2, 0x231f20, curAlpha);
			g.drawCircle(x, y, curRadius);
			
			curRadius += .8;
			curAlpha -= .01;			
			
			if (curAlpha <= 0){
				g.clear();
				removeEventListener(Event.ENTER_FRAME, update);
				
				if (useMask && parent.contains(myMask)){
					parent.removeChild(myMask);
				}
				
				parent.removeChild(this);
			}
		}
	}
	
}