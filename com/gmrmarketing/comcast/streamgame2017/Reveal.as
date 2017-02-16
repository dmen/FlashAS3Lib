package com.gmrmarketing.comcast.streamgame2017
{
	import flash.display.*;
	import flash.events.Event;
	import com.greensock.TweenMax;
	import flash.geom.Point;
	
	public class Reveal extends MovieClip
	{
		private var myMask:Sprite;
		private var origX:int;
		
		
		public function Reveal()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			myMask = new Sprite();
			myMask.name = "mask";//used by main when finding clips being displayed
			myMask.graphics.beginFill(0x00ff00, .5);
			myMask.graphics.drawRect(0, 0, width, height);			
			myMask.graphics.endFill();
			myMask.x = x;
			myMask.y = y;
			
			parent.addChild(myMask);//adds into top,middle,bottom clips
			
			mask = myMask;
			
			origX = x;
			
			if (x < 470){
				x = -width;
			}
			if (x >= 470){
				x = x + width;				
			}
			
			addEventListener(Event.ENTER_FRAME, checkOnPos);
		}
		
		
		private function checkOnPos(e:Event):void
		{
			var pos:Point = new Point(x, y);
			pos = parent.localToGlobal(pos);
			
			if (pos.y < 1720 && pos.y > 0){
				removeEventListener(Event.ENTER_FRAME, checkOnPos);
				TweenMax.to(this, 1, {x:origX, onComplete:showing});
			}			
		}
		
		
		private function showing():void
		{
			addEventListener(Event.ENTER_FRAME, checkOffPos);
		}
		
		
		private function checkOffPos(e:Event):void
		{
			var pos:Point = new Point(x, y);
			pos = parent.localToGlobal(pos);
			
			if (pos.y < -height){
				removeEventListener(Event.ENTER_FRAME, checkOffPos);
				
				if (x < 470){
					x = -width;
				}
				if (x >= 470){
					x = x + width;				
				}
				
				addEventListener(Event.ENTER_FRAME, checkOnPos);
			}
		}
		
		
		private function hidden():void
		{
			addEventListener(Event.ENTER_FRAME, checkOnPos);
		}		
		
	}
	
}