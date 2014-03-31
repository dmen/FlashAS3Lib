package com.gmrmarketing.nissan.canada.ridedrive2013
{
	import flash.display.*;	
	import flash.events.Event;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	
	
	public class Main extends MovieClip
	{
		private var btmContainer:Sprite;
		private var topContainer:Sprite;
		private var cornerContainer:Sprite; //for corner quit ad admin
		private var outerContainer:Sprite; //for rules, en/fr selector
		
		private var intro:Intro;		
		private var pin:PinEntry;
		private var wheel:Wheel;
		private var prize:Prize;
		private var admin:Admin;
		private var rules:Rules;
		private var lang:LanguageSelect;
		private var prizeStorage:PrizeStorage;
		
		private var currentLang:String = "fr";//default
		private var currentPrize:String;//the currrent prize, from prizeStorage
		
		private var adminCorner:CornerQuit;//upper left for admin panel
		private var cq:CornerQuit;//upper right for quitting
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();

			btmContainer = new Sprite();
			topContainer = new Sprite();
			cornerContainer = new Sprite();
			outerContainer = new Sprite();
			
			addChild(btmContainer);
			addChild(topContainer);
			addChild(outerContainer);
			addChild(cornerContainer);
			
			intro = new Intro();
			intro.setContainer(btmContainer);				
			
			rules = new Rules();
			rules.setContainer(outerContainer);
			rules.show();
			
			lang = new LanguageSelect();
			lang.setContainer(outerContainer);
			lang.addEventListener(LanguageSelect.LANGUAGE_EN, langEn, false, 0, true);
			lang.addEventListener(LanguageSelect.LANGUAGE_FR, langFr, false, 0, true);
			lang.show();
			
			pin = new PinEntry();
			pin.setContainer(topContainer);			
			
			wheel = new Wheel();
			wheel.setContainer(topContainer);
			
			prize = new Prize();
			prize.setContainer(topContainer);
			
			admin = new Admin();
			admin.setContainer(topContainer);
			
			prizeStorage = new PrizeStorage();
			
			adminCorner = new CornerQuit();
			adminCorner.init(cornerContainer, "ul");
			adminCorner.addEventListener(CornerQuit.CORNER_QUIT, showAdmin);
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ur");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApp);
			
			reset();
		}
		
		
		/**
		 * Resets to the intro screen
		 * called from constructor, prizeComplete() and adminClosed()
		 */
		private function reset():void
		{
			intro.hide();
			pin.hide();
			wheel.hide();
			prize.hide();
			admin.hide();
			lang.show();
			
			setLanguage();
			
			intro.addEventListener(Intro.INTRO_CLICKED, showPinEntry, false, 0, true);
			intro.show();
		}
		
		
		/**
		 * sets all the objects to the current language
		 * called from reset() and the two lang methods
		 */
		private function setLanguage():void
		{
			intro.setLanguage(currentLang);
			pin.setLanguage(currentLang);
			wheel.setLanguage(currentLang);
			rules.setLanguage(currentLang);
			prize.setLanguage(currentLang);
		}
		
		
		private function showPinEntry(e:Event):void
		{			
			pin.show();
			pin.addEventListener(PinEntry.PIN_ENTERED, pinEntered, false, 0, true);
			pin.addEventListener(PinEntry.PIN_CLOSED, pinClosed, false, 0, true);
		}
		
		
		private function pinEntered(e:Event):void
		{
			if(!prizeStorage.idExists(pin.getPin()) || pin.getPin() == "00000"){
				pin.hide();
				lang.hide();
				pin.removeEventListener(PinEntry.PIN_ENTERED, pinEntered);
				pin.removeEventListener(PinEntry.PIN_CLOSED, pinClosed);
				
				if (pin.getPin() == "00000") {
					currentPrize = "$1,000";
				}else{
					currentPrize = prizeStorage.getNextPrize();
				}
				
				wheel.show(currentPrize, prizeStorage.showCar());
				wheel.addEventListener(Wheel.SPIN_SHOWING, spinShowing, false, 0, true);
				wheel.addEventListener(Wheel.SPIN_COMPLETE, spinComplete, false, 0, true);
			}else {
				pin.idExists();
			}
		}
		
		
		private function pinClosed(e:Event):void
		{
			pin.hide();
			pin.removeEventListener(PinEntry.PIN_ENTERED, pinEntered);
			pin.removeEventListener(PinEntry.PIN_CLOSED, pinClosed);
		}
		
		
		private function spinShowing(e:Event):void
		{
			wheel.removeEventListener(Wheel.SPIN_SHOWING, spinShowing);
			intro.hide();
		}
		
		
		private function spinComplete(e:Event):void
		{
			prize.show(currentPrize);
			prizeStorage.addPrize(pin.getPin(), currentPrize);
			prize.addEventListener(Prize.PRIZE_SHOWING, prizeShowing, false, 0, true);
			prize.addEventListener(Prize.PRIZE_COMPLETE, prizeComplete, false, 0, true);
		}
		
		
		private function prizeShowing(e:Event):void
		{
			prize.removeEventListener(Prize.PRIZE_SHOWING, prizeShowing);
			wheel.hide();			
		}
		
		
		private function prizeComplete(e:Event):void
		{
			reset();
		}
		
		
		private function showAdmin(e:Event):void
		{
			admin.show(prizeStorage.showCar(), prizeStorage.numSpins(), prizeStorage.numFailed());
			admin.addEventListener(Admin.ADMIN_CLOSED, adminClosed, false, 0, true);
		}
		
		
		private function adminClosed(e:Event):void
		{
			admin.removeEventListener(Admin.ADMIN_CLOSED, adminClosed);
			prizeStorage.setShowCar(admin.doShowCar());
			admin.hide();
			reset();
		}
		
		
		private function langEn(e:Event):void
		{
			currentLang = "en";
			setLanguage();
		}
		
		
		private function langFr(e:Event):void
		{
			currentLang = "fr";
			setLanguage();
		}		
		
		
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}