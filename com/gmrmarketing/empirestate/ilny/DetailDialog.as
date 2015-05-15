package com.gmrmarketing.empirestate.ilny
{
	import com.adobe.air.logging.FileTarget;
	import flash.events.*;
	import flash.display.*;
	import flash.geom.Point;
	import flash.text.*;
	import flash.filesystem.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class DetailDialog extends EventDispatcher
	{
		public static const ADD_INTEREST:String = "addNewInterest";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var sourceFolder:File;
		private var detailImage:Bitmap;
		private var theInterest:Object;
		
		
		public function DetailDialog()
		{
			sourceFolder = File.applicationDirectory;
			sourceFolder = sourceFolder.resolvePath("detailImages/");
			clip = new mcDetailDialog();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * 
		 * @param	interest
		 * @param	inList
		 * @param	clickY Mouse Y click position
		 */
		public function show(interest:Object, inList:Boolean, clickY:int):void
		{
			theInterest = interest;
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			if(detailImage){
				if (clip.contains(detailImage)) {
					clip.removeChild(detailImage);
				}
			}
			
			clip.theName.autoSize = TextFieldAutoSize.LEFT;
			clip.theName.text = theInterest.name;
			clip.theName.y = Math.floor((82 - clip.theName.textHeight) * .5);
			
			clip.x = 410;
			if (clickY > 500) {
				clip.y = 255;
			}else {
				clip.y = 550;
			}			
			
			var info:String = theInterest.city + ", " + theInterest.region + "\n";
			info += theInterest.phone + "\n";
			info += theInterest.listing;
			
			clip.theInfo.text = info;
			
			//if too much text ellipsis it
			if (clip.theInfo.textHeight > clip.theInfo.height) {
				
				while (clip.theInfo.textHeight > clip.theInfo.height) {
					clip.theInfo.text = clip.theInfo.text.substr(0, clip.theInfo.text.length - 1);
				}
				//do 10 more so there's room for the ellipsis
				for (var i:int = 0; i < 10; i++) {
					clip.theInfo.text = clip.theInfo.text.substr(0, clip.theInfo.text.length - 1);
				}
				clip.theInfo.appendText("...");
			}
			
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeDialog);
			if(!inList){
				clip.btnAdd.addEventListener(MouseEvent.MOUSE_DOWN, addInterest);
			}
			
			if (inList) {
				TweenMax.to(clip.heart, 0, { colorMatrixFilter: { saturation:1 }} );//red
				TweenMax.to(clip.bucketText, 0, { colorMatrixFilter:{ saturation:1 }} );
				clip.bucketText.text = "THIS IS IN YOUR BUCKET LIST";
			}else {
				TweenMax.to(clip.heart, 0, { colorMatrixFilter: { saturation:0 }} );//gray
				TweenMax.to(clip.bucketText, 0, { colorMatrixFilter:{ saturation:0 }} );
				clip.bucketText.text = "ADD THIS TO MY BUCKET LIST";
			}
			
			//load image
			var f:File = File.applicationDirectory.resolvePath("detailImages/" + theInterest.name + ".jpg");
			if (f.exists) {
				var l:Loader = new Loader();
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
				l.load(new URLRequest(f.nativePath));
			}else {
				//show default
				
			}
		}
		
		
		private function imageLoaded(e:Event):void
		{
			detailImage = Bitmap(e.target.content);
			detailImage.smoothing = true;
			clip.addChild(detailImage);
			detailImage.x = 14;
			detailImage.y = 95;
		}
		
		
		private function closeDialog(e:MouseEvent):void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeDialog);
			clip.btnAdd.removeEventListener(MouseEvent.MOUSE_DOWN, addInterest);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		public function get interest():Object
		{
			return theInterest;
		}
		
		
		private function addInterest(e:MouseEvent):void
		{
			TweenMax.to(clip.heart, 0, { colorMatrixFilter: { saturation:1 }} );//red
			TweenMax.to(clip.bucketText, 0, { colorMatrixFilter:{ saturation:1 }} );
			clip.bucketText.text = "THIS IS IN YOUR BUCKET LIST";
				
			dispatchEvent(new Event(ADD_INTEREST));
		}
		
	}
	
}