package com.gmrmarketing.testing
{
	import flash.display.DisplayObject;	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	
	public class Limb extends Sprite
	{
		public static const BRANCH:String = "branchOut";
		private var arcPoint:Point;
		private var cx:Number;//center x,y
		private var cy:Number;
		private var radius:Number;
		private var targetAngle:Number;
		private var curAngle:Number;
		private var speed:Number;
		
		private var px:Number;
		private var py:Number;
		private var branchable:Boolean; //if true the drawing can randomly branch
		private var stopOnBranch:Boolean;//if true stops drawing after dispatching a BRANCH event
		private var thickness:Number;//current pen thickness
		private var curColor:Number = 0x000000;
		private var branchChance:Number; //0.0 - 1.0 the chance a branch will form - ie dispatch "branchOut" event
		
		private var vary:Number;
		private var lastPoint:Point;
		
		public function Limb($arcPoint:Point, $thickness:Number = 6, $minRadius:Number = 5, 
							$maxRadius:Number = 650, $branchable:Boolean = true, $stopOnBranch:Boolean = false, 
							$curColor:Number = 0x000000, $branchChance:Number = .1 )
		{
			/*
			 * 		t = current angle 0 - 2PI
			 * 
			 * 		point on circle arc
			 *     	x = a + r cos t 
			 *		y = b + r sin t
			 * 
			 * 		center from point on arc
			 * 		a = x - r cos t
			 * 		b = y - r sin t
			 */
			
			arcPoint = $arcPoint;
			branchable = $branchable;
			stopOnBranch = $stopOnBranch;
			thickness = $thickness;
			curColor = $curColor;
			branchChance = $branchChance;
			
			radius = $minRadius + (Math.random() * ($maxRadius - $minRadius));
			
			cx = arcPoint.x - radius * Math.cos(Math.PI / 4); //45 deg
			cy = arcPoint.y - radius * Math.sin(Math.PI / 4);						
			
			curAngle = Math.PI / 4;//start at 45 to match calculated center
			targetAngle = curAngle + ( 1 + Math.random() * 2.5);
			
			speed = .05;
			graphics.lineStyle(thickness, curColor);
			graphics.moveTo(arcPoint.x, arcPoint.y);
			lastPoint = new Point(arcPoint.x, arcPoint.y);
			addEventListener(Event.ENTER_FRAME, draw);
		}
		
		
		public function getArcPoint():Point
		{
			return new Point(px, py);
		}
		
		
		public function getLineSize():Number
		{
			return thickness;
		}
		
		
		public function getColor():Number
		{
			return curColor;
		}
		
		
		private function draw(e:Event):void
		{			
			curAngle += speed;
			if (curAngle < targetAngle) {
				
				//vary the radius
				if(Math.random() < .5){
					vary = radius - Math.random();
				}else {
					vary = radius + Math.random();
				}
				
				px = cx + vary * Math.cos(curAngle);				
				py = cy + vary * Math.sin(curAngle);
				
				//get center between last point and new point to use as control
				//handle point for curveTo function
				var hx:Number;
				var hy:Number;
				if (px > lastPoint.x) {
					hx = lastPoint.x + ((px - lastPoint.x) * .5);
				}else {
					hx = lastPoint.x - ((lastPoint.x - px) * .5);
				}
				if (py > lastPoint.y) {
					hy = lastPoint.y + ((py - lastPoint.y) * .5);
				}else {
					hy = lastPoint.y - ((lastPoint.y - py) * .5);
				}
				
				graphics.curveTo(hx, hy, px, py);
				lastPoint = new Point(px, py);
				
				if (Math.random() < .1) {
					//decrement the line size
					thickness--;
					curColor += 0x111111;
					if (thickness <= 0) {
						removeEventListener(Event.ENTER_FRAME, draw);
						dispatchEvent(new Event("finished"));
					}
					graphics.lineStyle(thickness, curColor);					
				}
				
				if(branchable){
					if (Math.random() <= branchChance) {
						//branch
						dispatchEvent(new Event(BRANCH));
						if(stopOnBranch){
							//stop drawing at branch...
							removeEventListener(Event.ENTER_FRAME, draw);
						}
					}
				}
				
			}else{
				//curAngle >= targetAngle
				removeEventListener(Event.ENTER_FRAME, draw);
				dispatchEvent(new Event("finished"));
			}
		}
	}
	
}