package com.gmrmarketing.testing
{
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.utils.Timer;
	import org.wiiflash.Wiimote;
	import org.wiiflash.events.ButtonEvent;
	import org.wiiflash.events.WiimoteEvent;
	import flash.events.*;
	
	
	public class CowboyWii extends Sprite
	{
		// create a new Wiimote
		private var myWiimote:Wiimote;
		private var cowboyTimer:Timer;
		private var theDot:Sprite;	

		private var lastX:Number = 350;
		private var lastY:Number;
		private var crossTimer:Timer;
		
		
		
		public function CowboyWii()
		{
			myWiimote = new Wiimote();
			// connect wiimote to WiiFlash Server
			myWiimote.connect ();
			
			/*
			// makes the wiimote rumble on click
			stage.addEventListener ( MouseEvent.CLICK, onClick );		
			function onClick ( pEvt:MouseEvent ):void
			{	
				myWiimote.rumbleTimeout = 1000;	
			}
			*/
			
			myWiimote.addEventListener( ButtonEvent.B_PRESS, onBPressed );
			myWiimote.addEventListener( ButtonEvent.B_RELEASE, onBReleased);

			myWiimote.addEventListener( Event.CONNECT, onWiimoteConnect );
			myWiimote.addEventListener( IOErrorEvent.IO_ERROR, onWiimoteConnectError );
			myWiimote.addEventListener( Event.CLOSE, onCloseConnection );

			myWiimote.addEventListener( WiimoteEvent.UPDATE, onUpdated );
			
			theDot = new Sprite();
			theDot.graphics.lineStyle(3, 0xFF0000);
			theDot.graphics.drawCircle(0,0,20);
			
			theDot.graphics.lineStyle(1, 0x990000);
			theDot.graphics.moveTo(0, -10);
			theDot.graphics.lineTo(0, 10);
			theDot.graphics.moveTo(-10, 0);
			theDot.graphics.lineTo(10, 0);
			
			addChild(theDot);
			
			cowboyTimer = new Timer(4000, 1);
			cowboyTimer.addEventListener(TimerEvent.TIMER, popUpCowboy, false, 0, true);
			cowboyTimer.start();			
			
			crossTimer = new Timer(100);
			crossTimer.addEventListener(TimerEvent.TIMER, moveCrossHair);
			crossTimer.start();
		}

		private function onCloseConnection ( pEvent:Event ):void
		{	
			//connection closed, WiiFlash Server has been closed				
		}

		private function onWiimoteConnectError ( pEvent:IOErrorEvent ):void
		{	
			//Couldn't connect, make sure WiiFlash Server is running	
		}

		private function onWiimoteConnect ( pEvent:Event ):void
		{				
			//Wiimote successfully connected	
		}


		private function onBPressed ( pEvt:ButtonEvent ):void 
		{	
			//point collision with dot
			if (theBar.cowboy.hitTestPoint(theDot.x, theDot.y, true)) {
				theBar.cowboy.gotoAndPlay(2);
			}
		}

		private function onBReleased ( pEvt:ButtonEvent ):void
		{			
		}

		private function popUpCowboy(e:TimerEvent):void
		{
			theBar.gotoAndPlay(2);
			cowboyTimer.removeEventListener(TimerEvent.TIMER, popUpCowboy);
			cowboyTimer = new Timer(3000,1);
			cowboyTimer.addEventListener(TimerEvent.TIMER, popDownCowboy, false, 0, true);
			cowboyTimer.start();
		}
		private function popDownCowboy(e:TimerEvent):void
		{
			theBar.gotoAndPlay(16);
			cowboyTimer.removeEventListener(TimerEvent.TIMER, popDownCowboy);
			cowboyTimer = new Timer(4000,1);
			cowboyTimer.addEventListener(TimerEvent.TIMER, popUpCowboy, false, 0, true);
			cowboyTimer.start();
		}

		private function onUpdated ( pEvt:WiimoteEvent ):void
		{	
			var inf = pEvt.target;
			lastX += pEvt.target.sensorX * 13;
			lastY = 290 + ((pEvt.target.pitch * 2) * 290);
			
			info.text = "X:"+inf.sensorX+"\n"+"Y:"+inf.sensorY+"\n"+"Z:"+inf.sensorZ+"\n"+"Roll:"+inf.roll+"\n"+"Pitch:"+inf.pitch+"\n"+"Yaw:"+inf.yaw+"\n"+"Battery:"+inf.batteryLevel;
			
		}

		private function moveCrossHair(e:TimerEvent):void
		{
			if (lastX < 0) { lastX = 0; }
			if (lastX > stage.stageWidth) { lastX = stage.stageWidth; }
			if (lastY < 0) { lastY = 0; }
			if (lastY > stage.stageHeight) { lastY = stage.stageHeight; }
			TweenLite.to(theDot, .5 ,{x:lastX, y:lastY});
		}
	}
	
}