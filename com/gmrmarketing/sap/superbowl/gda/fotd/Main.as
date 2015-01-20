package com.gmrmarketing.sap.superbowl.gda.fotd
{	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Main extends MovieClip implements IModuleMethods
	{
		public static const FINISHED:String = "finished";
		private var localCache:Object;
		private var TESTING:Boolean = true;
		
		private var animOb:Object;
		private var leftArc:Array;//circle clips on each arc
		private var rightArc:Array;
		
		private var players:Array; //players with stats
		private var circObject:Object;
		
		
		public function Main()
		{	
			//hides the two arcs
			arcL.rotation = 320;//to 180
			arcR.rotation = -140;//to 0
			arcL.visible = false;
			arcR.visible = false;
			
			//put 5 clips into each array then just modify pics and text in them as needed
			//clips in each arc arc copies of each other - only 5 users taken at a time
			leftArc = [];//put 5 on each arc - only show 2 on left arc at once
			rightArc = [];//only show 3 on right arc
			for (var i:int = 0; i < 5; i++){
				leftArc.push(new UserArc());
				rightArc.push(new UserArc());
			}
			
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
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetCachedFeed?feed=FeaturedFans");
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
			var i:int;
			
			if (e) {
				//array of objects with authorname,text,mediumresURL
				localCache = JSON.parse(e.currentTarget.data);
				
				//populate player arc arrays
				var n:int = Math.min(5, localCache.length);
				for (i = 0; i < n; i++) {
					
					leftArc[i].clip.nameRight.text = localCache[i].authorname;
					leftArc[i].clip.message.text = localCache[i].text;
					leftArc[i].container = this;
					leftArc[i].hideStats();
					
					rightArc[i].clip.nameRight.text = localCache[i].authorname;
					rightArc[i].clip.message.text = localCache[i].text;
					rightArc[i].container = this;
					rightArc[i].hideStats();
				}
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
			arcL.rotation = 320;//to 180
			arcR.rotation = -140;//to 0
			arcL.visible = true;
			arcR.visible = true;			
			
			for (var i:int = 0; i < 5; i++) {
				leftArc[i].clip.scaleX = leftArc[i].clip.scaleY = .5;				
				rightArc[i].clip.scaleX = rightArc[i].clip.scaleY = .5;
			}
			
			TweenMax.to(arcL, .5, { rotation:180, ease:Linear.easeNone } );
			TweenMax.to(arcR, .5, { rotation:0, delay:.2, ease:Linear.easeNone, onComplete:animTest} );
		}
		
		
		private function animTest():void
		{
			for (var i:int = 0; i < 4; i++) {
				leftArc[i].show();
				leftArc[i].clip.x = -100;//off stage left
				
				rightArc[i].show();
				rightArc[i].clip.x = 800;//off stage right
			}			
				
			animOb = { angL: -100, angR: -100 };			
			
			//TweenMax.to(animOb, 1, { angL:36, angR:36, onUpdate:cur, onComplete:openTest } );
			TweenMax.to(animOb, 1, { angL:36, angR:36, onUpdate:cur, onComplete:showNextPlayer } );
		}
		
		
		private function cur():void
		{
			for (var i:int = 0; i < 5; i++) {
				//animate in reverse (3-i) so #1 is last - ie at the top of the arc
				leftArc[i].clip.x = arcL.x + Math.cos((animOb.angL - (26 * i)) / 57.296) * 233;
				leftArc[i].clip.y = arcL.y + Math.sin((animOb.angL - (26 * i)) / 57.296) * 233;
				
				rightArc[i].clip.x = arcR.x - Math.cos((animOb.angR - (26 * i)) / 57.296) * 233;
				rightArc[i].clip.y = arcR.y - Math.sin((animOb.angR - (26 * i)) / 57.296) * 233;
			}
		}
		/*
		private function openTest():void
		{
			for (var i:int = 0; i < 4; i++) {
				TweenMax.delayedCall(i * .1, leftArc[i].showNameNumber);
				TweenMax.delayedCall(i * .2, rightArc[i].showNameNumber);
			}
			playersIndex = 0;
			
			showNextPlayer();
		}
	*/
		
		/**
		 * Called by Tweenmax once players are animated onto the arcs
		 * shows player stats at top
		 * First, highlight the player below being shown above
		 */
		private function showNextPlayer():void
		{			
			/*
			if(playersIndex < 8){
				if (playersIndex < 4) {
					leftArc[playersIndex].showNameNumber();
					TweenMax.to(leftArc[playersIndex].clip, .5, { alpha:1, onComplete:showNextPlayerStats } );
				}else {				
					rightArc[playersIndex - 4].showNameNumber();
					TweenMax.to(rightArc[playersIndex - 4].clip, .5, { alpha:1, onComplete:showNextPlayerStats } );
				}
			}else {
				dispatchEvent(new Event(FINISHED));//player will call cleanup()
			}
			*/
		}
		
		
		private function showNextPlayerStats():void
		{
			/*
			//move player off position so it can move while fading in
			if (playersIndex < 4) {
				//coming from left arc
				players[playersIndex].clip.x = 50;
			}else {
				//coming from right arc
				players[playersIndex].clip.x = 320;
			}
			players[playersIndex].show();
			players[playersIndex].clip.y = 280;
			players[playersIndex].clip.alpha = 0;
			
			TweenMax.to(players[playersIndex].clip, .5, { alpha:1, x:185, onComplete:showThePlayerStats } );
			*/
		}
		
		
		private function showThePlayerStats():void
		{			
			
			circObject = { ang:0 };
			TweenMax.to(circObject, 8, { ang:360, onUpdate:drawCircles, onComplete:showStatsComplete } );
		}
		
		
		//called by TweenMax.onUpdate from showPlayerStats()
		private function drawCircles():void
		{/*
			Utility.drawArc(players[playersIndex].circ, 0, 0, 72, 0, circObject.ang, 17, 0xedb01a);
			if (playersIndex < 4){
				Utility.drawArc(leftArc[playersIndex].circ, 0, 0, 72, 0, circObject.ang, 17, 0xedb01a);
			}else {
				Utility.drawArc(rightArc[playersIndex - 4].circ, 0, 0, 72, 0, circObject.ang, 17, 0xedb01a);
			}*/
		}
		
		private function showStatsComplete():void
		{	/*		
			players[playersIndex].hide();
			showNextPlayer();*/
		}
		
		
		public function cleanup():void
		{
			//hides the two arcs
			arcL.rotation = 320;//to 180
			arcR.rotation = -140;//to 0
			arcL.visible = false;
			arcR.visible = false;
			
			//remove players from arc lines
			for (var i:int = 0; i < 5; i++) {
				leftArc[i].hide();
				rightArc[i].hide();
			}			
			refreshData();
		}
		
		
	}
	
}