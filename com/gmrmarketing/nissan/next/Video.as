/**
 * Player for videos in the Model detail section
 * Instantiated by ModelDetail.as and Innovations.as
 */

package com.gmrmarketing.nissan.next
{
	import com.gmrmarketing.website.VPlayer;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.utils.Timer;
	import com.gmrmarketing.nissan.next.StaticData;
	
	public class Video extends EventDispatcher
	{
		public static const VIDEO_STOPPED:String = "videoStopped";
		
		private var container:DisplayObjectContainer;
		private var vid:VPlayer;
		private var bg:MovieClip;	
		
		private var timeoutHelper:TimeoutHelper;
		private var timeoutTimer:Timer;
		
		
		
		public function Video()
		{			
			bg = new modalBG(); //lib clip
		}
		
		
		public function show($container:DisplayObjectContainer, fName:String):void
		{			
			container = $container;
			
			container.addChild(bg);
			bg.alpha = 0;			
			TweenMax.to(bg, .5, { alpha:.85 } );
			
			timeoutHelper = TimeoutHelper.getInstance();
			
			timeoutTimer = new Timer(30000);
			timeoutTimer.addEventListener(TimerEvent.TIMER, sendTimeOutReset, false, 0, true);
			timeoutTimer.start();
			
			vid = new VPlayer();			
			vid.showVideo(container);
			
			vid.simpleShow();
			vid.addEventListener(VPlayer.STATUS_RECEIVED, checkStatus, false, 0, true);
			vid.addEventListener(VPlayer.META_RECEIVED, doCenter, false, 0, true);
			
			vid.playVideo(StaticData.getAssetPath() + fName);			
		}
		
		/**
		 * Called every 30 seconds when a video is playing
		 * @param	e
		 */
		private function sendTimeOutReset(e:TimerEvent):void
		{
			timeoutHelper.buttonClicked();
		}
		
		
		private function doCenter(e:Event):void
		{
			vid.removeEventListener(VPlayer.META_RECEIVED, doCenter);
			vid.centerVideo(1366, 675);			
		}
		
		
		public function hide():void
		{
			timeoutTimer.reset();
			timeoutTimer.removeEventListener(TimerEvent.TIMER, sendTimeOutReset);
			
			vid.stopVideo();
			vid.simpleHide();
			
			TweenMax.killTweensOf(bg);
			TweenMax.to(bg, .5, { alpha:0, onComplete:kill } );			
		}
		
		
		private function kill():void
		{
			vid.removeEventListener(VPlayer.STATUS_RECEIVED, checkStatus);
			vid.removeEventListener(VPlayer.META_RECEIVED, doCenter);
			if(container.contains(bg)){
				container.removeChild(bg);	
			}
		}
		
		
		private function checkStatus(e:Event):void
		{			
			if(vid.getStatus() == "NetStream.Play.Stop")
			{				
				dispatchEvent(new Event(VIDEO_STOPPED));
			}
		}
		
	}
	
}