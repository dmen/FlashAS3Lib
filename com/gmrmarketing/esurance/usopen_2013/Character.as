package com.gmrmarketing.esurance.usopen_2013
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.utils.Timer;
	import com.greensock.TweenLite;
	
	
	public class Character extends EventDispatcher
	{
		private const SQSIZE:int = 300;//300 for kiosk - 150 for FB version
		
		private var container:DisplayObjectContainer;
		private var maskShape:Sprite;
		private var frameTimer:Timer;
		private var frameIndex:int;
		private var curFrame:Bitmap;
		private var frame1:BitmapData;
		private var frame2:BitmapData;
		private var frame3:BitmapData;
		private var myX:int;
		private var myY:int;
		private var ds:DropShadowFilter;
		
		
		public function Character(char:String)
		{
			switch(char) {
				case "a":
					frame1 = new a1();
					frame2 = new a2();
					frame3 = new a3();
					break;
				case "b":
					frame1 = new b1();
					frame2 = new b2();
					frame3 = new b3();
					break;
				case "c":
					frame1 = new c1();
					frame2 = new c2();
					frame3 = new c3();
					break;
				case "d":
					frame1 = new d1();
					frame2 = new d2();
					frame3 = new d3();
					break;
				case "e":
					frame1 = new e1();
					frame2 = new e2();
					frame3 = new e3();
					break;
				case "f":
					frame1 = new f1();
					frame2 = new f2();
					frame3 = new f3();
					break;
				case "g":
					frame1 = new g1();
					frame2 = new g2();
					frame3 = new g3();
					break;
				case "h":
					frame1 = new h1();
					frame2 = new h2();
					frame3 = new h3();
					break;
				case "i":
					frame1 = new i1();
					frame2 = new i2();
					frame3 = new i3();
					break;
				case "j":
					frame1 = new j1();
					frame2 = new j2();
					frame3 = new j3();
					break;
				case "k":
					frame1 = new k1();
					frame2 = new k2();
					frame3 = new k3();
					break;
				case "l":
					frame1 = new l1();
					frame2 = new l2();
					frame3 = new l3();
					break;
				case "m":
					frame1 = new m1();
					frame2 = new m2();
					frame3 = new m3();
					break;
				case "n":
					frame1 = new n1();
					frame2 = new n2();
					frame3 = new n3();
					break;
				case "o":
					var r:Number = Math.random();
					if(r < .33){
						frame1 = new o1();
					}else if (r < .66) {
						frame1 = new o1_2();
					}else {
						frame1 = new o1_3();
					}
					frame2 = new o2();
					frame3 = new o3();
					break;
				case "p":
					frame1 = new p1();
					frame2 = new p2();
					frame3 = new p3();
					break;
				case "q":
					frame1 = new q1();
					frame2 = new q2();
					frame3 = new q3();
					break;
				case "r":
					frame1 = new r1();
					frame2 = new r2();
					frame3 = new r3();
					break;
				case "s":
					frame1 = new s1();
					frame2 = new s2();
					frame3 = new s3();
					break;
				case "t":
					frame1 = new t1();
					frame2 = new t2();
					frame3 = new t3();
					break;
				case "u":
					frame1 = new u1();
					frame2 = new u2();
					frame3 = new u3();
					break;
				case "v":
					frame1 = new v1();
					frame2 = new v2();
					frame3 = new v3();
					break;
				case "w":
					frame1 = new w1();
					frame2 = new w2();
					frame3 = new w3();
					break;
				case "x":
					frame1 = new x1();
					frame2 = new x2();
					frame3 = new x3();
					break;
				case "y":
					frame1 = new y1();
					frame2 = new y2();
					frame3 = new y3();
					break;
				case "z":
					frame1 = new z1();
					frame2 = new z2();
					frame3 = new z3();
					break;
			}
			
			maskShape = new Sprite();
			maskShape.graphics.beginFill(0x00FF00, 1);
			maskShape.graphics.drawRect(0, 0, SQSIZE, SQSIZE);
			
			curFrame = new Bitmap(frame1);
			ds = new DropShadowFilter(0, 0, 0x000000, .8, 6, 6, 1, 2);
			curFrame.filters = [ds];
			frameIndex = 1;
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(x:int, y:int):void
		{
			myX = x;
			myY = y;
			
			if (!container.contains(curFrame)) {
				container.addChild(curFrame);
				container.addChild(maskShape);
			}
			curFrame.x = myX;
			curFrame.y = myY;
			curFrame.mask = maskShape;
			curFrame.mask.x = myX;
			curFrame.mask.y = myY;
			curFrame.bitmapData = frame1;			
		}
		
		
		public function pause():void
		{
			TweenLite.killTweensOf(curFrame, false);
			TweenLite.to(curFrame, .6, { x:myX, y:myY } );
		}
		
		
		public function play():void
		{
			nextFrame();
		}
		
		
		private function nextFrame():void
		{
			frameIndex++;
			if (frameIndex > 3) {
				frameIndex = 1;
			}
			switch(frameIndex) {
				case 1:
					curFrame.bitmapData = frame1;
					break;
				case 2:
					curFrame.bitmapData = frame2;
					break;
				case 3:
					curFrame.bitmapData = frame3;
					break;
			}
			var n:Number = Math.random();
			if(n < .25){
				curFrame.y = SQSIZE + myY;//from down
			}else if(n < .5){
				curFrame.y = myY - SQSIZE;//from up
			}else if (n < .75) {
				curFrame.x = SQSIZE + myX;//from right
			}else {
				curFrame.x = myX - SQSIZE;//from left
			}
			
			TweenLite.to(curFrame, .2 + Math.random() * .3, { y:myY, x:myX, onComplete:nextFrame } );
		}
	}
	
}