package com.gmrmarketing.wrigley.gumergency
{
	import com.greensock.TweenMax;
	import flash.display.*;
	import flash.events.Event;
	
	
	public class BreathLine
	{
		private const screenWidth:int = 1920;
		private const baseLineY:int = 650;
		
		private var varyY;		
		private var container:Sprite;
		private var anchorPoints:Array;
		private var color:Number;	
		private var numPoints:int;
		private var waitingToAnalyze:Boolean;
		private var breathConLevel:int;
		
		
		public function BreathLine()
		{			
			numPoints = 10 + Math.round(Math.random() * 10);
			breathConLevel = 5;
			waitingToAnalyze = true;
			createAnchors(waitingToAnalyze);			
		}
		
		
		//values between ~3 - ~15
		public function setLevel(l:int):void
		{
			breathConLevel = l;
		}
		
		
		private function createAnchors(waiting:Boolean = false):void
		{					
			var colWidth:int = screenWidth / numPoints;			
			var thisX:int;
			var thisY:int;
			var i:int;
			var delta:int;			
			
			if (waiting) {				
				anchorPoints = new Array();
				anchorPoints.push([-100, baseLineY]); //screen left anchor
				
				for (i = 0; i < numPoints; i++) {				
					thisX = i * colWidth;
					
					//above or below the baseline
					if (Math.random() < .5) {
						varyY *= -1;
					}				
					thisY = Math.round(baseLineY + (Math.random() * 12));					
					
					anchorPoints.push([thisX, thisY]);					
				}
				anchorPoints.push([screenWidth + 200, baseLineY]); //screen right anchor				
				
			}else {
				for (i = 0; i < anchorPoints.length; i++) {					
					delta = Math.round(Math.random() * breathConLevel);
					if (Math.random() < .5) {
						delta *= -1;
					}					
					if (Math.abs((anchorPoints[i][1] + delta) - baseLineY) < (breathConLevel * 10)) {						
						anchorPoints[i][1] = anchorPoints[i][1] + delta;						
					}					
				}
			}			
		}
		
		
		public function init($container:Sprite, $color:Number):void
		{
			container = $container;
			color = $color;
			
		}
		
		
		public function startDrawing():void
		{
			breathConLevel = 5;
			container.stage.addEventListener(Event.ENTER_FRAME, draw, false, 0, true);
		}
		
		
		public function analyze():void
		{
			waitingToAnalyze = false;
		}
		
		
		public function stop():void
		{
			waitingToAnalyze = true;
			container.stage.removeEventListener(Event.ENTER_FRAME, draw);
		}
		
		
		/**
		 * Bisects the lines between each anchor to form new anchors - original anchors are then 
		 * used as the control points for curveTo
		 * @param	e
		 */
		private function draw(e:Event):void
		{	
			container.graphics.clear();
			container.graphics.lineStyle(3, color);
			
			for (var i:int = 2; i < anchorPoints.length; i++) {				
				
				var a2x:int = Math.round(anchorPoints[i - 1][0] + ((anchorPoints[i][0] - anchorPoints[i - 1][0]) * .5));
				var a2y:int = Math.round(anchorPoints[i - 1][1] + ((anchorPoints[i][1] - anchorPoints[i - 1][1]) * .5));
				
				var a1x:int = Math.round(anchorPoints[i - 2][0] + ((anchorPoints[i - 1][0] - anchorPoints[i - 2][0]) * .5));
				var a1y:int = Math.round(anchorPoints[i - 2][1] + ((anchorPoints[i - 1][1] - anchorPoints[i - 2][1]) * .5));				
				
				var cx = anchorPoints[i - 1][0];
				var cy = anchorPoints[i - 1][1];
				
				container.graphics.moveTo(a1x, a1y);
				container.graphics.curveTo(cx, cy, a2x, a2y);				
			}
			createAnchors(waitingToAnalyze);
		}
	}
	
}