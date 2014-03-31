package com.gmrmarketing.comcast.scratchnew
{	
	import flash.display.*;
	import flash.events.*;	
	import com.greensock.TweenLite;
	import flash.utils.Timer;
	import com.gmrmarketing.comcast.scratchnew.AdminFile;
	import flash.text.TextField;
	
	public class Admin extends EventDispatcher
	{
		public static const ADMIN_CLOSED:String = "adminClosed";
		public static const RESET:String = "resetReporting";
		
		private var af:AdminFile;
		private var theData:Object;
		private var reportingObject:Object;
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Admin()
		{
			clip = new adminClip(); //lib clip
			
			//uses AIR file classes
			af = new AdminFile();//init of constructor populates data object					
		}
		
		
		public function getData():Object
		{
			if (theData == null) {
				theData = af.getData();
			}
			return theData;
		}


		public function show($container:DisplayObjectContainer):void
		{		
			container = $container;
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.gotoAndStop(1);
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeClicked, false, 0, true);
			clip.tabConfig.addEventListener(MouseEvent.MOUSE_DOWN, configClicked, false, 0, true);
			clip.tabReporting.addEventListener(MouseEvent.MOUSE_DOWN, reportingClicked, false, 0, true);			
			init();
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}			
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeClicked);			
			clip.tabConfig.removeEventListener(MouseEvent.MOUSE_DOWN, configClicked);
			clip.tabReporting.removeEventListener(MouseEvent.MOUSE_DOWN, reportingClicked);			
		}
		
		
		private function init():void
		{			
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, saveClicked, false, 0, true);			
			
			theData = af.getData();
			
			var prizes:Array = theData.prizes;
			var descriptions:Array = theData.descriptions;
			
			clip.percent.restrict = "0-9";
			clip.percent.text = theData.winPercent;
		
			for (var j:int = 0; j < 8; j++) {				
				clip["prize" + (j + 1)].text = prizes[j];
				clip["prize" + (j + 1) + "d"].text = descriptions[j];				
			}			
		}
		
		
		private function configClicked(e:MouseEvent):void
		{
			clip.gotoAndStop(1);
			init();			
		}
		
		public function reportingClicked(e:MouseEvent = null):void
		{
			clip.gotoAndStop(2);			
			
			var scratch:Array = theData.scratch;
			clip.scratchStarted.text = String(scratch[0]);
			clip.scratchWon.text = String(scratch[1]);
			clip.scratchLost.text = String(scratch[2]);
			clip.scratchAbandoned.text = String(scratch[0] - (scratch[1] + scratch[2]));
			
			var prizes:Object = theData.prizes;
			clip.prizeList.text = "";
			for (var i:String in prizes) 
			{ 
				clip.prizeList.appendText(i + ": " + prizes[i] + "\n"); 
			} 
			
			//call this to make sure the reset dialog isn't showing
			cancelClicked();
			
			clip.btnReset.addEventListener(MouseEvent.MOUSE_DOWN, resetClicked, false, 0, true);
		}
		
		
		private function resetClicked(e:MouseEvent):void
		{
			clip.resetConfirm.visible = true;
			clip.resetConfirm.btnReset.addEventListener(MouseEvent.MOUSE_DOWN, resetConfirmed, false, 0, true);
			clip.resetConfirm.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelClicked, false, 0, true);
		}
		
		
		private function resetConfirmed(e:MouseEvent):void
		{
			dispatchEvent(new Event(RESET));
			cancelClicked();
		}
		
		
		/**
		 * Called from Main once a RESET event is received
		 */
		public function doReset():void
		{
			af.resetScratchData();
			cancelClicked();//close the reset dialog
			reportingClicked(); //to display data change
		}
		
		private function cancelClicked(e:MouseEvent = null):void
		{
			clip.resetConfirm.visible = false;
			clip.resetConfirm.btnReset.removeEventListener(MouseEvent.MOUSE_DOWN, resetConfirmed);
			clip.resetConfirm.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelClicked);
		}
		


		private function saveClicked(e:MouseEvent):void
		{
			theData = new Object();
			var oldData:Object = af.getData(); //need this for scratch reporting data
			
			clip.alert.tester.text = "Saving, please wait...";
			clip.alert.alpha = 1;
			TweenLite.to(clip.alert, 2, { alpha:0, delay:.5 } );
			
			var prizes:Array = new Array();			
			prizes.push(clip.prize1.text);
			prizes.push(clip.prize2.text);
			prizes.push(clip.prize3.text);
			prizes.push(clip.prize4.text);
			prizes.push(clip.prize5.text);
			prizes.push(clip.prize6.text);
			prizes.push(clip.prize7.text);
			prizes.push(clip.prize8.text);
			
			var descriptions:Array = new Array();			
			descriptions.push(clip.prize1d.text);
			descriptions.push(clip.prize2d.text);
			descriptions.push(clip.prize3d.text);
			descriptions.push(clip.prize4d.text);
			descriptions.push(clip.prize5d.text);
			descriptions.push(clip.prize6d.text);
			descriptions.push(clip.prize7d.text);
			descriptions.push(clip.prize8d.text);
			
			theData.scratch = oldData.scratch;
			theData.prizes = prizes;
			theData.descriptions = descriptions;
			theData.winPercent = Number(clip.percent.text);
			
			af.save(theData);
			
			//.5 second delay because saving is asynhronous and we need to wait
			//because the closeAdmin event causes init() in Main to run and reload
			//the data from the file - if we don't wait the file contents will be undefined
			var t:Timer = new Timer(500, 1);
			t.addEventListener(TimerEvent.TIMER, saveTimer, false, 0, true);
			t.start();
		}
		
		
		private function saveTimer(e:TimerEvent):void
		{
			closeClicked();
		}
		
		
		//listened for by Main
		private function closeClicked(e:MouseEvent = null):void
		{
			dispatchEvent(new Event(ADMIN_CLOSED));
		}
		
	}
	
}