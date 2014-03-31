package com.gmrmarketing.nissan.rodale.picstation
{
	import flash.display.MovieClip;
	import com.gmrmarketing.nissan.next.Clouds;	
	import com.gmrmarketing.nissan.next.XMLLoader;	
	import com.gmrmarketing.nissan.next.FleetViewer;	
	import com.gmrmarketing.nissan.next.ModelDetail;
	import com.gmrmarketing.nissan.next.GenericDialog;		
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.nissan.next.RFID;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.desktop.NativeApplication; //for quitting
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;	
	import flash.net.*;
	import flash.ui.Mouse;
	import flash.geom.Point;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	
	
	public class Main extends MovieClip
	{
		private var contentContainer:Sprite;
		
		private var xmlLoader:XMLLoader;
		private var clouds:Clouds;		
		private var fleetViewer:FleetViewer;		
		private var modelDetail:ModelDetail;		
		private var genericDialog:GenericDialog;
		private var quit:CornerQuit;
		private var currentSection:*;		
		private var timeoutHelper:TimeoutHelper;			
		private var iconMove:MovieClip;		
		private var iconSwype:MovieClip;
		private var iconContainer:Sprite;
		private var iconTimer:Timer;
		
		private var rfid:RFID;
		private var rfidURL:String;
		private var rfidSkip:CornerQuit;
		
		private var nav:MovieClip; //lib clip - logout button
		private var reset:CornerQuit;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			contentContainer = new Sprite();
			iconContainer = new Sprite();			
			
			quit = new CornerQuit();			
			quit.init(this, "ur");
			quit.customLoc(1, new Point(1216, 0));	
			quit.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			rfidSkip = new CornerQuit();
			rfidSkip.init(this, "ll");
			rfidSkip.customLoc(1, new Point(0, 618));
			rfidSkip.setSingleClick();
			rfidSkip.addEventListener(CornerQuit.CORNER_QUIT, rfidGood, false, 0, true);
			
			nav = new navClip(); //lib clip
			nav.y = 660;
			
			reset = new CornerQuit();
			reset.init(this, "lr");
			reset.customLoc(1, new Point(1216, 673));
			reset.setSingleClick();
			reset.addEventListener(CornerQuit.CORNER_QUIT, resetApplication, false, 0, true);
			
			timeoutHelper = TimeoutHelper.getInstance();
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, doReset, false, 0, true);
			timeoutHelper.init(120000);
			
			//lib clips	
			iconMove = new iconPinchZoomClip(); //for photos, circles
			iconSwype = new iconSwypeClip(); //for 360
			iconMove.x = 727;
			iconMove.y = 368;
			iconSwype.x = 710;
			iconSwype.y = 411;
			
			rfid = new RFID();
			
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			try{
				l.load(new URLRequest("config.xml"));
			}catch (e:Error) {
				quitApplication();
			}
		}
		
		
		
		private function configLoaded(e:Event):void
		{
			var data:XML = new XML(e.target.data);
			rfidURL = data.config.webServiceURL;
			
			loadFleetData();
		}
		
		
		
		private function loadFleetData():void
		{			
			xmlLoader = new XMLLoader();
			xmlLoader.addEventListener(XMLLoader.XML_LOADED, xmlLoaded, false, 0, true);
			xmlLoader.loadXML();
		}
		
		
		
		/**
		 * Called by listener once the fleet.xml has been loaded
		 * @param	e
		 */
		private function xmlLoaded(e:Event):void
		{
			clouds = new Clouds(this);
			addChild(contentContainer);
			addChild(iconContainer);			
			
			fleetViewer = new FleetViewer(xmlLoader.getFleetXML(), 140, -40);
			fleetViewer.addEventListener(FleetViewer.NEW_CAR_PICKED, showModelDetail, false, 0, true);
			
			modelDetail = new ModelDetail(xmlLoader.getFleetXML());
			modelDetail.addEventListener(ModelDetail.BACK_TO_LINEUP, restartClouds, false, 0, true);
			modelDetail.addEventListener(ModelDetail.VIEWING_360, show360Icon, false, 0, true);
			modelDetail.addEventListener(ModelDetail.VIEWING_PHOTO, showMoveIcon, false, 0, true);	
			genericDialog = new GenericDialog();
						
			timeoutHelper.startMonitoring();
			
			init();
		}
		
		
		private function init():void
		{
			while (iconContainer.numChildren) {
				iconContainer.removeChildAt(0);
			}
						
			fleetViewer.hide();
			modelDetail.hide();		
			navSelection();
			clouds.play();
			addChild(nav);
			rfid.show(this, rfidURL);
			rfid.addEventListener(RFID.CHECK_GOOD, rfidGood, false, 0, true);
			
			quit.moveToTop();
			rfidSkip.moveToTop();
			reset.moveToTop();
		}
		
		
		private function rfidGood(e:Event = null):void
		{
			rfid.hide();
		}
		
		
		/**
		 * Called from cornerQuit - by tapping four
		 * times at lower right
		 * @param	e
		 */
		private function resetApplication(e:Event):void
		{
			trace("reset");
			init();
		}		
				
		
		private function pauseClouds(e:Event = null):void
		{
			clouds.pause();	
		}
		
		
		/**
		 * Called from listener on ModelDetail and Innovations
		 * Called when the Back to model line-up button is pressed
		 */
		private function restartClouds(e:Event = null):void
		{
			clouds.play();
		}
		
		
		/**
		 * Called whenever a NAV_SELECTION event is dispatched from nav
		 * ie whenever the user makes a new nav pick
		 * @param	e Nav.NAV_SELECTION event
		 */
		private function navSelection(e:Event = null):void
		{
			timeoutHelper.buttonClicked();
			
			killMove();
			killSwype();
			
			//sel will be innovation,models,whichCar,cool,coolEntry,submit
			var sel:String = "models";
			
			//trace(currentSection,sel);
			if (currentSection) {				
				
				if (currentSection == modelDetail) {
					if(sel != "models"){
						fleetViewer.hide();
					}
					//trace("threemodels");
					modelDetail.closeModules();//calls hide on photo,video,360,features
					modelDetail.hide();
					clouds.play();
				}
			}
			
			switch(sel) {
				case "models":
					fleetViewer.show(contentContainer, "all");					
					currentSection = fleetViewer;
					break;				
			}
			
			quit.moveToTop();			
		}
		
		
		
		/**
		 * Called when a car is picked in the fleet viewer
		 * @param	e FleetViewer.NEW_CAR_PICKED
		 */
		private function showModelDetail(e:Event):void
		{
			timeoutHelper.buttonClicked();
			pauseClouds();					
			modelDetail.show(contentContainer, fleetViewer.getCarId());			
			currentSection = modelDetail;
		}
		
		
		/**
		 * Called from listener on ModelDetail when user clicks a 360 button
		 * @param	e
		 */
		private function show360Icon(e:Event):void
		{
			showIcon("swype");
		}
		
		
		private function showMoveIcon(e:Event):void
		{
			showIcon("move");
		}
		
		
		/**
		 * 
		 * @param	which String either swype or move
		 */
		private function showIcon(which:String):void
		{
			if (which == "swype") {
				iconSwype.alpha = 0;
				iconSwype.scaleX = iconSwype.scaleY = 3;
				iconContainer.addChild(iconSwype);
				iconTimer = new Timer(1500, 1);
				iconTimer.addEventListener(TimerEvent.TIMER, showSwype, false, 0, true);
				iconTimer.start();
			}else {
				iconMove.alpha = 0;
				iconMove.scaleX = iconMove.scaleY = 3;
				iconContainer.addChild(iconMove);
				iconTimer = new Timer(1500, 1);
				iconTimer.addEventListener(TimerEvent.TIMER, showMove, false, 0, true);
				iconTimer.start();
			}
		}
		
		
		private function showSwype(e:TimerEvent):void
		{
			iconSwype.alpha = 1;
			iconSwype.gotoAndPlay(1);			
			TweenMax.to(iconSwype, 1, { alpha:0, delay:1.5, onComplete:killSwype } );
		}
		
		
		private function showMove(e:TimerEvent):void
		{
			iconMove.alpha = 1;
			iconMove.gotoAndPlay(1);
			iconMove.hand.gotoAndPlay(1);
			TweenMax.to(iconMove, 1, { alpha:0, delay:1.5, onComplete:killMove } );
		}
		
		
		private function killSwype():void
		{
			if(iconTimer){
				iconTimer.reset();
			}
			if (iconContainer.contains(iconSwype)) {
				iconContainer.removeChild(iconSwype);
				iconSwype.stop();				
			}
		}
		
		
		private function killMove():void
		{
			if(iconTimer){
				iconTimer.reset();
			}
			if (iconContainer.contains(iconMove)) {
				iconContainer.removeChild(iconMove);
				iconMove.stop();
				iconMove.hand.stop();
			}
		}
		
		
		/**
		 * Called by clicking four times at lower left
		 * @param	e
		 */
		private function quitApplication(e:Event = null):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		/**
		 * Called from listener on timeoutHelper
		 * called when no user activity for specified time
		 * @param	e
		 */
		private function doReset(e:Event):void
		{			
				init();			
		}
		
	}
	
}