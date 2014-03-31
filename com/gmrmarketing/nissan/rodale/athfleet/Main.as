package com.gmrmarketing.nissan.rodale.athfleet
{	
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.display.MovieClip;	
	import flash.events.*;	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.nissan.rodale.athfleet.RFID;
	import com.gmrmarketing.nissan.rodale.athfleet.Sliders;
	import com.gmrmarketing.nissan.rodale.athfleet.Results;
	import com.gmrmarketing.nissan.rodale.athfleet.XMLLoader;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication; //for quitting
	import flash.filesystem.File;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	
	
	public class Main extends MovieClip
	{				
		private var rfid:RFID;
		private var sliders:Sliders;
		private var results:Results;
		private var xmlLoader:XMLLoader;
		
		private var calculating:MovieClip;//dialog between sliders and results
		
		private var skip:CornerQuit;
		private var quit:CornerQuit;
		
		private var timeoutHelper:TimeoutHelper;
		
		private var process:NativeProcess;//these for the virtual keyboard
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;
		
		
		public function Main()
		{			
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			//for closing the onscreen keyboard
			nativeProcessStartupInfo = new NativeProcessStartupInfo();			

			calculating = new dialogCalculating(); //lib clip
			calculating.dotAnim.stop();
			calculating.x = 648;
			calculating.y = 400;
			
			skip = new CornerQuit();
			quit = new CornerQuit();
			skip.init(this, "ul");
			skip.setSingleClick();			
			quit.init(this, "ll");
			quit.customLoc(1, new Point(0, 930));
			skip.addEventListener(CornerQuit.CORNER_QUIT, skipRFID, false, 0, true);
			quit.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			timeoutHelper = TimeoutHelper.getInstance();
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, doReset, false, 0, true);
			timeoutHelper.init(120000);
			
			xmlLoader = new XMLLoader();
			xmlLoader.addEventListener(XMLLoader.XML_LOADED, init, false, 0, true);
			xmlLoader.loadXML();
		}
		
		
		private function init(e:Event = null):void
		{
			//hideKeyboard();
			
			sliders = new Sliders(this);			
			rfid = new RFID(this, xmlLoader.getSliderXML());
			results = new Results(this, xmlLoader.getFleetXML(), xmlLoader.getSliderXML());			
			
			rfid.addEventListener(RFID.CHECK_BAD, badID, false, 0, true);
			rfid.addEventListener(RFID.CHECK_GOOD, goodID, false, 0, true);
			rfid.show();
			
			skip.moveToTop();
			quit.moveToTop();
			
			timeoutHelper.stopMonitoring();
		}
		
		
		private function badID(e:Event):void
		{
			//rfid clip already showing bad id message
			//wait then reset clip to waiting for rfid scan
			var t:Timer = new Timer(3000, 1);
			t.addEventListener(TimerEvent.TIMER, resetRFID, false, 0, true);
			t.start();
		}
		
		
		/**
		 * Called when upper left invis skip spot is tapped
		 * @param	e
		 */
		private function skipRFID(e:Event):void
		{
			rfid.setName();//sets name to Guest and registeredOnFacebook to 0
			goodID();
		}
		
		
		private function resetRFID(e:TimerEvent):void
		{
			rfid.show();
		}
		
		
		private function goodID(e:Event = null):void
		{	
			sliders.init(xmlLoader.getSliderXML());
			sliders.show(rfid.getName());
			sliders.addEventListener(Sliders.SUBMITTED, showResults, false, 0, true);
			sliders.addEventListener(Sliders.CLIP_ADDED, removeRFIDClip, false, 0, true);
			quit.moveToTop();
			timeoutHelper.startMonitoring();
		}
		
		
		private function removeRFIDClip(e:Event):void
		{
			rfid.hide();
		}
		
		
		/**
		 * Called when SUBMITTED event id dispatched from Sliders
		 * @param	e
		 */
		private function showResults(e:Event):void
		{
			sliders.removeEventListener(Sliders.SUBMITTED, showResults);
			
			calculating.alpha = 0;
			addChild(calculating);
			calculating.dotAnim.play();
			TweenMax.to(calculating, .5, { alpha:1 } );
			
			var calcTimer:Timer = new Timer(3000, 1);
			calcTimer.addEventListener(TimerEvent.TIMER, removeCalcDialog, false, 0, true);
			calcTimer.start();
		}
		
		
		private function removeCalcDialog(e:TimerEvent):void
		{
			calculating.dotAnim.stop();
			removeChild(calculating);
			
			var athletes:Array = sliders.getAthletes();
			var totals:Array = sliders.getTotals();
			var index:int = totals[0][0]; //index in athletes array
			
			var sliderXML:XML = xmlLoader.getSliderXML();
			var aths:XMLList = sliderXML.athletes.athlete;
			var ath:XML = aths[index];
			
			results.addEventListener(Results.CLIP_ADDED, removeSliders, false, 0, true);
			results.addEventListener(Results.TRY_AGAIN, doReset, false, 0, true);
			results.show(ath, rfid.getName(), rfid.getFB(), rfid.getRFID());
			
			quit.moveToTop();
		}
		
		
		private function removeSliders(e:Event):void
		{
			results.removeEventListener(Results.CLIP_ADDED, removeSliders);
			sliders.hide();
		}
		
		private function doReset(e:Event):void
		{
			init();
		}
		
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		/*
		private function hideKeyboard(e:Event = null):void
		{
			try{
				if(NativeProcess.isSupported){
					var file:File = File.desktopDirectory.resolvePath("hideKB.exe");
					nativeProcessStartupInfo.executable = file;
					
					process = new NativeProcess();
					process.start(nativeProcessStartupInfo);
				}
			}catch (e:Error) {
			
			}
		}
		*/
		
	}	
}