package com.gmrmarketing.sap.nhl2015.gda.cloud
{
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import flash.display.*;
	import com.gmrmarketing.sap.metlife.tagcloud.RectFinder;	
	import com.gmrmarketing.sap.superbowl.gda.tagcloud.TagCloud;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	import flash.filters.DropShadowFilter;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Main extends MovieClip implements IModuleMethods
	{		
		public static const FINISHED:String = "finished";//dispatched when the task is complete. Player will call cleanup() now
		private const DISPLAY_TIME:Number = 15000;//ms
		private var startTime:Number;
		
		private var dict:TagCloud;//tags from the service
		private var ra:RectFinder;
		private var tagName:String; //set in setConfig, one of: levis,offense,defense
		private var tagContainer:Sprite;//these two for the smaller clouds
		private var maskContainer:Sprite;
		
		private var localCache:Object;
		private var myDate:String; //from xml
		private var myColors:Array; //from xml
		
		private var TESTING:Boolean = false;
		
		private var cloud1Done:Boolean = false;
		private var cloud2Done:Boolean = false;
		private var grays:Array;
		private var tweenObject:Object;
		private var circleContainer:Sprite;
		
		public function Main()
		{			
			ra = new RectFinder(2);
			
			dict = new TagCloud(2, 22, 3);
			dict.addEventListener(TagCloud.TAGS_READY, tagsLoaded, false, 0, true);
			
			grays = new Array(0xffffff,0xffffff);
			
			tagContainer = new Sprite();			
			tagContainer.x = 183;
			tagContainer.y = 24;
			
			maskContainer = new Sprite();
			maskContainer.x = 183;
			maskContainer.y = 24;			
			maskContainer.addChild(new theMask());
			
			bottomBar.y = 512; //off screen bottom
			
			circleContainer = new Sprite();
			
			if (TESTING) {
				init("");
			}
		}		
		
		
		public function init(initValue:String = ""):void
		{
			addChild(tagContainer);
			addChild(maskContainer);
			tagContainer.mask = maskContainer;
			tagContainer.cacheAsBitmap = true;
			maskContainer.cacheAsBitmap = true;
			
			addChild(circleContainer);
			dict.refreshTags(grays);//TagCloud calls tagsLoaded when ready - this loads all the tags
		}			
		
		
		/**
		 * callback from calling TagCloud.refreshTags()
		 * all tags are ready now - all levels
		 * @param	e
		 */
		private function tagsLoaded(e:Event):void
		{
			localCache = 1;//this just so isready() will return true			
			if (TESTING) {
				show();
			}
		}		
		
		
		public function isReady():Boolean
		{
			return localCache != null;
		}		
		
	
		public function show():void
		{		
			startTime = new Date().valueOf();//now
			
			tweenObject = { ang:0 };
			
			//drop shadow:, new DropShadowFilter(4, 45, 0, .8, 6, 6, 1, 2)
			ra.create(tagContainer, new cloud(), dict.getTags(), true, false, 15000, 0);
			//ra.addEventListener(RectFinder.FINISHED, tagsComplete, false, 0, true);			
			
			TweenMax.to(tweenObject, DISPLAY_TIME / 1000, { ang:360, onUpdate:drawCircle, ease:Linear.easeNone, onComplete:waitThree } );
			TweenMax.to(bottomBar, .5, { y:449, ease:Back.easeOut, delay:1 } );
		}
		
		private function drawCircle():void
		{
			Utility.drawArc(circleContainer.graphics, 384, 225, 205, 0, tweenObject.ang, 8, 0xedb01a, 1);
		}
		
		
		/**
		 * called when the cloud has completed
		 * @param	e
		 */
		private function tagsComplete(e:Event):void
		{
			ra.removeEventListener(RectFinder.FINISHED, tagsComplete);
			//transitionLevel or done			
			done();
		}
		
		
		private function done(e:TimerEvent = null):void
		{
			var remTime:Number = (DISPLAY_TIME - (new Date().valueOf() - startTime)) / 1000;//seconds for TweenMax			
			TweenMax.delayedCall(remTime, doDispatch);
		}
		
		private function waitThree():void
		{
			TweenMax.delayedCall(3, doDispatch);
		}
		private function doDispatch():void
		{
			dispatchEvent(new Event(FINISHED));//will call cleanup
		}
		
		
		private function transition(e:TimerEvent = null):void
		{			
			var n:int = tagContainer.numChildren - 1;
			var t:Bitmap;
			var delay:Number = 0;
			for (var i:int = n; i >= 1; i--) {
				t = Bitmap(tagContainer.getChildAt(i));
				TweenMax.to(t, .75, { z: -500, y:"-25", alpha:0, delay:delay } );
				delay += .015;
			}
			t = Bitmap(tagContainer.getChildAt(0));
			TweenMax.to(t, .75, { z: -500, y:"-25", alpha:0, delay:delay, onComplete:clearLevel } );
		}
		
		
		private function clearLevel():void
		{
			while (tagContainer.numChildren) {
				tagContainer.removeChildAt(0);
			}
		}		
		
		
		public function cleanup():void
		{	
			bottomBar.y = 512; //off screen bottom
			circleContainer.graphics.clear();
			clearLevel();
			dict.refreshTags(grays);//calls tagsLoaded when ready
		}		
		
	}
	
}