package com.gmrmarketing.comcast.scratchoff
{	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Sprite;
	import com.gmrmarketing.utilities.LocalFile;
	import com.greensock.TweenLite;
	import flash.utils.Timer;
	
	
	public class Admin extends MovieClip
	{
		private var lf:LocalFile;
		private var theData:Object;
		private var reportingObject:Object;
		
		public function Admin($reportingObject:Object)
		{
			//uses AIR file classes
			lf = LocalFile.getInstance();
			
			reportingObject = $reportingObject;
			
			theData = new Object();
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);			
		}


		private final function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			btnSave.addEventListener(MouseEvent.MOUSE_DOWN, saveClicked, false, 0, true);
			btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeClicked, false, 0, true);
			
			tabConfig.addEventListener(MouseEvent.MOUSE_DOWN, configClicked, false, 0, true);
			tabReporting.addEventListener(MouseEvent.MOUSE_DOWN, reportingClicked, false, 0, true);
			
			scratch.gotoAndStop(1);
			punch.gotoAndStop(1);
			sixers.gotoAndStop(1);
			flyers.gotoAndStop(1);
			
			scratch.addEventListener(MouseEvent.MOUSE_DOWN, scratchSelect, false, 0, true);
			punch.addEventListener(MouseEvent.MOUSE_DOWN, punchSelect, false, 0, true);
			sixers.addEventListener(MouseEvent.MOUSE_DOWN, sixersSelect, false, 0, true);
			flyers.addEventListener(MouseEvent.MOUSE_DOWN, flyersSelect, false, 0, true);
			generic.addEventListener(MouseEvent.MOUSE_DOWN, genericSelect, false, 0, true);
			
			theData = lf.load();
			
			if(theData.error == "ok"){	
			
				if(theData.gameType == "scratch"){
					scratch.gotoAndStop(2);
				}else{
					punch.gotoAndStop(2);
				}
				
				if(theData.gameTheme == "sixers"){
					sixers.gotoAndStop(2);
				}else if(theData.gameTheme == "flyers"){
					flyers.gotoAndStop(2);
				}else {
					generic.gotoAndStop(2);
				}
				
				var j:int;
				
				var prizes:Array = theData.prizes;
				for(j = 1; j < prizes.length; j++){
					this["prize" + j].text = prizes[j];
				}	
				
				var descriptions:Array = theData.descriptions;
				for(j = 1; j < descriptions.length; j++){
					this["prize" + j + "d"].text = descriptions[j];
				}
			}	
		}
		
		private function configClicked(e:MouseEvent):void
		{
			gotoAndStop(1);
			init();
		}
		public function setReportingObject(o:Object):void
		{
			reportingObject = o;
		}
		public function reportingClicked(e:MouseEvent = null):void
		{
			gotoAndStop(2);
			//data object contains scratch,punch,prizes properties
			//scratch and punch are arrays of three items - started,won,lost counts
			//prizes is an object containing slice names as keys and counts as values
			var punch:Array = reportingObject.punch;
			punchStarted.text = String(punch[0]);
			punchWon.text = String(punch[1]);
			punchLost.text = String(punch[2]);
			punchAbandoned.text = String(punch[0] - (punch[1] + punch[2]));
			
			var scratch:Array = reportingObject.scratch;
			scratchStarted.text = String(scratch[0]);
			scratchWon.text = String(scratch[1]);
			scratchLost.text = String(scratch[2]);
			scratchAbandoned.text = String(scratch[0] - (scratch[1] + scratch[2]));
			
			var prizes:Object = reportingObject.prizes;
			prizeList.text = "";
			for (var i:String in prizes) 
			{ 
				prizeList.appendText(i + ": " + prizes[i] + "\n"); 
			} 
			
			//call this to make sure the dialog isn't showing
			cancelClicked();
			
			btnReset.addEventListener(MouseEvent.MOUSE_DOWN, resetClicked, false, 0, true);
		}
		
		private function resetClicked(e:MouseEvent):void
		{
			resetConfirm.visible = true;
			resetConfirm.btnReset.addEventListener(MouseEvent.MOUSE_DOWN, resetConfirmed, false, 0, true);
			resetConfirm.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelClicked, false, 0, true);
		}
		
		private function resetConfirmed(e:MouseEvent):void
		{
			dispatchEvent(new Event("resetReporting"));
			cancelClicked();
		}
		
		private function cancelClicked(e:MouseEvent = null):void
		{
			resetConfirm.visible = false;
			resetConfirm.btnReset.removeEventListener(MouseEvent.MOUSE_DOWN, resetConfirmed);
			resetConfirm.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelClicked);
		}
		
		private function scratchSelect(e:MouseEvent):void
		{
			scratch.gotoAndStop(2);
			punch.gotoAndStop(1);
		}
		private function punchSelect(e:MouseEvent):void
		{
			scratch.gotoAndStop(1);
			punch.gotoAndStop(2);
		}
		private function sixersSelect(e:MouseEvent):void
		{
			sixers.gotoAndStop(2);
			generic.gotoAndStop(1);
			flyers.gotoAndStop(1);
		}
		private function flyersSelect(e:MouseEvent):void
		{
			sixers.gotoAndStop(1);
			generic.gotoAndStop(1);
			flyers.gotoAndStop(2);
		}
		private function genericSelect(e:MouseEvent):void
		{
			sixers.gotoAndStop(1);
			flyers.gotoAndStop(1);
			generic.gotoAndStop(2);
		}


		private final function saveClicked(e:MouseEvent):void
		{
			theData = new Object();
			
			alert.tester.text = "Saving, please wait...";
			alert.alpha = 1;
			TweenLite.to(alert, 2, { alpha:0, delay:.5 } );
			
			var gameType:String = scratch.currentFrame == 2 ? "scratch" : "punch";		
			
			var gameTheme:String;
			if (sixers.currentFrame == 2) {
				gameTheme = "sixers";
			}else if (flyers.currentFrame == 2) {
				gameTheme = "flyers";
			}else {
				gameTheme = "generic";
			}
			
			var prizes:Array = new Array();	
			prizes.push(" ");
			prizes.push(prize1.text);
			prizes.push(prize2.text);
			prizes.push(prize3.text);
			prizes.push(prize4.text);
			prizes.push(prize5.text);
			prizes.push(prize6.text);
			prizes.push(prize7.text);
			prizes.push(prize8.text);
			
			var descriptions:Array = new Array();
			descriptions.push(" ");
			descriptions.push(prize1d.text);
			descriptions.push(prize2d.text);
			descriptions.push(prize3d.text);
			descriptions.push(prize4d.text);
			descriptions.push(prize5d.text);
			descriptions.push(prize6d.text);
			descriptions.push(prize7d.text);
			descriptions.push(prize8d.text);
			
			theData.gameType = gameType;
			theData.gameTheme = gameTheme;
			theData.prizes = prizes;
			theData.descriptions = descriptions;
			
			lf.save(theData);
			
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
		private final function closeClicked(e:MouseEvent = null):void
		{
			dispatchEvent(new Event("closeAdmin"));
		}
		
	}
	
}