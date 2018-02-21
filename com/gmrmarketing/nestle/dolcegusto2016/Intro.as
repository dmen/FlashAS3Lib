package com.gmrmarketing.nestle.dolcegusto2016
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Intro extends EventDispatcher
	{
		public static const COMPLETE:String = "introComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var videoPlayer:MovieClip;
		
		
		public function Intro()
		{
			clip = new mcIntro();
			videoPlayer = new mcVideoPlayer();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(isPhotoBooth:Boolean):void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			if (isPhotoBooth){
				clip.titleGroup.theTitle.text = "CREATE YOUR CUSTOM COFFEE SCENE";
				clip.titleGroup.subTitle.text = "Take a selfie & earn special offers";
			}else{
				//cafe only
				clip.titleGroup.theTitle.text = "WHAT'S YOUR RELATIONSHIP WITH COFFEE?";
				clip.titleGroup.subTitle.text = "Take the quiz to get special offers";
			}
			
			clip.alpha = 1;
			clip.btnStart.arrow.x = 0;
			clip.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, startClicked, false, 0, true);
			clip.btnVideoA.addEventListener(MouseEvent.MOUSE_DOWN, playVideoA, false, 0, true);
			clip.btnVideoB.addEventListener(MouseEvent.MOUSE_DOWN, playVideoB, false, 0, true);
			clip.btnVideoC.addEventListener(MouseEvent.MOUSE_DOWN, playVideoC, false, 0, true);
			clip.btnVideoD.addEventListener(MouseEvent.MOUSE_DOWN, playVideoD, false, 0, true);
			
			animateArrow();
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip, .5, {alpha:0, onComplete:killClip});
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, startClicked);
			clip.btnVideoA.removeEventListener(MouseEvent.MOUSE_DOWN, playVideoA);
			clip.btnVideoB.removeEventListener(MouseEvent.MOUSE_DOWN, playVideoB);
			clip.btnVideoC.removeEventListener(MouseEvent.MOUSE_DOWN, playVideoC);
			clip.btnVideoD.removeEventListener(MouseEvent.MOUSE_DOWN, playVideoD);
			
			TweenMax.killDelayedCallsTo(animateArrow);
			TweenMax.killTweensOf(clip.btnStart.arrow);
		}
		
		
		private function killClip():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
		}
		
		
		private function startClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(COMPLETE));		
		}
		
		
		private function playVideoA(e:MouseEvent):void
		{
			playVideo("assets/samp.mp4");
		}
		private function playVideoB(e:MouseEvent):void
		{
			playVideo("assets/samp.mp4");
		}
		private function playVideoC(e:MouseEvent):void
		{
			playVideo("assets/samp.mp4");
		}
		private function playVideoD(e:MouseEvent):void
		{
			playVideo("assets/samp.mp4");
		}
		
		private function playVideo(source:String):void
		{
			if (!myContainer.contains(videoPlayer)){
				myContainer.addChild(videoPlayer);
			}
			videoPlayer.alpha = 1;
			videoPlayer.player.source = source;
			videoPlayer.player.seek(0);
			videoPlayer.player.play();
			
			videoPlayer.blackOut.alpha = 0;
			TweenMax.to(videoPlayer.blackOut, 1, {alpha:.82});
			
			videoPlayer.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeVideoPlayer, false, 0, true);
		}
		
		
		/**
		 * called at end os show()
		 */
		private function animateArrow():void
		{
			clip.btnStart.arrow.x = -80;
			TweenMax.to(clip.btnStart.arrow, .75, {x:0, ease:Elastic.easeOut, onComplete:arrowWait});
		}
		private function arrowWait():void
		{
			TweenMax.delayedCall(2, animateArrow);
		}
		
		
		
		private function closeVideoPlayer(e:MouseEvent):void
		{
			videoPlayer.player.stop();
			videoPlayer.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeVideoPlayer);
			
			TweenMax.to(videoPlayer, .5, {alpha:0, onComplete:killVideoPlayer});			
		}
		
		private function killVideoPlayer():void
		{
			if (myContainer.contains(videoPlayer)){
				myContainer.removeChild(videoPlayer);
			}
		}
	}
	
}