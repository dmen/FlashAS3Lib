package com.gmrmarketing.sap.nhl2015.gda.didyouknow
{
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.Strings;
	import flash.text.TextFormat;
	
	public class Main extends MovieClip implements IModuleMethods
	{
		public static const FINISHED:String = "finished";
		
		private var degToRad:Number = 0.0174532925; //PI / 180
		private var dyk:MovieClip;
		private var tweenOb:Object;
		private var animRing:Sprite;
		private var tMask:MovieClip;
		private var localCache:Object;//last fact loaded
		private const TESTING:Boolean = false;
		
		
		public function Main()
		{
			dyk = new mcRing();//lib clip
			
			animRing = new Sprite();
			tMask = new textMask();//lib clip
			tMask.x = -211;
			tMask.y = -706;
			//tMask.alpha = 0;
			dyk.addChild(tMask);
			dyk.addChild(animRing);
			
			dyk.textGroup.cacheAsBitmap = true;
			tMask.cacheAsBitmap = true;
			
			dyk.textGroup.mask = tMask;
			
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
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/NHL/GetDidYouKnow?topic=NHL");
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
			localCache = JSON.parse(e.currentTarget.data);
			if (TESTING) {
				show();
			}
		}
		
		
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		private function dataError(e:IOErrorEvent):void{}
		
		
		
		public function show():void
		{
			if (!contains(dyk)) {
				addChild(dyk);
			}
			
			dyk.textGroup.theTitle.text = localCache.Subhead.replace(/\\n/g, '\n');
			dyk.textGroup.theTitle.autoSize = TextFieldAutoSize.CENTER;
			dyk.textGroup.theText.text = localCache.Body.replace(/\\n/g, '\n');
			
			var titleSize:Object = Utility.getTextBounds(dyk.textGroup.theTitle);
			var bodySize:Object = Utility.getTextBounds(dyk.textGroup.theText);
			
			var fSize:int = 22;//default font size
			var tf:TextFormat = new TextFormat();

			while(titleSize.height > 170){
				fSize--;
				tf.size = fSize;
				dyk.textGroup.theTitle.setTextFormat(tf);
				titleSize = Utility.getTextBounds(dyk.textGroup.theTitle);
			}
			
			dyk.textGroup.theText.y = dyk.textGroup.theTitle.y + titleSize.height + 26;
			dyk.scaleX = dyk.scaleY = 0;
			dyk.x = 400;
			dyk.y = 254;
			
			tweenOb = { ang:0 };
			
			TweenMax.to(dyk, 1, { scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:showText } );
		}
		
		
		private function showText():void
		{
			TweenMax.to(tMask, 10, { y: -249 } );//reveal the text
			
			var dTime:Number = Math.max(10, Strings.numWords(dyk.textGroup.theTitle.text) * .5);			
			
			TweenMax.to(tweenOb, dTime, { ang:360, ease:Linear.easeNone, onUpdate:drawcircleTween, onComplete:done } );
		}
		
		
		private function drawcircleTween():void
		{
			Utility.drawArc(animRing.graphics, 0, 0, 213, 0, tweenOb.ang, 10, 0xedb01a, 1);
		}
		
		private function done():void
		{
			dispatchEvent(new Event(FINISHED));//will call cleanup
		}
		
	
		public function cleanup():void
		{
			tMask.y = -706;
			dyk.textGroup.theTitle.text = "";
			dyk.textGroup.theText.text = "";
			animRing.graphics.clear();
			dyk.scaleX = dyk.scaleY = 0;
			refreshData();
		}
		
	}
	
}