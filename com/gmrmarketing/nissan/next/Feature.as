/**
 * Displays a swf from the assets folder
 * Instantiated by ModelDetail.as
 */
package com.gmrmarketing.nissan.next
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.net.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.gmrmarketing.nissan.next.StaticData;
	
	
	public class Feature extends EventDispatcher
	{
		public static const FEATURES_READY:String = "features_ready";
		
		private var container:DisplayObjectContainer;
		private var loader:Loader;
		private var bg:MovieClip;		
		private var timeoutHelper:TimeoutHelper;
		
		
		public function Feature()
		{
			loader = new Loader();			
			bg = new modalBG(); //lib clip
			timeoutHelper = TimeoutHelper.getInstance();
		}
		
		
		public function show($container:DisplayObjectContainer, whichSWF:String):void
		{
			timeoutHelper.buttonClicked();
			container = $container;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, featureLoaded, false, 0, true);
			loader.load(new URLRequest(StaticData.getAssetPath() + whichSWF));
		}
		
		
		private function featureLoaded(e:Event):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, featureLoaded);
			
			container.addChild(bg);
			bg.alpha = 0;			
			TweenMax.to(bg, .5, { alpha:.85 } );
			
			loader.alpha = 1;
			container.addChild(loader);
			loader.x = 283;
			loader.y = 767;
			
			TweenMax.to(loader, 1, { y:0, ease:Back.easeOut } );
			
			dispatchEvent(new Event(FEATURES_READY));
		}
		
		
		public function hide():void
		{
			timeoutHelper.buttonClicked();
			TweenMax.killTweensOf(bg);
			TweenMax.killTweensOf(loader);
			TweenMax.to(bg, .5, { alpha:0 } );
			TweenMax.to(loader, 1, { y:767, ease:Back.easeIn, onComplete:kill } );
		}
		
		
		
		private function kill():void
		{
			if(container){
				if (container.contains(bg)) {
					container.removeChild(bg);
				}
				if(container.contains(loader)){
					container.removeChild(loader);
				}
			}
			loader.unload();
		}
	}
	
}