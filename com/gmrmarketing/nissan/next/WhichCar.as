/**
 * Instantiated by Main
 * Circles - user car selctor
 */
package com.gmrmarketing.nissan.next
{
	import com.greensock.easing.Circ;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.events.*;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class WhichCar extends EventDispatcher
	{
		public static const DONE_CALCULATING:String = "doneCalculating";
		
		private var bg:MovieClip;
		private var offsetX:Number;
		private var offsetY:Number;
		private var container:DisplayObjectContainer;
		private var currentClip:MovieClip;
		private var fleetXML:XML;
		
		private var theCircles:Array;
		private var differenceTotals:Array;
		
		private var calculatingDialog:MovieClip; //dialogCalculating lib clip
		
		private var timeoutHelper:TimeoutHelper;
		
		private var localTweens:Array;//any current tweens
		
		private var dialogTimer:Timer;
		
		
		
		public function WhichCar($fleetXML:XML)
		{			
			fleetXML = $fleetXML;			
			bg = new whichCarClip();
			theCircles = new Array();
			localTweens = new Array();
		}
		
		
		public function show($container:DisplayObjectContainer):void
		{
			Multitouch.inputMode = MultitouchInputMode.GESTURE; //send gesture events
			
			TweenMax.killTweensOf(bg);//prevents delayed kill from being called when
			kill();
			
			container = $container;
			
			timeoutHelper = TimeoutHelper.getInstance();
			
			bg.alpha = 1;
			container.addChild(bg);
			theCircles = new Array();
			var i:int = 0;
			for each (var circle:XML in fleetXML.circles.circle) {
				var aCircle:MovieClip = new circleClip(); //library clip
				aCircle.x = 1366 * Math.random();
				aCircle.y = 768 * Math.random();
				aCircle.scaleX = .25;
				aCircle.scaleY = .25;
				aCircle.alpha = 0;
				aCircle.theText.text = circle.@title;
				aCircle.index = i; //inject 0 - numCircles into new circle - to know which circle for calculating results
				
				//center text - circles 0,0 is at circle center
				aCircle.theText.y = 0 - Math.round(aCircle.theText.textHeight * .5);
				
				TweenMax.to(aCircle, .5, { x:parseInt(circle.@x), y:parseInt(circle.@y), scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut, delay:.1 * i } );				
				i++;
				container.addChild(aCircle);				
				
				aCircle.addEventListener(TransformGestureEvent.GESTURE_ZOOM, scaleObj, false, 0, true);
				aCircle.addEventListener(MouseEvent.MOUSE_DOWN, dragBegin);
				
				theCircles.push(aCircle);
			}
			
			container.stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
		
		
		public function hide():void
		{
			Multitouch.inputMode = MultitouchInputMode.NONE; //revert to sending mouse events only
			
			if(container){
				container.stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveClip);
				container.stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			}
			
			for (var i:int = 0; i < theCircles.length; i++) {
				theCircles[i].removeEventListener(TransformGestureEvent.GESTURE_ZOOM, scaleObj);
				theCircles[i].removeEventListener(MouseEvent.MOUSE_DOWN, dragBegin);
				TweenMax.to(theCircles[i], .3, { alpha:0, scaleX:.25, scaleY:.25, delay:i * .15 } );
			}
			removeDialog();
			TweenMax.to(bg, 1, { delay:.6, alpha:0, onComplete:kill } );			
		}
		
		
		private function kill():void
		{
			if(container){
				if(container.contains(bg)){
					container.removeChild(bg);
				}
			}
			for (var i:int = 0; i < theCircles.length; i++) {
				container.removeChild(theCircles[i]);
			}
			theCircles = new Array();
		}
		
		
		
		/**
		 * Returns the top 3 results found after running calculate()
		 * @return
		 */
		public function getResults():Array
		{			
			differenceTotals.splice(3);
			return differenceTotals;
		}
		
		
		private function scaleObj(e:TransformGestureEvent):void
		{
			timeoutHelper.buttonClicked();
			
			currentClip = MovieClip(e.currentTarget);
			container.setChildIndex(currentClip, container.numChildren - 1);
			
			var prevScaleX:Number = currentClip.scaleX;
			var prevScaleY:Number = currentClip.scaleY;
			
			currentClip.scaleX *= e.scaleX;
			currentClip.scaleY *= e.scaleY;
			
			if(e.scaleX > 1 && currentClip.scaleX > 2.25){
				currentClip.scaleX = prevScaleX;
				currentClip.scaleY = prevScaleY;
			}
			if(e.scaleY > 1 && currentClip.scaleY > 2.25){
				currentClip.scaleX = prevScaleX;
				currentClip.scaleY = prevScaleY;
			}
			if(e.scaleX < 1 && currentClip.scaleX < 0.3){
				currentClip.scaleX = prevScaleX;
				currentClip.scaleY = prevScaleY;
			}
			if(e.scaleY < 1 && currentClip.scaleY < 0.3){
				currentClip.scaleX = prevScaleX;
				currentClip.scaleY = prevScaleY;
			}
		}
		
		
		/*
		private function rotateObj (e:TransformGestureEvent):void
		{
			currentClip = MovieClip(e.currentTarget);
			currentClip.rotation += e.rotation;
		}*/
		
		
		private function dragBegin(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			currentClip = MovieClip(e.currentTarget);
			container.setChildIndex(currentClip, container.numChildren - 1);
			offsetX = e.stageX - currentClip.x;
			offsetY = e.stageY - currentClip.y;
			
			container.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveClip);
		} 
		
		
		private function moveClip(e:MouseEvent):void
		{
			currentClip.x = e.stageX - offsetX;
			currentClip.y = e.stageY - offsetY;
		}
		
		
		private function stopDragging(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			container.stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveClip);
		}
		
		
		/**
		 * Called from Main.navSelection() when the user presses the Submit button
		 * over the 'which car for you' nav button
		 */
		public function calculate():void
		{
			timeoutHelper.buttonClicked();
			
			//timeoutHelper.buttonClicked();
			calculatingDialog = new dialogCalculating();//library clips
			calculatingDialog.x = 357;
			calculatingDialog.y = 254;
			container.addChild(calculatingDialog);
			
			var userValues:Array = new Array();
			
			var i:int;			
			
			//place each slider value into userValues
			for (i = 0; i < theCircles.length; i++) {				
				userValues.push(MovieClip(theCircles[i]).scaleX / 2.25);
			}			
			
			//iterate through all the cars to compare differences
			var thisCar:Array;
			differenceTotals = new Array();			
			
			for each (var car:XML in fleetXML.cars.car) {
				//the sum of the differences of user picks compared to the car's values
				var thisTot:Number = 0;
				var carValues:Array = String(car.circVals).split(",");
				
				for (var j:int = 0; j < carValues.length; j++) {
					thisTot += Math.abs(carValues[j] - userValues[j]);
				}
				
				differenceTotals.push([thisTot, car.id]); //need to store thisTot first, as sort() works on element 0 of the subArrays		
			}	
			
			differenceTotals.sort();
			
			dialogTimer = new Timer(2000, 1);
			dialogTimer.addEventListener(TimerEvent.TIMER, calculatingDone, false, 0, true);
			dialogTimer.start();
		}
		
		
		private function calculatingDone(e:TimerEvent):void
		{					
			dispatchEvent(new Event(DONE_CALCULATING));
		}
		
		
		private function removeDialog():void
		{
			if(dialogTimer){
				dialogTimer.reset();
				dialogTimer.removeEventListener(TimerEvent.TIMER, calculatingDone);
			}
			if(calculatingDialog){
				TweenMax.to(calculatingDialog, .5, { alpha:0, onComplete:killDialog } );
			}
		}
		
		
		private function killDialog():void
		{
			if(calculatingDialog){
				if (container.contains(calculatingDialog)) {
					container.removeChild(calculatingDialog);
					calculatingDialog = null;
				}
			}	
		}	
 
	}
	
}