package com.gmrmarketing.comcast.scratchnew
{	
	import flash.display.*;
	import com.coreyoneil.collision.CollisionList;	
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.geom.*;	
	import com.greensock.TweenLite;
	import flash.net.*;
	import flash.utils.*;
	import flash.media.*;	
	
	
	public class PrizeWheel extends EventDispatcher
	{
		public static const DONE_SPINNING:String = "doneSpinning";
		
		private var cList:CollisionList;
		private var spinnerRadius:int;
		
		private var colArray:Array;
		
		private var spinSpeed:Number = 21;
		
		private var colAngle:Number;
		private var rotationDirection:int = -1;
		
		private var offset:Number;
		private var initAngle:Number;
		private var initTime:int;		
		private var lastDragTime:int;
		
		private var totalRotation:Number; //accumulated rotation - used to know if the spinner made a complete revolution
		private var lastPegNumber:int = -1;
		
		private var angleList:Array;
		private var prizeList:Array;
		private var descriptionList:Array;
		
		private var spinner:Sprite;		
		
		private var thePointer:MovieClip; //lib clip
		
		private var thePrize:String;
		private var theDescription:String;
		
		private var channel:SoundChannel;
		private var sound:Sound;
		
		private var spinnerBMP:Bitmap;
		private var pegList:Array;
		
		private var container:DisplayObjectContainer;		
		
		
		public function PrizeWheel($container:DisplayObjectContainer)
		{
			container = $container;			
			sound = new spring(); //library sound			
		}
		
		
		/**
		 * Called from Main.showSpin()
		 * @param	theData Data object from Admin.getData()
		 */
		public function show(theData:Object):void
		{		
			spinner = new Sprite();
			
			//round pie image
			spinnerBMP = new Bitmap(new spinnerImage(624, 624));
			spinnerBMP.smoothing = true;
			spinnerRadius = 303;
			spinner.addChild(spinnerBMP);
			//center spinner image to top-left of container sprite
			spinnerBMP.x = -312;
			spinnerBMP.y = -312;
			
			spinner.x = 550;// 634;
			spinner.y = 402;//382
			
			container.addChild(spinner);			
			
			thePointer = new pointer();
			thePointer.x = 203;// 287;
			thePointer.y = 389;
			container.addChild(thePointer);						
			
			prizeList = theData.prizes;
			if (prizeList == null) {
				prizeList = new Array("Sample", "Sample", "Sample", "Sample", "Sample", "Sample", "Sample", "Sample", "Sample");
			}
			descriptionList = theData.descriptions; //used by the end game dialog
			if (descriptionList == null) {
				descriptionList = new Array("Sample", "Sample", "Sample", "Sample", "Sample", "Sample", "Sample", "Sample", "Sample");
			}
			
			angleList = new Array(0, 45, 75, 90, 180, 225, 255, 270, 360);
			
			begin();
		}
		
		
		public function hide():void
		{
			spinner.removeEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);
			container.stage.removeEventListener(MouseEvent.MOUSE_UP, endDragRotation);
			container.stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateDragRotation);
			container.stage.removeEventListener(Event.ENTER_FRAME, update);
			
			var n:int = container.numChildren;
			for (var i:int = n - 1; i >= 0; i--) {
				TweenLite.to(container.getChildAt(i), .5, { delay:1, overwrite:0, alpha:0, onComplete:killChild, onCompleteParams:[i, DisplayObject(container.getChildAt(i))] } );
			}	
		}		
		
		private function killChild(i:int, c:DisplayObject):void
		{	
			if(container.contains(c)){
				container.removeChild(c);
			}
			if (i == 1) {
				//last item removed
				//dispatchEvent(new Event(DONE_FADING));
			}
		}	
		
		
		private function begin():void
		{	
			thePrize = "";
			
			cList = new CollisionList(thePointer.point);
			cList.returnAngle = true;
			
			addPegs();			
			spinner.addEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);
			addTextFields();
			
			container.stage.addEventListener(MouseEvent.MOUSE_UP, endDragRotation);
		}
		
		
		
		private function addPegs():void
		{
			pegList = new Array();
			
			for (var i:int = 0; i < angleList.length - 1; i++) {
				var curAng:Number = angleList[i] * .0174532925; //* radians per degree
				
				var pegLoc:Point = new Point(Math.cos(curAng) * spinnerRadius, Math.sin(curAng) * spinnerRadius);
				
				var aPeg:peg = new peg(); //lib clip
				aPeg.index = i + 1;
				
				spinner.addChild(aPeg);
				//aPeg.alpha = .01;
				aPeg.x = pegLoc.x;
				aPeg.y = pegLoc.y;
				
				cList.addItem(aPeg);
				pegList.push(aPeg);
			}
		}
		
		
		/**
		 * Gets the prize and description
		 * Populated in update() when the wheel is done spinning
		 * @return Two item array containing prize, prize description
		 */
		public function getPrize():Array
		{
			return new Array(thePrize, theDescription);
		}
		
		
		/**
		 * Called from mouseDown on Spinner
		 * @param	e
		 */
		private function startDragRotation(e:MouseEvent):void
		{
			
			initTime = getTimer();
			var position:Number = Math.atan2(container.mouseY - spinner.y, container.mouseX - spinner.x);	
			var angle:Number = (position / Math.PI) * 180;
			initAngle = spinner.rotation;
			offset = spinner.rotation - angle;
			container.stage.addEventListener(MouseEvent.MOUSE_MOVE, updateDragRotation);			
		}
		
		
		
		/**
		 * Called on enter frame as the spinner is dragged
		 * @param	e
		 */
		private function updateDragRotation(e:Event):void
		{			
			lastDragTime = getTimer();
			var position:Number = Math.atan2(container.mouseY - spinner.y, container.mouseX - spinner.x);	
			spinner.rotation = (position / Math.PI) * 180 + offset;
		}
		
		
		
		/**
		 * Called on mouse up when spinner is dragging
		 * @param	e
		 */
		private function endDragRotation(e:MouseEvent):void
		{	
			var dLastDragTime = getTimer() - lastDragTime;
			var dAngle:Number = spinner.rotation - initAngle;	
			
			if (dAngle < 0) {
				rotationDirection = -1;
			}else {
				rotationDirection = 1;
			}			
			
			if (dLastDragTime == 0) dLastDragTime = 1;
			
			//spinSpeed = Math.min(25, Math.abs(2  * dAngle / dLastDragTime));
			spinSpeed = 12 + Math.random() * 12;
			
			totalRotation = 0; //accumulated rotation - used to tell if wheel spins around at least once
			
			container.stage.addEventListener(Event.ENTER_FRAME, update, false, 0, true);			
			container.stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateDragRotation);
			spinner.removeEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);				
			container.stage.removeEventListener(MouseEvent.MOUSE_UP, endDragRotation);			
		}
		
		
		private function update(e:Event):void
		{
			spinner.rotation += spinSpeed * rotationDirection;
			totalRotation += spinSpeed * rotationDirection;
			
			colArray = cList.checkCollisions();
			
			if (colArray.length && colArray[0].object1.index != lastPegNumber) {				
				
				lastPegNumber = colArray[0].object1.index;				
				
				colAngle = colArray[0].angle;				
				
				if (rotationDirection < 0) {					
					thePointer.rotation += 15;					
				}else {					
					thePointer.rotation -= 15;					
				}				
				
				//originally .9
				spinSpeed *= .85;
				channel = sound.play();
				
				//'bounce' off if spinner is going slow enough
				if (spinSpeed < .95) {					
					rotationDirection *= -1;					
					spinner.rotation += spinSpeed * rotationDirection * 3;
					totalRotation += spinSpeed * rotationDirection * 3;
				}
				
				TweenLite.to(thePointer, .3, { rotation:0 } );
			}			
						
			
			//slow it down quicker as it slows down			
			if (spinSpeed < .8) {
				spinSpeed *= .9;
			}else{
				spinSpeed *= .99;	
			}
			
			
			if (spinSpeed < .01) {
				spinSpeed = 0;
				
				removeEventListener(Event.ENTER_FRAME, update);				
				
				var prizeSlice:int;
				if (rotationDirection > 0) {
					if (lastPegNumber == 1) {
						prizeSlice = angleList.length - 1;
					}else{
						prizeSlice = lastPegNumber - 1;
					}
				}else {
					prizeSlice = lastPegNumber;
				}
				
				thePrize = prizeList[prizeSlice - 1];
				theDescription = descriptionList[prizeSlice - 1];
				
				dispatchEvent(new Event(DONE_SPINNING));				
			}
			
		}
		
		/**
		 * Adds text fields to the spinner
		 * 
		 */
		private function addTextFields():void
		{			
			var halfAngle:Number;
			var m:Matrix = new Matrix();
			var fList:Array = new Array();
			
			for (var i:int = 1; i < angleList.length; i++) {
				
				halfAngle = angleList[i-1] + ((angleList[i] - angleList[i - 1]) / 2);
				var curAng:Number = halfAngle * .0174532925; //* radians per degree
				
				var tLoc:Point = new Point(Math.cos(curAng) * (spinnerRadius - 40), Math.sin(curAng) * (spinnerRadius - 40));
					
				var aField:MovieClip = new tfield();				
				aField.theText.text = prizeList[i - 1];
				
				aField.x = tLoc.x;
				aField.y = tLoc.y;
				aField.rotation = halfAngle - 180;
				
				spinner.addChild(aField);
				fList.push(aField);
			}
			
			m.translate(312, 312);
			spinnerBMP.bitmapData.draw(spinner, m);
			
			while (fList.length) {
				spinner.removeChild(fList.splice(0, 1)[0]);
			}
			for (i = 0; i < pegList.length; i++ ) {
				pegList[i].visible = false;
			}
		}
	}
	
}