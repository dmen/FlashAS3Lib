package com.gmrmarketing.utilities
{
	import flash.external.ExternalInterface;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	public class AdClick extends Sprite
	{
		private var clickURL:String;
		
		public function AdClick(m:MovieClip)
		{
			clickURL = m.loaderInfo.parameters.clickTAG;
			if (clickURL == null) {
				clickURL = m.loaderInfo.parameters.clickTag;
			}
			addEventListener(Event.ADDED_TO_STAGE, init);
		}	
		
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			graphics.beginFill(0x00ff00, 0);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
			buttonMode = true;			
			addEventListener(MouseEvent.CLICK, clicked, false, 0, true);
		}
		
		
		private function clicked(e:MouseEvent):void
		{			
			if (clickURL) {
				openWindow(clickURL);			
			}
		}
		
		
		private function openWindow(url:String, target:String = '_blank', features:String=""):void
		{
			var WINDOW_OPEN_FUNCTION:String = "window.open";
			var myURL:URLRequest = new URLRequest(url);
			var browserName:String = getBrowserName();
			switch (browserName)
			{
				//If browser is Firefox, use ExternalInterface to call out to browser
				//and launch window via browser's window.open method.
				case "Firefox":
					ExternalInterface.call(WINDOW_OPEN_FUNCTION, url, target, features);
					break;
				//If IE,
				case "IE":
					ExternalInterface.call("function setWMWindow() {window.open('" + url + "', '"+target+"', '"+features+"');}");
					break;
				// If Safari or Opera or any other
				case "Safari":
					navigateToURL(myURL, target);
					break;
				case "Opera":
					navigateToURL(myURL, target);
					break;
				default:
					navigateToURL(myURL, target);
					break;
			}
		}

		private function getBrowserName():String
		{
			var browser:String;
			//Uses external interface to reach out to browser and grab browser useragent info.
			var browserAgent:String = ExternalInterface.call("function getBrowser(){return navigator.userAgent;}");
			//Determines brand of browser using a find index. If not found indexOf returns (-1).
			if(browserAgent != null && browserAgent.indexOf("Firefox")>= 0) {
				browser = "Firefox";
			}
			else if(browserAgent != null && browserAgent.indexOf("Safari")>= 0){
				browser = "Safari";
			}
			else if(browserAgent != null && browserAgent.indexOf("MSIE")>= 0){
				browser = "IE";
			}
			else if(browserAgent != null && browserAgent.indexOf("Opera")>= 0){
				browser = "Opera";
			}
			else {
				browser = "Undefined";
			}
			return browser;
		}
	}	
}