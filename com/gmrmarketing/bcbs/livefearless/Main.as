package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.*;
	import flash.events.*;
	
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var textEntry:TextEntry;
		private var takePhoto:TakePhoto;
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();
			
			textEntry = new TextEntry();
			textEntry.setContainer(this);
			
			takePhoto = new TakePhoto();
			takePhoto.setContainer(this);
			
			intro = new Intro();
			intro.setContainer(this);
			intro.addEventListener(Intro.BEGIN, showTextEntry, false, 0, true);
			intro.show();
		}
		
		
		/**
		 * User clicked the screen on the inro page
		 * @param	e
		 */
		private function showTextEntry(e:Event):void
		{
			textEntry.addEventListener(TextEntry.SHOWING, removeIntro, false, 0, true);
			textEntry.addEventListener(TextEntry.NEXT, showTakePhoto, false, 0, true);
			textEntry.show();
		}
		
		
		/**
		 * Hides intro screen once textEntry screen is showing
		 * @param	e
		 */
		private function removeIntro(e:Event):void
		{
			textEntry.removeEventListener(TextEntry.SHOWING, removeIntro);
			intro.hide();
		}
		
		
		private function showTakePhoto(e:Event):void
		{
			textEntry.removeEventListener(TextEntry.NEXT, showTakePhoto);
			takePhoto.addEventListener(TakePhoto.SHOWING, removeTextEntry, false, 0, true);
			takePhoto.addEventListener(TakePhoto.EDIT, editText, false, 0, true);
			takePhoto.show(textEntry.getMessage());
		}
		
		
		private function removeTextEntry(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOWING, removeTextEntry);
			textEntry.hide();
		}
		
		/**
		 * user pressed the edit text button on the take photo screen
		 * @param	e
		 */
		private function editText(e:Event):void
		{
			textEntry.addEventListener(TextEntry.NEXT, showTakePhoto, false, 0, true);
			textEntry.addEventListener(TextEntry.SHOWING, removePhoto, false, 0, true);
			textEntry.show(false);
		}
		
		private function removePhoto(e:Event):void
		{
			textEntry.removeEventListener(TextEntry.SHOWING, removePhoto);
			takePhoto.hide();
		}
	}
	
}