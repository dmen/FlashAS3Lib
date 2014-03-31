package com.gmrmarketing.indian.daytona
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.gmrmarketing.indian.daytona.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	
	public class MainForm extends EventDispatcher
	{
		public static const FORM_CANCEL:String = "form_canceled";		
		public static const FORM_GOOD:String = "form_posted";
		public static const FORM_BAD:String = "form_failed";
		public static const ERROR:String = "error_occured";
		public static const NAME_BAD:String = "name_wrong";
		public static const PHONE_BAD:String = "phone_wrong";
		public static const ZIP_BAD:String = "zip_wrong";		
		public static const RULES_BAD:String = "rules_not_checked";		
		public static const SHOW_RULES:String = "show_rules";
		public static const PRIVACY:String = "showPrivacyPolicy";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var userEmail:String;
		
		private var database:Database;
		private var timeoutHelper:TimeoutHelper;
		private var userInDB:Boolean;
		
		public function MainForm() 
		{
			timeoutHelper = TimeoutHelper.getInstance();
			database = Database.getInstance();
			
			clip = new mainForm();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(email:String):void
		{			
			userEmail = email;			
			
			if (!container.contains(clip)) {
				container.addChild(clip);				
			}
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1 } );
			
			database.addEventListener(Database.INDB, emailCheckComplete, false, 0, true);
			database.inDatabase(userEmail);
		}
		
		
		private function emailCheckComplete(e:Event):void
		{			
			database.removeEventListener(Database.INDB, emailCheckComplete);
			
			var ud:Object = database.getUserData();
			
			if (ud.fname != "") {
				userInDB = true;
				
				//user already in the database - preopopulate the form
				clip.fName.text = ud.fname;
				clip.lName.text = ud.lname;
				clip.zip.text = ud.zip;
				clip.phone.text = ud.phone;
			}else {
				userInDB = false;
				
				clip.fName.text = "";
				clip.lName.text = "";
				clip.zip.text = "";
				clip.phone.text = "";
			}			
		
			clip.zip.restrict = "0-9";
			clip.phone.restrict = "-0-9";
			
			clip.c1.visible = false; //acutal check mark clips
			clip.c2.visible = false;			
			
			clip.cc1.addEventListener(MouseEvent.MOUSE_DOWN, cc1Clicked, false, 0, true);
			clip.cc2.addEventListener(MouseEvent.MOUSE_DOWN, cc2Clicked, false, 0, true);			
			
			clip.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelClicked, false, 0, true);
			clip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, submitClicked, false, 0, true);
			clip.btnPrivacy.addEventListener(MouseEvent.MOUSE_DOWN, privacyClicked, false, 0, true);			
			clip.btnPrivacy2.addEventListener(MouseEvent.MOUSE_DOWN, privacyClicked, false, 0, true);			
			clip.btnRules.addEventListener(MouseEvent.MOUSE_DOWN, showRules, false, 0, true);
			clip.btnRules2.addEventListener(MouseEvent.MOUSE_DOWN, showRules, false, 0, true);
			
			clip.stage.focus = clip.fName;
		}
		
		
		private function showRules(e:MouseEvent):void
		{
			dispatchEvent(new Event(SHOW_RULES));
		}
		
		
		public function getFields():Array
		{
			return [clip.fName, clip.lName, clip.zip, clip.phone];
		}
		
		
		public function hide():void		
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			removeListeners();
		}
		
		
		private function cancelClicked(e:MouseEvent):void
		{
			removeListeners();			
			dispatchEvent(new Event(FORM_CANCEL));
		}
		
		private function privacyClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(PRIVACY));
		}
		
		private function removeListeners():void
		{
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelClicked);
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submitClicked);
			clip.btnPrivacy.removeEventListener(MouseEvent.MOUSE_DOWN, privacyClicked);
			clip.btnPrivacy2.removeEventListener(MouseEvent.MOUSE_DOWN, privacyClicked);
			clip.btnRules.removeEventListener(MouseEvent.MOUSE_DOWN, showRules);
			clip.btnRules2.removeEventListener(MouseEvent.MOUSE_DOWN, showRules);
			
			clip.cc1.removeEventListener(MouseEvent.MOUSE_DOWN, cc1Clicked);
			clip.cc2.removeEventListener(MouseEvent.MOUSE_DOWN, cc2Clicked);
		}
		
		
		/**
		 * Called by clicking on the submit button
		 * Validates form data before calling database.addUser()
		 * @param	ev
		 */
		public function submitClicked(ev:MouseEvent = null):void
		{
			timeoutHelper.buttonClicked();
			
			var a:String = clip.fName.text;
			var b:String = clip.lName.text;
			var c:String = clip.zip.text;
			var d:String = clip.phone.text;			
			
			var g:int = clip.c1.visible == true ? 1 : 0;//official rules
			var h:int = clip.c2.visible == true ? 1 : 0;//more info			
			
			var filter:Array = ["fuck", "shit", "bitch", "cunt", "pussy", "clit", "nigger", "asshole", "cock", "penis", "whore", "vagina", "faggot"];
			var swear:Boolean;
			var i:int;
			
			for (i = 0; i < filter.length; i++) {
				if (a.toLowerCase().indexOf(filter[i]) != -1) {
					swear = true;
					break;
				}
			}
			for (i = 0; i < filter.length; i++) {
				if (b.toLowerCase().indexOf(filter[i]) != -1) {
					swear = true;
					break;
				}
			}
			
			if (a == "" || b == "" || swear) {
				dispatchEvent(new Event(NAME_BAD));
			}else if (c.length != 5) {
				dispatchEvent(new Event(ZIP_BAD));						
			}else if (g != 1) {
				dispatchEvent(new Event(RULES_BAD));
			}else {
				if (userInDB) {
					database.addEventListener(Database.USER_ADDED, userAdded, false, 0, true);
					database.updateTimestamp(userEmail);
				}else{
					database.addEventListener(Database.USER_ADDED, userAdded, false, 0, true);
					database.addUser(a, b, c, d, userEmail, h);
				}
			}
		}
		
		
		private function cc1Clicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			if (clip.c1.visible) {
				clip.c1.visible = false;
			}else {
				clip.c1.visible = true;
			}
		}		
		
		
		private function cc2Clicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			if (clip.c2.visible) {
				clip.c2.visible = false;
			}else {
				clip.c2.visible = true;
			}
		}
		
		
		private function userAdded(e:Event):void
		{
			database.removeEventListener(Database.USER_ADDED, userAdded);
			dispatchEvent(new Event(FORM_GOOD));
		}		
		
	}
	
}