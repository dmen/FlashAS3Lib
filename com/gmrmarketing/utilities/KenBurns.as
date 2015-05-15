/**
 * Ken Burns
 * give it a list of images and a container to play them in
 *
	import com.gmrmarketing.utilities.KenBurns;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	var kb:KenBurns = new KenBurns();
	kb.container = aContainer;
	kb.images = [im1,im2,etc];
	kb.show();
 *
 * 	Dispatches a CHANGE event everytime a new image begins to fade in
 */
	
package com.gmrmarketing.utilities
{
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.utils.Timer;
	
	
	public class KenBurns extends EventDispatcher
	{
		public static const CHANGE:String = "newImageFadingIn";
		private var myContainer:DisplayObjectContainer;
		private var myImages:Array;
		private var myDisplayTime:int = 10;//seconds to show
		private var curImage:int; //index in myImages
		private var nextTimer:Timer;
		private var tSprite:Sprite;
		
		public function KenBurns()
		{
			myImages = [];
			nextTimer = new Timer(myDisplayTime * 1000 - 2000, 1);			
		}
		
		
		/**
		 * sets the container to hold the images
		 */
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * Sets the list of images to play through
		 * @param ims Array of BitmapData objects
		 */
		public function set images(ims:Array):void
		{			
			myImages = [];
			curImage = 0;
			
			for (var i:int = 0; i < ims.length; i++) {
				var b:Bitmap = new Bitmap(ims[i]);
				b.smoothing = true;
				
				var s:Sprite = new Sprite();
				s.addChild(b);
				b.x = -960;
				b.y = -540;
				s.x = 960;
				s.y = 540;
				
				myImages.push(s);
			}
		}
		
		
		/**
		 * Starts the images fading and burnsing
		 */
		public function show():void
		{
			nextTimer.addEventListener(TimerEvent.TIMER, next);
			next();
		}
		
		
		/**
		 * Stops the images and removes them from the container
		 */
		public function stop():void
		{
			nextTimer.stop();
			nextTimer.removeEventListener(TimerEvent.TIMER, next);			
		}
		
		
		/**
		 * Removes the images from the container
		 */
		public function unload():void
		{
			while (myContainer.numChildren) {
				myContainer.removeChildAt(0);
			}
		}
		
		
		private function next(e:TimerEvent = null):void
		{			
			tSprite = myImages[curImage];
			myContainer.addChild(tSprite);
			
			curImage++;
			if (curImage >= myImages.length) {
				curImage = 0;
			}
			
			tSprite.alpha = 0;
			
			if (Math.random() < .5) {
				//scale it up
				tSprite.scaleX = tSprite.scaleY = 1;
				TweenMax.to(tSprite, myDisplayTime, { scaleX:1.1, scaleY:1.1, ease:Linear.easeNone } );
			}else {
				//scale it down
				tSprite.scaleX = tSprite.scaleY = 1.1;
				TweenMax.to(tSprite, myDisplayTime, { scaleX:1, scaleY:1, ease:Linear.easeNone } );
			}
			
			//new image fading in
			dispatchEvent(new Event(CHANGE));
			TweenMax.to(tSprite, 2, { alpha:1, onComplete:removeOld } );
			
			
			//fade in the next one before the current one finishes
			nextTimer.reset();			
			nextTimer.start();
		}
		
		
		private function removeOld():void
		{
			while (myContainer.numChildren > 1) {
				myContainer.removeChildAt(0);
			}
		}
		
	}
	
}