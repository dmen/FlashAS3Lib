package com.gmrmarketing.pm
{
	import flash.display.MovieClip;
	import flash.utils.ByteArray;
	import com.dynamicflash.util.Base64;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import com.gmrmarketing.bicycle.SWFKitFiles;
	import flash.display.Loader;
	import flash.events.*;
	import flash.display.LoaderInfo;
	import fl.data.DataProvider;

	public class PhotoViewer extends MovieClip
	{
		private var fileList:Array;
		private var fileIndex:int;
		private var fileCount:int; //used for showing only the last 150 images
		private var swfKit:SWFKitFiles;
		private var byteLoader:Loader; //for loading of the images
		
		public function PhotoViewer()
		{
			swfKit = new SWFKitFiles();
			byteLoader = new Loader();
			byteLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bytesLoaded, false, 0, true);
			
			btnDelete.addEventListener(MouseEvent.CLICK, deleteItems, false, 0, true);
			btnClear.addEventListener(MouseEvent.CLICK, clearItems, false, 0, true);
			
			tiles.addEventListener(Event.CHANGE, showFName, false, 0, true);
			
			init();
		}
		
		private function init():void
		{
			refreshFileList();
			if(fileIndex != -1){
				loadImage();			
			}
		}
		
		private function showFName(e:Event):void
		{
			fName.text = tiles.selectedItem.data;
		}
		
		private function clearItems(e:MouseEvent):void
		{
			tiles.selectedItems = [];
		}
		
		private function deleteItems(e:MouseEvent):void
		{
			var a:Array = tiles.selectedItems;
			for (var i:int = 0; i < a.length; i++) {
				swfKit.removeFile(a[i].data);
			}
			tiles.dataProvider = new DataProvider();
			init();
		}
		
		private function refreshFileList():void
		{
			fileList = new Array();
			
			var files:Array = swfKit.getFiles();
			var file:String;
			var fileArray:Array;
			if(files != null){
				for (var i:int = 0; i < files.length; i++) {
					fileArray = files[i].split("\\");
					fileList.push(fileArray[fileArray.length - 1]);
				}			
			}
			//start at the last file in the list
			fileIndex = fileList.length - 1;
			fileCount = 0;
		}
		

		private function loadImage():void
		{
			var ba:ByteArray = Base64.decodeToByteArray(swfKit.readFile(fileList[fileIndex]));
			byteLoader.loadBytes(ba);
		}
		
		
		private function bytesLoaded(e:Event):void
		{	
			var aloader:Loader = (e.target as LoaderInfo).loader;
			var bmp:Bitmap = Bitmap(aloader.content);
			bmp.smoothing = true;					
			
			tiles.addItem( { data:fileList[fileIndex], source:bmp } );
			
			fileIndex--;
			fileCount++;
			
			if (fileIndex > -1 && fileCount < 150) {
				loadImage();
			}
		}	
	}
	
}