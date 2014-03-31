
package com.gmrmarketing.pm
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
		public static const CHECK_GOOD:String = "RFIDGood"; //called from dispatchGood()
		public static const CHECK_BAD:String = "RFIDNoGood";
		public static const CLIP_REMOVED:String = "rfidClipRemoved"; //dispatched in kill()
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var theStage:Stage;
		private var rfid:String;
		private var userName:String;
		private var cityState:String;		
		private var serviceURL:String;
		
		private var showing:Boolean = false;
		
		
		public function RFID()
		{	
			clip = new rfidClip(); //lib clip
		}		
		
		
		public function show($container:DisplayObjectContainer, $serviceURL:String):void
		{
			container = $container;
			theStage = container.stage;
			
			serviceURL = $serviceURL;
			//serviceURL = "http://dservices.mangoapi.com/lab/testrfid.php";
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.alpha = 1;
			//clip.rfidText.theText.htmlText = "TOUCH YOUR <font color='#b41f18'>WRISTBAND</font> BELOW TO START";
			clip.rfidText.theText.htmlText = "TOUCH YOUR WRISTBAND BELOW TO START";
			userName = "";
			clip.rfidField.text = "";
			theStage.addEventListener(KeyboardEvent.KEY_DOWN, checkField, false, 0, true);
			theStage.addEventListener(MouseEvent.MOUSE_DOWN, setFocus, false, 0, true); //reset focus if screen is touched
			
			showing = true;
			
			setFocus();		
		}		
		
		public function isShowing():Boolean
		{
			return showing;
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
			if(container){
				if(container.contains(clip)){
					container.removeChild(clip);
				}
			}
			showing = false;
			dispatchEvent(new Event(CLIP_REMOVED));
		}
		
		
		private function checkField(e:KeyboardEvent):void
		{
			if (e.charCode == 13) {
				
				theStage.removeEventListener(KeyboardEvent.KEY_DOWN, checkField);
				container.removeEventListener(Event.ENTER_FRAME, setFocus);
			
				clip.rfidText.theText.text = "CHECKING - PLEASE WAIT A MOMENT";	
				
				rfid = clip.rfidField.text;		
				//trace(rfid);
				//rfid = "2882565486";//TESTING
					
				//var variables:URLVariables = new URLVariables();
				//variables.rfid = rfid;
				var request:URLRequest = new URLRequest(serviceURL + rfid);
				//request.data = variables;
				
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
			
			//USA
			var ret:XML = new XML(lo.data);
			var fName = ret.name;
			
			//RODALE
			/*
			var ret:String = lo.data;//Milind,1
			//trace("dataPosted", ret);
			var comPos:int = ret.indexOf(",");
			var fName:String = ret.substr(0, comPos);
			*/
			
			if (fName != "") {
				
				//need userName as firstName, last initial: "John D.";
				//need cityState
				userName = fName;
				//cityState = ret.city + ", " + ret.state;
				
				//allow 1.5 seconds to show text
				//clip.rfidText.theText.text = "WELCOME" + userName.toUpperCase();
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
		
		
		
		/**
		 * called from Main if the skip RFID button is pressed
		 */
		public function setName():void
		{			
			userName = "Guest";
			cityState = "New Berlin, WI";
		}
		
		
		/**
		 * Returns the user name like John D.
		 * @return
		 */
		public function getName():String
		{
			return userName;
		}
		
		
		public function getCity():String
		{
			return cityState;
		}
				
		
		public function getRFID():String
		{			
			return rfid;
		}
		
		
		private function dataError(e:IOErrorEvent = null):void
		{			
			clip.rfidField.text = "";
			dispatchEvent(new Event(CHECK_BAD));
			clip.rfidText.theText.text = "RFID SCAN ERROR";
			var a:Timer = new Timer(3000, 1);
			a.addEventListener(TimerEvent.TIMER, resetScanText, false, 0, true);
			a.start();
		}
		
		
		private function resetScanText(e:TimerEvent):void
		{
			//clip.theText.text = "SCAN WRISTBAND TO ACTIVATE";
			clip.rfidText.theText.htmlText = "TOUCH YOUR <font color='#b41f18'>WRISTBAND</font> BELOW TO START";
			theStage.addEventListener(KeyboardEvent.KEY_DOWN, checkField, false, 0, true);
			theStage.addEventListener(MouseEvent.MOUSE_DOWN, setFocus, false, 0, true); //reset focus if screen is touched
		}
		
	}
	
}