/**
 * Form data collection
 */
package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.*;
	import flash.events.*;	
	import com.gmrmarketing.intel.girls20.ComboBox;
	import com.gmrmarketing.utilities.US_StateList;
	import com.gmrmarketing.utilities.Validator;
	
	
	public class ControllerIntro extends EventDispatcher
	{
		public static const START:String = "startPressed";
		public static const REQUIRED:String = "fieldsRequired";
		public static const EMAIL:String = "badEmail";
		public static const PHONE:String = "badPhone";
		public static const RULES:String = "rulesNotChecked";
		public static const STATE:String = "noState";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var statesDropdown:ComboBox;
		
		
		public function ControllerIntro()
		{
			clip = new mcIntro();//lib clip			
			statesDropdown = new ComboBox();
			statesDropdown.populate(US_StateList.getStates());
			clip.addChild(statesDropdown);
			statesDropdown.x = 100;
			statesDropdown.y = 282;
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
			
			statesDropdown.setSelection("");
			
			/*
			clip.fname.text = "";
			clip.lname.text = "";
			clip.email.text = "";
			clip.phone.text = "";			
			*/
			
			clip.fname.maxChars = 25;
			clip.lname.maxChars = 1;//just last initial
			clip.email.maxChars = 25;			
			
			clip.phone.restrict = "-0-9";
			clip.phone.maxChars = 12;
			
			clip.check.gotoAndStop(1);
			
			clip.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, startClicked, false, 0, true);
			clip.btnCheck.addEventListener(MouseEvent.MOUSE_DOWN, checkClicked, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, startClicked);
			clip.btnCheck.removeEventListener(MouseEvent.MOUSE_DOWN, checkClicked);
		}
		
		
		/**
		 * called from ControllerMain.sweepsDone()
		 * @return
		 */
		public function getData():Array
		{			
			return new Array(clip.fname.text, clip.lname.text, clip.email.text, clip.phone.text, statesDropdown.getSelection());			
		}
		
		
		private function startClicked(e:MouseEvent):void
		{
			if (clip.fname.text == "" || clip.lname.text == "" || clip.email.text == "" || clip.phone.text == "") {
				dispatchEvent(new Event(REQUIRED));
			}else if (!Validator.isValidEmail(clip.email.text)) {
				dispatchEvent(new Event(EMAIL));
			}else if (!Validator.isValidPhoneNumber(clip.phone.text)) {
				dispatchEvent(new Event(PHONE));			
			}else if (statesDropdown.getSelection() == "") {
				dispatchEvent(new Event(STATE));
			}else if (clip.check.currentFrame == 1) {
				dispatchEvent(new Event(RULES));
			}else{
				dispatchEvent(new Event(START));
			}
		}
		
		
		private function checkClicked(e:MouseEvent):void
		{
			if (clip.check.currentFrame == 1) {
				clip.check.gotoAndStop(2);
			}else {
				clip.check.gotoAndStop(1);
			}
		}
		
	}
	
}