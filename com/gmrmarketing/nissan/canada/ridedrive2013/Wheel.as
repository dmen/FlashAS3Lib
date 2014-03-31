package com.gmrmarketing.nissan.canada.ridedrive2013
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	import flash.display.*;	
	import flash.events.*;
	
	
	
	public class Wheel extends EventDispatcher
	{
		public static const SPIN_COMPLETE:String = "stringComplete";
		public static const SPIN_SHOWING:String = "spinShowing";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var offset:Number;
		private var initAngle:Number;
		private var rotationDirection:int;
		
		private var carAngle:int;
		private var oneAngles:Array;
		private var threeAngles:Array;		
			
		private var thePrize:String;
		private var lang:String;
		
		
		public function Wheel()
		{
			clip = new mcWheel();
			
			//stopping angles for each slice
			carAngle = 720;
			oneAngles = new Array(756, 828, 900, 972, 1044);
			threeAngles = new Array(792, 864, 936, 1008);	
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		public function setLanguage($lang:String):void
		{
			lang = $lang;
			if (lang == "en") {
				clip.en.visible = 1;
				clip.fr.visible = 0;
			}else {
				clip.en.visible = 0;
				clip.fr.visible = 1;
			}
		}
		
		public function show(prize:String, carOnWheel:Boolean):void
		{			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}			
			thePrize = prize;
			clip.alpha = 0;
			clip.wheel.wheel.rotation = 0;
			if (carOnWheel) {
				if(lang == "en"){
					clip.wheel.wheel.gotoAndStop(1);
				}else {
					clip.wheel.wheel.gotoAndStop(3);
				}
			}else {
				if(lang == "en"){
					clip.wheel.wheel.gotoAndStop(2);
				}else {
					clip.wheel.wheel.gotoAndStop(4);
				}
			}
			TweenMax.to(clip, 1, { alpha:1, onComplete:addListeners } );
		}
		
		
		public function hide():void
		{
			clip.wheel.wheel.removeEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);
			container.stage.removeEventListener(MouseEvent.MOUSE_UP, endDragRotation);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function addListeners():void
		{
			dispatchEvent(new Event(SPIN_SHOWING));
			//clip.wheel.wheel.addEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);			
			clip.wheel.hit.addEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);			
		}
		

		private function startDragRotation(e:MouseEvent):void
		{	
			var position:Number = Math.atan2(container.stage.mouseY - clip.wheel.wheel.y, container.stage.mouseX - clip.wheel.wheel.x);	
			var angle:Number = (position / Math.PI) * 180;
			initAngle = clip.wheel.wheel.rotation;
			offset = clip.wheel.wheel.rotation - angle;
			container.stage.addEventListener(MouseEvent.MOUSE_MOVE, updateDragRotation);
			container.stage.addEventListener(MouseEvent.MOUSE_UP, endDragRotation);
		}


		private function updateDragRotation(e:Event):void
		{	
			var position:Number = Math.atan2(container.stage.mouseY - clip.wheel.wheel.y, container.stage.mouseX - clip.wheel.wheel.x);	
			clip.wheel.wheel.rotation = -1 * ((position / Math.PI) * 180 + offset);//WTF! *-1
		}

		
		private function endDragRotation(e:MouseEvent):void
		{		
			var dAngle:Number = clip.wheel.wheel.rotation - initAngle;	
			var toAngle:int;
			
			if (thePrize == "$1,000") {
				toAngle = getAngle(oneAngles);
			}else if (thePrize == "$3,000") {
				toAngle = getAngle(threeAngles);
			}else {
				toAngle = carAngle;
			}	
			
			toAngle += 720;
			
			if (dAngle < 0) {
				toAngle *= -1;
			}			
			
			
			TweenMax.to(clip.wheel.wheel, 7, {rotation:toAngle, onComplete:spinComplete});			
					
			container.stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateDragRotation);
			clip.wheel.hit.removeEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);				
			container.stage.removeEventListener(MouseEvent.MOUSE_UP, endDragRotation);			
		}		

		
		private function getAngle(angleArray:Array):int
		{
			return angleArray[Math.floor(Math.random() * angleArray.length)];
		}
		
		
		private function spinComplete():void
		{
			dispatchEvent(new Event(SPIN_COMPLETE));
		}
	}	
}