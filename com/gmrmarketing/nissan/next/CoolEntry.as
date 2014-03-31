/**
 * instantiated by Main
 * 
 */

package com.gmrmarketing.nissan.next
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;	
	import flash.filesystem.File;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import com.greensock.TweenMax;
	import flash.net.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.text.TextFieldAutoSize;
	
	public class CoolEntry extends EventDispatcher
	{
		public static const ENTRY_SUBMITTING:String = "coolEntrySubmitting";
		public static const ENTRY_SUBMITTED:String = "coolEntrySubmitted";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var dialog:MovieClip; //lib clip
		
		private var process:NativeProcess;//these for the virtual keyboard
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;
		
		private var theStage:Stage;
		
		private var rfid:String; //sent in from Main
		private var nameString:String;
		private var serviceURL:String;
		
		private var timeoutHelper:TimeoutHelper;
		
		
		public function CoolEntry($serviceURL:String)
		{
			serviceURL = $serviceURL	
			
			clip = new coolEntry(); //library clips
			
			dialog = new coolDialog();
			
			timeoutHelper = TimeoutHelper.getInstance();
			
			//for closing the onscreen keyboard
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
		}		
		
		
		/**
		 * 
		 * @param	$container
		 * @param	$nameString User name and city to be displayed in the preview
		 */
		public function show($container:DisplayObjectContainer, $nameString:String, $rfid:String):void
		{
			timeoutHelper.buttonClicked();
			
			container = $container;
			nameString = $nameString;
			rfid = $rfid;
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.theText.text = "";//main message box
			clip.chars.text = "50"; //characters remaining
			clip.stage.focus = clip.theText;
			clip.theText.addEventListener(Event.CHANGE, stripLF, false, 0, true);
			
			theStage = container.stage;
			theStage.addEventListener(KeyboardEvent.KEY_UP, checkField, false, 0, true);
			theStage.addEventListener(MouseEvent.MOUSE_DOWN, setFocus, false, 0, true);
			
			showKeyboard();//shows Hot virtual keyboard
			setFocus();
		}		
		
		
		private function setFocus(e:Event = null) {
			theStage.focus = clip.theText;
		}
		
		
		public function hide():void
		{
			if(container){
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
				if (container.contains(dialog)) {
					container.removeChild(dialog);
				}
			}
			if(theStage){
				theStage.removeEventListener(KeyboardEvent.KEY_UP, checkField);
				theStage.removeEventListener(MouseEvent.MOUSE_DOWN, setFocus);
			}
			clip.theText.removeEventListener(Event.CHANGE, stripLF);
			
			hideKeyboard();
		}		
		
		
		/**
		 * Removes the carriage return from the field
		 * @param	e CHANGE event
		 */
		private function stripLF(e:Event):void
		{			
			clip.theText.text = clip.theText.text.replace("\r", "");
		}		
		
		
		/**
		 * Shows preview message when enter on keyboard is pressed
		 * @param	e
		 */
		private function checkField(e:KeyboardEvent):void
		{			
			clip.chars.text = String(50 - clip.theText.length);
			
			timeoutHelper.buttonClicked();
			
			//ENTER
			if (e.charCode == 13) {
				
				var targetString:String = String(clip.theText.text).toUpperCase();						
				targetString = targetString.replace("'", "’"); //All upper and using the curved single quote ’
			
				dialog.preview.theText.autoSize = TextFieldAutoSize.LEFT;
				
				dialog.preview.theText.text = targetString;
				dialog.preview.theName.text = nameString.toUpperCase(); //nameString is populated in show()
				
				//positioning from CoolMessage.addCharacter()
				dialog.preview.theName.y = dialog.preview.theText.y + ((dialog.preview.theText.numLines * 37) - ((dialog.preview.theText.numLines - 1) * 6));
				
				dialog.preview.cursor.alpha = 0;
				dialog.alpha = 1;
				container.addChild(dialog);
				
				hideKeyboard();
				
				dialog.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, submitClicked, false, 0, true);
				dialog.btnEdit.addEventListener(MouseEvent.MOUSE_DOWN, editClicked, false, 0, true);
			}		
		}		
		
		
		/**
		 * Called when submit in the preview dialog is called
		 * @param	e
		 */
		private function submitClicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			dispatchEvent(new Event(ENTRY_SUBMITTING));
			
			theStage.removeEventListener(KeyboardEvent.KEY_DOWN, checkField);
			TweenMax.to(dialog, 1, { alpha:0, onComplete:killDialog } );
			hideKeyboard();
			
			//send to web service
			var mess:String = escape(clip.theText.text);
			var request:URLRequest = new URLRequest(serviceURL + "?rfid=" + rfid + "&post=" + mess);
			
			//var vars:URLVariables = new URLVariables();
			//vars.message = dialog.preview.theText.text;
					
			//request.data = vars;			
			request.method = URLRequestMethod.GET;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			lo.load(request);
		}
		
		
		
		private function dataError(e:IOErrorEvent):void
		{
			
		}
		
		
		
		private function dataPosted(e:Event):void
		{
			var lo:URLLoader = URLLoader(e.target);
			var vars:URLVariables = new URLVariables(lo.data);
			trace(vars.success);
			
			dispatchEvent(new Event(ENTRY_SUBMITTED));
		}		
		
		
		private function editClicked(e:MouseEvent):void
		{
			TweenMax.to(dialog, 1, { alpha:0, onComplete:killDialog } );
				
			dialog.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submitClicked);
			dialog.btnEdit.removeEventListener(MouseEvent.MOUSE_DOWN, editClicked);
			
			theStage.addEventListener(KeyboardEvent.KEY_DOWN, checkField, false, 0, true);
			
			clip.stage.focus = clip.theText;
			
			showKeyboard();
		}		
		
		
		private function killDialog():void
		{
			if(container.contains(dialog)){
				container.removeChild(dialog);
			}
		}		
		
		
		private function showKeyboard(e:Event = null):void
		{
			try{
				if(NativeProcess.isSupported){				
					var file:File = File.desktopDirectory.resolvePath("showKB.exe");
					nativeProcessStartupInfo.executable = file;
					
					process = new NativeProcess();
					process.start(nativeProcessStartupInfo);
				}
			}catch (e:Error) {
				
			}
		}		
		
		
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
		
	}
	
}