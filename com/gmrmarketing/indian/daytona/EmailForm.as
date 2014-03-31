package com.gmrmarketing.indian.daytona
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.gmrmarketing.indian.daytona.*;
	import com.gmrmarketing.utilities.Validator;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class EmailForm extends EventDispatcher
	{
		public static const EMAIL_CANCEL:String = "email_canceled";
		public static const EMAIL_ENTERED:String = "email_entered"; //dispatched is user is already in the database		
		public static const ERROR:String = "error_occured";
		public static const INVALID_EMAIL:String = "not_a_valid_email";
		public static const PRIVACY:String = "showPrivacyPolicy";		
		public static const RULES:String = "showOfficialRules";		
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var database:Database;
		private var timeoutHelper:TimeoutHelper;
		
		
		public function EmailForm()
		{
			timeoutHelper = TimeoutHelper.getInstance();
			database = Database.getInstance();
			
			clip = new emailForm();
		}
		
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);				
			}
			clip.textEmail.text = "";
			
			clip.stage.focus = clip.textEmail;
			
			clip.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelClicked, false, 0, true);
			clip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, submitClicked, false, 0, true);
			clip.btnPrivacy.addEventListener(MouseEvent.MOUSE_DOWN, privacyClicked, false, 0, true);
			clip.btnRules.addEventListener(MouseEvent.MOUSE_DOWN, rulesClicked, false, 0, true);
		}
		
		
		
		public function getFields():Array
		{
			return [clip.textEmail];
		}
		
		
		/**
		 * returns the last email address entered
		 * @return
		 */
		public function getEmail():String
		{
			return clip.textEmail.text;			
		}
		
		
		public function hide():void		
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelClicked);
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submitClicked);
			clip.btnPrivacy.removeEventListener(MouseEvent.MOUSE_DOWN, privacyClicked);
			clip.btnRules.removeEventListener(MouseEvent.MOUSE_DOWN, rulesClicked);
		}		
		
		
		private function cancelClicked(e:MouseEvent):void
		{
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelClicked);
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submitClicked);
			clip.btnPrivacy.removeEventListener(MouseEvent.MOUSE_DOWN, privacyClicked);
			clip.btnRules.removeEventListener(MouseEvent.MOUSE_DOWN, rulesClicked);
			
			dispatchEvent(new Event(EMAIL_CANCEL));
		}		
		
		
		public function submitClicked(e:MouseEvent = null):void
		{
			if (Validator.isValidEmail(clip.textEmail.text)) {				
				dispatchEvent(new Event(EMAIL_ENTERED));	
			}else {
				dispatchEvent(new Event(INVALID_EMAIL));
			}
		}
		
		
		private function privacyClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(PRIVACY));
		}
		
		
		private function rulesClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(RULES));
		}
		
	}
	
}