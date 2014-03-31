package com.sagecollective.corona.atp
{
	import com.adobe.utils.ArrayUtil;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.Sprite;
	import flash.events.*;
	import com.sagecollective.utilities.NumericStepper;	
	import com.sagecollective.utilities.TimeoutHelper;
	import com.sagecollective.utilities.ComboBox;
	import flash.utils.Timer;
	import flash.filters.DropShadowFilter;
	
	

	public class Intro extends EventDispatcher
	{	
		public static const AGE_VERIFIED:String = "ageVerificationOK";		
		public static const ITEMS_REMOVED:String = "introContainerCleared";
		public static const INTERACTION_STARTED:String = "interactionStarted";
		public static const RESET:String = "appReset"; //for when age gate fails
		public static const SHOW_TERMS:String = "showTheTerms";
		
		private var container:DisplayObjectContainer;
		
		private var theLogo:MovieClip;
		private var topText:MovieClip;
		
		private var theBottle:MovieClip;
		private var theBottleShadow:MovieClip;
		private var bottleSand:MovieClip;
		
		private var sign:MovieClip;
		private var signShadow:MovieClip;
		
		//lime behind sign
		private var lime1:MovieClip;
		private var lime1Shadow:MovieClip;
		
		//lime at front right of bottle
		private var lime2:MovieClip;
		private var lime2Shadow:MovieClip;
		private var lime2Sand:MovieClip;
		
		//lime at right - behind bottle
		private var lime3:MovieClip;
		private var lime3Shadow:MovieClip;
		private var lime3Sand:MovieClip;
		
		//lime at front bottle left
		private var lime4:MovieClip;
		private var lime4Shadow:MovieClip;
		private var lime4Sand:MovieClip;
		
		//stamps
		//private var stampCorona:MovieClip;
		//private var stampMiami:MovieClip;
		//private var stampBeachHouse:MovieClip;
		
		//age gate
		private var ageGate:MovieClip;
		private var ageGateShadow:MovieClip;
		private var theMonths:Array; //january,february,etc
		private var theYears:Array;
		private var today:Date;
		private var currentBirthdate:String;
		private var ageGateShowing:Boolean = false;
		
		//sorry
		private var sorrySign:MovieClip;
		private var sorryTimer:Timer;
		
		//timeout cards			
		private var isTimedOut:Boolean = false;
		
		private var timeoutHelper:TimeoutHelper;
		private var cardShadow:DropShadowFilter;		
		private var cardContainer:Sprite;
		
		
		public function Intro($container:DisplayObjectContainer)
		{			
			container = $container;
			
			cardContainer = new Sprite();			
			
			timeoutHelper = TimeoutHelper.getInstance();			
			cardShadow = new DropShadowFilter(3, 0, 0, 1, 12, 12, 1.2, 2);
			
			theLogo = new logo(); //lib clip
			theLogo.x = 1640;
			theLogo.y = 78;
			
			sign = new sign_touch(); //lib clip
			signShadow = new sign_shadow();
			
			ageGate = new sign_ageGate();//lib clip
			ageGateShadow = new sign_shadow2();
			theMonths = new Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
			today = new Date();
			theYears = new Array();
			for (var i:int = today.getFullYear(); i >= 1920 ; i--) {
				theYears.push(String(i));
			}
			
			sorrySign = new sign_sorry(); //lib clip
			
			topText = new postcardText(); //lib clip	
			
			theBottle = new bottle();//lib clip
			theBottle.x = 275;
			theBottle.y = 62;
			theBottle.alpha = 0;
			
			theBottleShadow = new limeBallShadow();
			theBottleShadow.x = 377;
			theBottleShadow.y = 932;
			theBottleShadow.alpha = 0;
			theBottleShadow.width = 257;
			theBottleShadow.height = 37;
			
			bottleSand = new sandCover();
			bottleSand.x = 233;
			bottleSand.y = 918;			
			
			lime1 = new limeBall_small();			
			lime1Shadow = new limeBallShadow();			
			
			lime2 = new limeBall_big();
			lime2Shadow = new limeBallShadow();
			lime2Sand = new sandCover();
			
			lime3 = new limeBall();
			lime3Shadow = new limeBallShadow();
			lime3Sand = new sandCover();
			
			lime4 = new limeBall_big();
			lime4Shadow = new limeBallShadow();
			lime4Sand = new sandCover();
			
			//lib clips
			/*
			stampBeachHouse = new stamp_beachHouse();
			stampCorona = new stamp_corona();
			stampMiami = new stamp_miami();
			
			stampMiami.x = 855;
			stampMiami.y = 363;
			
			stampCorona.x = 1052;
			stampCorona.y = 284;
			
			stampBeachHouse.x = 1452;
			stampBeachHouse.y = 321;
			*/
			
			sorryTimer = new Timer(15000, 1);
			sorryTimer.addEventListener(TimerEvent.TIMER, sorryReset, false, 0, true);
		}
		
		
		/**
		 * Called from Main.appTimedOut() if the app times out - shows the
		 * premade postcards - kind of an attract loop
		 */
		public function timedOut():void
		{
			if(!isTimedOut){
			
				if (!container.contains(cardContainer)) {
					container.addChild(cardContainer);
				}
				cardContainer.alpha = 1;
				
				cardContainer.stage.addEventListener(MouseEvent.MOUSE_DOWN, clearTimeoutCards, false, 0, true);
				container.stage.removeEventListener(MouseEvent.MOUSE_DOWN, addAgeGate);
				
				isTimedOut = true;
				sorryTimer.reset();
				
				addCard();
			}
		}
		
		
		private function addCard():void
		{
			if(cardContainer.numChildren < 30){
				var aCard:Sprite = new Sprite();
				
				var tr:Number = Math.random();
				var t:BitmapData;
				if(tr < .33){
					t = new t1();
				}else if(tr < .66){
					t = new t2();
				}else{
					t = new t3();
				}
				var cr:Number = Math.random();
				var c:BitmapData;
				if(cr < .2){
					c = new c1();
				}else if(cr < .4){
					c = new c2();
				}else if(cr < .6){
					c = new c3();
				}else if(cr < .8){
					c = new c4();
				}else{			
					c = new c5();
				}
				 
				c.draw(t,null,null,null,null,true);
				var b:Bitmap = new Bitmap(c);
				b.smoothing = true;
				aCard.addChild(b);				
				
				aCard.filters = [cardShadow];				
				cardContainer.addChild(aCard);
				
				if(Math.random() < .5){
					aCard.x = -600;
				}else{
					aCard.x = container.stage.stageWidth + 100;
				}
				if(Math.random() < .5){
					aCard.y = -400;
				}else{
					aCard.y = container.stage.stageHeight + 100;
				}
				if(Math.random() < .5){
					aCard.rotation = Math.random() * 360;
				}else{
					aCard.rotation = 0 - (Math.random() * 360);
				}
				var scale = Math.min(1, Math.random() + .6);
				aCard.scaleX = aCard.scaleY = scale;
				
				//.75 - 1.25
				var speed:Number = .75 + (Math.random() * .5);
				
				var finX:int = Math.round(150 + (Math.random() * (container.stage.stageWidth - 300)));
				var finY:int = Math.round(20 + (Math.random() * (container.stage.stageHeight - 200)));
				var finR:int;
				if(Math.random() < .5){
					finR = Math.round(Math.random() * 30);
				}else{
					finR = Math.round(0 - (Math.random() * 30));
				}
				TweenMax.to(aCard, speed, { x:finX, y:finY, rotation:finR, onComplete:addCard } );
				
			}else{
				clearTimeoutCards();
			}
		}
		
		
		/**
		 * Called by clicking the screen when the attract loop is playing
		 * or called when all cards have been added
		 * @param	e
		 */
		private function clearTimeoutCards(e:MouseEvent = null):void
		{			
			TweenMax.killAll();
			cardContainer.stage.removeEventListener(MouseEvent.MOUSE_DOWN, clearTimeoutCards);
			TweenMax.to(cardContainer, 1, { alpha:0, onComplete:killTimeoutCards } );
		}
		
		/**
		 * Called from clearTimeourCards when cardContainer is done fading out
		 * called from Main.closeClicked()
		 */
		public function killTimeoutCards():void
		{		
			var aCard:Sprite;
			while(cardContainer.numChildren){
				aCard = Sprite(cardContainer.getChildAt(0));
				aCard.removeChildAt(0);//removes bitmap from card sprite
				cardContainer.removeChildAt(0);
			}
			
			if(container.contains(cardContainer)){
				container.removeChild(cardContainer);
			}
			container.stage.addEventListener(MouseEvent.MOUSE_DOWN, addAgeGate, false, 0, true);
			
			removeItems(true);
		}
		
		
		/**
		 * Disables event listeners on the age gate
		 */
		public function dispose():void
		{
			ageGate.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, checkAge);
			ageGateShowing = false;
		}
		
		
		/**
		 * Returns a MDY string like: 2/14/1978
		 */
		public function getBirthdate():String
		{
			return currentBirthdate;
		}
		
		
		/**
		 * Animates items off the screen
		 * 
		 * When Complete:
		 * if reset = false - dispatches ITEMS_REMOVED
		 * if reset = true - calls addLimes to restart the intro
		 */
		public function removeItems(reset:Boolean = false):void
		{			
			isTimedOut = false;			
			
			TweenMax.killAll();
			
			TweenMax.to(theLogo, 2, { alpha:0 } );
			
			TweenMax.to(theBottle, .5, { alpha:0 } );
			TweenMax.to(theBottleShadow, .5, { alpha:0 } );
			
			TweenMax.to(lime1, .3, { y: -240, ease:Linear.easeNone } );
			TweenMax.to(lime2, .3, { y: -240, ease:Linear.easeNone, delay:.1 } );
			TweenMax.to(lime3, .3, { y: -240, ease:Linear.easeNone, delay:.2 } );
			TweenMax.to(lime4, .3, { y: -240, ease:Linear.easeNone, delay:.3 } );
			
			TweenMax.to(lime1Shadow, .25, { alpha:0 } );
			TweenMax.to(lime2Shadow, .25, { alpha:0, delay:.1 } );
			TweenMax.to(lime3Shadow, .25, { alpha:0, delay:.2 } );
			TweenMax.to(lime4Shadow, .25, { alpha:0, delay:.3 } );
			
			//TweenMax.to(stampBeachHouse, .5, { alpha:0, delay:.5 } );
			//TweenMax.to(stampCorona, .5, { alpha:0, delay:.5 } );
			//TweenMax.to(stampMiami, .5, { alpha:0, delay:.5 } );
			
			TweenMax.to(topText, .5, { alpha:0, delay:.5 } );
			
			if (container.contains(ageGate)) {
				dispose();
				TweenMax.to(ageGate, .75, { y:1300, ease:Back.easeIn, delay:.75 } );
				if (reset) {
					TweenMax.to(ageGateShadow, .75, { y:1800, ease:Back.easeIn, delay:.75, onComplete:addLime } );
				}else{
					TweenMax.to(ageGateShadow, .75, { y:1800, ease:Back.easeIn, delay:.75, onComplete:dispatchRemove } );
				}
				
			}else if (container.contains(sorrySign)) {				
				TweenMax.to(sorrySign, .75, { y:1300, ease:Back.easeIn, delay:.75 } );
				if (reset) {
					TweenMax.to(ageGateShadow, .75, { scaleY:0, ease:Back.easeIn, delay:.75, onComplete:addLime } );
				}else{
					TweenMax.to(ageGateShadow, .75, { scaleY:0, ease:Back.easeIn, delay:.75, onComplete:dispatchRemove } );
				}
			}else {
				TweenMax.to(sign, .75, { y:1100, ease:Back.easeIn, delay:.75 } );
				if (reset) {
					TweenMax.to(signShadow, .75, { scaleY:0, ease:Back.easeIn, delay:.75, onComplete:addLime } );
				}else{
					TweenMax.to(signShadow, .75, { scaleY:0, ease:Back.easeIn, delay:.75, onComplete:dispatchRemove } );
				}
			}
		}
		
		
		/**
		 * Called from checkAge() when age < 21
		 */
		private function removeAgeGate():void
		{
			container.removeChild(ageGate);
			ageGateShowing = false;
		}
		
		private function dispatchRemove():void
		{
			dispatchEvent(new Event(ITEMS_REMOVED));
		}
		
		
		//lime at front right of bottle
		public function addLime(e:Event = null):void
		{	
			if (ageGate) {
				if (container.contains(ageGate)) {
					container.removeChild(ageGate);
				}
			}
			ageGateShowing = false;
			
			if (sorrySign) {
				if (container.contains(sorrySign)) {
					container.removeChild(sorrySign);
				}
			}
			
			timeoutHelper.buttonClicked();
			sorryTimer.reset();
			
			container.addChild(theLogo);
			container.addChild(theBottleShadow);
			container.addChild(theBottle);
			container.addChild(bottleSand);
			
			lime2.x = 530;
			lime2.y = -140;
			
			lime2Sand.x = 450;
			lime2Sand.y = 1000;
			
			lime2Shadow.x = 600;
			lime2Shadow.y = 1028;
			lime2Shadow.width = 178;
			lime2Shadow.height = 27;
			lime2Shadow.alpha = 0;
			
			container.addChild(lime2Shadow);
			container.addChild(lime2);
			container.addChild(lime2Sand);
			
			TweenMax.to(lime2, .75, { y:835, ease:Bounce.easeOut, onComplete:addLimes } );
			TweenMax.to(lime2Shadow, .5, { delay:.25, alpha:.5 } );
		}
		
		
		
		private function addLimes():void
		{			
			//lime at right - behind bottle
			lime3.x = 453;
			lime3.y = -200;
			
			lime3Sand.x = 369;
			lime3Sand.y = 847;
			
			lime3Shadow.x = 499;
			lime3Shadow.y = 860;			
			lime3Shadow.alpha = 0;
			
			//lime at front left of bottle			
			lime4.x = 147;
			lime4.y = -200;
			lime4.width = 192;
			lime4.height = 188;
			
			lime4Sand.x = 71;
			lime4Sand.y = 978;
			
			lime4Shadow.x = 249;
			lime4Shadow.y = 990;			
			lime4Shadow.alpha = 0;
			
			//lime behind popup sign
			lime1.x = 1604;
			lime1.y = -200;
			
			lime1Shadow.x = 1627;
			lime1Shadow.y = 851;
			lime1Shadow.width = 111;
			lime1Shadow.height = 25;
			lime1Shadow.alpha = 0;
			
			if(!ageGateShowing){
				container.addChild(lime1Shadow);
				container.addChild(lime1);
			}
			
			container.addChild(lime4Shadow);
			container.addChild(lime4);
			container.addChild(lime4Sand);
			
			container.addChildAt(lime3Sand, 1);
			container.addChildAt(lime3,1);
			container.addChildAt(lime3Shadow, 1);
			
			TweenMax.to(theLogo, 1, { alpha:1 } );
			TweenMax.to(theBottle, 1, { alpha:1 } );
			TweenMax.to(theBottleShadow, 1, { alpha:.5 } );
			
			TweenMax.to(lime3, .75, { y:758, ease:Bounce.easeOut, delay:.5} );
			TweenMax.to(lime3Shadow, .5, { delay:.75, alpha:.5 } );
			
			TweenMax.to(lime4, .75, { y:845, ease:Bounce.easeOut, delay:.6 } );
			TweenMax.to(lime4Shadow, .5, { delay:.75, alpha:.5 } );
			
			TweenMax.to(lime1, .75, { y:765, ease:Bounce.easeOut, delay:.5, onComplete:addSigns } );
			TweenMax.to(lime1Shadow, .5, { delay:.75, alpha:.5 } );
		}
	
		/*
		private function addStamps():void
		{
			stampCorona.alpha = 0;
			stampMiami.alpha = 0;
			stampBeachHouse.alpha = 0;
			container.addChild(stampCorona);
			container.addChild(stampMiami);
			container.addChild(stampBeachHouse);
			TweenMax.to(stampCorona, 0, { alpha:1, delay:.25 } );
			TweenMax.to(stampMiami, 0, { alpha:1, delay:.5 } );
			TweenMax.to(stampBeachHouse, 0, { alpha:1, delay:.75, onComplete:addSigns } );
		}
		*/	
		
		
		/**
		 * Called by TweenMax onComplete of lime1 tween - from addLimes()
		 */
		private function addSigns():void
		{
			if(!ageGateShowing){
				signShadow.x = 928;
				signShadow.y = 1084;
				signShadow.scaleY = 0;
				signShadow.alpha = .3;
				container.addChild(signShadow);
				
				sign.x = 895;
				sign.y = 1050;
				container.addChild(sign);
				
				TweenMax.to(sign, 1, { y:626, ease:Bounce.easeOut} );
				TweenMax.to(signShadow, 1, { scaleY:1, ease:Bounce.easeOut } );
				
				addAgeGateListener();
			}
			topText.x = 616;
			topText.y = 180;
			topText.alpha = 0;
			container.addChild(topText);	
			TweenMax.to(topText, 1.5, { alpha:1 } );
		}
		public function addAgeGateListener():void
		{
			if(!ageGateShowing){
				container.stage.addEventListener(MouseEvent.MOUSE_DOWN, addAgeGate, false, 0, true);
			}
		}
		public function removeAgeGateListener():void
		{
			container.stage.removeEventListener(MouseEvent.MOUSE_DOWN, addAgeGate);
		}
	
		private function isLeapYear(yr:int):Boolean {
			return (yr % 400 == 0) || ((yr % 4 == 0) && (yr % 100 != 0));
		}
		
		/**
		 * Returns the days in the month
		 * @param	mo integer 0-11
		 */
		private function daysInMonth(mo:String, yr:int):int
		{
			var index:int = theMonths.indexOf(mo);
			var days:Array = new Array(31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
			if (index == 1 && isLeapYear(yr)) {				
				return 28;				
			}
			return days[index];
		}
		
		private function addAgeGate(e:MouseEvent):void
		{	
			ageGateShowing = true;
			isTimedOut = false;
			
			timeoutHelper.buttonClicked();
			
			//interaction started - stats
			dispatchEvent(new Event(Intro.INTERACTION_STARTED));
			
			container.stage.removeEventListener(MouseEvent.MOUSE_DOWN, addAgeGate);
			
			ageGate.x = 735;
			ageGate.y = 1080;
			ageGateShadow.x = 820;
			ageGateShadow.y = 1080;
			ageGateShadow.scaleY = 0;
			ageGateShadow.alpha = .3;
			
			container.addChild(ageGateShadow);
			container.addChild(ageGate);
			
			//remove first sign and shadow
			TweenMax.to(sign, .5, { y:1100, ease:Back.easeIn, overwrite:1 } );
			TweenMax.to(signShadow, .5, { scaleY:0, ease:Back.easeIn, overwrite:1 } );
			
			//remove stamps
			//TweenMax.to(stampCorona, 0, { alpha:0, delay:.2 } );
			//TweenMax.to(stampMiami, 0, { alpha:0, delay:.3 } );
			//TweenMax.to(stampBeachHouse, 0, { alpha:0, delay:.4 } );
			
			TweenMax.to(ageGate, .75, { y:420, ease:Bounce.easeOut, delay:.3 } );
			TweenMax.to(ageGateShadow, .75, { scaleY:1, ease:Bounce.easeOut, delay:.3 } );
			
			//enable age gate
			today = new Date();
			
			ageGate.theMonth.addEventListener(ComboBox.CHANGE, changeDays, false, 0, true);
			ageGate.theMonth.populate(theMonths);
			ageGate.theMonth.setSelection(theMonths[today.getMonth()]); //set to current month - cause changeDays to run
			
			ageGate.theYear.populate(theYears);
			ageGate.theYear.setSelection(String(today.getFullYear()));
			
			ageGate.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, checkAge, false, 0, true);
			ageGate.btnTerms.addEventListener(MouseEvent.MOUSE_DOWN, showTerms, false, 0, true);
		}
		
		private function changeDays(e:Event = null):void
		{
			//trace("changeDays",ageGate.theMonth.getSelection(), today.getFullYear());
			var theDays:Array = new Array();
			var numDays:int = daysInMonth(ageGate.theMonth.getSelection(), today.getFullYear());
			for (var i:int = 1; i <= numDays; i++) {
				theDays.push(String(i));
			}
			ageGate.theDay.populate(theDays);
			ageGate.theDay.setSelection("1");
		}
		
		private function showTerms(e:MouseEvent):void
		{
			dispatchEvent(new Event(SHOW_TERMS));
		}
		
		private function ageGateClick(e:Event):void
		{
			timeoutHelper.buttonClicked();
		}
		
		private function checkAge(e:MouseEvent):void
		{		
			timeoutHelper.buttonClicked();
			
			var today:Date = new Date();
			var bDay:Date = new Date(parseInt(ageGate.theYear.getSelection()), theMonths.indexOf(ageGate.theMonth.getSelection()), parseInt(ageGate.theDay.getSelection()));			
			
			currentBirthdate = String(ageGate.theMonth.getSelection()) + "/" + String(ageGate.theDay.getSelection()) + "/" + String(ageGate.theYear.getSelection());
			
			var yrs:int = today.getFullYear() - bDay.getFullYear();
			
			if (today.getMonth() < bDay.getMonth() || (today.getMonth() == bDay.getMonth() && bDay.getDay() < today.getDay())) {
				yrs--;
			}			
			
			if (yrs < 21) {
				
				TweenMax.to(ageGate, .75, { y:1100, ease:Back.easeIn, onComplete:removeAgeGate } );
				
				sorrySign.x = 789;
				sorrySign.y = 1100;
				container.addChild(sorrySign);
				
				TweenMax.to(sorrySign, .75, { y:428, ease:Bounce.easeOut, delay:.5, onComplete:waitSorry } );
				
			}else {				
				dispatchEvent(new Event(AGE_VERIFIED));
			}			
		}
		
		
		private function waitSorry():void
		{
			timeoutHelper.buttonClicked();
			sorryTimer.start();//calls sorryReset() after 15sec
		}
		
		
		private function sorryReset(e:TimerEvent):void
		{
			dispatchEvent(new Event(RESET)); //causes main to reset
		}
		
		
	}
	
}