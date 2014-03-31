package com.gmrmarketing.nissan
{
	import fl.data.DataProvider;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import com.gmrmarketing.bicycle.SWFKitFiles;	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import com.dynamicflash.util.Base64;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	
	public class PhotoAdmin extends MovieClip
	{
		private var fileList:Array;
		private var fileIndex:int;
		private var fileCount:int; //used for showing only the last 150 images
		
		private var byteLoader:Loader; //for loading of the images
		private var bigByteLoader:Loader; //for loading of the individual big image
		private var bgLoader:Loader; //for loading the background image
		
		private var swfKit:SWFKitFiles;
		
		
		public function PhotoAdmin()
		{
			swfKit = new SWFKitFiles();
			
			byteLoader = new Loader();
			byteLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bytesLoaded, false, 0, true);
			
			btnDelete.addEventListener(MouseEvent.CLICK, deleteItems, false, 0, true);
			btnClear.addEventListener(MouseEvent.CLICK, clearItems, false, 0, true);
			
			init();
		}
		
		private function init():void
		{
			refreshFileList();
			if(fileIndex != -1){
				loadImage();			
			}
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
		
		
		private function clearItems(e:MouseEvent):void
		{
			tiles.selectedItems = [];
		}
		
		
		private function refreshFileList():void
		{
			fileList = new Array();
			
			var files:Array = swfKit.getFiles();
			var file:String;
			var fileArray:Array;
			
			for (var i:int = 0; i < files.length; i++) {
				fileArray = files[i].split("\\");
				fileList.push(fileArray[fileArray.length - 1]);
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