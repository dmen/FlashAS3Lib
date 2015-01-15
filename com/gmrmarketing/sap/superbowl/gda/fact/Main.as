package com.gmrmarketing.sap.superbowl.gda.fact
{
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.text.TextFormat;
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.Strings;
	
	
	public class Main extends MovieClip implements IModuleMethods
	{
		private const DISPLAY_TIME:Number = 12; //seconds this screen is shown for
		
		public static const FINISHED:String = "finished";//dispatched when the task is complete. Player will call cleanup() now
		
		private var localCache:Object;
		private var bgCircle:Sprite;
		private var colorCircle:Sprite;
		private var animValue:Object;
		private var animCharIndexes:Array;
		private var tf:TextFormat;
		private var displayAnother:Boolean = false;
		private var TESTING:Boolean = false;
		private var theStat:MovieClip;//lib clip
		
		public function Main()
		{
			tf = new TextFormat();
			animCharIndexes = new Array();
			bgCircle = new Sprite();
			colorCircle = new Sprite();
			theStat = new mcStat();
			if (TESTING) {
				init();
			}			
		}		
		
		
		/** 
		 * Called once by Player at initial load of all tasks
		 * receives any data from config file
		 */
		public function init(initValue:String = ""):void
		{
				if(!contains(theStat)){
				addChild(theStat);
			}
			theStat.x = 56;
			theStat.y = 244;
			
			if(!contains(bgCircle)){
				addChild(bgCircle);
			}
			bgCircle.x = 139;
			bgCircle.y = 274;
			bgCircle.cacheAsBitmap = true;
			
			if(!contains(colorCircle)){
				addChild(colorCircle);
			}
			colorCircle.x = 139;
			colorCircle.y = 274;
			colorCircle.cacheAsBitmap = true;
			
		
			
			if(TESTING){
				localCache = { Body:"The coldest Super Bowl game on record: Super Bowl VI - Tulane Stadium  - New Orleans, LA", Stat:"36°" };				
			}
			//anim elements off screen
			slider.y = 448;
			theTitle.x = 640;
			theText.x = 640;
			theStat.alpha = 0;
			
			refreshData();
		}
		
		
		private function refreshData():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetDidYouKnow?topic=superbowl");
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
			if (TESTING || displayAnother) {
				show();
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void	
		{
			if (TESTING || displayAnother) {
				show();
			}
		}
		
		
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		/**
		 * Called right before the task is placed on screen
		 */
		public function show():void
		{	
			colorCircle.alpha = 1;
			bgCircle.alpha = 1;
			
			//anim elements off screen
			slider.y = 448;
			theTitle.x = 640;
			theTitle.alpha = 1;
			theText.x = 640;
			theText.alpha = 1;
			theStat.alpha = 0;
			
			//clip on stage	
			theStat.theUnit.text = "";//millions etc. under the number
			
			animValue = { angle:0, dummy:0 };
			
			var val:String;
			var ind:int = String(localCache.Stat).indexOf(" ");
			
			if (ind != -1) {
				//number with text attached - like $4.5 million
				val = String(localCache.Stat).substring(0, ind);
				theStat.theUnit.text = String(localCache.Stat).substring(ind + 1);
			}else {
				val = String(localCache.Stat);
				theStat.theUnit.text = "";
			}
			if (val.indexOf("°") != -1) {
				theStat.theValue.x = 10; //compensate for degree sign
			}else {
				theStat.theValue.x = 5;//default
			}
			
			theStat.theValue.text = val; //val like $4.5, 109,385 etc - mark number positions
			//make sure text fits in circle nicely			
			
			var fSize:int = 50;
			tf.size = fSize;
			theStat.theValue.setTextFormat(tf);
			while(theStat.theValue.textWidth > 100){
				fSize--;
				tf.size = fSize;
				theStat.theValue.setTextFormat(tf);
			}
			theStat.theUnit.y = theStat.theValue.y + theStat.theValue.textHeight - 6;
			
			//center stat
			if (theStat.theUnit.text == "") {
				theStat.y = 212 + ((121 - theStat.theValue.textHeight) * .5);
			}else {
				theStat.y = 212 + ((121 - (fSize + 20)) * .5);
			}
			
			for (var i:int = 0; i < val.length; i++) {
				var n:int = val.charCodeAt(i);
				if (n >= 48 && n <= 57) {
					//number
					animCharIndexes[i] = 1;//mark this character for animation
				}else {
					animCharIndexes[i] = 0;//don't animate this char - it's not a number
				}
			}
			animValue.string = val;//original, unmodified stat
			
			theText.theText.text = localCache.Body;
			
			TweenMax.to(slider, .5, { y:94, ease:Linear.easeNone } );//pop the slider up from bottom - white bg
			TweenMax.to(theTitle, .75, { x:231, ease:Back.easeOut, delay:.5 } );
			TweenMax.to(theText, .75, { x:234, ease:Back.easeOut, delay:.6 } );
			
			Utility.drawArc(bgCircle.graphics, 0, 0, 70, 0, 360, 18, 0xefb21c, 1);//draw purple ring
			bgCircle.alpha = 0;
			TweenMax.to(bgCircle, 1, { alpha:1, delay:1 } );//fade purple ring in
			TweenMax.to(theStat, 1, { alpha:1, delay:1 } );//fade stat in
				
			//animate the arc and the numbers
			TweenMax.to(animValue, DISPLAY_TIME - 1, { angle:360, onUpdate:fillArc, delay:1, ease:Linear.easeNone, onComplete:nextFact } );
			TweenMax.to(animValue, 3, { dummy:100, onUpdate:animateText, onComplete:showActualText } );
			
			//call complete when finished
			//TweenMax.delayedCall(DISPLAY_TIME, complete);
		}
		
		private function nextFact():void
		{
			displayAnother = true;
			TweenMax.to(colorCircle, .5, { alpha:0 } );
			TweenMax.to(bgCircle, .5, { alpha:0 } );
			TweenMax.to(theTitle, .5, { alpha:0 } );
			TweenMax.to(theText, .5, { alpha:0 } );
			TweenMax.to(theStat, .5, { alpha:0, onComplete:removeSlider } );
		}
		
		private function fillArc():void
		{
			Utility.drawArc(colorCircle.graphics, 0, 0, 70, 0, animValue.angle, 18, 0x2a1c50, 1);
		}
		
		
		private function animateText():void
		{
			var modString:String = animValue.string;//unmodified
			var newString:String = "";
			for (var i:int = 0; i < modString.length; i++) {
				var n:int = 47 + Math.ceil(Math.random() * 10); //48 to 57
				if (animCharIndexes[i] == 1) {
					newString += String.fromCharCode(n);
				}else {
					newString += modString.charAt(i);
				}
			}
			theStat.theValue.text = newString;
			theStat.theValue.setTextFormat(tf);
		}
		
		
		private function showActualText():void
		{
			theStat.theValue.text = animValue.string;
			theStat.theValue.setTextFormat(tf);
		}
		
		
		private function complete():void
		{
			dispatchEvent(new Event(FINISHED));
		}
		
		
		public function cleanup():void
		{		
			displayAnother = false;
			TweenMax.killTweensOf(animValue);
			TweenMax.to(theTitle, .5, { alpha:0 } );
			TweenMax.to(theText, .5, { alpha:0 } );
			TweenMax.to(theStat, .5, { alpha:0, onComplete:removeSlider } );
		}
		
		
		private function removeSlider():void
		{
			TweenMax.to(slider, .5, { y:448, ease:Linear.easeNone, onComplete:kill } );//pop the slider up from bottom - white bg
		}
		
		
		private function kill():void
		{
			colorCircle.graphics.clear();
			bgCircle.graphics.clear();
			refreshData(); //preload next trivia	
		}
	}
	
}