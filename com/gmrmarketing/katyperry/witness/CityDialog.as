package com.gmrmarketing.katyperry.witness
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	
	public class CityDialog extends EventDispatcher
	{
		public static const COMPLETE:String = "cityDialogComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var theCity:String;
		private var so:SharedObject;
		private var tClip:MovieClip;//cityText clip from the library
		
		
		public function CityDialog()
		{
			clip = new cityDialog();
			tClip = new cityText();
			
			so = SharedObject.getLocal("KPCityData");
			if (so.data.city == null){
				so.data.city = "";
				so.flush();
			}
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeDialog, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, saveCity, false, 0, true);
			
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			clip.x = 50;
			clip.y = 50;
			
			clip.theText.text = so.data.city;
		}
		
		
		public function get cityImage():BitmapData
		{
			var b:BitmapData = new BitmapData(750, 120, true, 0x00000000);
			b.draw(tClip);
			
			return b;
		}
		
		
		private function closeDialog(e:MouseEvent):void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeDialog);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, saveCity);
			
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function saveCity(e:MouseEvent):void
		{
			so.data.city = clip.theText.text;
			so.flush();
			
			tClip.theText.text = so.data.city;
		}
		
	}
	
}