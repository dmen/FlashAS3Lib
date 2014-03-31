package com.gmrmarketing.nissan
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;
	
	
	public class ZipDialog_web extends MovieClip
	{
		public static const ZIP_CLICK:String = "zipDialogOkClicked";		
		private var container:DisplayObjectContainer;
		
		
		
		public function ZipDialog_web($container:DisplayObjectContainer)
		{
			container = $container;		
			
			btnOK.addEventListener(MouseEvent.CLICK, ok, false, 0, true);
			btnCancel.addEventListener(MouseEvent.CLICK, cancel, false, 0, true);
			btnOK.buttonMode = true;
			btnCancel.buttonMode = true;
			addEventListener(KeyboardEvent.KEY_UP, checkEnter, false, 0, true);
		}
		
		
		private function checkEnter(e:KeyboardEvent):void
		{
			if (e.keyCode == 13) {
				ok();
			}
		}
		
		
		public function show():void
		{
			theZip.text = "";
			this.x = 521;
			this.y = 119;
			this.alpha = 0;
			container.addChild(this);
			stage.focus = this.theZip;
			TweenMax.to(this, .5, { alpha:1 } );
		}
		
		
		
		public function hide():void
		{
			container.removeChild(this);
		}
		
		
		
		public function getZip():String
		{
			var curZip:String = theZip.text;
			if (curZip != "" && curZip.length == 5) {
				return curZip;
			}
			return "";
		}
		
		
		
		private function backSpace(e:MouseEvent):void
		{
			var curZip:String = theZip.text;
			if (curZip.length > 0) {
				curZip = curZip.substr(0, curZip.length - 1);
				theZip.text = curZip;
			}
		}
		
		
		
		private function ok(e:MouseEvent = null):void
		{
			dispatchEvent(new Event(ZIP_CLICK));
			hide();
		}
		
		
		
		private function cancel(e:MouseEvent):void
		{
			hide();
		}
		
		
		
		private function numPadClicked(e:MouseEvent):void
		{
			var num:String = e.currentTarget.theText.text;
			var curZip:String = theZip.text;
			if (curZip.length < 5) {
				curZip += num;
				theZip.text = curZip;
			}
		}
	}
	
}