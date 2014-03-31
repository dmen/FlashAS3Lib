package com.gmrmarketing.comcast.laacademia2011
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.SharedObject;
	import com.greensock.TweenLite;
	
	public class PrizeDialogController extends EventDispatcher
	{
		public static const PRIZE_SAVED:String = "thePrizesAreSaved";
		
		private var dlg:MovieClip;
		private var container:DisplayObjectContainer;
		private var so:SharedObject;
		private var myData:Object;
		
		
		
		public function PrizeDialogController($container:DisplayObjectContainer)
		{
			container = $container;
			so = SharedObject.getLocal("scratchData");
			myData = so.data.dataObject;			
			
			//det defaults for myData if it's null - so getData() returns a proper object to ScratchOff
			if (myData == null) {
				populateDefaults();
			}
			
			dlg = new configDialog(); //lib clip
		}		
		
		
		
		public function showDialog():void
		{			
			dlg.percentError.alpha = 0;
			
			container.addChild(dlg);			
			
			myData = so.data.dataObject;
			
			if(myData != null){
				//populate
				dlg.t1.text = String(myData.t1);
				dlg.t2.text = String(myData.t2);
				dlg.t3.text = String(myData.t3);			
				dlg.grandNum.text = String(myData.grandNum);
				dlg.grandMin.text = String(myData.grandMin);
				
				if (myData.grandChecked == true) {
					dlg.checkGrand.gotoAndStop(2);
				}else {
					dlg.checkGrand.gotoAndStop(1);
				}
			}else {
				populateDefaults();
			}
			
			dlg.btnOK.addEventListener(MouseEvent.CLICK, saveDialog, false, 0, true);
			dlg.btnCancel.addEventListener(MouseEvent.CLICK, closeDialog, false, 0, true);
			dlg.t1Up.addEventListener(MouseEvent.CLICK, t1Up, false, 0, true);
			dlg.t1Down.addEventListener(MouseEvent.CLICK, t1Down, false, 0, true);
			dlg.t2Up.addEventListener(MouseEvent.CLICK, t2Up, false, 0, true);
			dlg.t2Down.addEventListener(MouseEvent.CLICK, t2Down, false, 0, true);
			dlg.t3Up.addEventListener(MouseEvent.CLICK, t3Up, false, 0, true);
			dlg.t3Down.addEventListener(MouseEvent.CLICK, t3Down, false, 0, true);
			dlg.prizesUp.addEventListener(MouseEvent.CLICK, pUp, false, 0, true);
			dlg.prizesDown.addEventListener(MouseEvent.CLICK, pDown, false, 0, true);
			dlg.timeUp.addEventListener(MouseEvent.CLICK, tUp, false, 0, true);
			dlg.timeDown.addEventListener(MouseEvent.CLICK, tDown, false, 0, true);
			dlg.checkGrand.addEventListener(MouseEvent.CLICK, toggleCheck, false, 0, true);
		}
		
		
		public function getData():Object
		{
			return myData;
		}
		
		
		public function isGrandPrizeTime():Boolean
		{
			var curTime:Number = new Date().valueOf(); //current epoch time
			if(myData.winTimes){
				if (curTime > myData.winTimes[0]) {
					return true;
				}
			}
			return false;
		}
		
		
		
		public function grandPrizeWon():void
		{
			myData.grandNum--;
			myData.winTimes.shift();
			if (myData.grandNum == 0) {
				myData.grandChecked = false;
			}
			
			so.data.dataObject = myData;
			so.flush();
		}
		
		
		private function populateDefaults():void
		{
			myData = new Object();
			myData.t1 = 60;
			myData.t2 = 30;
			myData.t3 = 10;
			myData.grandChecked = false;
			myData.winTimes = new Array();
		}
		
		/**
		 * Callback from pressing the OK button
		 * @param	e
		 */
		private function saveDialog(e:MouseEvent):void
		{
			var t1:int = parseInt(dlg.t1.text);
			var t2:int = parseInt(dlg.t2.text);
			var t3:int = parseInt(dlg.t3.text);
			
			if(t1 + t2 + t3 == 100){
				myData = new Object();
				
				myData.t1 = t1;
				myData.t2 = t2;
				myData.t3 = t3;
				
				myData.grandNum = parseInt(dlg.grandNum.text);
				myData.grandMin = parseInt(dlg.grandMin.text);
				myData.grandChecked = dlg.checkGrand.currentFrame == 1 ? false : true;
				
				var curTime:Number = new Date().valueOf(); //current epoch time
				var fullRange:Number = myData.grandMin * 60 * 1000; //milliseconds
				var segment:Number = fullRange / myData.grandNum;
				
				var wt:Array = new Array();
				for (var i:int = 0; i < myData.grandNum; i++) {
					wt.push(curTime + (segment * i) + (Math.random() * segment));
				}
				myData.winTimes = wt;
				
				so.data.dataObject = myData;
				so.flush();
				
				closeDialog();
				
			}else {
				dlg.percentError.alpha = 1;
				TweenLite.to(dlg.percentError, 1, { alpha:0, delay:1 } );
			}
		}
		
		
		/**
		 * Callback from pressing Cancel
		 * called from saveDialog
		 * @param	e
		 */
		private function closeDialog(e:MouseEvent = null):void
		{
			container.removeChild(dlg);
			
			dlg.btnOK.removeEventListener(MouseEvent.CLICK, saveDialog);
			dlg.btnCancel.removeEventListener(MouseEvent.CLICK, closeDialog);
			dlg.t1Up.removeEventListener(MouseEvent.CLICK, t1Up);
			dlg.t1Down.removeEventListener(MouseEvent.CLICK, t1Down);
			dlg.t2Up.removeEventListener(MouseEvent.CLICK, t2Up);
			dlg.t2Down.removeEventListener(MouseEvent.CLICK, t2Down);
			dlg.t3Up.removeEventListener(MouseEvent.CLICK, t3Up);
			dlg.t3Down.removeEventListener(MouseEvent.CLICK, t3Down);
			dlg.prizesUp.removeEventListener(MouseEvent.CLICK, pUp);
			dlg.prizesDown.removeEventListener(MouseEvent.CLICK, pDown);
			dlg.timeUp.removeEventListener(MouseEvent.CLICK, tUp);
			dlg.timeDown.removeEventListener(MouseEvent.CLICK, tDown);
			dlg.checkGrand.removeEventListener(MouseEvent.CLICK, toggleCheck);
			
			//prizing is not actually saved but this causes the listener on the dialog to be removed
			dispatchEvent(new Event(PRIZE_SAVED));
		}
		
		
		private function t1Up(e:MouseEvent):void
		{
			if(parseInt(dlg.t1.text) < 100){
				dlg.t1.text = String(parseInt(dlg.t1.text) + 5);
			}
		}
		
		
		private function t1Down(e:MouseEvent):void
		{
			if(parseInt(dlg.t1.text) > 0){
				dlg.t1.text = String(parseInt(dlg.t1.text) - 5);
			}
		}
		
		
		private function t2Up(e:MouseEvent):void
		{
			if(parseInt(dlg.t2.text) < 100){
				dlg.t2.text = String(parseInt(dlg.t2.text) + 5);
			}
		}
		
		
		private function t2Down(e:MouseEvent):void
		{
			if(parseInt(dlg.t2.text) > 0){
				dlg.t2.text = String(parseInt(dlg.t2.text) - 5);
			}
		}
		
		
		private function t3Up(e:MouseEvent):void
		{
			if(parseInt(dlg.t3.text) < 100){
				dlg.t3.text = String(parseInt(dlg.t3.text) + 5);
			}
		}
		
		
		private function t3Down(e:MouseEvent):void
		{
			if(parseInt(dlg.t3.text) > 0){
				dlg.t3.text = String(parseInt(dlg.t3.text) - 5);
			}
		}
		
		
		private function pUp(e:MouseEvent):void
		{
			dlg.grandNum.text = String(parseInt(dlg.grandNum.text) + 1);
		}
		
		
		private function pDown(e:MouseEvent):void
		{
			if(parseInt(dlg.grandNum.text) > 1){
				dlg.grandNum.text = String(parseInt(dlg.grandNum.text) - 1);
			}
		}
		
		
		private function tUp(e:MouseEvent):void
		{
			dlg.grandMin.text = String(parseInt(dlg.grandMin.text) + 10);
		}
		
		
		private function tDown(e:MouseEvent):void
		{
			if(parseInt(dlg.grandMin.text) > 10){
				dlg.grandMin.text = String(parseInt(dlg.grandMin.text) - 10);
			}
		}
		
		
		private function toggleCheck(e:MouseEvent):void
		{
			if (dlg.checkGrand.currentFrame == 1) {
				dlg.checkGrand.gotoAndStop(2);
			}else {
				dlg.checkGrand.gotoAndStop(1);
			}
		}
		
	}
	
}