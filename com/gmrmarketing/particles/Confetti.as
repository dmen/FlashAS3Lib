package com.gmrmarketing.particles
{	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;

	public class Confetti extends Sprite
	{
		private var mySize:int;
		private var myRotation:Number;
		private var mySpeed:Number;
		private var myRadius:int;
		private var myAngle:Number = 0;
		private var stHeight:int;
		private var stWidth:int;
		private var myFrequency:Number;
		private var myColors:Array;
		private var baseSpeed:int;
		private var amplitude:int;
		
		public function Confetti(colors:Array, w:int, h:int, $x:int, $y:int, bs:int, amp:int)
		{			
			stWidth = w;
			stHeight = h;
			myColors = colors;
			baseSpeed = bs;
			amplitude = amp;
			init($x, $y);
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		
		private function init($x = 0, $y = 0):void
		{
			mySize = Math.round(4 + Math.random() * 10);
			graphics.clear();
			var colorSet:Array = myColors[Math.floor(Math.random() * myColors.length)];			
			var alpha:Number = .23 + Math.random() / 1.3;
			var matr:Matrix = new Matrix();
			matr.createGradientBox(mySize, mySize);
			graphics.beginGradientFill(GradientType.LINEAR, [colorSet[0], colorSet[1]], [alpha, alpha],[0,255],matr);
			
			graphics.drawRect(0, 0, mySize, mySize);
			
			x = $x == 0 ? Math.random() * stWidth : $x;			
			y = $y == 0 ? -mySize - 10 : $y;
			
			myRotation = Math.random();
			myFrequency = Math.random() / 5;
			mySpeed = baseSpeed + 3 * Math.random();
			myRadius = Math.ceil(amplitude + Math.random());
		}
		
		
		private function update(e:Event):void
		{
			y += mySpeed;
			if (y > stHeight + mySize + 10) {
				init();
			}
			rotationZ += myRotation;
			rotationY += myRotation;
			myAngle += myFrequency;
			if (myAngle > 6.28) { myAngle = 0; }
			x += myRadius * Math.cos(myAngle);
		}
		
	}
	
}