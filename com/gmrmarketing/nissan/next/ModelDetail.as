/**
 * Instantiated by Main
 */

package com.gmrmarketing.nissan.next
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.Loader;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import com.gmrmarketing.nissan.next.Feature;
	import com.gmrmarketing.nissan.next.ThreeSixty;
	import com.gmrmarketing.nissan.next.Video;
	import flash.display.Bitmap;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.gmrmarketing.nissan.next.StaticData;
	
	
	public class ModelDetail extends EventDispatcher
	{
		public static const BACK_TO_LINEUP:String = "backToModelLineUp";
		public static const VIEWING_360:String = "viewing360";
		public static const VIEWING_PHOTO:String = "viewingPhoto";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var cars:XMLList;
		
		private var loader1:Loader; //for pic defined in xml
		private var loader2:Loader; //for car pic - like one defined in xml but car only
		
		private var justCarPic:String;
		
		private var photos:Array; //images for photos
		private var theVideo:String; //file name for the video
		private var threeSixty:String; //file name of the 360 swf		
		private var features:String; //file name of the feature swf - set in show()
		private var buttonLocations:Array;
		
		//bubble buttons
		private var featureButton:MovieClip;
		private var threeSixtyButton:MovieClip;
		private var videoButton:MovieClip;
		private var photosButton:MovieClip;
		
		private var modal:MovieClip; //modalBG clip from library
		
		private var photoPositions:Array;
		
		private var btnClose:MovieClip; //buttonClose lib clip
		private var carPhotos:Array;
		private var feature:Feature;
		private var threeSix:ThreeSixty;
		private var video:Video;
		
		private var currentCar:XMLList; //current car being viewed from the fleetXML - set in show()
		private var timeoutHelper:TimeoutHelper;
		
		
		
		public function ModelDetail(fleetXML:XML)
		{
			clip = new modelDetailClip(); //lib clip
			
			cars = fleetXML.cars.car;
			
			//bubble button locations
			buttonLocations = new Array(new Point(1285, 400), new Point(1205, 400), new Point(1125, 400), new Point(1045, 400));
			
			photoPositions = new Array([423, 124, .3], [675, 76, .5], [264, 293, .5], [675, 353, .3], [173, 124, .3], [923, 353, .3]);
			
			//this is the close button used to close the modules - photos,video,360,features
			btnClose = new buttonClose(); //lib clip
			//btnClose.width = btnClose.height = 40;
			btnClose.x = 1185;
			btnClose.y = 610;
			
			carPhotos = new Array();
			
			timeoutHelper = TimeoutHelper.getInstance();
			
			loader1 = new Loader();
			loader2 = new Loader();
		}
		
		
		/**
		 * Shows the car at the specified index
		 * @param	$container
		 * @param	xmlId Car id from the fleet xml
		 */
		public function show($container:DisplayObjectContainer, xmlId:String):void
		{
			timeoutHelper.buttonClicked();
			
			container = $container;
			
			currentCar = cars.(id == xmlId);
			
			var glamPic:String = currentCar.glamourPic; //pic with text - this is a png
			var pieces:Array = glamPic.split("."); //splits file name into name,extension
			justCarPic = pieces[0] + "_car.jpg"; //just car pic is a jpg
			
			//split on a null string returns an array with one item - so need to make sure there's a ,
			photos = new Array();
			if(String(currentCar.photos) != ""){
				photos = String(currentCar.photos).split(","); 
			}
		
			theVideo = String(currentCar.video);
			threeSixty = String(currentCar.threeSixty);
			features = String(currentCar.features);
			
			clip.btnBack.alpha = 0; //Back button at upper left
			
			loader1.contentLoaderInfo.addEventListener(Event.COMPLETE, carPicWithTextLoaded, false, 0, true);
			loader1.load(new URLRequest(StaticData.getAssetPath() + glamPic));
		}
		
		
		private function carPicWithTextLoaded(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			var b:Bitmap = Bitmap(e.target.content);
			b.smoothing = true;	
			
			loader1.width = 1366; loader1.height = 672;
			
			clip.addChildAt(loader1, 0);			
			loader1.contentLoaderInfo.removeEventListener(Event.COMPLETE, carPicWithTextLoaded);
			
			loader2.contentLoaderInfo.addEventListener(Event.COMPLETE, justCarPicLoaded, false, 0, true);
			loader2.load(new URLRequest(StaticData.getAssetPath() + justCarPic));
		}
		
		
		/**
		 * puts just car pic behind the car with text pic
		 * @param	e
		 */
		private function justCarPicLoaded(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			var b:Bitmap = Bitmap(e.target.content);
			b.smoothing = true;	
			
			loader2.width = 1366; loader2.height = 672;
			
			clip.addChildAt(loader2, 0);
			loader2.contentLoaderInfo.removeEventListener(Event.COMPLETE, justCarPicLoaded);
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.alpha = 1;
			clip.glamMask.scaleX = 0;
			loader1.mask = clip.glamMask;
			
			var positionIndex:int = 0;
			//add needed bubble buttons
			if (features.length > 0) {
				featureButton = new modelDetailButton(); //lib clip
				featureButton.theText.text = "Features";
				clip.addChild(featureButton);
				featureButton.x = 1340;
				featureButton.y = buttonLocations[positionIndex].y;
				
				featureButton.alpha = 0;
				TweenMax.to(featureButton, .6, { x:buttonLocations[positionIndex].x, alpha:.95, delay:.75, ease:Back.easeOut } );
				featureButton.addEventListener(MouseEvent.MOUSE_DOWN, featuresClicked, false, 0, true);
				positionIndex++;
			}
			if (threeSixty.length > 0) {
				threeSixtyButton = new modelDetailButton(); //lib clip
				threeSixtyButton.theText.text = "360";
				clip.addChild(threeSixtyButton);
				threeSixtyButton.x = 1340;
				threeSixtyButton.y = buttonLocations[positionIndex].y;
				
				threeSixtyButton.alpha = 0;
				TweenMax.to(threeSixtyButton, .6, { x:buttonLocations[positionIndex].x, alpha:.95, delay:.75, ease:Back.easeOut } );
				threeSixtyButton.addEventListener(MouseEvent.MOUSE_DOWN, threeSixtyClicked, false, 0, true);
				positionIndex++;
			}
			if (theVideo.length > 0) {
				videoButton = new modelDetailButton(); //lib clip
				videoButton.theText.text = "Video";
				clip.addChild(videoButton);
				videoButton.x = 1340;
				videoButton.y = buttonLocations[positionIndex].y;
				
				videoButton.alpha = 0;
				TweenMax.to(videoButton, .6, { x:buttonLocations[positionIndex].x, alpha:.95, delay:.75, ease:Back.easeOut } );
				videoButton.addEventListener(MouseEvent.MOUSE_DOWN, videoClicked, false, 0, true);
				positionIndex++;
			}
			if (photos.length > 0) {
				photosButton = new modelDetailButton(); //lib clip
				photosButton.theText.text = "Photos";
				clip.addChild(photosButton);
				photosButton.x = 1340;
				photosButton.y = buttonLocations[positionIndex].y;
				
				photosButton.alpha = 0;
				TweenMax.to(photosButton, .6, { x:buttonLocations[positionIndex].x, alpha:.95, delay:.75, ease:Back.easeOut } );
				photosButton.addEventListener(MouseEvent.MOUSE_DOWN, photosClicked, false, 0, true);
				positionIndex++;
			}
			
			TweenMax.to(clip.glamMask, .75, { scaleX:1, ease:Linear.easeNone, delay:.5 } );	
			TweenMax.to(clip.btnBack, 1, { alpha:1, delay:1 } );
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, hide, false, 0, true);
		}
		
		
		/**
		 * Called when the photos button is clicked
		 * @param	e
		 */
		private function photosClicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			Multitouch.inputMode = MultitouchInputMode.GESTURE; //send gesture events
			photosButton.removeEventListener(MouseEvent.MOUSE_DOWN, photosClicked);
			
			modal = new modalBG();
			clip.addChild(modal);
			modal.alpha = 0;
			TweenMax.to(modal, .5, { alpha:.85 } );
			
			carPhotos = new Array(); //keep track of photos for calling hide on them in closePhotos()
			for (var i:int = 0; i < photos.length; i++) {
				var a:Photo = new Photo(clip, StaticData.getAssetPath() + photos[i], photoPositions[i][0], photoPositions[i][1], photoPositions[i][2]);
				carPhotos.push(a);
			}
			
			//all photos are in - add the close button
			container.addChild(btnClose);
			btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closePhotos, false, 0, true);
			
			dispatchEvent(new Event(VIEWING_PHOTO));
		}
		
		
		/**
		 * Called when the features balloon button is picked
		 * @param	e
		 */
		private function featuresClicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			featureButton.removeEventListener(MouseEvent.MOUSE_DOWN, featuresClicked);			
			if (!feature) {
				feature = new Feature();
			}
			feature.show(container, features);
			feature.addEventListener(Feature.FEATURES_READY, addFeatureClose, false, 0, true);
		}
		private function addFeatureClose(e:Event):void
		{			
			container.addChild(btnClose);
			btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeFeatures, false, 0, true);
		}
		
		
		private function threeSixtyClicked(e:MouseEvent):void
		{			
			timeoutHelper.buttonClicked();
			
			threeSixtyButton.removeEventListener(MouseEvent.MOUSE_DOWN, threeSixtyClicked);
			if (!threeSix) {
				threeSix = new ThreeSixty();
			}
			threeSix.show(container, threeSixty);
			threeSix.addEventListener(ThreeSixty.THREESIXTY_READY, addThreeSixtyClose, false, 0, true);
			
			dispatchEvent(new Event(VIEWING_360));
		}
		
		private function addThreeSixtyClose(e:Event):void
		{
			threeSix.listen();
			container.addChild(btnClose);
			btnClose.addEventListener(MouseEvent.MOUSE_DOWN, close360, false, 0, true);
		}
		
		
		private function videoClicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			videoButton.removeEventListener(MouseEvent.MOUSE_DOWN, videoClicked);
			
			video = new Video();
			video.show(container, theVideo);
			video.addEventListener(Video.VIDEO_STOPPED, closeVideo, false, 0, true);
		
			container.addChild(btnClose);
			btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeVideo, false, 0, true);
		}		
		
		
		public function closePhotos(e:MouseEvent = null):void
		{
			timeoutHelper.buttonClicked();
			
			Multitouch.inputMode = MultitouchInputMode.NONE; //revert to sending mouse events only
			if(photosButton){
				photosButton.addEventListener(MouseEvent.MOUSE_DOWN, photosClicked, false, 0, true);
			}
			
			for (var i:int = 0; i < carPhotos.length; i++) {
				Photo(carPhotos[i]).hide();
			}
			carPhotos = new Array();
			if(modal){
				if(clip.contains(modal)){
					clip.removeChild(modal);
				}
			}
			if (btnClose) {
				btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closePhotos);
				if(container){
					if(container.contains(btnClose)){
						container.removeChild(btnClose);
					}
				}
			}
		}
		
		public function closeFeatures(e:MouseEvent = null):void
		{
			timeoutHelper.buttonClicked();
			
			if(featureButton){
				featureButton.addEventListener(MouseEvent.MOUSE_DOWN, featuresClicked, false, 0, true);
			}
			btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeFeatures);
			if(feature){
				feature.hide();
			}
			if (btnClose) {
				btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeFeatures);
				if(container){
					if(container.contains(btnClose)){
						container.removeChild(btnClose);
					}
				}
			}
		}
		
		public function close360(e:MouseEvent = null):void
		{
			timeoutHelper.buttonClicked();
			
			if(threeSixtyButton){
				threeSixtyButton.addEventListener(MouseEvent.MOUSE_DOWN, threeSixtyClicked, false, 0, true);
			}
			
			if(threeSix){
				threeSix.hide();
			}
			if (btnClose) {
				btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, close360);
				if(container){
					if(container.contains(btnClose)){
						container.removeChild(btnClose);
					}
				}
			}
		}
		
		public function closeVideo(e:* = null):void
		{
			timeoutHelper.buttonClicked();
			
			if(videoButton){
				videoButton.addEventListener(MouseEvent.MOUSE_DOWN, videoClicked, false, 0, true);
			}			
			
			if(video){
				video.hide();
				video.removeEventListener(Video.VIDEO_STOPPED, closeVideo);
			}
			if (btnClose) {
				btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeVideo);
				if(container){
					if(container.contains(btnClose)){
						container.removeChild(btnClose);
					}
				}
			}
		}
		
		/**
		 * Closes all the modules - photos, video, 360, features
		 */
		public function closeModules():void
		{
			timeoutHelper.buttonClicked();
			
			closePhotos();
			closeFeatures();
			close360();
			closeVideo();
		}
		
		/**
		 * Called by pressing Back button at upper left
		 * @param	e
		 */
		public function hide(e:MouseEvent = null):void
		{			
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );			
		}		
		
		
		private function kill():void
		{	
			closeModules();
			
			try{
				loader1.close();
			}catch (e:Error) {
				
			}
			
			try{
				loader2.close();
			}catch (e:Error) {
				
			}
			
			loader1.unload();
			loader2.unload();
			loader1.contentLoaderInfo.removeEventListener(Event.COMPLETE, carPicWithTextLoaded);
			loader2.contentLoaderInfo.removeEventListener(Event.COMPLETE, justCarPicLoaded);
			
			if(clip.contains(loader1)){
				clip.removeChild(loader1);
			}
			
			if(clip.contains(loader2)){
				clip.removeChild(loader2);
			}
			if(container){
				if(container.contains(clip)) {
					container.removeChild(clip);
				}
			}
			
			if (photosButton) {
				TweenMax.killTweensOf(photosButton);
				if (clip.contains(photosButton)) {
					clip.removeChild(photosButton);
				}
				photosButton.removeEventListener(MouseEvent.MOUSE_DOWN, photosClicked);
			}
			
			if (videoButton) {
				TweenMax.killTweensOf(videoButton);
				if (clip.contains(videoButton)) {
					clip.removeChild(videoButton);
				}
				videoButton.removeEventListener(MouseEvent.MOUSE_DOWN, videoClicked);
			}
			
			if (threeSixtyButton) {
				TweenMax.killTweensOf(threeSixtyButton);
				if (clip.contains(threeSixtyButton)) {
					clip.removeChild(threeSixtyButton);
				}
				threeSixtyButton.removeEventListener(MouseEvent.MOUSE_DOWN, threeSixtyClicked);
			}
			
			if (featureButton) {
				TweenMax.killTweensOf(featureButton);
				if (clip.contains(featureButton)){
					clip.removeChild(featureButton);
				}
				featureButton.removeEventListener(MouseEvent.MOUSE_DOWN, featuresClicked);
			}
			
			dispatchEvent(new Event(BACK_TO_LINEUP));
		}
		
	}
	
}