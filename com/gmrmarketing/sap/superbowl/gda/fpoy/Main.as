package com.gmrmarketing.sap.superbowl.gda.fpoy
{
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import flash.display.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.events.*;
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.sap.superbowl.gda.fpoy.PlayerR;
	
	
	public class Main extends MovieClip implements IModuleMethods
	{
		private var localCache:Object;
		private var TESTING:Boolean = true;
		
		private var animOb:Object;
		private var test:PlayerR;
		
		public function Main()
		{			
			test = new PlayerR("beckham");
			test.container = this;
			test.hideStats();
			test.show();
			
			if (TESTING) {
				init();
			}
		}
		
		
		public function init(initValue:String = ""):void
		{
			refreshData();
		}
		
		
		private function refreshData():void
		{			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/getplayersentiment");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		
		private function dataLoaded(e:Event):void
		{
			if(e){
				localCache = JSON.parse(e.currentTarget.data);
			}
			if (TESTING) {
				show();
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			
		}
		
		
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		public function show():void
		{			
			arcL.rotation = -140;//to 0
			arcR.rotation = 40;//to 180
			
			test.clip.scaleX = test.clip.scaleY = .5;//smaller for moving on arc
			
			TweenMax.to(arcL, 2, { rotation:0, ease:Linear.easeNone } );
			TweenMax.to(arcR, 2, { rotation:180, delay:.5, ease:Linear.easeNone, onComplete:animTest} );
		}
		
		
		private function animTest():void
		{
			animOb = { ang:-100 };
			TweenMax.to(animOb, 3, { ang:36, onUpdate:cur, onComplete:openTest } );
		}
		
		
		private function cur():void
		{
			test.clip.x = arcL.x + Math.cos(animOb.ang / 57.296) * 236;
			test.clip.y = arcL.y + Math.sin(animOb.ang / 57.296) * 236;
		}
		
		private function openTest():void
		{
			test.showNameNumber();
		}
		
		
		public function cleanup():void
		{
			
		}
		
		
	}
	
}