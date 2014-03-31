package com.gmrmarketing.comcast.scratchoff
{	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import com.coreyoneil.collision.CollisionList;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import com.greensock.TweenLite;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	import flash.net.SharedObject;
    import flash.net.SharedObjectFlushStatus;
	import flash.display.Bitmap;
	import com.gmrmarketing.utilities.LocalFile;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Timer;
	
	
	
	public class PrizeWheel extends MovieClip
	{
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
		
		private var mySo:SharedObject;
		
		private var spinner:Sprite;
		private var spinnerLoader:Loader;
		
		private var thePointer:pointer; //lib clip
		
		private var lf:LocalFile; //for retrieving slice/prize data
		
		private var thePrize:String;
		private var theDescription:String;
		
		private var channel:SoundChannel;
		private var sound:Sound;
		
		private var stageRef:Stage;
		private var spinnerBMP:Bitmap;
		private var pegList:Array;
		
		
		
		public function PrizeWheel($stageRef:Stage)
		{			
			stageRef = $stageRef;
			
			//uses AIR file classes
			lf = LocalFile.getInstance();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, clear, false, 0, true);
		}
		
		
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			sound = new spring(); //library sound
			
			//loads the data object from the local file
			var theData:Object = lf.load();
			
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
			
			addChild(spinner);
			
			thePointer = new pointer();
			thePointer.x = 203;// 287;
			thePointer.y = 389;
			addChild(thePointer);
			
			//var tpc:BitmapData = new triplePlayCube(109, 165);
			//var tpcb:Bitmap = new Bitmap(tpc);
			//addChild(tpcb);
			//tpcb.x = 498;// 582;
			//tpcb.y = 350;			
			
			//thePointer.cacheAsBitmap = true;
			//thePointer.cacheAsBitmapMatrix = new Matrix();
			
			
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
		
		
		private function clear(e:Event):void
		{
			spinner.removeEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);
			stageRef.removeEventListener(MouseEvent.MOUSE_UP, endDragRotation);
			removeEventListener(MouseEvent.MOUSE_MOVE, updateDragRotation);
			removeEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function begin():void
		{	
			thePrize = "";
			
			cList = new CollisionList(thePointer.point);
			cList.returnAngle = true;
			
			addPegs();
			//addIcons();
			spinner.addEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);
			addTextFields();
			
			//spinner.cacheAsBitmap = true;
			//spinner.cacheAsBitmapMatrix = new Matrix();
			
			//addEventListener(Event.ENTER_FRAME, update);
			stageRef.addEventListener(MouseEvent.MOUSE_UP, endDragRotation);
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
		
		
		/*
		private function addIcons():void
		{
			var halfAngle:Number;
			for (var i:int = 1; i < angleList.length; i++) {
				halfAngle = angleList[i - 1] + ((angleList[i] - angleList[i - 1]) / 2);
				var curAng:Number = halfAngle * .0174532925; //* radians per degree
				var newIcon:icon = new icon();
				var buffer:Number = newIcon.width;
				var pegLoc:Point = new Point(Math.cos(curAng) * (spinnerRadius - buffer), Math.sin(curAng) * (spinnerRadius - buffer));
				newIcon.x = pegLoc.x;
				newIcon.y = pegLoc.y;
				newIcon.rotation = halfAngle;
				
				spinner.addChild(newIcon);
			}
		}
		*/
		
		
		
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
				
				thePrize = prizeList[prizeSlice];
				theDescription = descriptionList[prizeSlice];
				
				dispatchEvent(new Event("doneSpinning"));				
			}
			
		}
		
		
		public function getPrize():Array
		{
			return new Array(thePrize, theDescription);
		}
		
		
		
		private function startDragRotation(e:MouseEvent):void
		{
			initTime = getTimer();
			var position:Number = Math.atan2(mouseY - spinner.y, mouseX - spinner.x);	
			var angle:Number = (position / Math.PI) * 180;
			initAngle = spinner.rotation;
			offset = spinner.rotation - angle;
			addEventListener(MouseEvent.MOUSE_MOVE, updateDragRotation);			
		}
		
		
		
		/**
		 * Called on enter frame as the spinner is dragged
		 * @param	e
		 */
		private function updateDragRotation(e:Event):void
		{
			lastDragTime = getTimer();
			var position:Number = Math.atan2(mouseY - spinner.y, mouseX - spinner.x);	
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
			
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			
			removeEventListener(MouseEvent.MOUSE_MOVE, updateDragRotation);
			spinner.removeEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);				
			stageRef.removeEventListener(MouseEvent.MOUSE_UP, endDragRotation);			
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
				
				halfAngle = angleList[i - 1] + ((angleList[i] - angleList[i - 1]) / 2);
				var curAng:Number = halfAngle * .0174532925; //* radians per degree
				
				var tLoc:Point = new Point(Math.cos(curAng) * (spinnerRadius - 40), Math.sin(curAng) * (spinnerRadius - 40));
					
				var aField:MovieClip = new tfield();				
				aField.theText.text = prizeList[i];
				
				aField.x = tLoc.x;
				aField.y = tLoc.y;
				aField.rotation = halfAngle - 180;
				
				spinner.addChild(aField);
				fList.push(aField);
				
				//m.translate( -312, -312);
				//m.translate(tLoc.x, tLoc.y);
				//m.rotate(curAng);
				
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