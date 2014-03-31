/**
 * Instantiated by Main
 */
package com.gmrmarketing.nissan.next
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
	
	
	public class RFID_CANADA extends EventDispatcher 
	{
		public static const CHECK_GOOD:String = "RFIDGood";
		public static const CHECK_BAD:String = "RFIDNoGood";
		public static const CLIP_REMOVED:String = "rfidClipRemoved";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var theStage:Stage;
		private var rfid:String;
		private var userName:String;
		private var cityState:String;	
		
		private var showing:Boolean = false;
		
		
		public function RFID_CANADA()
		{	
			clip = new rfidClip(); //lib clip
		}		
		
		
		public function show($container:DisplayObjectContainer):void
		{
			container = $container;
			theStage = container.stage;	
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.alpha = 1;
			clip.theText.text = "TOUCH SCREEN TO ACTIVATE";
			container.addEventListener(MouseEvent.MOUSE_DOWN, screenClicked, false, 0, true);
		}		
		
		public function isShowing():Boolean
		{
			return showing;
		}
		
		
		public function hide():void
		{			
			container.removeEventListener(MouseEvent.MOUSE_DOWN, screenClicked);
			kill();
		}
		
		
		public function kill():void
		{			
			if(container){
				if(container.contains(clip)){
					container.removeChild(clip);
				}
			}			
			dispatchEvent(new Event(CLIP_REMOVED));
		}
		
		private function screenClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(CHECK_GOOD));
		}
		
	}
	
}