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
				so.data.bri = 60;
				so.data.con = 20;
				so.data.sat = 30;
				so.flush();
			}
			
			tClip.theText.text = String(so.data.city).toUpperCase();
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
			clip.bri.text = int(so.data.bri).toString();
			clip.con.text = int(so.data.con).toString();
			clip.sat.text = int(so.data.sat).toString();
		}
		
		
		public function get cityImage():BitmapData
		{
			var b:BitmapData = new BitmapData(430, 60, true, 0x00000000);
			b.draw(tClip);
			
			return b;
		}
		
		
		public function getColorValues():Array
		{
			return [so.data.bri, so.data.con, so.data.sat];
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
			so.data.bri = parseInt(clip.bri.text);
			so.data.con = parseInt(clip.con.text);
			so.data.sat = parseInt(clip.sat.text);
			so.flush();
			
			tClip.theText.text = String(so.data.city).toUpperCase();
		}
		
	}
	
}