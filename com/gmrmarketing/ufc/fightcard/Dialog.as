package com.gmrmarketing.ufc.fightcard
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenLite;
	
	
	public class Dialog extends EventDispatcher
	{
		public static const DIALOG_OK:String = "dialogOkClicked";
		public static const DIALOG_CANCEL:String = "dialogCancelClicked";
		public static const DIALOG_CLOSED:String = "dialogClosed";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Dialog()
		{
			clip = new dialog();
		}
		
		
		public function show($container:DisplayObjectContainer, message:String, useButtons:Boolean = false, keepAlive:Boolean = false ):void
		{
			container = $container;
			clip.btnOK.alpha = 0;
			clip.btnCancel.alpha = 0;
			
			clip.theText.text = message;
			clip.alpha = 1;
			container.addChild(clip);
			
			if (useButtons) {
				clip.btnOK.alpha = 1;
				clip.btnCancel.alpha = 1;
				clip.btnOK.addEventListener(MouseEvent.CLICK, okClicked, false, 0, true);
				clip.btnCancel.addEventListener(MouseEvent.CLICK, cancelClicked, false, 0, true);
				clip.btnOK.buttonMode = true;
				clip.btnCancel.buttonMode = true;
			}else {
				//just show for 2 seconds and auto-dismiss
				if(!keepAlive){					
					TweenLite.to(clip, 2, { alpha:0, delay:2, onComplete:hide } );
				}
			}
		}
		
		
		private function okClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(DIALOG_OK));
		}
		
		
		private function cancelClicked(e:MouseEvent):void
		{
			clip.btnOK.removeEventListener(MouseEvent.CLICK, okClicked);
			clip.btnCancel.removeEventListener(MouseEvent.CLICK, cancelClicked);
			container.removeChild(clip);
			dispatchEvent(new Event(DIALOG_CANCEL));
		}
		
		
		/**
		 * Called by tweenlite once the dialog autohides
		 */
		public function hide():void
		{
			clip.btnOK.removeEventListener(MouseEvent.CLICK, okClicked);
			clip.btnCancel.removeEventListener(MouseEvent.CLICK, cancelClicked);
			container.removeChild(clip);
			
			dispatchEvent(new Event(DIALOG_CLOSED));
		}
		
	}
	
}