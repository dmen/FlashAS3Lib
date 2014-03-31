package com.gmrmarketing.nissan.rodale
{
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.XMLLoader;
	import flash.utils.getDefinitionByName;
	import com.gmrmarketing.nissan.rodale.Bullet;
	import com.gmrmarketing.utilities.ScreenSaverHelper;
	
	
	public class Main extends MovieClip
	{
		private var clip:MovieClip;
		private var lastMousePos:int;
		private var mouseDelta:int;
		private var xmlLoader:XMLLoader;
		private var xml:XML;
		//private var ss:Scr
		
		
		public function Main()
		{
			showVehicle("armada");
		}
		
		
		private function showVehicle(which:String):void
		{
			var theCar:String = which;			
			
			switch(theCar) {
				case "armada":
					clip = new armada();
					clip.stop();
					addChild(clip);
					break;
			}
			
			listen();
		}
		
		
		private function listen():void
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, gestureStart, false, 0, true);
		}
		
		
		private function gestureStart(e:MouseEvent):void
		{
			TweenMax.killAll();
			lastMousePos = mouseX;
			addEventListener(Event.ENTER_FRAME, gestureMid, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, gestureEnd, false, 0, true);
		}
		
		
		/**
		 * Called on ENTER_FRAME while swiping
		 * @param	e
		 */
		private function gestureMid(e:Event):void
		{
			mouseDelta = mouseX - lastMousePos;
			lastMousePos = mouseX;
			if (mouseDelta > 3) {
				if (clip.currentFrame == clip.totalFrames) {
					clip.gotoAndStop(1);
				}else{
					clip.nextFrame();
				}
			}else if (mouseDelta < -3) {
				if (clip.currentFrame == 1) {
					clip.gotoAndStop(clip.totalFrames);
				}else{
					clip.prevFrame();
				}
			}
		}
		
		
		private function gestureEnd(e:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, gestureMid);
			stage.removeEventListener(MouseEvent.MOUSE_UP, gestureEnd);
			TweenMax.to(clip, Math.abs(mouseDelta / 45), { frame:Math.round(clip.currentFrame + mouseDelta / 2)} );
		}
		
	}
	
}