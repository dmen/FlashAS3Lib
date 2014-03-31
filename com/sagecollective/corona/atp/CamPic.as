/**
 * Webcam wrapper
 * 
 * Makes it easy to take pictures with a web cam
 * Allows setting of the camera resolution, display resolution and capture resolution independently
 * 
 * Allows the addition of camera filters from the CamPicFilters class
 * 
 * usage:
 * var a:CamPic = new CamPic();
 * a.init(800, 600, 0, 0, 342, 223, 24); //set camera and capture res to 800x600 and display at 342x223 (24 fps)
 * a.show(container);
 * 
 * Use getCapture() to return the current image
 * 
 * Use pause()to show/stop on the captured pic
 * Use resume() to return to showing live video
 * 
 * Use addFilter() to add filters from the CamPicFilters class
 * Any filters affect the live video, and any returned captures
 * 
 */
package com.sagecollective.corona.atp
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.media.Camera;	
	import flash.media.Video;
	import flash.events.*;
	import flash.display.DisplayObject;
	import flash.utils.Timer;
	import flash.geom.Matrix;
	import flash.geom.Point;	
	

	public class CamPic extends EventDispatcher
	{
		private var cam:Camera;
		private var fullWidth:int;
		private var fullHeight:int;
		private var camWidth:int; //actual resolution the camera was set to - set in init
		private var camHeight:int;		
		private var theVideo:Video;		
		private var container:DisplayObjectContainer;		
		private var camTimer:Timer;
		private var captureMatrix:Matrix; //for scaling camera to the capture size
		
		private var displayData:BitmapData;
		private var displayBMP:Bitmap;
		private var displayMatrix:Matrix; //for scaling capture size to display size
		
		private var camAvailable:Boolean;
		
		private var filters:Array; //array of filters
		
		
		/**
		 * CONSTRUCTOR
		 */
		public function CamPic() 
		{			
			cam = Camera.getCamera();
			
			camAvailable = cam == null ? false : true;			
			clearFilters();
		}
		
		
		
		/**
		 * Initializes the object
		 * 
		 * Note - typically fullWidth/fullHeight will match camWidth/camHeight but there may be instances when you want the camera
		 * to capture at a lower resolution then the image you want returned from it. This can happen on low end machines where
		 * capturing at the proper resolution is too much for the processor - so you capture at low res and set fullWidth and fullHeight
		 * to something higher. 
		 * 
		 * @param	camWidth Required - the camera resolution width
		 * @param	camHeight Required - the camera resolution height
		 * @param	fullWidth - Full size capture image width - use 0 to have full size same as camera size
		 * @param	fullHeight - Full size capture image height
		 * @param	displayWidth - Display image width - use 0 to have display size same as camera size
		 * @param	displayHeight - Display image height
		 * @param	fps - Capture fps
		 */
		public function init($camWidth:int, $camHeight:int, $fullWidth:int = 0, $fullHeight:int = 0, displayWidth:int = 0, displayHeight:int = 0, fps:int = 24):void
		{	
			if($fullWidth == 0){
				fullWidth = $camWidth;
				fullHeight = $camHeight;
			}else {
				fullWidth = $fullWidth;
				fullHeight = $fullHeight;
			}
			
			if (displayWidth == 0) {
				displayWidth = $camWidth;
				displayHeight = $camHeight;
			}
			
			if (camAvailable) {
				cam.setMode($camWidth, $camHeight, fps);				
				camWidth = cam.width; //actual resolution the camera was set to
				camHeight = cam.height;	
			}else {
				camWidth = 1;
				camHeight = 1;
			}		
			
			displayData = new BitmapData(displayWidth, displayHeight, false, 0x000000);
			displayBMP = new Bitmap(displayData); //shown on stage
			
			//for copying theVideo into the display / preview bitmap
			displayMatrix = new Matrix();				
			displayMatrix.scale(displayWidth / camWidth, displayHeight / camHeight);
			
			//for scaling the video into the full size capture image
			captureMatrix = new Matrix();			
			captureMatrix.scale(fullWidth / camWidth, fullHeight / camHeight);
			
			theVideo = new Video(camWidth, camHeight);			
			
			camTimer = new Timer(1000 / fps);			
		}		
		
		
		/**
		 * Returns true if the camera is available or false if not
		 * camAvailable is set in the constructor
		 * 
		 * @return Boolean
		 */
		public function isAvailable():Boolean
		{
			return camAvailable;
		}		
		
		
		/**
		 * Gets the actual resolution the camera was set to in init()
		 * 
		 * @return an object containing width and height properties
		 */
		public function getResolution():Object
		{
			var o:Object = new Object();
			o.width = camWidth;
			o.height = camHeight;
			return o;
		}
		
		
		/**
		 * Adds a filter from the CamPicFilters class
		 * @param	filter
		 */
		public function addFilter(filter:*):void
		{
			filters.push(filter);
		}
		
		
		/**
		 * Removes all filters
		 */
		public function clearFilters():void
		{
			filters = new Array();
		}		
		
		
		/**
		 * Shows the video in the container at the display resolution
		 * @param	$container
		 */
		public function show($container:DisplayObjectContainer):void
		{	
			container = $container;				
			
			if(!container.contains(displayBMP)){
				container.addChild(displayBMP);
			}
			if(camAvailable){
				theVideo.attachCamera(cam);
			}
			
			camTimer.addEventListener(TimerEvent.TIMER, update, false, 0, true);
			camTimer.start();
		}		
		
		
		/**
		 * Removes the display image from the container
		 * Does not turn off the camera
		 */
		public function hide():void
		{
			if(container){
				if(container.contains(displayBMP)){
					container.removeChild(displayBMP);
				}
			}
		}
		
		
		/**
		 * Disposes the camera
		 * Removes the display image, stops the timer
		 * and removes the listener for it
		 * Turns off the camera
		 */
		public function dispose():void
		{						
			camTimer.stop();
			camTimer.removeEventListener(TimerEvent.TIMER, update);
			theVideo.attachCamera(null);
			trace("campic.dispose");
		}
		
		
		/**
		 * Stops drawing the camera to the display image
		 */
		public function pause():void
		{			
			camTimer.stop();
		}
		
		
		/**
		 * Resumes drawing the camera to the display image
		 */
		public function resume():void
		{
			camTimer.start();
		}
		
		
		/**
		 * Retrieves a copy of the camera image at camera resolution
		 * Camera resolution is set in init()
		 * 
		 * @param	withFilters Pass in False to get camera pic with no filters
		 * @return BitmapData
		 */
		public function getCamera(withFilters:Boolean = true):BitmapData
		{
			var blank:BitmapData = new BitmapData(camWidth, camHeight, false, 0xffffff);
			blank.draw(theVideo, null, null, null, null, true);
			
			if(withFilters){
				var p:Point = new Point(0, 0);
				var r:Rectangle = blank.rect;
				for (var i:int = 0; i < filters.length; i++) {
					blank.applyFilter(blank, r, p, filters[i]);
				}
			}
			
			return blank;
		}
		
		/**
		 * Retrieves a copy of the camera image at capture resolution
		 * Capture resolution is set in init()
		 * 
		 * @param	withFilters Pass in False to get camera pic with no filters
		 * @return BitmapData
		 */
		public function getCapture(withFilters:Boolean = true):BitmapData
		{		
			var blank:BitmapData = new BitmapData(fullWidth, fullHeight, false, 0xffffff);
			blank.draw(theVideo, captureMatrix, null, null, null, true);
			
			if(withFilters){
				var p:Point = new Point(0, 0);
				var r:Rectangle = blank.rect;
				for (var i:int = 0; i < filters.length; i++) {
					blank.applyFilter(blank, r, p, filters[i]);
				}
			}
			
			return blank;
		}
		
		
		/**
		 * Retrieves a copy of the camera image at display resolution
		 * Display resolution is set in init()
		 * 
		 * @param	withFilters Pass in False to get camera pic with no filters
		 * @return
		 */
		public function getDisplay(withFilters:Boolean = true):BitmapData
		{
			var blank:BitmapData = new BitmapData(displayData.width, displayData.height, false, 0xffffff);
			blank.draw(theVideo, displayMatrix, null, null, null, true);
			
			if(withFilters){
				var p:Point = new Point(0, 0);
				var r:Rectangle = blank.rect;
				for (var i:int = 0; i < filters.length; i++) {
					blank.applyFilter(blank, r, p, filters[i]);
				}
			}
			
			return blank;
		}
	
		
		/**
		 * Called by Timer event
		 * Draws the video onto the display bitmap object
		 * Update speed is determined by fps set in init()
		 * 
		 * @param	e TIMER TimerEvent
		 */
		private function update(e:TimerEvent):void
		{	
			displayData.draw(theVideo, displayMatrix, null, null, null, true);			
			
			var p:Point = new Point(0, 0);
			var r:Rectangle = displayData.rect;
			for (var i:int = 0; i < filters.length; i++) {
				displayData.applyFilter(displayData, r, p, filters[i]);
			}			
		}		
		
	}
	
}