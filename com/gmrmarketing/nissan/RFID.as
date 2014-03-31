//100MILE specific RFID

package com.gmrmarketing.nissan
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Utility;
	import flash.display.BlendMode;
	
	
	public class RFID extends EventDispatcher 
	{
		public static const CHECK_GOOD:String = "RFIDGood";
		public static const CHECK_BAD:String = "RFIDNoGood";
		public static const CLIP_REMOVED:String = "rfidClipRemoved";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var theStage:Stage;
		private var rfid:String;
		private var userName:String;
		private var registeredOnFacebook:Boolean;
		
		private var serviceURL:String;
		
		
		public function RFID($container:DisplayObjectContainer, sliderXML:XML)
		{
			container = $container;
			theStage = container.stage;
			
			serviceURL = sliderXML.webServiceURL;
			trace(serviceURL);
			
			clip = new rfidClip(); //lib clip
		}
		
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}	
			
			clip.theText.text = "scan keychain to begin";
			
			
			theStage.addEventListener(KeyboardEvent.KEY_DOWN, checkField, false, 0, true);
			theStage.addEventListener(MouseEvent.MOUSE_DOWN, setFocus, false, 0, true); //reset focus if screen is touched
			
			setFocus();			
		}
		
		
		private function setFocus(e:MouseEvent = null):void
		{
			theStage.focus = clip.rfidField;
		}
		
		
		public function hide():void
		{
			theStage.removeEventListener(KeyboardEvent.KEY_DOWN, checkField);
			theStage.removeEventListener(MouseEvent.MOUSE_DOWN, setFocus);
			kill();
		}
		
		
		public function kill():void
		{			
			if(container.contains(clip)){
				container.removeChild(clip);
			}
			dispatchEvent(new Event(CLIP_REMOVED));
		}
		
		
		private function checkField(e:KeyboardEvent):void
		{
			if (e.charCode == 13) {
				
				theStage.removeEventListener(KeyboardEvent.KEY_DOWN, checkField);
				container.removeEventListener(Event.ENTER_FRAME, setFocus);
			
				clip.theText.text = "checking - please wait a moment";
				
				rfid = clip.rfidField.text;
				//rfid = "3168131626";//TESTING
				var request:URLRequest = new URLRequest(serviceURL + rfid + "/100MileApplication" + "?");
				
				var lo:URLLoader = new URLLoader();
				lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
				lo.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
				
				try{
					lo.load(request);
				}catch (e:Error) {
					dataError();
				}
			}
		}
		

		private function dataPosted(e:Event):void
		{
			var lo:URLLoader = URLLoader(e.target);	
			
			//remove any returned lineFeed CR's
			var ret:String = lo.data;
			ret = ret.split("\r").join("");
			ret = ret.split("\n").join("");
			
			if (ret.indexOf("-1") == -1) {
				
				var lastComma:int = ret.lastIndexOf(",");
				var name:String = ret.substring(0, lastComma);
				var fb:String = ret.substr(lastComma + 1);
				registeredOnFacebook = false;// fb == "1" ? true : false;				
				
				userName = name;
				
				//allow 1.5 seconds to show text
				clip.theText.text = "thanks, " + userName.toLowerCase();
				clip.rfidField.text = "";
				var a:Timer = new Timer(1500, 1);
				a.addEventListener(TimerEvent.TIMER, dispatchGood, false, 0, true);
				a.start();
			}else {
				dataError();
			}
		}
		
		private function dispatchGood(e:TimerEvent):void
		{
			dispatchEvent(new Event(CHECK_GOOD));
		}
		
		//called from Main if the skip RFID button is pressed
		public function setName():void
		{
			registeredOnFacebook = false;
			userName = "Guest";
		}
		
		public function getName():String
		{
			return userName;
		}
		
		public function getFB():Boolean
		{
			return registeredOnFacebook;
		}
		
		public function getRFID():String
		{
			return rfid;
		}
		
		
		private function dataError(e:IOErrorEvent = null):void
		{	
			clip.theText.text = "scan error";
			clip.rfidField.text = "";
			dispatchEvent(new Event(CHECK_BAD));
		}			
		
	}
	
}