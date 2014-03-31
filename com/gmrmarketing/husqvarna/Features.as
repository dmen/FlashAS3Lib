/**
 * Feature manager
 */

package com.gmrmarketing.husqvarna
{	
	import flash.display.DisplayObjectContainer;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.display.Loader;
	
	import com.gmrmarketing.utilities.XMLLoader;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	

	
	
	public class Features extends EventDispatcher
	{
		public static const FEATURE_CLICKED:String = "featureWasClicked";
		public static const BOTTOM_FEATURE_CLICKED:String = "bottomFeatureWasClicked";
		public static const FEATURES_REMOVED:String = "allFeaturesRemoved";
		
		private var xmlLoader:XMLLoader;
		private var feats:XML;
		
		private var musicURL:String;
		private var showMusic:Boolean;
		
		private var container:DisplayObjectContainer;
		private var allFeatures:Array;
		
		private var clickedFeature:feature; //last clicked feature - used for retrieving data
		
		private var onBottom:Boolean;
		
		//for playing sound
		private var channel:SoundChannel;		
		
		//library sound		
		private var buttonSound:buttonPop;		
		
		//array index of the currently selected bottom feature
		private var currentIndex:int; 
		
	
		
		
		/**
		 * CONSTRUCTOR
		 * @param	$container Container where features are placed
		 */
		public function Features($container:DisplayObjectContainer, xmlURL:String)
		{
			buttonSound = new buttonPop();
			
			container = $container;
			
			showMusic = false;
			musicURL = "";
			
			xmlLoader = new XMLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlError, false, 0, true);
			xmlLoader.load(xmlURL);
			
			allFeatures = new Array();
		}
		
		
		private function xmlLoaded(e:Event):void
		{
			feats = xmlLoader.getXML();
		}
		
		
		private function xmlError(e:IOErrorEvent):void
		{
			feats = null;
		}
		
		public function showingMusic():Boolean
		{
			return feats.music.@show == "true" ? true : false;
		}
		
		public function getMusicURL():String
		{
			return feats.music;
		}
		
		
		/**
		 * Returns an object containing the description and video path for
		 * the last clicked feature icon
		 * 
		 * @return object
		 */
		public function getFeatureData():Object
		{
			var data:Object = new Object();
			data.description = clickedFeature.description;
			data.video = clickedFeature.video;
			data.feature = clickedFeature.feature;
			//data.callout = clickedFeature.callout;
			//data.calloutLoc = clickedFeature.calloutLoc;			
			
			return data;
		}
		
		
		
		/**
		 * Shows the features for the currentView
		 * places the features around the mower view according to the loc node in the xml
		 * 
		 * @param	theView String name of the view - front, side, top
		 */
		public function showFeaturesForView(theView:String):void
		{
			onBottom = false;			
			
			var curFeats:XMLList = feats.features.(@view == theView).feature;
			
			for (var i:int = 0; i < curFeats.length(); i++) {
				
				var f:feature = new feature(); //library item
				
				var tl:Loader = new Loader();				
				var thisFeat:XML = curFeats[i];
				tl.load(new URLRequest(thisFeat.thumb));
				f.slide = Number(thisFeat.slide); //slide distance of target
				f.description = thisFeat.description;
				f.video = thisFeat.video;
				f.feature = thisFeat.name;
				
				//if callout is undefined then the node doesn't exist in the xml
				//if callout is "" then it exists but is blank
				/*
				if (thisFeat.callout == undefined || thisFeat.callout == "") {
					f.callout = "";
				}else {					
					f.callout = thisFeat.callout;
					f.calloutLoc = thisFeat.callout.@loc;					
				}
				*/
				
				
				//5,5 is the offset of the image in the frame - gives a 5 pixel border
				tl.x = 5;
				tl.y = 5;				
				f.addChildAt(tl, 5);
				
				var loc:Array = String(thisFeat.loc).split(",");
				f.x = Number(loc[0]);
				f.y = Number(loc[1]);
				
				//slideDirection is used by showTarget to move the slider left or right of the feature icon
				//if the icon x is > 470 then the icon is on the right side of the screen and the slider should
				//move left to hit the mower				
				if (f.x > 470) {
					f.slideDirection = "l"; //slide left if feature is right of center
				}else {
					f.slideDirection = "r"; //slide right if feature is left of center
				}
				
				f.scaleX = f.scaleY = .8;
				f.theFeature.text = thisFeat.name;
				container.addChild(f);
				allFeatures.push(f);
				
				TweenLite.to(f, .75, { scaleX:1, scaleY:1, ease:Bounce.easeOut } );
				
				f.addEventListener(MouseEvent.MOUSE_OVER, showTarget, false, 0, true);
				f.addEventListener(MouseEvent.MOUSE_OUT, hideTarget, false, 0, true);
				f.addEventListener(MouseEvent.CLICK, featureClicked, false, 0, true);
				
				f.mouseChildren = false;
				f.buttonMode = true;
			}
		}
		
		
		/**
		 * Shows features along the bottom
		 * No view parameter because all features are shown at bottom
		 */
		public function showFeaturesAtBottom():void
		{
			onBottom = true;			
			
			var curFeats:XMLList = feats.features.feature; //gets all features
			var duplicates:Array = new Array();
			var ok:Boolean;
			
			var startX:int = 55;
			var startY:int = 680;
			var buffer:int = 12;
			
			for (var i:int = 0; i < curFeats.length(); i++) {
				
				var thisFeat:XML = curFeats[i];
				var featName:String = thisFeat.name;
				
				if (duplicates.indexOf(featName) == -1) {
					duplicates.push(featName);
				
					var f:feature = new feature();
					
					var tl:Loader = new Loader();
					
					tl.load(new URLRequest(thisFeat.thumb));				
					tl.x = 5;
					tl.y = 5;
					f.addChildAt(tl, 5);				
					
					f.description = thisFeat.description;
					f.video = thisFeat.video;
					f.feature = featName;
					
					//set the current index based on the feature that was clicked on in the view
					if (clickedFeature.feature == thisFeat.name) {
						currentIndex = allFeatures.length;
					}else {
						//set all but currently selected to alpha 0
						f.bg.alpha = 0;
					}
					
					//if callout is undefined then the node doesn't exist in the xml
					//if callout is "" then it exists but is blank
					/*
					if (thisFeat.callout == undefined || thisFeat.callout == "") {
						f.callout = "";
					}else {
						f.callout = thisFeat.callout;
						f.calloutLoc = thisFeat.callout.@loc;						
					}
					*/
					
					f.x = startX;
					f.y = startY;				
					
					f.slider.alpha = 0;
					f.sliderR.alpha = 0;
					f.scaleX = f.scaleY = .8;
					f.theFeature.text = thisFeat.name;
					f.featureIndex = allFeatures.length;
					container.addChild(f);
					
					allFeatures.push(f);
					
					TweenLite.to(f, .75, { scaleX:1, scaleY:1, ease:Bounce.easeOut } );
					
					startX += (126 + buffer);
					
					f.addEventListener(MouseEvent.MOUSE_OVER, showTargetBottom, false, 0, true);
					f.addEventListener(MouseEvent.MOUSE_OUT, hideTargetBottom, false, 0, true);
					f.addEventListener(MouseEvent.CLICK, bottomFeatureClicked, false, 0, true);
					
					f.mouseChildren = false;
					f.buttonMode = true;
				}
			}			
		}
		
		
		
		private function featureClicked(e:MouseEvent):void
		{			
			clickedFeature = feature(e.currentTarget);
			dispatchEvent(new Event(FEATURE_CLICKED));
		}
		
		
		
		/**
		 * Slides out the target from the left or right side of the icon depending on the slideDirection property
		 * Called on MouseOver 
		 * 
		 * @param	e
		 */
		private function showTarget(e:MouseEvent):void
		{
			var f:feature = feature(e.currentTarget);
			var dir:String = f.slideDirection;
			if(dir == "l"){
				TweenLite.to(f.slider, 1, { x:0 - f.slide, ease:Bounce.easeOut } );
			}else {
				//feature is 126 pixels wide
				TweenLite.to(f.sliderR, 1, {  x:126 + f.slide, ease:Bounce.easeOut } );
			}
			playButtonSound();
		}
		
		
		/**
		 * Slides the target back in on MouseOut
		 * @param	e
		 */
		private function hideTarget(e:MouseEvent):void
		{
			var f:feature = feature(e.currentTarget);
			var dir:String = f.slideDirection;
			
			if(dir == "l"){
				TweenLite.to(f.slider, .5, { x:0} );
			}else {
				TweenLite.to(f.sliderR, .5, { x:126 } );
			}			
		}
		
		
		
		private function bottomFeatureClicked(e:MouseEvent):void
		{						
			clickedFeature = feature(e.currentTarget);
			if (currentIndex != clickedFeature.featureIndex) {
				TweenLite.to(feature(allFeatures[currentIndex]).bg, .5, { alpha:0 } );
			}
			currentIndex = clickedFeature.featureIndex;
			dispatchEvent(new Event(BOTTOM_FEATURE_CLICKED));
		}
		
		
		/**
		 * Fades in the white background
		 * Called on MouseOver
		 * Used when the icon are all at bottom versus around the mower
		 * @param	e
		 */
		private function showTargetBottom(e:MouseEvent):void
		{
			playButtonSound();
			
			var f:feature = feature(e.currentTarget);			
			TweenLite.to(f.bg, .5, { alpha:1 } );			
		}
		
		
		private function hideTargetBottom(e:MouseEvent):void
		{
			var f:feature = feature(e.currentTarget);
			//hide border if this is not the current selection
			if(f.featureIndex != currentIndex){
				TweenLite.to(f.bg, .5, { alpha:0 } );
			}
		}
		
		private function playButtonSound():void
		{
			buttonSound.play();
		}
		
		/**
		 * Removes features from the view
		 * Called from PZT.showDetail()
		 */
		public function clearFeatures():void
		{		
			var d:String;
			var f:feature;
			
			for (var i:int = 0; i < allFeatures.length - 1; i++){
				f = allFeatures[i];				
				if (f.x < 470) {
					d = "-50";					
				}else {
					d = "50";
				}
				TweenLite.to(f, .5, { x:d, alpha:0} );
			}
			f = allFeatures[allFeatures.length - 1];				
			if (f.x < 470) {
				d = "-50";					
			}else {
				d = "50";
			}
			TweenLite.to(f, .5, { x:d, alpha:0, onComplete:killFeatures} );
		}
		
		
		public function killFeatures():void
		{
			while (allFeatures.length) {
				var f:feature = allFeatures.splice(0, 1)[0];
				f.removeEventListener(MouseEvent.CLICK, featureClicked);
				f.removeEventListener(MouseEvent.MOUSE_OVER, showTarget);
				f.removeEventListener(MouseEvent.MOUSE_OUT, hideTarget);
				f.removeEventListener(MouseEvent.MOUSE_OVER, showTargetBottom);
				f.removeEventListener(MouseEvent.MOUSE_OUT, hideTargetBottom);
				f.removeEventListener(MouseEvent.CLICK, bottomFeatureClicked);
				container.removeChild(f);
			}
			dispatchEvent(new Event(FEATURES_REMOVED));
		}
	}
	
}