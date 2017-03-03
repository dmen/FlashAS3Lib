/**
 * Manages the kioskName
 * Defaults to "Info kiosk 1" if not yet set
 * call config.kioskName to get the name
 */

package com.gmrmarketing.stryker.mako2016
{
	import flash.net.*;
	import flash.display.*;
	import flash.events.*;

	
	public class Config extends EventDispatcher
	{
		public static const CONFIG_COMPLETE:String = "configDone";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		private var so:SharedObject;
		
		//this kiosks name/position on the map - set in config dialog
		private var myKioskName:String; //Info kiosk 1 - 8
		
		
		public function Config()
		{
			clip = new mcConfig();
			
			so = SharedObject.getLocal("strykerData");
			
			myKioskName = so.data.kioskName;
			if (myKioskName == null){
				myKioskName = "Info kiosk 1";//matches kiosk gate names in orchestrate		
			}
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * returns the kiosk name as the gate name - like "Info Kiosk 2"
		 */
		public function get kioskName():String
		{
			return myKioskName;
		}
		
		
		/**
		 * returns the kioskName as the login name that Kevin made
		 * ie Info Kiosk 2 returns as Kiosk2
		 */
		public function get loginName():String
		{
			return myKioskName.substr(5, 5) + myKioskName.substr(11, 1);
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			clip.x = 200;
			clip.y = 200;
			
			clip.combo.selectedIndex = parseInt(myKioskName.substr(11)) - 1;
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, doSave, false, 0, true);
		}
		
		
		private function doSave(e:MouseEvent):void
		{
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, doSave);
			
			myKioskName = clip.combo.selectedItem.data;			
			so.data.kioskName = myKioskName;
			so.flush();
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			
			dispatchEvent(new Event(CONFIG_COMPLETE));
		}
	}
	
}