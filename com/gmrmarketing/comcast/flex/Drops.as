package com.gmrmarketing.comcast.flex
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import com.gmrmarketing.comcast.flex.Dot;
	
	
	public class Drops
	{
		private var container:DisplayObjectContainer;
		private var glow:GlowFilter;
		private var dots:Array;
		private var ang:Number = 0;
		private var numDots:int = 200;
		
		public function Drops($container:DisplayObjectContainer)
		{
			container = $container;
			makeDots();			
		}
		
		public function stop():void
		{
			container.removeEventListener(Event.ENTER_FRAME, update);
			while(dots.length){
				container.removeChild(dots.splice(0,1)[0]);
			}
		}
		
		private function makeDots():void
		{
			dots = new Array();
			
			for (var i:int = 0; i < numDots; i++) {				
				var d:Dot = new Dot(container);							
				container.addChild(d);
				dots.push(d);
			}
			
			container.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		private function update(e:Event):void
		{
			for (var i:int = 0; i < numDots; i++) {
				Dot(dots[i]).change();
			}
		}
	
	}
	
}