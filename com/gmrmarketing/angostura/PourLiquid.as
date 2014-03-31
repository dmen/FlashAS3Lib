/**
 * This class controls, and is linked to, the pouringAnimation clip in the library 
 * instantiated by Main
 */
package com.gmrmarketing.angostura
{
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	import flash.geom.ColorTransform;
	import flash.display.DisplayObjectContainer;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class PourLiquid extends MovieClip
	{
		private var container:DisplayObjectContainer;
		private var bottle:IBottle;
		private var glass:MovieClip;
		private var tinter:ColorTransform;		
		
		public function PourLiquid($container:DisplayObjectContainer) 
		{
			//TweenPlugin.activate([TintPlugin]);
			tinter = new ColorTransform();
			container = $container;
		}
		
		
		public function pour($glass:MovieClip, $bottle:IBottle):void
		{
			glass = $glass;
			bottle = $bottle;
			
			if (!container.contains(this)) {
				container.addChildAt(this, container.numChildren - 4); //change to num bottles...
			}
			
			var delta:int = glass.y - bottle.getSpoutLoc().y;
			var toHeight:int = delta * 2;
			height = 0;
			//scaleX = .8;
			blendMode = BlendMode.ADD;
			//alpha = .9;
			
			x = bottle.getSpoutLoc().x;
			y = bottle.getSpoutLoc().y;
			
			tinter.color = bottle.getColor();
			tinter.alphaMultiplier = .9;
			this.transform.colorTransform = tinter;
			
			//tween the height so it appears to pour from bottle to glass
			TweenLite.to(this, .25, { height:toHeight, ease:Linear.easeNone, onComplete:listenForUpdate } );
		}
		
		
		public function stopPour():void
		{
			if(glass){
				removeEventListener(Event.ENTER_FRAME, update);
				//tween height and y so it goes down into the glass and gets smaller
				TweenLite.to(this, .25, { height:0, y:glass.y, ease:Linear.easeNone, onComplete:kill } );
			}
		}
		
		
		private function kill():void
		{
			if (container.contains(this)) {
				container.removeChild(this);
			}
		}
		
		
		private function listenForUpdate():void
		{
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		
		private function update(e:Event):void
		{
			var delta:int = glass.y - bottle.getSpoutLoc().y;
			height = delta * 2;
			x = bottle.getSpoutLoc().x;
			y = bottle.getSpoutLoc().y;
		}
		
	}
	
}