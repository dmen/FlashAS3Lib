/**
 * Linked to dialog clip in the library
 */

package com.gmrmarketing.bicycle
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Dialog extends MovieClip
	{
		public static const DIALOG_YES:String = "dialogYesButtonClicked";
		public static const DIALOG_NO:String = "dialogNoButtonClicked";
		
		public function Dialog()
		{
			btnYes.addEventListener(MouseEvent.CLICK, yesClick, false, 0, true);
			btnNo.addEventListener(MouseEvent.CLICK, noClick, false, 0, true);
		}
		
		public function show(mess:String, btn1:String = "YES", btn2:String = "NO", theID:String = ""):void
		{
			theText.text = mess;
			theUID.text = theID;
			
			if (btn1 == "") {
				btnYes.visible = false;
			}else {
				btnYes.visible = true;
				btnYes.theText.text = btn1;
			}
			btnNo.theText.text = btn2;
		}
		
		private function yesClick(e:MouseEvent):void
		{
			dispatchEvent(new Event(DIALOG_YES));
		}
		
		private function noClick(e:MouseEvent):void
		{
			dispatchEvent(new Event(DIALOG_NO));
		}
	}
	
}