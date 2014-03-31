package com.gmrmarketing.jimbeam.boldchoice
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import com.gmrmarketing.utilities.Validator;
	import flash.net.SharedObject;
	import flash.external.ExternalInterface;
	
	public class ThanksFB extends EventDispatcher
	{
		public static const THANKS_ADDED:String = "thanksAdded";
		public static const FB_PRESSED:String = "facebookPressed";
		public static const DATA_SUBMITTED:String = "dataWasSubmitted";
		public static const BAD_EMAIL:String = "badEmailAddress";
		public static const NO_OPT:String = "noOptInWithoutEmail";
		public static const DATA_POSTING:String = "dataSending";		
		
		private var container:DisplayObjectContainer;
		private var clip:MovieClip;
		private var isChecked:Boolean;
		private var venue:String; //used when posting data to service
		
		
		
		public function ThanksFB()
		{
			clip = new the_thanks(); //lib clip
		}
		
		
		public function show($container:DisplayObjectContainer, right:int, total:int, $venue:String):void
		{
			container = $container;
			
			clip.alpha = 0;
			clip.theCheck.alpha = 0;
			isChecked = false;
			
			clip.theEmail.text = "";
			
			container.addChild(clip);
			
			clip.numRight.text = String(right);
			clip.numTotal.text = String(total);
			
			venue = $venue;
			
			clip.btnCheck.addEventListener(MouseEvent.MOUSE_DOWN, checkPressed, false, 0, true);
			clip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, submitPressed, false, 0, true);
			clip.btnFBShare.addEventListener(MouseEvent.MOUSE_DOWN, FBSharePressed, false, 0, true);
			clip.btnCheck.buttonMode = true;
			clip.btnSubmit.buttonMode = true;
			clip.btnFBShare.buttonMode = true;
			
			TweenMax.to(clip, .5, { alpha:1, onComplete:clipAdded } );
		}
		
		
		public function hide():void
		{			
			clip.btnCheck.removeEventListener(MouseEvent.MOUSE_DOWN, checkPressed);
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submitPressed);
			clip.btnFBShare.removeEventListener(MouseEvent.MOUSE_DOWN, FBSharePressed);
			
			if(container){
				if(container.contains(clip)){
					container.removeChild(clip);
				}
			}
		}
		
		private function FBSharePressed(e:MouseEvent):void
		{
			ExternalInterface.call("pubFeed", clip.numRight.text, clip.numTotal.text);
		}
		
		public function optinStatus():Boolean
		{
			return isChecked;
		}
		
		
		public function getEmail():String
		{
			return clip.theEmail.text;
		}
		
		
		private function clipAdded():void
		{
			dispatchEvent(new Event(THANKS_ADDED));
		}
		
		
		private function checkPressed(e:MouseEvent):void
		{
			TweenMax.killTweensOf(clip.theCheck);
			if (!isChecked) {
				isChecked = true;				
				TweenMax.to(clip.theCheck, .5, { alpha:1 } );
			}else {
				isChecked = false;
				TweenMax.to(clip.theCheck, .5, { alpha:0 } );
			}
		}
		
		
		private function submitPressed(e:MouseEvent):void
		{
			if (clip.theEmail.text != "") {
				if (!Validator.isValidEmail(clip.theEmail.text)) {
					dispatchEvent(new Event(BAD_EMAIL));
				}else {
					//email is ok
					postData();
				}
			}else {
				//email blank
				if (isChecked) {
					dispatchEvent(new Event(NO_OPT));
				}else {
					//no email - no optin
					postData();
				}
				
			}			
		}
		
		
		private function postData():void
		{
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submitPressed);
			dispatchEvent(new Event(DATA_POSTING));//shows please wait a moment
			
			var request:URLRequest = new URLRequest("http://jimbeamboldchoice.thesocialtab.net/Home/Submit");
				
			var vars:URLVariables = new URLVariables();
			vars.market = venue;
			vars.email = clip.theEmail.text;
			
			var opt:String = isChecked == true ? "true" : "false";
			vars.optin = opt;			
			
			request.data = vars;			
			request.method = URLRequestMethod.GET;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			lo.load(request);
		}
		
		
		private function dataError(e:IOErrorEvent = null):void
		{	
			var so:SharedObject = SharedObject.getLocal("JBBC_bad_data", "/");
			var currentData:Array = so.data.records;
			if (currentData == null) {
				currentData = new Array();
			}
			var opt:String = isChecked == true ? "true" : "false";
			
			currentData.push([venue, clip.theEmail.text, opt]);
			
			so.data.records = currentData;
			so.flush();
			
			dispatchEvent(new Event(DATA_SUBMITTED));
		}
		
		
		private function dataPosted(e:Event):void
		{
			var lo:URLLoader = URLLoader(e.target);
			var vars:URLVariables = new URLVariables(lo.data);
			if(vars.success == "true"){			
				dispatchEvent(new Event(DATA_SUBMITTED));
			}else {
				dataError();
			}
		}
		
	}
	
}