package com.gmrmarketing.comcast.flex
{
	import com.adobe.utils.IntUtil;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	import com.greensock.easing.*;
	import flash.filters.*;

	public class HairDraw
	{
		private var pa:Point;
		private var pb:Point;
		private var pc:Point;
		private var pd:Point;
		private var pe:Point;
		private var count:int;
		private var container:DisplayObjectContainer;
		private var pen:Sprite;
		private var strands:Array;
		private var colors:Array;
		private var colorCount:int;
		private var curBlur:int;
		//private var mousePoints:Array;
		private var strandCount:int;
		private var lastTime:Number;
		private var curStrand:Sprite;
		private var frameCount:int;
		private var xBuffer:int;
		private var yBuffer:int;
		private var isDrawing:Boolean = true;
		
		private var stageColumn:Number;
		private var drawRect:Rectangle;
		
		private var initNumChildren:int;
		
		private var glow:GlowFilter;
		
		
		public function HairDraw($container:DisplayObjectContainer, xPad:int = 150, yPad:int = 100)
		{
			container = $container;
			
			initNumChildren = container.numChildren; //bg(0) & logo(1) - 2 children
			
			xBuffer = xPad;
			yBuffer = yPad;
			
			TweenPlugin.activate([BezierThroughPlugin]);
			frameCount = 0;
			strands = new Array();
			strandCount = 1;
			colors = new Array(0xff0000, 0x0000ff);
			colorCount = 0;
			curBlur = 0;			
			pen = new Sprite();			
			
			count = 0;			
			container.addChild(pen); //pen at index 2 - 3 children
			drawRect = new Rectangle(0, 0, container.width, container.height);
			stageColumn = drawRect.width / 5;
		}
		
		public function turnOn():void
		{
			isDrawing = true;			
			container.addEventListener(Event.ENTER_FRAME, erase);
			drawHair();
		}
		
		public function turnOff():void
		{
			isDrawing = false;
			TweenLite.killTweensOf(pen);
			container.removeEventListener(Event.ENTER_FRAME, erase);
			
			//empty container except for logo,bg and pen
			while(container.numChildren > 3){				
				var c = container.getChildAt(container.numChildren - 3); //oldest strand - sprite onject
				c.graphics.clear();
				c.filters = [];
				container.removeChild(c);
				c = null;
			}
		}
		
		public function updateRect(r:Rectangle)
		{			
			drawRect = r;
			stageColumn = r.width / 5;
		}
		
		private function erase(e:Event)
		{	
			frameCount++;
			if(frameCount == 3){
				var p:int = container.numChildren; //3 with no strands
				for (var i:int = 1; i < p - 1; i++) {
					container.getChildAt(i).alpha -= .1 / (i*100000);
				}				
				if(p > initNumChildren){				
					var c = container.getChildAt(p - 3); //oldest strand - sprite onject				
					
					if (c.alpha  <= 0) {
						
						c.graphics.clear();
						c.filters = [];
						container.removeChild(c);
						c = null;
					}
				}
				frameCount = 0;
			}
		}
		
		private function drawHair()
		{	
			if(isDrawing){
				var s:Sprite = new Sprite();
				curStrand = s;				
				container.addChildAt(s,1);	//bg is at 0 //logo at 1 - so this puts it behind the logo			
				s.graphics.lineStyle(1, 0xffffff, 1);// colors[colorCount], 1);
				glow = new GlowFilter(colors[colorCount], 1, 12, 12, 14, 2, false, false);
				s.filters = [glow];
				colorCount++;
				if (colorCount == colors.length) { colorCount = 0; }
				
				pa = new Point(-20, yBuffer + Math.random() * drawRect.height);
				pb = new Point(xBuffer + stageColumn + Math.random() * stageColumn, yBuffer + Math.random() * (drawRect.height * .5));
				pc = new Point(xBuffer + (stageColumn * 2) + Math.random() * stageColumn, yBuffer + Math.random() * (drawRect.height * .5));			
				pd = new Point(xBuffer + (stageColumn * 3) + Math.random() * stageColumn, yBuffer + Math.random() * (drawRect.height * .5));			
				pe = new Point(xBuffer + drawRect.width + 20, yBuffer + Math.random() * drawRect.height);	
				
				s.graphics.moveTo(pa.x, pa.y);
				pen.x = pa.x; pen.y = pa.y;	
				
				TweenLite.to(pen, 8, { bezierThrough:[ { x:pa.x, y:pa.y }, { x:pb.x, y:pb.y }, { x:pc.x, y:pc.y }, { x:pd.x, y:pd.y }, { x:pe.x, y:pe.y } ], onUpdate:doDraw, onComplete:drawHair, ease:Linear.easeNone } );		
			}
		}
		
		private function doDraw() 
		{			
			curStrand.graphics.lineTo(pen.x, pen.y);			
		}		
	}	
}