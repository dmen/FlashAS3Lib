package com.gmrmarketing.toyota.witw
{
	import flash.display.*;
	import flash.events.*;	
	import com.greensock.TweenMax;

	
	public class DisplayText extends Sprite
	{
		private var myTexts:Array;
		
		
		public function DisplayText($x:int, $y:int, w:int, h:int, borderColor:Number, fillColor:Number):void
		{
			x = $x;
			y = $y;
			
			var g:Graphics = graphics;
			g.lineStyle(2, borderColor);
			g.beginFill(fillColor, 1);
			g.drawRect(0, 0, w, h);
			g.endFill();
			
			myTexts = [];
		}
		
		
		/**
		 * adds an object with message,user properties
		 * @param	o
		 */
		public function addText(o:Object):void
		{
			myTexts.push(o);
		}
	}
	
}