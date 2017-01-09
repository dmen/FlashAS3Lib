package com.gmrmarketing.goldenOne.cheerBooth2016
{
	import flash.events.*;
	import flash.display.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import flash.net.SharedObject;
	
	
	public class Config extends EventDispatcher 
	{
		public static const COMPLETE:String = "configSaved";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var kbd:KeyBoard;
		
		private var so:SharedObject;
		private var configData:Object;
		
		
		public function Config()
		{
			clip = new mcConfig();
			
			so = SharedObject.getLocal("goldenoneconfig");
			configData = so.data.config;
			if (configData == null){
				configData = {};
				configData.mode = "video";
				configData.event = "testing";
			}
			
			kbd = new KeyBoard();
			kbd.loadKeyFile("keyboard2.xml");
			kbd.x = 230;
			kbd.y = 400;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			if (!myContainer.contains(kbd)){
				myContainer.addChild(kbd);
			}
			
			kbd.setFocusFields([[clip.event, 0]]);
			kbd.enableKeyboard();
			
			clip.event.text = configData.event;
			if (configData.mode == "video"){
				clip.btnVideo.check.gotoAndStop(2);
				clip.btnPhoto.check.gotoAndStop(1);
			}else{
				clip.btnVideo.check.gotoAndStop(1);
				clip.btnPhoto.check.gotoAndStop(2);
			}
			
			clip.btnVideo.addEventListener(MouseEvent.MOUSE_DOWN, vidToggle, false, 0, true);
			clip.btnPhoto.addEventListener(MouseEvent.MOUSE_DOWN, photoToggle, false, 0, true);
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeConfig, false, 0, true);
			kbd.addEventListener(KeyBoard.SUBMIT, saveConfig, false, 0, true);
		}
		
		
		/**
		 * returns video or photo
		 */
		public function get mode():String
		{
			return configData.mode;
		}
		
		
		/**
		 * returns the current event, or testing of it hasn't been set
		 */
		public function get event():String
		{
			return configData.event;
		}
		
		
		private function vidToggle(e:MouseEvent):void
		{			
			clip.btnVideo.check.gotoAndStop(2);
			clip.btnPhoto.check.gotoAndStop(1);			
		}
		
		
		private function photoToggle(e:MouseEvent):void
		{
			clip.btnVideo.check.gotoAndStop(1);
			clip.btnPhoto.check.gotoAndStop(2);	
		}
		
		
		/**
		 * called by pressing Submit on keyboard
		 * @param	e
		 */
		private function saveConfig(e:Event):void
		{
			configData.event = clip.event.text;
			if (clip.btnVideo.check.currentFrame == 2){
				configData.mode = "video";
			}else{
				configData.mode = "photo";
			}
			so.data.config = configData;
			so.flush();
			
			closeConfig();			
		}
		
		
		/**
		 * called from Save or by pressing close button in dialog
		 * @param	e
		 */
		private function closeConfig(e:MouseEvent = null):void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			if (myContainer.contains(kbd)){
				myContainer.removeChild(kbd);
			}
			kbd.disableKeyboard();
			clip.btnVideo.removeEventListener(MouseEvent.MOUSE_DOWN, vidToggle);
			clip.btnPhoto.removeEventListener(MouseEvent.MOUSE_DOWN, photoToggle);
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeConfig);
			kbd.removeEventListener(KeyBoard.SUBMIT, saveConfig);
			
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}