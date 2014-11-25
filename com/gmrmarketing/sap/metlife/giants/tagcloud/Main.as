package com.gmrmarketing.sap.metlife.giants.tagcloud
{
	import com.gmrmarketing.sap.metlife.ISchedulerMethods;
	import flash.display.*;
	import com.gmrmarketing.sap.metlife.tagcloud.RectFinder;	
	import com.gmrmarketing.sap.metlife.tagcloud.TagCloud;	
	import flash.events.*;	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	import flash.filters.DropShadowFilter;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const FINISHED:String = "finished";//dispatched when the task is complete. Player will call cleanup() now
		
		private const WIDTH:int = 1008;
		private const HEIGHT:int = 567;
		
		private var dict:TagCloud;//tags from the service
		private var ra:RectFinder;
		private var tagName:String; //set in setConfig, one of: levis,offense,defense
		private var tagContainer:Sprite;
		
		private var localCache:Object;
		private var myDate:String; //from xml
		private var myColors:Array; //from xml
		private var currentLevel:int;
		
		private var tag1:MovieClip;
		private var tag2:MovieClip;
		
		private var flareDelay:int;
		
		
		public function Main()
		{	
			tag1 = new tagHolder();//lib clip
			tag2 = new tagHolder();//lib clip
			
			dict = new TagCloud(5, 56, 22);
			dict.addEventListener(TagCloud.TAGS_READY, tagsLoaded, false, 0, true);
			
			tagContainer = new Sprite();
			addChild(tagContainer);
			
			//init("11/16/14,0xFFFFFF,0xDDDDDD,0xBBBBBB,0xAAAAAA");
		}
		
		
		/**
		 * ISChedulerMethods
		 * initValue is gameDate, array of colors: levis,0xffffff,0xcccccc,0x678900,etc
		 */
		public function init(initValue:String = ""):void
		{	
			var i:int = initValue.indexOf(",");//first occurence of comma
			myDate = initValue.substring(0, i);
			var cols:String = initValue.substr(i + 1);
			myColors = cols.split(",");
			
			ra = new RectFinder(5);
			
			dict.refreshTags(myColors, myDate);//calls tagsLoaded when ready
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function getFlareList():Array
		{
			var fl:Array = new Array();
			//screen 1
			fl.push([300, 94, 700, "line", 1]);//x, y, to x, type, delay
			fl.push([327, 172, 682, "point", 1.5]);//x, y, to x, type, delay
			fl.push([286, 473, 718, "line", 2]);//x, y, to x, type, delay
			fl.push([301, 515, 702, "point", 2.2]);//x, y, to x, type, delay
			//screen 2
			fl.push([300, 94, 700, "line", 7.5]);//x, y, to x, type, delay
			fl.push([327, 172, 682, "point", 8.5]);//x, y, to x, type, delay
			fl.push([286, 473, 718, "line", 9]);//x, y, to x, type, delay
			fl.push([301, 515, 702, "point", 9.2]);//x, y, to x, type, delay
			//screen 3
			fl.push([300, 94, 700, "line", 17]);//x, y, to x, type, delay
			fl.push([327, 172, 682, "point", 17.5]);//x, y, to x, type, delay
			fl.push([286, 473, 718, "line", 18]);//x, y, to x, type, delay
			fl.push([301, 515, 702, "point", 18.2]);//x, y, to x, type, delay			
			//hash tags
			fl.push([395, 180, 610, "line", 7.5]);//x, y, to x, type, delay
			fl.push([507, 180, 720, "line", 16]);//x, y, to x, type, delay
			
			return fl;
		}
		
		
		/**
		 * callback from setConfig()
		 * @param	e
		 */
		private function tagsLoaded(e:Event):void
		{
			localCache = dict.getTags(1);//this just so isready() will return true
			tag1.theText.text = dict.getHashTag(2);
			tag2.theText.text = dict.getHashTag(3);
			//trace("tagsLoaded", dict.getHashTag(2), dict.getHashTag(3));
			//show();//TESTING
		}
		
		
		/**
		 * ISchedulerMethods
		 * Returns true if localCache has data in it
		 * ie if the service has completed successfully at least once
		 * @return
		 */
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function show():void
		{
			theVideo.play();			
			currentLevel = 1;			
			nextLevel();			
		}
		
		
		private function nextLevel():void
		{
			flareDelay = getTimer();
			ra.create(tagContainer, new cloud(), dict.getTags(currentLevel), true, false, 8000, 0, new DropShadowFilter(8,45,0,1,12,12,2,2));
			ra.addEventListener(RectFinder.FINISHED, tagsComplete, false, 0, true);
		}
		
		
		/**
		 * called when the cloud has completed
		 * @param	e
		 */
		private function tagsComplete(e:Event):void
		{
			ra.removeEventListener(RectFinder.FINISHED, tagsComplete);
			
			var waitTime:int = 7000 - (getTimer() - flareDelay);
			var t:Timer;
			
			if (currentLevel < 3) {
				if (waitTime > 0) {
					t = new Timer(waitTime, 1);
					t.addEventListener(TimerEvent.TIMER, transitionLevel, false, 0, true);
					t.start();
				}else{
					transitionLevel();
				}
			}else {
				if (waitTime > 0) {
					t = new Timer(waitTime, 1);
					t.addEventListener(TimerEvent.TIMER, done, false, 0, true);
					t.start();
				}else{
					done();
				}
			}
		}
		
		
		private function done(e:TimerEvent = null):void
		{
			dispatchEvent(new Event(FINISHED));//will call cleanup
		}
		
		
		private function transitionLevel(e:TimerEvent = null):void
		{
			if (currentLevel == 1) {
				//about to show level 2
				tag1.x = 395;
				tag1.y = 126;
				addChildAt(tag1, numChildren - 2);//add behind text layer on stage
				TweenMax.to(tag1, .5, { y:180, ease:Back.easeOut } );
			}
			if (currentLevel == 2) {
				//about to show level 3
				tag2.x = 395;
				tag2.y = 180;
				addChildAt(tag2, numChildren - 2);//add behind first tag
				TweenMax.to(tag1, .5, { x:269, ease:Back.easeOut } );
				TweenMax.to(tag2, .5, { x:507, ease:Back.easeOut } );
			}
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
			currentLevel++;			
			nextLevel();
		}
		
		
		
		/**
		 * ISChedulerMethods
		 */
		public function cleanup():void
		{			
			theVideo.seek(0);
			theVideo.stop();
			if (contains(tag1)) {
				removeChild(tag1);
			}
			if (contains(tag2)) {
				removeChild(tag2);
			}
			while (tagContainer.numChildren) {
				tagContainer.removeChildAt(0);
			}
			dict.refreshTags(myColors, myDate);//calls tagsLoaded when ready
		}
		
		
		
	}
	
}