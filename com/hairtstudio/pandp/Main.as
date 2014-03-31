package com.hairtstudio.pandp
{
	import fl.data.DataProvider;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.*;
	import fl.controls.ComboBox;
	import fl.controls.ScrollBarDirection;
	import flash.ui.Mouse;
	
	import flash.display.MovieClip;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.FileFilter;
	
	
	
	public class Main extends MovieClip
	{		
		private const BASE_URL:String = "http://www.wisconsinpandp.com/";
		
		
		private var dbLoader:URLLoader; //database loader
		private var dbXML:XML; //returned xml from the database
		
		//private var categories:DataProvider;
		
		private var selectedImage:Object; //contains the clicked (selectedItem) from the tiles component
		//this is an object with properties passed in from getImages.php
		
		//for loading the full size image
		private var imageLoader:Loader;
		
		private var imDialog:imageDialog; //lib clip
		private var dialog:generalDialog;
		
		private var fileRef:FileReferenceList;
		private var files:Array; //array of FileReference objects
		
		
		
		
		public function Main()
		{			
			dbLoader = new URLLoader();			
			
			dialog = new generalDialog();
			dialog.x = 267;
			dialog.y = 126;			
			
			imDialog = new imageDialog();
			imDialog.x = 131;
			imDialog.y = 16;			
			
			var categories:DataProvider = new DataProvider();
			catSelector.dataProvider = categories;
			categories.addItem( { label:"Slot Machines", data:"slot" } );
			categories.addItem( { label:"Jukeboxes", data:"juke" } );
			categories.addItem( { label:"Pinball Machines", data:"pin" } );
			categories.addItem( { label:"Used Machines", data:"used" } );
			
			catSelector.addEventListener(Event.CHANGE, catChanged, false, 0, true);			
			
			tiles.allowDuplicates = false;
			tiles.rowHeight = 132;
			tiles.columnWidth = 128;
			tiles.canDragFrom = true;
			tiles.dragRemovesItem = true;
			tiles.dropOffRemovesItem = false;
			tiles.canDropOn = true;
			tiles.dragAlpha = .43;
			tiles.autoScroll = true;
			tiles.scrollZone = .1;
			tiles.scrollSpeed = 5;
			tiles.direction = ScrollBarDirection.VERTICAL;
			tiles.addEventListener(MouseEvent.CLICK, tileClicked, false, 0, true);
			
			//interface button listeners
			btnFull.addEventListener(MouseEvent.CLICK, viewFullSize, false, 0, true);
			btnDelete.addEventListener(MouseEvent.CLICK, confirmDelete, false, 0, true);
			btnSave.addEventListener(MouseEvent.CLICK, confirmSaveOrder, false, 0, true);
			btnUpload .addEventListener(MouseEvent.CLICK, uploadClicked, false, 0, true);
			
			//select first item in the dropdown and call catChanged() in order to load the
			//data for the selection
			catSelector.selectedIndex = 0;
			catChanged();
			
		}
		
		
		/**
		 * Called when the upload new images button is clicked
		 * @param	e
		 */
		private function uploadClicked(e:MouseEvent):void
		{
			fileRef = new FileReferenceList();
			fileRef.addEventListener(Event.SELECT, onFileSelected, false, 0, true);
			var typeFilter:FileFilter = new FileFilter("JPG/PNG Files", "*.jpeg; *.jpg; *.png");			
			fileRef.browse([typeFilter]);
		}
		
		
		/**
		 * Called when the user selects files, and presses ok, in the file dialog
		 * @param	e
		 */
		private function onFileSelected(e:Event):void
		{			
			files = fileRef.fileList;
			
			dialog.theText.text = "";
			if (!contains(dialog)) {
				addChild(dialog);
			}
			dialog.btnOK.addEventListener(MouseEvent.CLICK, closeDialog, false, 0, true);
			dialog.btnCancel.addEventListener(MouseEvent.CLICK, closeDialog, false, 0, true);			
			
			uploadFile();
		}
		
		private function uploadFile():void
		{
			if(files.length){
				var file:FileReference = files.splice(0, 1)[0];
				dialog.theText.text = "Uploading: " + file.name;
				dialog.progBar.alpha = 1;
				dialog.progBar.bar.scaleX = 0;
				file.addEventListener(Event.COMPLETE, uploadComplete, false, 0, true);
				file.addEventListener(ProgressEvent.PROGRESS, uploadProgress, false, 0, true);				
			
				var request:URLRequest = new URLRequest(BASE_URL + "script/fileUpload.php");
				var variables:URLVariables = new URLVariables();
			
				variables.category = catSelector.selectedItem.data;            
				request.data = variables;
				
				file.upload(request);
				
			}else {
				dialog.theText.text = "Upload Complete";
				dialog.progBar.alpha = 0;
				catChanged();
			}
		}
		
		private function uploadProgress(e:ProgressEvent):void
		{
			dialog.progBar.bar.scaleX = e.bytesLoaded / e.bytesTotal;
		}
		
		private function uploadComplete(e:Event):void
		{
			uploadFile();
		}
		
		
		
		
		private function confirmDelete(e:MouseEvent):void
		{
			dialog.theText.text = "Press ok to confirm deletion of " + selectedImage.fname + " from the server";
			if (!contains(dialog)) {
				addChild(dialog);
			}
			dialog.btnOK.addEventListener(MouseEvent.CLICK, deleteConfirmed, false, 0, true);
			dialog.btnCancel.addEventListener(MouseEvent.CLICK, closeDialog, false, 0, true);
		}
		
		
		private function closeDialog(e:MouseEvent = null):void
		{
			removeChild(dialog);
			dialog.btnOK.removeEventListener(MouseEvent.CLICK, closeDialog);
			dialog.btnOK.removeEventListener(MouseEvent.CLICK, deleteConfirmed);
			dialog.btnCancel.removeEventListener(MouseEvent.CLICK, closeDialog);
		}
		
		private function deleteConfirmed(e:MouseEvent):void
		{
			dialog.theText.text = "Deleting image...";
			
			dbLoader.addEventListener(Event.COMPLETE, imageDeleted, false, 0, true);
			
			var request:URLRequest = new URLRequest(BASE_URL + "script/deleteImage.php");
            var variables:URLVariables = new URLVariables();
			
            variables.id = selectedImage.id;
			variables.fileName = selectedImage.fname;			
            request.data = variables;
			
			dbLoader.load(request);
		}
		
		private function imageDeleted(e:Event):void
		{
			dbLoader.removeEventListener(Event.COMPLETE, imageDeleted);
			closeDialog();
			catChanged();
		}
		
		
		
		
		private function confirmSaveOrder(e:MouseEvent):void
		{
			dialog.theText.text = "Press ok to save the current set of images in the order specified.";
			if (!contains(dialog)) {
				addChild(dialog);
			}
			dialog.btnOK.addEventListener(MouseEvent.CLICK, saveConfirmed, false, 0, true);
			dialog.btnCancel.addEventListener(MouseEvent.CLICK, closeDialog, false, 0, true);
		}
		private function saveConfirmed(e:MouseEvent):void
		{
			dialog.theText.text = "Saving order...";
			
			dbLoader.addEventListener(Event.COMPLETE, saveCompleted, false, 0, true);
			
			var request:URLRequest = new URLRequest(BASE_URL + "script/saveOrder.php");
            var variables:URLVariables = new URLVariables();
			
			var c:int = tiles.length; //num items in the data provider
			var reqString:String = "";
			var curItem:Object;
			
			for (var i:int = 0; i < c; i++) {
				curItem = tiles.getItemAt(i);
				reqString += "id=" + String(curItem.id) + "xor=" + String(i + 1) + "z";				
			}
			
			//delete final z
			reqString = reqString.substr(0, reqString.length - 1);
			
            variables.orderString = reqString;						
            request.data = variables;
			
			dbLoader.load(request);
			
		}
		
		
		private function saveCompleted(e:Event):void
		{			
			dbLoader.removeEventListener(Event.COMPLETE, saveCompleted);
			closeDialog();			
			catChanged();
		}
		
		
		
		
		
		/**
		 * populates selectedImage with the clicked on image object data
		 * current properties passed back from getImages:
		 * id, order, category, source, fname, image
		 * @param	e
		 */
		private function tileClicked(e:MouseEvent):void
		{
			if(tiles.selectedItem != null){
				selectedImage = tiles.selectedItem;
				fileName.text = selectedImage.fname;			
			}
		}
		
		/**
		 * Called when the dropdown selector changes
		 * loads the data from the database for the given category
		 *
		 * @param	e Event.CHANGE
		 */
		private function catChanged(e:Event = null):void
		{
			dbLoader.addEventListener(Event.COMPLETE, catDataLoaded, false, 0, true);
			
			var request:URLRequest = new URLRequest(BASE_URL + "script/getImages.php");
            var variables:URLVariables = new URLVariables();
			
            variables.category = catSelector.selectedItem.data;            
            request.data = variables;
			dbLoader.load(request);
		}
		
		
		/**
		 * Called by complete listener on dbLoader when the data is finished loading
		 * populates the tiles object from the incoming xml
		 * @param	e
		 */
		private function catDataLoaded(e:Event):void
		{			
			dbLoader.removeEventListener(Event.COMPLETE, catDataLoaded);
			
			dbXML = new XML(dbLoader.data);
			var dp:DataProvider = new DataProvider(dbXML);
			tiles.dataProvider = dp;			
		}
		
		
		/**
		 * Cakked by click on view full size button
		 */
		private function viewFullSize(e:MouseEvent):void
		{			
			if(!contains(imDialog)){
				addChild(imDialog);
			}
			imDialog.btnClose.addEventListener(MouseEvent.CLICK, closeImageDialog, false, 0, true);
			imDialog.progBar.scaleX = 0;
			
			imageLoader = new Loader();
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bigImageLoaded, false, 0, true);
			imageLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, bigImageLoading, false, 0, true);			
			imageLoader.load(new URLRequest(selectedImage.image));
		}
		
		
		private function closeImageDialog(e:MouseEvent):void
		{
			imDialog.btnClose.removeEventListener(MouseEvent.CLICK, closeImageDialog);
			if (imDialog.contains(imageLoader)) {
				imDialog.removeChild(imageLoader);
			}
			imageLoader.unload();
			if (contains(imDialog)) {
				removeChild(imDialog);
			}
		}
		
		private function bigImageLoading(e:ProgressEvent):void
		{
			imDialog.progBar.scaleX = e.bytesLoaded / e.bytesTotal;
		}
		
		
		
		/**
		 * Called by complete listener on imageLoader
		 * @param	e Event.COMPLETE
		 */
		private function bigImageLoaded(e:Event):void
		{			
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}
			
			imDialog.fileSize.text = String(bit.width) + " x " + String(bit.height);
		 
			var imRatio:Number = 420 / bit.height; //420 is height of container
			imageLoader.height *= imRatio;
			imageLoader.width *= imRatio;
			
			if(!imDialog.contains(imageLoader)){
				imDialog.addChild(imageLoader);
				imageLoader.x = 6 + ((560 - imageLoader.width) * .5);
				imageLoader.y = 5;				
			}
			
			
		}
	}
	
}