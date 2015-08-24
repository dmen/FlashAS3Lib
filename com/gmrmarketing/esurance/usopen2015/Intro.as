package com.gmrmarketing.esurance.usopen2015
{
	import flash.display.*	
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Strings;
	import com.dmennenoh.keyboard.KeyBoard;
	
	
	public class Intro extends EventDispatcher
	{
		public static const RFID:String = "gotRFID";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var rfid:String;
		private var email:String;
		private var kbd:KeyBoard;
		private var isKids:Boolean;
		
		public function Intro()
		{
			kbd = new KeyBoard();
			//kbd.addEventListener(KeyBoard.KEYFILE_LOADED, init, false, 0, true);
			kbd.loadKeyFile("numpad.xml");
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(isKidsDay:Boolean = false):void
		{
			isKids = isKidsDay;
			
			if (isKids) {
				clip = new mcIntroKids();
			}else {
				clip = new mcIntro();
			}
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.alpha = 0;			
			
			if(!isKids){
				clip.dialogAck.visible = false;
				clip.dialogBadUser.visible = false;		
				clip.dialogBadUser.mouseEnabled = false;
				
				clip.rfid.text = "";
				
				myContainer.stage.focus = clip.rfid;
				myContainer.stage.addEventListener(KeyboardEvent.KEY_DOWN, checkRFID, false, 0, true);
				
				clip.codeField.theText.text = "";
				clip.codeField.theText.restrict = "0-9";
				clip.codeField.scaleX = 0;
				
				clip.btnEnterCode.visible = true;
				clip.btnEnterCode.addEventListener(MouseEvent.MOUSE_DOWN, showNumPad, false, 0, true);
			}else {
				clip.addEventListener(MouseEvent.MOUSE_DOWN, dispatchRFID, false, 0, true);
			}
			
			TweenMax.to(clip, 1, { alpha:1 } );
		}
		
		
		private function checkRFID(e:KeyboardEvent):void
		{
			if (e.charCode == 13) {
				//got enter in field
				rfid = Strings.removeLineBreaks(clip.rfid.text);
				
				//if rfid is "" the scan went into the manual field
				if (rfid == "") {
					rfid = clip.codeField.theText.text;
				}
				
				//per fish docs - only use chars 2-8 of 10 digit string
				
				if(rfid.length == 11){
					rfid = rfid.substring(2, 9);
				}
				
				callFish();
			}
		}
		
		
		private function callFish():void
		{			
			var request:URLRequest = new URLRequest("https://fishapi.fishsoftware.com/content/usopen/rdq/v1/prod");
				
			var vars:URLVariables = new URLVariables();
			vars.badgeid = rfid;
			vars.client = "E1wVm3twDJGsEs4NmgKtEfFFw";		
					
			request.requestHeaders.push(new URLRequestHeader("Accept", "application/json"));
			request.data = vars;			
			request.method = URLRequestMethod.GET;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, dataRetrieved, false, 0, true);
			lo.load(request);
		}		


		private function dataRetrieved(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);
			
			if(j.email != undefined){
				email = j.email;
				
				if (parseInt(j.age) >= 18) {
					kbd.removeEventListener(KeyBoard.SUBMIT, manualRFID);
					if(myContainer.contains(kbd)){
						TweenMax.to(kbd, .5, { alpha:0 } );
					}
					showAckDialog();
				}else {
					showBadUserDialog("age");
				}
			}else {
				//id not located in Fish DB
				showBadUserDialog("error");
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			showBadUserDialog("error");
		}

		
		private function showNumPad(e:MouseEvent):void
		{
			myContainer.addChild(kbd);
			kbd.x = 506; kbd.y = 590;
			kbd.alpha = 0;
			clip.btnEnterCode.visible = false;
			
			TweenMax.to(kbd, .5, { alpha:1, y:554, ease:Back.easeOut } );
			TweenMax.to(clip.codeField, .5, { scaleX:1, ease:Back.easeOut } );
			
			kbd.setFocusFields([[clip.codeField.theText, 7]]);
			kbd.addEventListener(KeyBoard.SUBMIT, manualRFID, false, 0, true);
		}
		
		
		private function manualRFID(e:Event):void
		{
			rfid = clip.codeField.theText.text;			
			callFish();
		}
		
		
		private function showAckDialog():void
		{
			clip.dialogAck.btnAck.addEventListener(MouseEvent.MOUSE_DOWN, showAckX, false, 0, true);
			clip.dialogAck.visible = true;
			clip.dialogAck.alpha = 0;
			clip.dialogAck.ackX.alpha = 0;
			TweenMax.to(clip.dialogAck, .5, { alpha:1 } );
		}
		
		
		private function showBadUserDialog(which:String):void
		{
			if (which == "error") {
				clip.dialogBadUser.theText.text = "We're sorry, but an error occurred processing your badge number. Please try again, or see an Esurance ambassador for assistance."
			}else if (which == "age") {
				clip.dialogBadUser.theText.text = "We're sorry, but this badge number is registered to a minor. You must be 18 to participate."
			}
			clip.codeField.theText.text = "";
			clip.rfid.text = "";
			myContainer.stage.focus = clip.rfid;
			
			clip.dialogBadUser.visible = true;
			clip.dialogBadUser.alpha = 0;
			TweenMax.to(clip.dialogBadUser, .5, { alpha:1 } );
			TweenMax.to(clip.dialogBadUser, 1, { alpha:0, delay:5, onComplete:killBadUser } );
		}
		private function killBadUser():void
		{
			clip.dialogBadUser.visible = false;
		}
		
		
		private function showAckX(e:MouseEvent):void
		{
			TweenMax.to(clip.dialogAck.ackX, .25, { alpha:1, onComplete:dispatchRFID } );
		}
		
		
		private function dispatchRFID(e:MouseEvent = null):void
		{
			dispatchEvent(new Event(RFID));
		}
		
		
		public function getData():Object
		{
			return { rfid:rfid, email:email };
		}

		
		public function hide():void
		{
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, dispatchRFID);
			myContainer.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkRFID);
			if(!isKids){
				clip.dialogAck.btnAck.removeEventListener(MouseEvent.MOUSE_DOWN, showAckX);
			}
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			if (myContainer.contains(kbd)) {
				myContainer.removeChild(kbd);
			}
			clip.dialogAck.visible = false;
				clip.dialogBadUser.visible = false;		
		}		
		
	}	
	
}