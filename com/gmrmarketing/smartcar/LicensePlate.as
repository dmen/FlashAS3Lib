package com.gmrmarketing.smartcar
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.*;	
	import flash.geom.Matrix;
	import flash.text.*;
	
	
	public class LicensePlate extends MovieClip
	{
		public static const PLATE_NOT_DONE:String = "GoBackToEditingMode";
		public static const PLATE_DONE:String = "PlateEditingComplete";
		
		private var theField:TextField;
		private var fieldData:BitmapData;
		private var fieldMatrix:Matrix;		
		
		private var license:String;
		
		
		
		public function LicensePlate()
		{
			fieldData = new BitmapData(108, 34, true, 0x00000000);			
			addEventListener(Event.ADDED_TO_STAGE, setFocus, false, 0, true);			
		}
		
		
		public function init($license:String = ""):void
		{
			license = $license;
			textHolder.theText.text = license;			
			
			addEventListener(Event.REMOVED_FROM_STAGE, cleanUp, false, 0, true);
			addEventListener(Event.ENTER_FRAME, forceLower, false, 0, true);
			
			btnEdit.addEventListener(MouseEvent.CLICK, backToEdit, false, 0, true);
			btnOK.addEventListener(MouseEvent.CLICK, plateComplete, false, 0, true);
		}
		
		private function setFocus(e:Event):void
		{		
			TextField(textHolder.theText).stage.focus = TextField(textHolder.theText);
			TextField(textHolder.theText).setSelection(textHolder.theText.text.length, textHolder.theText.text.length);
		}
		
		public function getLicense():String
		{
			return license;
		}
		
		public function getLicenseImage():BitmapData
		{
			fieldMatrix = new Matrix();
			fieldMatrix.scale(108 / theText.textWidth, 34 / theText.textHeight);
			if (theText.text.length < 7) {
				var diff:int = 7 - theText.text.length;
				for (var i:int = 0; i < diff; i++) {
					theText.appendText(" ");
				}
			}
			fieldData.draw(theText, fieldMatrix);
			return fieldData;
		}
		
		/**
		 * Forces all lower case
		 * @param	e
		 */
		private function forceLower(e:Event):void
		{			
			textHolder.theText.text = String(textHolder.theText.text).toLowerCase();
			license = textHolder.theText.text;
			theText.text = license;
		}
		
		/**
		 * Called by clicking the back to editing button
		 * @param	e
		 */
		private function backToEdit(e:MouseEvent):void
		{
			dispatchEvent(new Event(PLATE_NOT_DONE));
		}
		
		/**
		 * Called by clicking the Okay, I'm done button
		 * @param	e
		 */
		private function plateComplete(e:MouseEvent):void
		{
			dispatchEvent(new Event(PLATE_DONE));
		}
		
		private function cleanUp(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, setFocus);
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
			removeEventListener(Event.ENTER_FRAME, forceLower);
			
			btnEdit.removeEventListener(MouseEvent.CLICK, backToEdit);
			btnOK.removeEventListener(MouseEvent.CLICK, plateComplete);
		}
	
	}
	
}