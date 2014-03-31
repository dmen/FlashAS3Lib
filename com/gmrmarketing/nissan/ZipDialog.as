package com.gmrmarketing.nissan
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;
	
	
	public class ZipDialog extends MovieClip
	{
		public static const ZIP_CLICK:String = "zipDialogOkClicked";		
		private var container:DisplayObjectContainer;
		
		
		
		public function ZipDialog($container:DisplayObjectContainer)
		{
			container = $container;
			
			btn7.theText.text = "7";
			btn8.theText.text = "8";
			btn9.theText.text = "9";			
			btn4.theText.text = "4";
			btn5.theText.text = "5";
			btn6.theText.text = "6";	
			btn1.theText.text = "1";
			btn2.theText.text = "2";
			btn3.theText.text = "3";
			btn0.theText.text = "0";
			
			btnOK.addEventListener(MouseEvent.CLICK, ok, false, 0, true);
			btnCancel.addEventListener(MouseEvent.CLICK, cancel, false, 0, true);
			btnBackspace.addEventListener(MouseEvent.CLICK, backSpace, false, 0, true);
			
			btn7.addEventListener(MouseEvent.CLICK, numPadClicked, false, 0, true);
			btn8.addEventListener(MouseEvent.CLICK, numPadClicked, false, 0, true);
			btn9.addEventListener(MouseEvent.CLICK, numPadClicked, false, 0, true);
			btn4.addEventListener(MouseEvent.CLICK, numPadClicked, false, 0, true);
			btn5.addEventListener(MouseEvent.CLICK, numPadClicked, false, 0, true);
			btn6.addEventListener(MouseEvent.CLICK, numPadClicked, false, 0, true);
			btn1.addEventListener(MouseEvent.CLICK, numPadClicked, false, 0, true);
			btn2.addEventListener(MouseEvent.CLICK, numPadClicked, false, 0, true);
			btn3.addEventListener(MouseEvent.CLICK, numPadClicked, false, 0, true);
			btn0.addEventListener(MouseEvent.CLICK, numPadClicked, false, 0, true);
		}
		
		
		
		public function show():void
		{			
			theZip.text = "";
			this.x = 650;
			this.y = 168;
			this.alpha = 0;
			container.addChild(this);
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
		
		
		
		private function ok(e:MouseEvent):void
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