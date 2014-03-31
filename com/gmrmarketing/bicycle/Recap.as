package com.gmrmarketing.bicycle
{	
	import flash.display.MovieClip;
	import flash.events.*;	
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;	
	import fl.data.DataProvider;
	import fl.controls.List;
	import com.gmrmarketing.bicycle.SWFKitFiles;
	import com.gmrmarketing.bicycle.CardImage;
		
	
	public class Recap extends MovieClip
	{
		private var files:SWFKitFiles;
		private var cardImage:CardImage;
		private var dp:DataProvider;
		private var curFileIndex:int;
		private var uid:String;				
		
		
		public function Recap()
		{
			files = new SWFKitFiles();
			cardImage = new CardImage();
			
			dp = new DataProvider();
			
			var fileList:Array = files.getFiles();
			for (var i:int = 0; i < fileList.length; i++) {				
				dp.addItem( { label:fileList[i] } );
			}
			
			theFiles.dataProvider = dp;
			
			info.text = "There are " + dp.length + " files to be uploaded";
			
			perBar.scaleX = 0;
			
			btnUpload.addEventListener(MouseEvent.CLICK, beginUpload, false, 0, true);
			btnCancel.addEventListener(MouseEvent.CLICK, stopProcessing, false, 0, true);
		}				
		
		
		private function beginUpload(e:MouseEvent):void
		{
			//info.appendText("beginUpload\n");
			if (dp.length > 0) {
				btnUpload.removeEventListener(MouseEvent.CLICK, beginUpload); //disable upload button
				cardImage.addEventListener(CardImage.DID_POST, uploadCompleted, false, 0, true);
				cardImage.addEventListener(CardImage.DID_NOT_POST, uploadFailed, false, 0, true);
				addEventListener(Event.ENTER_FRAME, updateProgress, false, 0, true);
				curFileIndex = -1;
				processNextFile();
			}
		}				
		
		
		private function processNextFile(e:Event = null):void
		{
			curFileIndex++;
			
			info.text = "Processing file: " + String(curFileIndex + 1);
			if (curFileIndex < dp.length) {
				theFiles.selectedIndex = curFileIndex;
				var uFile:String = dp.getItemAt(curFileIndex).label;
				fName.text = uFile; //display file being uploaded
				
				var ind = uFile.indexOf("."); //remove extension to get uid
				uid = uFile.substr(0, ind);
				
				var contents:String = files.readFile(uFile);
				cardImage.postImage(contents, uid);				
				
			}else {
				stopProcessing();
			}		
		}		

		
		private function updateProgress(e:Event):void
		{
			perBar.scaleX = cardImage.getProgress();
		}		
		
		
		private function uploadCompleted(e:Event):void
		{			
			var uFile:String = dp.getItemAt(curFileIndex).label;			
			var didMove:Boolean = files.moveFile(uFile);
			processNextFile();			
		}		
		
		
		private function uploadFailed(e:Event):void
		{
			//info.appendText("fail\n");
			processNextFile();			
		}		
		
		
		private function stopProcessing(e:MouseEvent = null):void
		{
			info.text = "Processing Complete";
			
			btnUpload.addEventListener(MouseEvent.CLICK, beginUpload, false, 0, true);
			removeEventListener(Event.ENTER_FRAME, updateProgress);
			
			//refresh the list
			dp = new DataProvider();
			var fileList:Array = files.getFiles();
			for (var i:int = 0; i < fileList.length; i++) {				
				dp.addItem( { label:fileList[i] } );
			}
			
			theFiles.dataProvider = dp;
			perBar.scaleX = 0;
		}
	}	
}