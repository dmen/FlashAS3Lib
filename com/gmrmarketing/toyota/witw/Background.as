/**
 * Circles moving in the background
 * with distance-based connecting lines
 */
package com.gmrmarketing.toyota.witw
{
	import com.gmrmarketing.testing.Circle;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	
	public class Background extends Sprite
	{		
		private var circles:Array;
		private var lines:Sprite;
		private var g:Graphics;
		private var dist:Number;
		private var c:Circle;
		private var d:Circle;
		
		public function Background()
		{			
			circles = [];			
			for(var i:int = 0; i < 100; i++){
				var c:Circle = new Circle(true);//debug - show circle
				circles.push(c);
				c.x = Math.random() * 1920;
				c.y = Math.random() * 1080;
				addChild(c);
				c.startMoving();
			}
			
			g = graphics;			
			addEventListener(Event.ENTER_FRAME, updateBG);
		}


		private function updateBG(e:Event):void
		{
			g.clear();	
			for(var i:int = 0; i < circles.length; i++){
				c = circles[i];
				for(var j:int = 0; j < circles.length; j++){
					d = circles[j];
					dist = Math.sqrt(((c.x - d.x)*(c.x - d.x)) + ((c.y - d.y)*(c.y - d.y)));			
								
					if(dist < 200){
						g.lineStyle(1, 0xD71B23, (200 - dist)/200);
						g.moveTo(c.x, c.y);
						g.lineTo(d.x, d.y);
					}					
				}
			}
		}
	}	
}