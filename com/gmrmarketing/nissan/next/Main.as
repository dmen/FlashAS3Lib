package com.gmrmarketing.nissan.next
{
	import flash.display.MovieClip;
	import com.gmrmarketing.nissan.next.Clouds;
	import com.gmrmarketing.nissan.next.RFID;
	import com.gmrmarketing.nissan.next.XMLLoader;
	import com.gmrmarketing.nissan.next.Welcome;
	import com.gmrmarketing.nissan.next.Nav;
	import com.gmrmarketing.nissan.next.FleetViewer;
	import com.gmrmarketing.nissan.next.Cool;
	import com.gmrmarketing.nissan.next.CoolEntry;
	import com.gmrmarketing.nissan.next.ModelDetail;
	import com.gmrmarketing.nissan.next.GenericDialog;
	import com.gmrmarketing.nissan.next.WhichCar;
	import com.gmrmarketing.nissan.next.ThreeModels;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.desktop.NativeApplication; //for quitting
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;	
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
		private var rfid:RFID;
		private var welcome:Welcome;
		private var fleetViewer:FleetViewer;
		private var cool:Cool;
		private var coolEntry:CoolEntry;
		private var modelDetail:ModelDetail;
		private var threeModels:ThreeModels;
		private var innovations:Innovations;
		private var nav:Nav;
		private var genericDialog:GenericDialog;
		private var whichCar:WhichCar;
		
		private var skip:CornerQuit;
		private var quit:CornerQuit;
		
		private var currentSection:*;		
		private var timeoutHelper:TimeoutHelper;		
		
		private var iconMove:MovieClip;		
		private var iconSwype:MovieClip;
		private var iconContainer:Sprite;
		private var iconTimer:Timer;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			//stage.scaleMode = StageScaleMode.NO_SCALE;
			Mouse.hide();
			
			contentContainer = new Sprite();
			iconContainer = new Sprite();
			
			skip = new CornerQuit();
			skip.init(this, "ul");
			skip.setSingleClick();
			skip.addEventListener(CornerQuit.CORNER_QUIT, skipRFID, false, 0, true);
			
			quit = new CornerQuit();			
			quit.init(this, "ll");
			quit.customLoc(1, new Point(0, 618));			
			quit.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
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
			
			rfid = new RFID();
			rfid.addEventListener(RFID.CHECK_BAD, badID, false, 0, true);
			rfid.addEventListener(RFID.CHECK_GOOD, goodID, false, 0, true);
			
			nav = new Nav(this);
			cool = new Cool(xmlLoader.getApprovedPostsURL());
			
			coolEntry = new CoolEntry(xmlLoader.getPostMessageURL());
			coolEntry.addEventListener(CoolEntry.ENTRY_SUBMITTING, showCoolSubmitting, false, 0, true);			
			coolEntry.addEventListener(CoolEntry.ENTRY_SUBMITTED, showCoolSubmitted, false, 0, true);
			
			fleetViewer = new FleetViewer(xmlLoader.getFleetXML(), 140, -40);
			fleetViewer.addEventListener(FleetViewer.NEW_CAR_PICKED, showModelDetail, false, 0, true);
			
			modelDetail = new ModelDetail(xmlLoader.getFleetXML());
			modelDetail.addEventListener(ModelDetail.BACK_TO_LINEUP, restartClouds, false, 0, true);
			modelDetail.addEventListener(ModelDetail.VIEWING_360, show360Icon, false, 0, true);
			modelDetail.addEventListener(ModelDetail.VIEWING_PHOTO, showMoveIcon, false, 0, true);
			
			whichCar = new WhichCar(xmlLoader.getFleetXML()); //circle picker
			
			threeModels = new ThreeModels(); //the three front views after 'which car is right for you'
			
			innovations = new Innovations();
			innovations.addEventListener(Innovations.VIDEO_STARTED, pauseClouds, false, 0, true);
			innovations.addEventListener(Innovations.VIDEO_CLOSED, restartClouds, false, 0, true);
			
			genericDialog = new GenericDialog();
			
			welcome = new Welcome();
			
			timeoutHelper.startMonitoring();
			
			init();
		}
		
		
		private function init():void
		{
			while (iconContainer.numChildren) {
				iconContainer.removeChildAt(0);
			}
			
			welcome.hide();
			coolEntry.hide();
			fleetViewer.hide();
			modelDetail.hide();
			whichCar.hide();
			threeModels.hide();
			innovations.hide();
			nav.hide();
			
			rfid.show(contentContainer, xmlLoader.getRFIDServiceURL());			
			cool.show(contentContainer, false); //attract
			
			skip.addEventListener(CornerQuit.CORNER_QUIT, skipRFID, false, 0, true);
			
			nav.disabeCreateOne();
			nav.disableSubmit();
			
			skip.moveToTop();
			quit.moveToTop();			
		}
		
		/**
		 * Called from cornerQuit - by tapping four
		 * times at lower right
		 * @param	e
		 */
		private function resetApplication(e:Event):void
		{
			init();
		}
		
		
		/**
		 * Called by tapping once at upper left to skip rfid scan
		 * @param	e CORNER_QUIT event
		 */
		private function skipRFID(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			skip.removeEventListener(CornerQuit.CORNER_QUIT, skipRFID);
			skip.hide();
			
			rfid.setName();
			goodID();
		}		
		
		
		private function goodID(e:Event = null):void
		{			
			timeoutHelper.buttonClicked();
			
			rfid.hide();
			cool.hide();			
			
			welcome.show(this, rfid.getName());
			currentSection = welcome;
			
			nav.show();
			nav.addEventListener(Nav.NAV_SELECTION, navSelection, false, 0, true);			
			
			quit.moveToTop();
			skip.hide();
		}
		
		
		private function badID(e:Event):void
		{
			//rfid clip already showing bad id message
			//wait then reset clip to waiting for rfid scan
			var t:Timer = new Timer(3000, 1);
			t.addEventListener(TimerEvent.TIMER, resetRFID, false, 0, true);
			t.start();
		}
		
		private function resetRFID(e:TimerEvent):void
		{
			rfid.show(contentContainer, xmlLoader.getRFIDServiceURL());
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
		private function navSelection(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			killMove();
			killSwype();
			
			//sel will be innovation,models,whichCar,cool,coolEntry,submit
			var sel:String = nav.getNav();
			//trace(currentSection,sel);
			if (currentSection) {
				//special case - if selection is submit the calculating results dialog is shown for two seconds
				//before hide is called in whichCar - handled below in switch
				if(sel != "submit"){
					currentSection.hide();
				}
				
				if (currentSection == modelDetail || currentSection == threeModels) {
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
					nav.disabeCreateOne();
					nav.disableSubmit();
					currentSection = fleetViewer;
					break;
				case "innovation":			
					nav.disabeCreateOne();
					nav.disableSubmit();
					innovations.show(contentContainer);
					currentSection = innovations;					
					break;
				case "cool":
					cool.show(contentContainer);					
					nav.enableCreateOne();
					nav.disableSubmit();
					currentSection = cool;
					break;
				case "coolEntry":
					var nameString:String = rfid.getName() + ", " + rfid.getCity();
					coolEntry.show(contentContainer, nameString, rfid.getRFID());
					nav.disabeCreateOne();
					nav.disableSubmit();
					currentSection = coolEntry;
					break;
				case "whichCar":
					whichCar.show(contentContainer);
					nav.disabeCreateOne();
					nav.enableSubmit();
					currentSection = whichCar;
					showIcon("move");
					break;
				case "submit":	
					nav.disabeCreateOne();
					nav.disableSubmit();
					whichCar.calculate();
					whichCar.addEventListener(WhichCar.DONE_CALCULATING, whichCarDoneCalculating, false, 0, true);					
					break;
				case "logout":
					init();
					break;
			}
			
			quit.moveToTop();			
		}
		
		
		private function whichCarDoneCalculating(e:Event):void
		{
			whichCar.removeEventListener(WhichCar.DONE_CALCULATING, whichCarDoneCalculating);
			whichCar.hide();
			currentSection = threeModels;
			threeModels.show(contentContainer, whichCar.getResults(), xmlLoader.getFleetXML());
			threeModels.addEventListener(ThreeModels.CAR_CLICKED, showModelDetail2, false, 0, true);
		}
		
		
		/**
		 * Shows the generic dialog to let the user know their cool entry is being submitted
		 * Called when submit button is pressed in cool entry
		 * @param	e CoolEntry.ENTRY_SUBMITTING
		 */
		private function showCoolSubmitting(e:Event):void
		{
			currentSection.hide(); //coolEntry
			cool.show(contentContainer);					
			nav.enableCreateOne();
			currentSection = cool;
			
			genericDialog.show(contentContainer, "your entry is being submitted...");
		}
		
		
		/**
		 * Shows thanks in the generic dialog
		 * @param	e CoolEntry.ENTRY_SUBMITTED
		 */
		private function showCoolSubmitted(e:Event):void
		{
			genericDialog.show(contentContainer, "thank you, your entry has been submitted, and is awaiting moderation", 4);
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
		 * Called when a car is clicked in ThreeModels
		 * @param	e
		 */
		private function showModelDetail2(e:Event):void
		{
			timeoutHelper.buttonClicked();
			pauseClouds();
			modelDetail.show(contentContainer, threeModels.getCarId());
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
		private function quitApplication(e:Event):void
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
			if(!rfid.isShowing()){
				init();
			}
		}
		
	}
	
}