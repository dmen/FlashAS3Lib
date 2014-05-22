package com.gmrmarketing.reeses.scratchgame
{	
	import flash.display.*;
	import flash.events.*;	
	import com.greensock.TweenLite;
	import flash.text.TextField;
	import flash.net.SharedObject;
	
	public class Admin_NewAdmin extends EventDispatcher
	{
		public static const ADMIN_CLOSED:String = "adminClosed";
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;		
		private var so:SharedObject;
		private var thePercent:int;
		
		
		public function Admin_NewAdmin()
		{
			clip = new adminClip(); //lib clip
			
			so = SharedObject.getLocal("reesesData");
			
			if (so.data.percent == null) {
				clip.percent.text = 50;
				so.data.percent = 50;
				so.flush();
			}
		}
		
		
		public function getPercent():int
		{
			return so.data.percent;
		}
		

		public function show($container:DisplayObjectContainer):void
		{		
			container = $container;
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.theAlert.text = "";
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeClicked, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, saveClicked, false, 0, true);
			clip.percent.text = String(getPercent());
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}			
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeClicked);	
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, saveClicked);
		}		


		private function saveClicked(e:MouseEvent):void
		{
			so.data.percent = parseInt(clip.percent.text);
			so.flush();
			clip.theAlert.text = "Saved...";			
		}
		
		
		private function closeClicked(e:MouseEvent = null):void
		{
			dispatchEvent(new Event(ADMIN_CLOSED));
		}
		
	}
	
}