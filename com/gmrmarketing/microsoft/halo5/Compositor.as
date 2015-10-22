package com.gmrmarketing.microsoft.halo5
{
	import flash.events.*;
	import flash.display.*;
	import flash.utils.getTimer;
	import flash.geom.Matrix;
	
	
	public class Compositor extends EventDispatcher
	{
		public static const EDIT_SPLINE:String = "editSpline";		
		public static const COMPLETE:String = "compositorComplete";		
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		private var facePic:Bitmap;	
		private var armor:MovieClip;
		
		private var controls:MovieClip;
		
		private var faceContainer:Sprite;//contains facePic - added to armor clip
		
		private var timeDelta:int;
		private const buttonDelay:int = 400;
		
		
		
		public function Compositor()
		{
			clip = new mcCompositor();			
			
			controls = new mcControls();
			controls.x = 1881;
			controls.y = 420;
			controls.alpha = .7;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(userImage:BitmapData, armorType:String):void
		{
			armor = null;
			//faceContainer added to armor
			if (faceContainer && facePic) {
				if (faceContainer.contains(facePic)) {
					faceContainer.removeChild(facePic);
				}
				facePic = null;
				faceContainer = null;
			}	
			faceContainer = new Sprite();
			
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
			}

			clip.visible = true;
			
			facePic = new Bitmap(userImage, "auto", true);
			
			switch(armorType) {
				case "b1":
					armor = new b1();
					break;
				case "b2":
					armor = new b2();
					break;
				case "r1":
					armor = new r1();
					break;
				case "r2":
					armor = new r2();
					break;
			}
			
			faceContainer.addChild(facePic);
			facePic.x = -(facePic.width * .5);
			facePic.y = -(facePic.height * .5);
			
			armor.addChildAt(faceContainer, 1);
			faceContainer.x = 1040;
			faceContainer.y = 480;
			faceContainer.scaleX = faceContainer.scaleY = .72;
			clip.addChild(armor);
			clip.addChild(controls);
			
			controls.rotLeft.addEventListener(MouseEvent.MOUSE_DOWN, rotateLeft, false, 0, true);
			controls.rotRight.addEventListener(MouseEvent.MOUSE_DOWN, rotateRight, false, 0, true);
			controls.scaleMinus.addEventListener(MouseEvent.MOUSE_DOWN, scaleMinus, false, 0, true);
			controls.scalePlus.addEventListener(MouseEvent.MOUSE_DOWN, scalePlus, false, 0, true);
			controls.moveUp.addEventListener(MouseEvent.MOUSE_DOWN, moveUp, false, 0, true);
			controls.moveLeft.addEventListener(MouseEvent.MOUSE_DOWN, moveLeft, false, 0, true);
			controls.moveRight.addEventListener(MouseEvent.MOUSE_DOWN, moveRight, false, 0, true);
			controls.moveDown.addEventListener(MouseEvent.MOUSE_DOWN, moveDown, false, 0, true);
			controls.btnSpline.addEventListener(MouseEvent.MOUSE_DOWN, editSpline, false, 0, true);
			controls.btnMirror.addEventListener(MouseEvent.MOUSE_DOWN, mirror, false, 0, true);
			controls.btnFinish.addEventListener(MouseEvent.MOUSE_DOWN, editComplete, false, 0, true);
			myContainer.stage.addEventListener(MouseEvent.MOUSE_UP, endAutoButton, false, 0, true);
		}
		
		
		public function hide():void
		{
			controls.rotLeft.removeEventListener(MouseEvent.MOUSE_DOWN, rotateLeft);
			controls.rotRight.removeEventListener(MouseEvent.MOUSE_DOWN, rotateRight);
			controls.scaleMinus.removeEventListener(MouseEvent.MOUSE_DOWN, scaleMinus);
			controls.scalePlus.removeEventListener(MouseEvent.MOUSE_DOWN, scalePlus);
			controls.moveUp.removeEventListener(MouseEvent.MOUSE_DOWN, moveUp);
			controls.moveLeft.removeEventListener(MouseEvent.MOUSE_DOWN, moveLeft);
			controls.moveRight.removeEventListener(MouseEvent.MOUSE_DOWN, moveRight);
			controls.moveDown.removeEventListener(MouseEvent.MOUSE_DOWN, moveDown);
			controls.btnSpline.removeEventListener(MouseEvent.MOUSE_DOWN, editSpline);
			controls.btnMirror.removeEventListener(MouseEvent.MOUSE_DOWN, mirror);
			controls.btnFinish.removeEventListener(MouseEvent.MOUSE_DOWN, editComplete);
			myContainer.stage.removeEventListener(MouseEvent.MOUSE_UP, endAutoButton);
			
			endAutoButton();
			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}			
			
			if(armor){
				if (clip.contains(armor)) {
					clip.removeChild(armor);
				}				
			}
			if (clip.contains(controls)) {
				clip.removeChild(controls);	
			}
					
		}
		
		
		public function suspend():void
		{
			clip.visible = false;
		}
		
		public function wake(userImage:BitmapData):void
		{
			clip.visible = true;
			facePic.bitmapData = userImage;
		}
		
		private function rotateLeft(e:MouseEvent):void
		{	
			faceContainer.rotation -= 1;
			timeDelta = getTimer() + buttonDelay;
			myContainer.addEventListener(Event.ENTER_FRAME, autoRotLeft, false, 0, true);
		}
		
		private function rotateRight(e:MouseEvent):void
		{
			faceContainer.rotation += 1;
			timeDelta = getTimer() + buttonDelay;
			myContainer.addEventListener(Event.ENTER_FRAME, autoRotRight, false, 0, true);
		}
		
		private function scaleMinus(e:MouseEvent):void
		{
			var a:Number = faceContainer.scaleX;
			faceContainer.scaleX = faceContainer.scaleY = a - .01;
			timeDelta = getTimer() + buttonDelay;
			myContainer.addEventListener(Event.ENTER_FRAME, autoScaleMinus, false, 0, true);
		}
		
		private function scalePlus(e:MouseEvent):void
		{
			var a:Number = faceContainer.scaleX;
			faceContainer.scaleX = faceContainer.scaleY = a + .01;
			timeDelta = getTimer() + buttonDelay;
			myContainer.addEventListener(Event.ENTER_FRAME, autoScalePlus, false, 0, true);
		}
		
		private function moveUp(e:MouseEvent):void
		{
			faceContainer.y -= 1;
			timeDelta = getTimer() + buttonDelay;
			myContainer.addEventListener(Event.ENTER_FRAME, autoUp, false, 0, true);
		}
		
		private function moveLeft(e:MouseEvent):void
		{
			faceContainer.x -= 1;
			timeDelta = getTimer() + buttonDelay;
			myContainer.addEventListener(Event.ENTER_FRAME, autoLeft, false, 0, true);
		}
		
		private function moveRight(e:MouseEvent):void
		{
			faceContainer.x += 1;
			timeDelta = getTimer() + buttonDelay;
			myContainer.addEventListener(Event.ENTER_FRAME, autoRight, false, 0, true);
		}
		
		private function moveDown(e:MouseEvent):void
		{
			faceContainer.y += 1;
			timeDelta = getTimer() + buttonDelay;
			myContainer.addEventListener(Event.ENTER_FRAME, autoDown, false, 0, true);
		}
		
		
		//AUTO
		private function autoRotLeft(e:Event):void
		{
			if (getTimer() > timeDelta) {
				faceContainer.rotation -= 1;
			}
		}
		
		private function autoRotRight(e:Event):void
		{
			if (getTimer() > timeDelta) {
				faceContainer.rotation += 1;
			}
		}
		
		private function autoScaleMinus(e:Event):void
		{
			if (getTimer() > timeDelta) {
				var a:Number = faceContainer.scaleX;
				faceContainer.scaleX = faceContainer.scaleY = a - .01;
			}
		}
		
		private function autoScalePlus(e:Event):void
		{
			if (getTimer() > timeDelta) {
				var a:Number = faceContainer.scaleX;
				faceContainer.scaleX = faceContainer.scaleY = a + .01;
			}
		}
		
		private function autoUp(e:Event):void
		{
			if (getTimer() > timeDelta) {
				faceContainer.y -= 1;
			}
		}
		
		private function autoLeft(e:Event):void
		{
			if (getTimer() > timeDelta) {
				faceContainer.x -= 1;
			}
		}
		
		private function autoRight(e:Event):void
		{
			if (getTimer() > timeDelta) {
				faceContainer.x += 1;
			}
		}
		
		private function autoDown(e:Event):void
		{
			if (getTimer() > timeDelta) {
				faceContainer.y += 1;
			}
		}
		
		private function endAutoButton(e:MouseEvent = null):void
		{
			myContainer.removeEventListener(Event.ENTER_FRAME, autoRotLeft);
			myContainer.removeEventListener(Event.ENTER_FRAME, autoRotRight);
			myContainer.removeEventListener(Event.ENTER_FRAME, autoScaleMinus);
			myContainer.removeEventListener(Event.ENTER_FRAME, autoScalePlus);
			myContainer.removeEventListener(Event.ENTER_FRAME, autoUp);
			myContainer.removeEventListener(Event.ENTER_FRAME, autoLeft);
			myContainer.removeEventListener(Event.ENTER_FRAME, autoRight);
			myContainer.removeEventListener(Event.ENTER_FRAME, autoDown);
		}
		
		
		private function editSpline(e:MouseEvent):void
		{
			dispatchEvent(new Event(EDIT_SPLINE));
		}
		
		
		private function mirror(e:MouseEvent):void
		{
			var flipped:BitmapData = new BitmapData(facePic.width, facePic.height, true, 0x00000000);
			var matrix:Matrix = new Matrix( -1, 0, 0, 1, facePic.width, 0);
			flipped.draw(facePic.bitmapData, matrix, null, null, null, true);
			facePic.bitmapData = flipped;
		}
		
		
		private function editComplete(e:Event):void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		public function get image():BitmapData
		{
			var a:BitmapData = new BitmapData(armor.width, armor.height, true, 0x00000000);
			a.draw(armor, null, null, null, null, true);
			return a;
		}
	}
	
}