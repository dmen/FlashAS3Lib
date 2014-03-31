package com.gmrmarketing.smartcar
{
	import flash.display.MovieClip;
	import flash.events.*;
	import com.blurredistinction.validators.EmailValidator;
	import flash.net.*;
	import flash.text.*;
	import com.greensock.TweenMax;
	import flash.utils.Timer;
	
	
	
	public class TheForm extends MovieClip 
	{
		public static const BAD_EMAIL:String = "emailDidNotValidate";
		public static const BAD_STATE:String = "stateDidNotValidate";
		public static const BAD_ZIP:String = "zipCodeDidNotValidate";
		public static const ALL_REQUIRED:String = "allFieldsAreRequired";
		public static const FORM_POSTED:String = "formDataWasPosted";
		public static const FORM_CANCELLED:String = "formWasCancelled";
		
		private var emVal:EmailValidator;		
		private var regID:String = "";
		private var states:Array;		
		
		private var userData:Array;
		private var localData:Object;
		private var isConnected:Boolean;
		
		
		public function TheForm()
		{
			states = new Array("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY");
			
			emVal = new EmailValidator();
		}
		
		
		public function init(theID:String, connected:Boolean):void
		{
			regID = theID;
			isConnected = connected;
			
			//clear fields
			fname.text = "";
			lname.text = "";
			address.text = "";
			city.text = "";
			state.text = "";
			zip.text = "";
			email.text = "";
			
			//set restrictions
			fname.restrict = "a-zA-Z";
			lname.restrict = "a-zA-Z";
			address.restrict = "0-9 a-zA-Z.";
			city.restrict = "a-zA-Z";
			state.restrict = "a-zA-Z";
			zip.restrict = "0-9";
			email.restrict = "0-9a-zA-Z@.";
			
			btnSubmit.addEventListener(MouseEvent.CLICK, formSubmitted, false, 0, true);
			btnCancel.addEventListener(MouseEvent.CLICK, formCanceled, false, 0, true);
			
			addEventListener(Event.REMOVED_FROM_STAGE, cleanUp, false, 0, true);
			
			setFocus();
		}
		
		
		private function setFocus():void
		{
			thanks.alpha = 0;
			thanks.mouseEnabled = false;
			thanks.mouseChildren = false;
			
			TextField(fname).stage.focus = TextField(fname);
			TextField(fname).setSelection(0,0);
		}
		
		
		private function formSubmitted(e:MouseEvent):void
		{
			if (!emVal.validate(email.text)) {
				dispatchEvent(new Event(BAD_EMAIL));
				return;
			}
			if (zip.text.length != 5) {
				dispatchEvent(new Event(BAD_ZIP));
				return;
			}
			if (states.indexOf(String(state.text).toUpperCase()) == -1) {
				dispatchEvent(new Event(BAD_STATE));
				return;
			}
			if (fname.text == "" || lname.text == "" || address.text == "" || city.text == "" || state.text == "" || zip.text == "" || email.text == "") {
				dispatchEvent(new Event(ALL_REQUIRED));
				return;
			}
				
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, formPosted, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, formPosted, false, 0, true);
			
			var request:URLRequest = new URLRequest(StaticData.POST_FORM_URL);
			request.method = URLRequestMethod.POST;
			
			userData = new Array();
			userData.push("FIRST_NAME: '" + fname.text + "'");
			userData.push("LAST_NAME: '" + lname.text + "'");
			userData.push("ADDRESS: '" + address.text + "'");
			userData.push("CITY: '" + city.text + "'");
			userData.push("STATE: '" + String(state.text).toUpperCase() + "'");
			userData.push("ZIP: '" + zip.text + "'");
			userData.push("EMAIL: '" + email.text + "'");
			userData.push("registrantId: '" + regID + "'");
			
			request.data =  " { " + userData + " } ";
			
			if(isConnected){
				try {
					loader.load(request);
				} catch (e:Error) {
					trace(e);
				}
			}else {
				formPosted();
			}
		}
		
		/**
		 * returns an Array
		 * @return
		 */
		public function getRequest():Array
		{
			return userData;
		}
		
		private function formPosted(e:Event = null):void
		{
			TweenMax.to(thanks, 1, { alpha:1, onComplete:thanksWait } );			
		}
		
		private function thanksWait():void
		{
			var a:Timer = new Timer(8000, 1);
			a.addEventListener(TimerEvent.TIMER, formComplete, false, 0, true);
			a.start();
		}
		
		private function formComplete(e:TimerEvent):void
		{
			dispatchEvent(new Event(FORM_POSTED));
		}
		
		
		private function formCanceled(e:Event):void
		{
			dispatchEvent(new Event(FORM_CANCELLED));
		}
		
		
		private function cleanUp(e:Event):void
		{			
			btnSubmit.removeEventListener(MouseEvent.CLICK, formSubmitted);
			btnCancel.removeEventListener(MouseEvent.CLICK, formSubmitted);
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
		}
	}
	
}