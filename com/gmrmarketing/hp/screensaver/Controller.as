package com.gmrmarketing.hp.screensaver
{	
	import com.gmrmarketing.hp.screensaver.Row;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.system.fscommand;
	import com.greensock.TweenMax;
	
	public class Controller extends MovieClip
	{		
		private var r1:Row;
		private var r2:Row;
		private var r3:Row;
		private var r4:Row;
		private var r5:Row;
		private var r6:Row;
		private var r7:Row;
		private var r8:Row;
		private var r9:Row;
		private var r10:Row;
		private var r11:Row;
		private var r12:Row;
		private var r13:Row;
		private var r14:Row;
		private var r15:Row;
		private var r16:Row;
		private var r17:Row;
		private var r18:Row;
		private var r19:Row;
		
		private var rows:Array;
		private var changeTimer:Timer;
		private var rowMonitor:Timer; //monitors row 1
		
		private var theCover:MovieClip; //lib clip for covering text while resetting
		
		//row1: -1412 to 0 -r
		//row2: 0 to -1370 -l
		//row3: -1356 to 0 -r
		//row4: 0 to -1336 -l
		//row5: -1387 to 0 -r
		//row6: 0 to -1358 -l
		//row7: -1354 to 0 -r
		//row8: 0 to -1372 -l
		//row9: -1436 to 0 -r
		//row10: 0 to -1458 -l
		//row11: -1380 to 0 -r
		public function Controller()
		{	
			//stage.displayState = StageDisplayState.FULL_SCREEN;
			//stage.scaleMode = StageScaleMode.EXACT_FIT; 
			
			changeTimer = new Timer(1500);
			changeTimer.addEventListener(TimerEvent.TIMER, changeRow, false, 0, true);
			changeTimer.start();
			
			rowMonitor = new Timer(250);
			rowMonitor.addEventListener(TimerEvent.TIMER, monitorRow, false, 0, true);
			rowMonitor.start();
			
			r1 = new Row(new row1());	
			r1.setData( -1412, 0, .5);			
			addChild(r1);			
			
			r2 = new Row(new row2());
			r2.setData(0, -1370, -.5);
			r2.y = 40;
			addChild(r2);
			
			r3 = new Row(new row3());
			r3.setData(-1356,0,.5);
			r3.y = 80;
			addChild(r3);
			
			r4 = new Row(new row4());
			r4.setData(0,-1336,-.5);
			r4.y = 120;
			addChild(r4);
			
			r5 = new Row(new row5());
			r5.setData(-1387,0,.5);
			r5.y = 160;
			addChild(r5);
			
			r6 = new Row(new row6());
			r6.setData(0,-1358,-.5);
			r6.y = 200;
			addChild(r6);
			
			r7 = new Row(new row7());
			r7.setData(-1354,0,.5);
			r7.y = 240;
			addChild(r7);
			
			r8 = new Row(new row8());
			r8.setData(0,-1372,-.5);
			r8.y = 280;
			addChild(r8);
			
			r9 = new Row(new row9());
			r9.setData(-1436,0,.5);
			r9.y = 320;
			addChild(r9);
			
			r10 = new Row(new row10());
			r10.setData(0,-1458,-.5);
			//r10.x = 0;
			r10.y = 360;
			addChild(r10);
			
			r11 = new Row(new row11());
			r11.setData(-1380,0,.5);
			r11.y = 400;
			addChild(r11);
			
			r12 = new Row(new row2());
			r12.setData(0, -1370, -.5);
			r12.y = 440;
			addChild(r12);
			
			r13 = new Row(new row3());
			r13.setData(-1356,0,.5);
			r13.y = 480;
			addChild(r13);
			
			r14 = new Row(new row4());
			r14.setData(0,-1336,-.5);
			r14.y = 520;
			addChild(r14);
			
			r15 = new Row(new row5());
			r15.setData(-1387,0,.5);
			r15.y = 560;
			addChild(r15);
			
			r16 = new Row(new row6());
			r16.setData(0,-1358,-.5);
			r16.y = 600;
			addChild(r16);
			
			r17 = new Row(new row7());
			r17.setData(-1354,0,.5);
			r17.y = 640;
			addChild(r17);
			
			r18 = new Row(new row8());
			r18.setData(0,-1372,-.5);
			r18.y = 680;
			addChild(r18);
			
			r19 = new Row(new row9());
			r19.setData(-1436,0,.5);
			r19.y = 720;
			addChild(r19);
			
			rows = new Array(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19);
			
			theCover = new cover();
			theCover.x = 0;
			theCover.y = 0;
			theCover.alpha = 0;
		}
		
		
		private function changeRow(e:TimerEvent):void
		{
			var randRow:Row = rows[Math.floor(Math.random() * rows.length)];			
			randRow.changeWidth();
		}
		
		
		private function monitorRow(e:TimerEvent):void
		{
			if (r1.getX() > -150) {
				rowMonitor.stop();
				changeTimer.stop();
				showCover();
			}
		}
		
		
		private function showCover():void
		{
			addChild(theCover);
			TweenMax.to(theCover, .5, { alpha:1, onComplete:hideCover } );
		}
		
		
		private function hideCover():void
		{
			for (var i:int = 0; i < rows.length; i++) {
				Row(rows[i]).reset();
			}
			TweenMax.to(theCover, .5, { alpha:0, delay:3, onComplete:killCover } );
		}
		
		
		private function killCover():void
		{
			rowMonitor.start();
			changeTimer.start();
			removeChild(theCover);
		}
	}
	
}