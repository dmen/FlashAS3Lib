package com.gmrmarketing.nissan.rodale.athfleet
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
		private var registeredOnFacebook:int;
		
		//screen saver
		private var curAthlete:MovieClip;
		private var curCar:MovieClip;
		private var athletes:Array;
		private var cars:Array;
		private var ssIndex:int;
		private var switchTimer:Timer;
		
		private var serviceURL:String;		
		
		
		public function RFID($container:DisplayObjectContainer, sliderXML:XML)
		{
			container = $container;
			theStage = container.stage;
			
			serviceURL = sliderXML.webServiceURL;			
			
			athletes = new Array(["HALL", new ssHall()], ["LOCHTE", new ssLochte()],["GOUCHER", new ssGoucher()], ["HORNER", new ssHorner()],["FLANAGAN", new ssFlanagan()]);
			cars = new Array(["VERSA", new ssVersa()], ["LEAF", new ssLeaf()], ["ALTIMA", new ssAltima()], ["SENTRA", new ssSentra()], ["PATHFINDER", new ssPathfinder()]);
			
			switchTimer = new Timer(3000, 1);
			switchTimer.addEventListener(TimerEvent.TIMER, removeSS, false, 0, true);
			
			clip = new rfidClip(); //lib clip
		}
		
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			//athletes = Utility.randomizeArray(athletes);
			//cars = Utility.randomizeArray(cars);
			ssIndex = 0;
			
			curCar = cars[ssIndex][1];
			curAthlete = athletes[ssIndex][1];
			curAthlete.x = -700;
			curAthlete.y = 115;
			curCar.x = 2500;
			curCar.y = 75;
			
			clip.ssText.theText.text = athletes[ssIndex][0] + " = " + cars[ssIndex][0];
			
			clip.addChildAt(curAthlete, 1);
			clip.addChildAt(curCar, 1);
			
			//curAthlete.blendMode = BlendMode.MULTIPLY;	
			
			clip.alpha = 1;
			clip.theText.text = "SCAN KEYCHAIN TO BEGIN";
			
			userName = "";
			clip.rfidField.text = "";
			theStage.addEventListener(KeyboardEvent.KEY_DOWN, checkField, false, 0, true);
			theStage.addEventListener(MouseEvent.MOUSE_DOWN, setFocus, false, 0, true); //reset focus if screen is touched
			
			setFocus();
			saverSwitch();
			glowUp();
		}
		
		private function glowUp():void
		{			
			TweenMax.to(clip.theText, 2, {glowFilter:{color:0x000000, alpha:1, blurX:15, blurY:15, strength:1, quality:2}, onComplete:glowDown});
		}
		private function glowDown():void
		{			
			TweenMax.to(clip.theText, 2, {glowFilter:{color:0x000000, alpha:0, blurX:15, blurY:15, strength:1, quality:2}, delay:.5, onComplete:glowUp});
		}
		
		
		
		/**
		 * Removes current car and athlete before calling saverSwitch() to add new one
		 * @param	e
		 */
		private function removeSS(e:TimerEvent = null):void
		{				
			TweenMax.to(curAthlete, .4, {x:-700, ease:Sine.easeIn } );
			TweenMax.to(curCar, .4, {x:2500, ease:Sine.easeIn, onComplete:switchClips } );			
		}
		
		
		
		private function switchClips():void
		{
			ssIndex++;
			if (ssIndex >= cars.length) {
				ssIndex = 0;
			}
			
			clip.removeChild(curAthlete);
			clip.removeChild(curCar);
			       
			curAthlete = athletes[ssIndex][1];
			curCar = cars[ssIndex][1];
			
			clip.addChildAt(curAthlete, 1);
			clip.addChildAt(curCar, 1);
			
			curAthlete.x = -700;
			curAthlete.y = 115;
			curCar.x = 2500;
			curCar.y = 75;
			
			//curAthlete.blendMode = BlendMode.MULTIPLY;	
			
			//TweenMax.to(clip.ssText, .1, { scaleY:.2 } );
			
			saverSwitch();
		}
		
		
		private function saverSwitch():void
		{	
			clip.ssText.theText.text = athletes[ssIndex][0] + " = " + cars[ssIndex][0];
			//TweenMax.to(clip.ssText, .3, { delay:.1, scaleY:1, ease:Sine.easeOut } );      
			TweenMax.to(curAthlete, .4, { x:50, ease:Sine.easeOut } );
			TweenMax.to(curCar, .4, { x:800, ease:Sine.easeOut } );
			
			switchTimer.start();//calls removeSS() after 5 sec
		}
		
		
		
		private function setFocus(e:MouseEvent = null):void
		{
			theStage.focus = clip.rfidField;
		}
		
		
		public function hide():void
		{			
			TweenMax.killAll();
			
			if (clip.contains(curAthlete)) {
				TweenMax.killAll();
				clip.removeChild(curAthlete);
				clip.removeChild(curCar);
			}
			switchTimer.reset();
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
			
				clip.theText.text = "CHECKING - PLEASE WAIT A MOMENT";
				
				rfid = clip.rfidField.text;
				//rfid = "3168131626";//TESTING
				var request:URLRequest = new URLRequest(serviceURL + "AddStationVisit/" + rfid + "/AthFleet" + "?");
				
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
				registeredOnFacebook = parseInt(ret.substr(lastComma + 1));//0 not registered, 1 registered, 2 disable FB button
				
				userName = name;
				
				//allow 1.5 seconds to shwo text
				clip.theText.text = "THANK YOU " + userName.toUpperCase();
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
			registeredOnFacebook = 0;
			userName = "Guest";
		}
		
		
		public function getName():String
		{
			return userName;
		}
		
		
		/**
		 * Called by main when showing results
		 * @return int 0 = not registered on FB, 1 = registered, 2 = hide FB button
		 */
		public function getFB():int
		{
			return registeredOnFacebook;
		}
		
		
		public function getRFID():String
		{			
			return rfid;
		}
		
		
		private function dataError(e:IOErrorEvent = null):void
		{			
			clip.rfidField.text = "";
			//dispatchEvent(new Event(CHECK_BAD));
			clip.theText.text = "RFID SCAN ERROR";
			var a:Timer = new Timer(1500, 1);
			a.addEventListener(TimerEvent.TIMER, resetScanText, false, 0, true);
			a.start();
		}
		
		private function resetScanText(e:TimerEvent):void
		{
			clip.theText.text = "SCAN KEYCHAIN TO BEGIN";
			theStage.addEventListener(KeyboardEvent.KEY_DOWN, checkField, false, 0, true);
			theStage.addEventListener(MouseEvent.MOUSE_DOWN, setFocus, false, 0, true); //reset focus if screen is touched
		}
		
	}
	
}