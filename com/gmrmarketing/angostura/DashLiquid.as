package com.gmrmarketing.angostura
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	
	public class DashLiquid extends MovieClip
	{
		private var container:DisplayObjectContainer;
		private var bottle:IBottle;
		private var glass:MovieClip;
		private var drips:Array;
		
		
		public function DashLiquid($container:DisplayObjectContainer)
		{
			container = $container;
			drips = new Array();
			
			drips.push(new drip());
		}
		
		
		public function pour($glass:MovieClip, $bottle:IBottle):void
		{
			glass = $glass;
			bottle = $bottle;			
		
			for (var i:int = 0; i < drips.length; i++) {
				drips[i].x = bottle.getSpoutLoc().x;
				drips[i].y = bottle.getSpoutLoc().y;
				container.addChild(drips[i]);
				TweenLite.to(drips[i], .3, { x:glass.x, y:glass.y, ease:Linear.easeNone } );
			}
		}
		
		public function stopPour():void
		{
			for (var i:int = 0; i < drips.length; i++) {			
				container.removeChild(drips[i]);
			}
		}
	
		
	}
	
}