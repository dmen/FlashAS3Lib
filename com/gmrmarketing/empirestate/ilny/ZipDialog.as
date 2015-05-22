package com.gmrmarketing.empirestate.ilny
{
	import flash.events.*;
	import flash.display.*;
	import flash.geom.Point;
	
	
	public class ZipDialog extends EventDispatcher
	{
		public static const CANCEL:String = "zipCancel";
		public static const OK:String = "zipOK";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var zips:Zips;
		
		public function ZipDialog()
		{
			clip = new mcZip();
			clip.x = 1230;
			clip.y = 90;
			
			zips = new Zips();//call getZip("55555") to get x,y
		}
		
		
		public function getPosition():Point
		{
			return zips.getZip(clip.theText.text);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.btn7.addEventListener(MouseEvent.MOUSE_DOWN, c7);
			clip.btn8.addEventListener(MouseEvent.MOUSE_DOWN, c8);
			clip.btn9.addEventListener(MouseEvent.MOUSE_DOWN, c9);
			clip.btn4.addEventListener(MouseEvent.MOUSE_DOWN, c4);
			clip.btn5.addEventListener(MouseEvent.MOUSE_DOWN, c5);
			clip.btn6.addEventListener(MouseEvent.MOUSE_DOWN, c6);
			clip.btn1.addEventListener(MouseEvent.MOUSE_DOWN, c1);
			clip.btn2.addEventListener(MouseEvent.MOUSE_DOWN, c2);
			clip.btn3.addEventListener(MouseEvent.MOUSE_DOWN, c3);
			clip.btn0.addEventListener(MouseEvent.MOUSE_DOWN, c0);
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, cBack);
			
			clip.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, doCancel);
			clip.btnOK.addEventListener(MouseEvent.MOUSE_DOWN, doOK);
		}
		
		public function hide():void
		{
			removeListeners();
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		private function removeListeners():void
		{
			clip.btn7.removeEventListener(MouseEvent.MOUSE_DOWN, c7);
			clip.btn8.removeEventListener(MouseEvent.MOUSE_DOWN, c8);
			clip.btn9.removeEventListener(MouseEvent.MOUSE_DOWN, c9);
			clip.btn4.removeEventListener(MouseEvent.MOUSE_DOWN, c4);
			clip.btn5.removeEventListener(MouseEvent.MOUSE_DOWN, c5);
			clip.btn6.removeEventListener(MouseEvent.MOUSE_DOWN, c6);
			clip.btn1.removeEventListener(MouseEvent.MOUSE_DOWN, c1);
			clip.btn2.removeEventListener(MouseEvent.MOUSE_DOWN, c2);
			clip.btn3.removeEventListener(MouseEvent.MOUSE_DOWN, c3);
			clip.btn0.removeEventListener(MouseEvent.MOUSE_DOWN, c0);
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, cBack);
			
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, doCancel);
			clip.btnOK.removeEventListener(MouseEvent.MOUSE_DOWN, doOK);
		}
		
		private function c7(e:MouseEvent):void
		{
			clip.theText.appendText("7");
		}
		
		private function c8(e:MouseEvent):void
		{
			clip.theText.appendText("8");
		}
		
		private function c9(e:MouseEvent):void
		{
			clip.theText.appendText("9");
		}
		
		private function c4(e:MouseEvent):void
		{
			clip.theText.appendText("4");
		}
		
		private function c5(e:MouseEvent):void
		{
			clip.theText.appendText("5");
		}
		
		private function c6(e:MouseEvent):void
		{
			clip.theText.appendText("6");
		}
		
		private function c1(e:MouseEvent):void
		{
			clip.theText.appendText("1");
		}
		
		private function c2(e:MouseEvent):void
		{
			clip.theText.appendText("2");
		}
		
		private function c3(e:MouseEvent):void
		{
			clip.theText.appendText("3");
		}
		
		private function c0(e:MouseEvent):void
		{
			clip.theText.appendText("0");
		}
		
		private function cBack(e:MouseEvent):void
		{
			clip.theText.text = String(clip.theText.text).substr(0, String(clip.theText.text).length - 1);
		}
		
		private function doCancel(e:MouseEvent):void
		{
			dispatchEvent(new Event(CANCEL));
		}
		
		private function doOK(e:MouseEvent):void
		{			
			dispatchEvent(new Event(OK));
		}
		
		
		
	}
	
}