/**
 * Loads and controls the three tickers
 * Branding, Twitter and Events
 */
package com.gmrmarketing.sap.metlife.giants.tickers
{
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.AIRXML;
	import flash.desktop.NativeApplication;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	
	public class Main extends MovieClip
	{		
		private var sapTicker:MovieClip;//'branding ticker (video) at the top - 1008x160
		private var twitterTicker:MovieClip;//ticker under the main content area - 1008x47
		private var eventsTicker:MovieClip;//bottom ticker - 1008x306
		private var configLoader:URLLoader;
		private var eventsDate:String;
		
		public function Main()
		{
			stage.displayState = StageDisplayState.NORMAL;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			Mouse.hide();	
			addEventListener(Event.ACTIVATE, initWindowPosition);			
			
			var req:URLRequest = new URLRequest("http://design.gmrstage.com/sap/metlife/giants/gda/config.xml");
			configLoader = new URLLoader();
			configLoader.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			configLoader.addEventListener(IOErrorEvent.IO_ERROR, configError, false, 0, true);			
			configLoader.load(req);
		}
		
		private function initWindowPosition(e:Event):void
		{
			NativeApplication.nativeApplication.activeWindow.x = 0;
			NativeApplication.nativeApplication.activeWindow.y = 0;
		}
		
		private function configLoaded(e:Event):void
		{			
			configLoader.removeEventListener(Event.COMPLETE, configLoaded);
			var xm:XML = XML(configLoader.data);			
			eventsDate = xm.eventsDate;
			
			//load top ticker
			var r:URLRequest = new URLRequest("giants.swf");
			var l:Loader = new Loader();		
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, brandingTickerLoaded, false, 0, true);
			l.load(r);
		}
		
		private function configError(e:IOErrorEvent = null):void
		{
			
		}
		
		private function brandingTickerLoaded(e:Event):void
		{
			var l:Loader = Loader(LoaderInfo(e.target).loader);
			sapTicker = MovieClip(l.content);
			addChild(sapTicker);
			
			//load twitter ticker
			var r:URLRequest = new URLRequest("twitterTicker.swf");
			l = new Loader();		
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, twitterTickerLoaded, false, 0, true);
			l.load(r);
		}
		
		
		private function twitterTickerLoaded(e:Event):void
		{
			var l:Loader = Loader(LoaderInfo(e.target).loader);
			twitterTicker = MovieClip(l.content);
			twitterTicker.y = 727;
			addChild(twitterTicker);
			
			//load events ticker
			var r:URLRequest = new URLRequest("eventsTicker.swf");
			l = new Loader();		
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, eventsTickerLoaded, false, 0, true);
			l.load(r);
		}
		
		
		private function eventsTickerLoaded(e:Event):void
		{
			var l:Loader = Loader(LoaderInfo(e.target).loader);
			eventsTicker = MovieClip(l.content);
			eventsTicker.y = 774;
			eventsTicker.getData(eventsDate);
			addChild(eventsTicker);
		}		
		
	}
	
}