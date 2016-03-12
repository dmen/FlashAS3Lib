package com.gmrmarketing.humana.gifbooth
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	
	public class ConfigDialog
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var so:SharedObject;
		private var totalFrames:int;
		
		
		public function ConfigDialog()
		{
			clip = new mcConfig();
			clip.x = 1326;
			clip.y = 0;
			
			so = SharedObject.getLocal("humanaGif");
			if (so.data.numSeconds == undefined) {
				so.data.numSeconds = 3;
				so.data.everyNth = 10;
				so.flush();
			}
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function get numSeconds():int
		{
			return so.data.numSeconds;
		}
		
		public function get everyNth():int
		{
			return so.data.everyNth;
		}
		
		public function get maxFrames():int
		{
			totalFrames = Math.round((30 / everyNth) * numSeconds);	
			return totalFrames;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.nSeconds.restrict = "0-9";
			clip.nSeconds.maxChars = 2;
			clip.nthFrame.restrict = "0-9";
			clip.nthFrame.maxChars = 2;
			
			clip.nSeconds.text = String(so.data.numSeconds);
			clip.nthFrame.text = String(so.data.everyNth);
			
			clip.nSeconds.addEventListener(Event.CHANGE, updateDialog, false, 0, true);
			clip.nthFrame.addEventListener(Event.CHANGE, updateDialog, false, 0, true);
			
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, doClose, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, doSave, false, 0, true);
			
			updateDialog();
		}
		
		
		private function doClose(e:MouseEvent = null):void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, doClose);
			clip.nSeconds.removeEventListener(Event.CHANGE, updateDialog);
			clip.nthFrame.removeEventListener(Event.CHANGE, updateDialog);
			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
		}
		
		
		private function doSave(e:MouseEvent):void
		{
			so.data.numSeconds = parseInt(clip.nSeconds.text);
			so.data.everyNth = parseInt(clip.nthFrame.text);
			so.flush();
			
			doClose();
		}
		
		
		private function updateDialog(e:Event = null):void
		{
			totalFrames = Math.round((30 / parseInt(clip.nthFrame.text)) * parseInt(clip.nSeconds.text));				
			clip.numFrames.text = "Capturing " + totalFrames + " frames";
		}
		
	}
	
}