package com.gmrmarketing.sap.superbowl.gda.teamvteam
{
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.loading.*;
	import com.greensock.loading.display.*;
	import com.greensock.*;
	import com.greensock.events.LoaderEvent;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Main extends MovieClip implements IModuleMethods
	{
		private var localCache:Object;
		private var video:VideoLoader;
		private var tvtCircle:Sprite;//gray circle in the title
		private var TESTING:Boolean = true;
		private var animValue:Object;
		
		private var videos:Array;
		private var vidIndex:int;
		
		public function Main()
		{
			tvtCircle = new Sprite();
			
			videos = new Array("test.mp4");
			vidIndex = 0;
			
			if(TESTING){
				init();
			}
		}
		
		
		/**
		 * Only called once
		 * @param	initValue
		 */
		public function init(initValue:String = ""):void
		{
			if(!contains(tvtCircle)){
				addChild(tvtCircle);
			}
			tvtCircle.x = 320;
			tvtCircle.y = 166;
			
			tvt.alpha = 0;//team vs team text inside circle
			
			lWing.x = 265;//hide wings in masks
			rWing.x = 175;
			
			team1.alpha = 0;//logos
			team2.alpha = 0;
			team1.scaleX = team1.scaleY = 2;
			team2.scaleX = team2.scaleY = 2;
			
			t1s1.alpha = 0;
			t1s2.alpha = 0;
			t1s3.alpha = 0;
			t1s4.alpha = 0;
			t1s5.alpha = 0;
			t1s1.wing.x = 182;
			t1s2.wing.x = 182;
			t1s3.wing.x = 182;
			t1s4.wing.x = 182;
			t1s5.wing.x = 182;
			
			t2s1.alpha = 0;
			t2s2.alpha = 0;
			t2s3.alpha = 0;
			t2s4.alpha = 0;
			t2s5.alpha = 0;
			t2s1.wing.x = -111;
			t2s2.wing.x = -111;
			t2s3.wing.x = -111;
			t2s4.wing.x = -111;
			t2s5.wing.x = -111;
			
			sent.y = 427;
			sent.lWing.x = 8;
			sent.rWing.x = 110;
			
			theFact.alpha = 0;
			
			vidBar.alpha = 0;
			week15.y = 740;			
			
			refreshData();
		}
		
		
		private function refreshData():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetDidYouKnow?topic=superbowl" + "&abc=" + String(new Date().valueOf()));
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		//callback from refreshData()
		private function dataLoaded(e:Event):void
		{
			localCache = JSON.parse(e.currentTarget.data);
			incVideo();
			if (TESTING) {
				show();
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void	
		{
			incVideo();
			if (TESTING) {
				show();
			}
		}
		
		private function incVideo():void
		{
			video = new VideoLoader(videos[vidIndex], { width:432, height:244, x:104, y:510, autoPlay:false, container:this } );
			video.load();
			video.content.alpha = 0;
			vidIndex++;
			if (vidIndex >= videos.length) {
				vidIndex = 0;
			}
		}
		
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		public function show():void
		{
			tvt.alpha = 0;//team vs team text inside circle
			
			lWing.x = 265;//hide wings in masks
			rWing.x = 175;
			
			team1.alpha = 0;//logos
			team2.alpha = 0;
			team1.scaleX = team1.scaleY = 2;
			team2.scaleX = team2.scaleY = 2;
			
			t1s1.alpha = 0;
			t1s2.alpha = 0;
			t1s3.alpha = 0;
			t1s4.alpha = 0;
			t1s5.alpha = 0;
			t1s1.wing.x = 182;
			t1s2.wing.x = 182;
			t1s3.wing.x = 182;
			t1s4.wing.x = 182;
			t1s5.wing.x = 182;
			
			t2s1.alpha = 0;
			t2s2.alpha = 0;
			t2s3.alpha = 0;
			t2s4.alpha = 0;
			t2s5.alpha = 0;
			t2s1.wing.x = -111;
			t2s2.wing.x = -111;
			t2s3.wing.x = -111;
			t2s4.wing.x = -111;
			t2s5.wing.x = -111;
			
			sent.y = 427;
			sent.lWing.x = 8;
			sent.rWing.x = 110;
			
			theFact.alpha = 0;
			
			vidBar.alpha = 0;
			week15.y = 740;
			
			animValue = { angle:0 };			
			
			TweenMax.to(tvt, .75, { alpha:1, delay:.5 } );			
			TweenMax.to(animValue, .5, { angle:360, onUpdate:fillArc, onComplete:showWings, ease:Linear.easeNone } );			
		}
		
		
		private function fillArc():void
		{
			Utility.drawArc(tvtCircle.graphics, 0, 0, 60, 0, animValue.angle, 18, 0xcccccc, 1);
		}
		
		
		private function showWings():void
		{
			TweenMax.to(lWing, .75, { x:59 } );
			TweenMax.to(rWing, .75, { x:379 } );
			
			TweenMax.to(team1, 1, { scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut, delay:.5 } );
			TweenMax.to(team2, 1, { scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut, delay:.5 } );
			
			TweenMax.to(t1s1, .25, { alpha:1, delay:1 } );			
			TweenMax.to(t1s2, .25, { alpha:1, delay:1.1 } );
			TweenMax.to(t1s3, .25, { alpha:1, delay:1.2 } );
			TweenMax.to(t1s4, .25, { alpha:1, delay:1.3 } );
			TweenMax.to(t1s5, .25, { alpha:1, delay:1.4 } );
			TweenMax.to(t1s1.wing, .5, { x:0, delay:1 } );
			TweenMax.to(t1s2.wing, .5, { x:0, delay:1.1 } );
			TweenMax.to(t1s3.wing, .5, { x:0, delay:1.2 } );
			TweenMax.to(t1s4.wing, .5, { x:0, delay:1.3 } );
			TweenMax.to(t1s5.wing, .5, { x:0, delay:1.4 } );
			
			TweenMax.to(t2s1, .25, { alpha:1, delay:1 } );			
			TweenMax.to(t2s2, .25, { alpha:1, delay:1.1 } );
			TweenMax.to(t2s3, .25, { alpha:1, delay:1.2 } );
			TweenMax.to(t2s4, .25, { alpha:1, delay:1.3 } );
			TweenMax.to(t2s5, .25, { alpha:1, delay:1.4 } );
			TweenMax.to(t2s1.wing, .5, { x:72, delay:1 } );
			TweenMax.to(t2s2.wing, .5, { x:72, delay:1.1 } );
			TweenMax.to(t2s3.wing, .5, { x:72, delay:1.2 } );
			TweenMax.to(t2s4.wing, .5, { x:72, delay:1.3 } );
			TweenMax.to(t2s5.wing, .5, { x:72, delay:1.4 } );
			
			TweenMax.to(sent, .5, { y:467, delay:1.5, ease:Back.easeOut, onComplete:showFact } );
			TweenMax.to(sent.lWing, .5, { x:-62, delay:1.75 } );
			TweenMax.to(sent.rWing, .5, { x:190, delay:1.75 } );
		}
		
		
		private function showFact():void
		{
			TweenMax.to(theFact, .5, { alpha:1 } );
			TweenMax.to(theFact, 1, { alpha:0, delay:3, onComplete:playVid } );
		}
		
		
		/**
		 * callback from TweenMax in showFact()
		 */
		private function playVid():void
		{
			video.playVideo();
			TweenMax.to(video.content, .5, { alpha:1 } );
			TweenMax.to(vidBar, .5, { alpha:1 } );
			TweenMax.to(week15, .5, { y:780, delay:.25, ease:Back.easeOut } );
		}
		
		public function cleanup():void
		{
			video.dispose(true);
			tvtCircle.graphics.clear();
			refreshData();
		}
		
	}
	
}