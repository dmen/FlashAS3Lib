package com.gmrmarketing.associatedbank.mnwild
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import flash.net.SharedObject;
	
	
	public class ConfigDialog
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var so:SharedObject;
		
		
		public function ConfigDialog()
		{
			clip = new mcConfig();
			
			so = SharedObject.getLocal("mnWildConfig");
			
			if (so.data.numSec == undefined) {
				so.data.numSec = 5;
				so.data.nth = 10;
				so.flush();
			}
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.numSec.text = String(so.data.numSec);
			clip.nth.text = String(so.data.nth);
			
			calcFrames();
			
			clip.numSec.addEventListener(Event.CHANGE, calcFrames, false, 0, true);
			clip.nth.addEventListener(Event.CHANGE, calcFrames, false, 0, true);
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1 } );			
			
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, saveConfig, false, 0, true);
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeConfig, false, 0, true);
		}
		
		
		public function get data():Object
		{
			var o:Object = { };
			o.numSec = so.data.numSec;
			o.nth = so.data.nth;
			
			return o;
		}
		
		
		private function closeConfig(e:MouseEvent = null):void
		{
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			clip.numSec.removeEventListener(Event.CHANGE, calcFrames);
			clip.nth.removeEventListener(Event.CHANGE, calcFrames);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, saveConfig);
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeConfig);
			
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function calcFrames(e:Event = null):void
		{
			clip.theText.text = "Capturing " + String(parseInt(clip.numSec.text) * (30 / parseInt(clip.nth.text))) + " frames";
		}
		
		
		private function saveConfig(e:MouseEvent):void
		{
			so.data.numSec = parseInt(clip.numSec.text);
			so.data.nth = parseInt(clip.nth.text);
			so.flush();
			
			closeConfig();
		}
		
	}
	
}