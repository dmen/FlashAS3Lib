/**
 * Intro screen and leaderboard
 * 
 */

package com.gmrmarketing.bcbs.findyourbalance
{	
	import flash.display.*;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	
	
	public class GameIntro
	{
		private var clip:MovieClip;
		private var clip2:MovieClip;
		private var container:DisplayObjectContainer;
		private var leaders:Array;
		private var switchTimer:Timer;
		private var cloudTimer:Timer;
		private var speeds:Array;
		
		
		public function GameIntro()
		{
			clip = new mcIntro();//intro graphic with background and clouds
			clip2 = new mcLeaderboard();//transparent
			
			switchTimer = new Timer(10000, 1);
			
			cloudTimer = new Timer(20);
			cloudTimer.addEventListener(TimerEvent.TIMER, updateClouds, false, 0, true);
			
			speeds = new Array();
			var s:Number;
			for (var i:int = 0; i < 9; i++) {
				s = .4 + (Math.random() * .3);
				if (Math.random() < .5) {
					s *= -1;
				}
				speeds.push(s);
			}
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		/**
		 * leaders will contain 0 to 10 leaderboard entries
		 * from WebService.getLeaderboard()
		 * each entry is an array containing
		 * fname,lname,email,phone,state,entry,optin,moreInfo,q1a,q2a,event,score
		 * @param	$leaders Array with at max 10 entries
		 */
		public function show(leaders:Array):void
		{
			//populate leaderboard with names/scores
			var fn:String;
			var ln:String;
			for (var i:int = 0; i < leaders.length; i++) {
				fn = leaders[i][0];
				fn = fn.substr(0, 1).toUpperCase() + fn.substr(1);				
				ln = String(leaders[i][1]).substr(0, 1).toUpperCase();
				clip2["n" + i].text = fn + " " + ln + ".";
				clip2["s" + i].text = String(leaders[i][11]);				
			}
			
			clip.ic1.y = -50;
			clip.ic2.y = -50;
			clip.ic3.y = -50;
			clip.ic4.y = -50;
			clip.ic5.y = -50;
			clip.ic6.y = -50;
			clip.ic7.y = -50;
			clip.ic8.y = -50;
			clip.ic9.y = -50;
			clip.ic10.y = -50;
			
			clip.ic1.alpha = .4 * Math.random() * .5;
			clip.ic2.alpha = .4 * Math.random() * .5;
			clip.ic3.alpha = .4 * Math.random() * .5;
			clip.ic4.alpha = .4 * Math.random() * .5;
			clip.ic5.alpha = .4 * Math.random() * .5;
			clip.ic6.alpha = .4 * Math.random() * .5;
			clip.ic7.alpha = .4 * Math.random() * .5;
			clip.ic8.alpha = .4 * Math.random() * .5;
			clip.ic9.alpha = .4 * Math.random() * .5;
			clip.ic10.alpha = .4 * Math.random() * .5;
			
			clip.ic1.scaleX = clip.ic1.scaleY = .5 + Math.random() * .5;
			clip.ic2.scaleX = clip.ic2.scaleY = .5 + Math.random() * .5;
			clip.ic3.scaleX = clip.ic3.scaleY = .5 + Math.random() * .5;
			clip.ic4.scaleX = clip.ic4.scaleY = .5 + Math.random() * .5;
			clip.ic5.scaleX = clip.ic5.scaleY = .5 + Math.random() * .5;
			clip.ic6.scaleX = clip.ic6.scaleY = .5 + Math.random() * .5;
			clip.ic7.scaleX = clip.ic7.scaleY = .5 + Math.random() * .5;
			clip.ic8.scaleX = clip.ic8.scaleY = .5 + Math.random() * .5;
			clip.ic9.scaleX = clip.ic9.scaleY = .5 + Math.random() * .5;
			clip.ic10.scaleX = clip.ic10.scaleY = .5 + Math.random() * .5;
			
			
			container.addChild(clip);//add intro graphic
			cloudTimer.start();
			showLeaderboard();
		}
		
		
		private function showLeaderboard(e:TimerEvent = null):void
		{
			switchTimer.removeEventListener(TimerEvent.TIMER, showLeaderboard);
			
			if (container.contains(clip2)) {
				container.removeChild(clip2);
			}
			
			TweenMax.killTweensOf(clip.balance);
			clip.balance.visible = false;
			clip.theText.visible = false;
			
			container.addChild(clip2);
			clip2.alpha = 0;
			TweenMax.to(clip2, 1, { alpha:.9 } );			
			
			switchTimer.reset();
			switchTimer.addEventListener(TimerEvent.TIMER, showIntro, false, 0, true);
			switchTimer.start();
		}
		
		
		private function showIntro(e:TimerEvent = null):void
		{
			switchTimer.removeEventListener(TimerEvent.TIMER, showIntro);
			
			TweenMax.to(clip2, 1, { alpha:0 } );//fade out leaderboard
			clip.balance.visible = true;
			clip.theText.visible = true;
			clip.balance.alpha = 0;
			clip.theText.alpha = 0;
			TweenMax.to(clip.balance, .5, { alpha:1 } );
			TweenMax.to(clip.theText, .5, { alpha:1 } );
			
			animRight();
			
			switchTimer.reset();
			switchTimer.addEventListener(TimerEvent.TIMER, showLeaderboard, false, 0, true);
			switchTimer.start();
			
		}
		
		
		/**
		 * called by cloudTimer every 20ms
		 * @param	e
		 */
		private function updateClouds(e:TimerEvent):void
		{
			var n:int = 10;
			
			clip.ic1.y += speeds[0] * n;
			clip.ic2.y += speeds[1] * n;
			clip.ic3.y += speeds[2] * n;
			clip.ic4.y += speeds[3] * n;
			clip.ic5.y += speeds[4] * n;
			clip.ic6.y += speeds[5] * n;
			clip.ic7.y += speeds[6] * n;
			clip.ic8.y += speeds[7] * n;
			clip.ic9.y += speeds[8] * n;
			clip.ic10.y += speeds[0] * n;
			
			
			clip.c1.x += speeds[0];
			clip.c2.x += speeds[1];
			clip.c3.x += speeds[2];
			clip.c4.x += speeds[3];
			clip.c5.x += speeds[4];
			clip.c6.x += speeds[5];
			clip.c7.x += speeds[6];
			clip.c8.x += speeds[7];
			clip.c9.x += speeds[8];
			
			if (clip.c1.x < -70) {
				clip.c1.x = 1990;
			}
			if (clip.c2.x < -70) {
				clip.c2.x = 1990;
			}
			if (clip.c3.x < -70) {
				clip.c3.x = 1990;
			}
			if (clip.c4.x < -70) {
				clip.c4.x = 1990;
			}
			if (clip.c5.x < -70) {
				clip.c5.x = 1990;
			}
			if (clip.c6.x < -70) {
				clip.c6.x = 1990;
			}
			if (clip.c7.x < -70) {
				clip.c7.x = 1990;
			}
			if (clip.c8.x < -70) {
				clip.c8.x = 1990;
			}
			if (clip.c9.x < -70) {
				clip.c9.x = 1990;
			}
			
			
			if (clip.c1.x > 1990) {
				clip.c1.x = -70;
			}
			if (clip.c2.x > 1990) {
				clip.c2.x = -70;
			}
			if (clip.c3.x > 1990) {
				clip.c3.x = -70;
			}
			if (clip.c4.x > 1990) {
				clip.c4.x = -70;
			}
			if (clip.c5.x > 1990) {
				clip.c5.x = -70;
			}
			if (clip.c6.x > 1990) {
				clip.c6.x = -70;
			}
			if (clip.c7.x > 1990) {
				clip.c7.x = -70;
			}
			if (clip.c8.x > 1990) {
				clip.c8.x = -70;
			}
			if (clip.c9.x > 1990) {
				clip.c9.x = -70;
			}
			
			if (clip.ic1.y > 850) {
				clip.ic1.y = -50;
				clip.ic1.scaleX = clip.ic1.scaleY = .5 + Math.random() * .5;
				clip.ic1.x = 50 + Math.random() * 1820;
				clip.ic1.alpha = .2 + Math.random() * .4;
			}
			if (clip.ic2.y > 850) {
				clip.ic2.y = -50;
				clip.ic2.scaleX = clip.ic2.scaleY = .5 + Math.random() * .5;
				clip.ic2.x = 50 + Math.random() * 1820;
				clip.ic2.alpha = .2 + Math.random() * .4;
			}
			if (clip.ic3.y > 850) {
				clip.ic3.y = -50;
				clip.ic3.scaleX = clip.ic3.scaleY = .5 + Math.random() * .5;
				clip.ic3.x = 50 + Math.random() * 1820;
				clip.ic3.alpha = .2 + Math.random() * .4;
			}
			if (clip.ic4.y > 850) {
				clip.ic4.y = -50;
				clip.ic4.scaleX = clip.ic4.scaleY = .5 + Math.random() * .5;
				clip.ic4.x = 50 + Math.random() * 1820;
				clip.ic4.alpha = .2 + Math.random() * .4;
			}
			if (clip.ic5.y > 850) {
				clip.ic5.y = -50;
				clip.ic5.scaleX = clip.ic5.scaleY = .5 + Math.random() * .5;
				clip.ic5.x = 50 + Math.random() * 1820;
				clip.ic5.alpha = .2 + Math.random() * .4;
			}
			if (clip.ic6.y > 850) {
				clip.ic6.y = -50;
				clip.ic6.scaleX = clip.ic6.scaleY = .5 + Math.random() * .5;
				clip.ic6.x = 50 + Math.random() * 1820;
				clip.ic6.alpha = .2 + Math.random() * .4;
			}
			if (clip.ic7.y > 850) {
				clip.ic7.y = -50;
				clip.ic7.scaleX = clip.ic7.scaleY = .5 + Math.random() * .5;
				clip.ic7.x = 50 + Math.random() * 1820;
				clip.ic7.alpha = .2 + Math.random() * .4;
			}
			if (clip.ic8.y > 850) {
				clip.ic8.y = -50;
				clip.ic8.scaleX = clip.ic8.scaleY = .5 + Math.random() * .5;
				clip.ic8.x = 50 + Math.random() * 1820;
				clip.ic8.alpha = .2 + Math.random() * .4;
			}
			if (clip.ic9.y > 850) {
				clip.ic9.y = -50;
				clip.ic9.scaleX = clip.ic9.scaleY = .5 + Math.random() * .5;
				clip.ic9.x = 50 + Math.random() * 1820;
				clip.ic9.alpha = .2 + Math.random() * .4;
			}
			if (clip.ic10.y > 850) {
				clip.ic10.y = -50;
				clip.ic10.scaleX = clip.ic10.scaleY = .5 + Math.random() * .5;
				clip.ic10.x = 50 + Math.random() * 1820;
				clip.ic10.alpha = .2 + Math.random() * .4;
			}
		}
		
		private function animRight():void
		{
			TweenMax.to(clip.balance, 1, { rotation:Math.random() * 8, onComplete:animLeft } );
		}
		
		
		private function animLeft():void
		{
			TweenMax.to(clip.balance, 1, { rotation:-(Math.random() * 8), onComplete:animRight } );
		}
		
		
		public function hide():void
		{
			switchTimer.reset();
			cloudTimer.reset();
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			if (container.contains(clip2)) {
				container.removeChild(clip2);
			}
		}
		
	}
	
}