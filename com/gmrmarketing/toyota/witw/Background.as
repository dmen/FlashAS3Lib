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
			for(var i:int = 0; i < 70; i++){
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
			
			for(var i:int = 0; i < 70; i++){
				c = circles[i];
				for(var j:int = 0; j< 70; j++){
					d = circles[j];
					dist = ((c.x - d.x)*(c.x - d.x)) + ((c.y - d.y)*(c.y - d.y));	//distance squared - remove Math.sqrt() for speed ~20% faster
								
					if(dist < 40000){
						g.lineStyle(1, 0xD71B23, (40000 - dist)/40000);
						g.moveTo(c.x, c.y);
						g.lineTo(d.x, d.y);
					}					
				}
			}
		}
	}	
}