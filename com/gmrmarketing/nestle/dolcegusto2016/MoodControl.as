package com.gmrmarketing.nestle.dolcegusto2016
{
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	
	
	public class MoodControl extends EventDispatcher
	{
		private var myIP:String;
		private var myUser:String;		
		private var baseURL:String;
		
		public function MoodControl(){}
		
		
		/**
		 * Called from Main.showIntro()
		 * @param	ip
		 * @param	user
		 */
		public function bridgeInit(ip:String, user:String):void		
		{
			myIP = ip;
			myUser = user;
			baseURL = "http://" + ip + "/api/" + user + "/";
		}
		
		
		/**
		 * mc is an array of three x,y color arrays
		 */
		public function set moodColor(mc:Array):void
		{
			for (var i:int = 0; i < mc.length; i++){
				setLightColor(mc[i], i + 1);
			}
		}
		
		
		private function setLightColor(hueXY:Array, lightNum:int):void
		{
			var req:URLRequest = new URLRequest(baseURL + "lights/" + lightNum.toString() + "/state");
			req.method = URLRequestMethod.PUT;
			
			req.data = "{\"on\":true, \"xy\":[" + hueXY[0] + "," + hueXY[1] + "],\"bri\":254}";			
			
			var lo:URLLoader = new URLLoader();
			//lo.addEventListener(IOErrorEvent.IO_ERROR, imageError, false, 0, true);
			//lo.addEventListener(Event.COMPLETE, imagePosted, false, 0, true);
			lo.load(req);
		}
		
	}
	
}