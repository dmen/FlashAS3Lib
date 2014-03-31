package com.gmrmarketing.comcast.vodipad
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
		
		public function Admin()
		{
			//uses AIR file classes
			lf = LocalFile.getInstance();
			
			theData = new Object();
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);			
		}


		private final function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			btnSave.addEventListener(MouseEvent.MOUSE_DOWN, saveClicked, false, 0, true);
			btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeClicked, false, 0, true);
			
			theData = lf.load();
			
			if(theData.error == "ok"){	
				
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
		

		private final function saveClicked(e:MouseEvent):void
		{
			theData = new Object();
			
			alert.tester.text = "Saving, please wait...";
			alert.alpha = 1;
			TweenLite.to(alert, 2, { alpha:0, delay:.5 } );
			
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