package com.gmrmarketing.testing
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.MovieClip;
	import flash.events.*;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Wheel extends MovieClip
	{
		private var offset:Number;
		private var initAngle:Number;
		private var rotationDirection:int;
		
		private var carAngle:int;
		private var oneAngles:Array;
		private var threeAngles:Array;
		
		private var prizes:Array;
		private var prizeIndex:int;
		
		public function Wheel()
		{
			//stopping angles for each slice
			carAngle = 720;
			oneAngles = new Array(756, 828, 900, 972, 1044);
			threeAngles = new Array(792, 864, 936, 1008);			
			
			//802 $1000, 10 $3000, 1 car
			prizes = new Array();
			for (var i:int = 0; i < 802; i++) {
				prizes.push(1000);
			}
			for (i = 0; i < 10; i++) {
				prizes.push(3000);
			}
			prizes.push(30000);
			prizes = Utility.randomizeArray(prizes);
			prizeIndex = 0;
			
			wheel.addEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);
			stage.addEventListener(MouseEvent.MOUSE_UP, endDragRotation);
		}


		private function startDragRotation(e:MouseEvent):void
		{	
			var position:Number = Math.atan2(mouseY - wheel.y, mouseX - wheel.x);	
			var angle:Number = (position / Math.PI) * 180;
			initAngle = wheel.rotation;
			offset = wheel.rotation - angle;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, updateDragRotation);	
		}


		private function updateDragRotation(e:Event):void
		{	
			var position:Number = Math.atan2(mouseY - wheel.y, mouseX - wheel.x);	
			wheel.rotation = (position / Math.PI) * 180 + offset;
		}

		
		private function endDragRotation(e:MouseEvent):void
		{		
			var dAngle:Number = wheel.rotation - initAngle;	
			var toAngle:int;
			
			var thisPrize:int = prizes[prizeIndex];
			prizeIndex++;
			
			if (thisPrize == 1000) {
				toAngle = getAngle(oneAngles);
			}else if (thisPrize == 3000) {
				toAngle = getAngle(threeAngles);
			}else {
				toAngle = carAngle;
			}	
			if (dAngle < 0) {
				toAngle *= -1;
			}			
			
			TweenMax.to(wheel, 7, {rotation:toAngle, ease:Elastic.easeOut});			
					
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateDragRotation);
			wheel.removeEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);				
			stage.removeEventListener(MouseEvent.MOUSE_UP, endDragRotation);			
		}		

		private function getAngle(angleArray:Array):int
		{
			return angleArray[Math.floor(Math.random() * angleArray.length)];
		}
	}	
}