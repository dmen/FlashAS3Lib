
package com.gmrmarketing.esurance.usopen_2013.kiosk
{	
	import flash.display.*;	
	import flash.events.*;	
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Utility;
	
	
	
	public class RFID extends EventDispatcher 
	{
		public static const RFID_GOOD:String = "RFIDGood";
		public static const RFID_BAD:String = "RFIDNoGood";		
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var theStage:Stage;
		private var rfid:String;
		private var user:Object;
		
		
		public function RFID()
		{			
			clip = new mcRFID(); //lib clip
			user = new Object();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
			theStage = container.stage;
		}
		
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.rfidField.text = "";
			
			theStage.addEventListener(KeyboardEvent.KEY_DOWN, checkField, false, 0, true);
			theStage.addEventListener(MouseEvent.MOUSE_DOWN, setFocus, false, 0, true); //reset focus if screen is touched
			
			setFocus();			
		}
		
		
		private function setFocus(e:MouseEvent = null):void
		{
			theStage.focus = clip.rfidField;//input type field
		}
		
		
		public function hide():void
		{
			theStage.removeEventListener(KeyboardEvent.KEY_DOWN, checkField);
			theStage.removeEventListener(MouseEvent.MOUSE_DOWN, setFocus);
			container.removeEventListener(Event.ENTER_FRAME, setFocus);
			
			if(container.contains(clip)){
				container.removeChild(clip);
			}
		}
		
		
		/**
		 * Returns the user data object
		 * Properties are:
			 * Id, FirstName, LastName, Email, ZipCode, Rfid
			 * UserID, AccessToken, Age, MoreInfo, IsWinner, Prize, InsertDate
		 * @return
		 */
		public function getUserData():Object
		{
			return user;
		}
		
		
		private function checkField(e:KeyboardEvent):void
		{
			if (e.charCode == 13) {
				
				var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
				var request:URLRequest = new URLRequest("http://esuranceusopen2013.thesocialtab.net/api/Register?");
				
				var vars:URLVariables = new URLVariables();
				vars.rfid = clip.rfidField.text;//"F24313CE";////chas noffke 
				
				request.data = vars;
				request.method = URLRequestMethod.GET;
				request.requestHeaders.push(hdr);
				
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
		
		private function dataError(e:IOErrorEvent = null):void
		{				
			clip.rfidField.text = "";
			dispatchEvent(new Event(RFID_BAD));
		}
		
		
		private function dataPosted(e:Event):void
		{		
			user = JSON.parse(e.currentTarget.data);
			dispatchEvent(new Event(RFID_GOOD));
		}
		
		
	}
	
}