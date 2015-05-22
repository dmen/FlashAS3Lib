package com.gmrmarketing.empirestate.ilny
{
	import com.adobe.air.logging.FileTarget;
	import flash.events.*;
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.*;
	import flash.filesystem.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import org.gestouch.gestures.TransformGesture;
	import org.gestouch.events.GestureEvent;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	public class DetailDialog extends EventDispatcher
	{
		public static const ADD_INTEREST:String = "addNewInterest";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var sourceFolder:File;
		private var detailImage:Bitmap;
		private var theInterest:Object;
		private var tranGes:TransformGesture;
		private var tim:TimeoutHelper;
		private var userMoved:Boolean;
		
		
		public function DetailDialog()
		{
			sourceFolder = File.applicationDirectory;
			sourceFolder = sourceFolder.resolvePath("detailImages/");
			clip = new mcDetailDialog();
			
			userMoved = false;
			tranGes = new TransformGesture(clip.dragger);
			tim = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * 
		 * @param	interest
		 * @param	inList
		 * @param	clickPoint the mouse x,y when the icon was clicked
		 */
		public function show(interest:Object, inList:Boolean, clickPoint:Point):void
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
			clip.theName.y = Math.floor((82 - clip.theName.textHeight) * .5);//center name verticallyin the red bar at top
			
			//move the dialog north or south of the click loc
			//if the user hasn't positioned it somewhere...
			if(!userMoved){
				clip.x = 410;
				if (clickPoint.y > 500) {
					clip.y = clickPoint.y - clip.height - 50;
				}else {
					clip.y = clickPoint.y + 50;
				}
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
			var l:Loader = new Loader();
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
			if (f.exists) {				
				l.load(new URLRequest(f.nativePath));
			}else {
				//show default
				switch(theInterest.cat1) {
					case "Must See":
						l.load(new URLRequest("detailImages/Default_MustSee.png"));
						break;
					case "History":
						l.load(new URLRequest("detailImages/Default_History.png"));
						break;
					case "Family Fun":
						l.load(new URLRequest("detailImages/Default_FamilyFun.png"));
						break;
					case "Family Fun":
						l.load(new URLRequest("detailImages/Default_FamilyFun.png"));
						break;
					case "Wineries":
						l.load(new URLRequest("detailImages/Default_Wineries.png"));
						break;
					case "Breweries":
						l.load(new URLRequest("detailImages/Default_Breweries.png"));
						break;
					case "Wineries":
						l.load(new URLRequest("detailImages/Default_Wineries.png"));
						break;
					case "Art & Culture":
						l.load(new URLRequest("detailImages/Default_Culture.png"));
						break;
					case "Parks and Beaches":
						l.load(new URLRequest("detailImages/Default_Parks.png"));
						break;
				}
			}
			
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_BEGAN, onGesture);
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_CHANGED, onGesture);
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_ENDED, onGestureEnded);
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_CANCELLED, onGestureEnded);
		}
		
		
		private function onGesture(e:org.gestouch.events.GestureEvent):void
		{			
			tim.buttonClicked();
			var matrix:Matrix = clip.transform.matrix;
			matrix.translate(tranGes.offsetX, tranGes.offsetY);
			clip.transform.matrix = matrix;
		}
		
		
		private function onGestureEnded(e:org.gestouch.events.GestureEvent):void
		{
			userMoved = true;
			//clip is 1063x388
			if (clip.x < -800) {
				TweenMax.to(clip, .3, { x: -800 } );
			}
			if (clip.x > 1800) {
				TweenMax.to(clip, .3, { x:1800 } );
			}
			if (clip.y < -50) {
				TweenMax.to(clip, .3, { y: -50 } );
			}
			if (clip.y > 1000) {
				TweenMax.to(clip, .3, { y:1000 } );
			}
		}
		
		
		public function hide():void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeDialog);
			clip.btnAdd.removeEventListener(MouseEvent.MOUSE_DOWN, addInterest);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
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
		
		
		public function resetMove():void
		{
			userMoved = false;
		}
		
		
		private function closeDialog(e:MouseEvent):void
		{
			hide();
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