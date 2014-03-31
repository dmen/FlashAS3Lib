package com.gmrmarketing.comcast.university.ipad2013
{
	import flash.display.*;	
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	import flash.utils.Timer;
	import flash.media.*;
	
	
	public class PopUp extends EventDispatcher
	{
		public static const POPUP_COMPLETE:String = "popupComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var messages:Object;
		private var tempTimer:Timer;
		private var shown:Array;
		private var isShowingFlag:Boolean;
		
		private var vo:Sound;
		private var channel:SoundChannel;
		
		
		public function PopUp()
		{
			clip = new mcPopUp();
			shown = new Array();
			isShowingFlag = false;
			
			//message keys match icon names in Scratch.as
			messages = new Object();						
			messages.espn = "WATCH ESPN\nXFINITY® is Your Home for the Most Live Sports. Watch your favorite ESPN networks LIVE on your Apple® or Android™ tablet or smartphone — included with your XFINITY TV service at no extra cost.";
			messages.hbo = "HBO®\nSee the shows that everybody's talking about - Game of Thrones®, True Blood®, GIRLS® and more - with HBO® included with your XFINITY® TV subscription.";
			messages.internet = "XFINITY® Internet\nXFINITY® delivers the fastest in-home\nWi-Fi, so you and your roommates get the speed you need to surf, stream and download on multiple devices simultaneously.";			
			messages.showtime = "Showtime®\nWatch Dexter®, Homeland®, Shameless® and other original series, comedy and sports on Showtime, included with your XFINITY® TV subscription.";
			messages.xfinity = "XFINITY™ TV Player App\nWatch thousands of your favorite XFINITY On Demand™ TV shows and movies on your Apple® or Android® device. Plus, you can download your favorites from Showtime, Starz, Encore and Movieplex on your mobile device and watch them offline.";
			messages.tv = "Xfinity.com/TV\nGet streaming access to thousands of hot movies and entire seasons of top TV shows at Xfinity.com/TV, included at no extra cost.";
			messages.xod = "XFINITY On Demand™\nGet access to the best selection of current TV shows and hit movies, anytime, on any screen with XFINITY On Demand™, included with your subscription.";			
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		public function reset():void
		{
			shown = new Array();
		}
		
		public function show(which:String):void
		{
			//only add unique items
			if (shown.indexOf(which) == -1) {
				shown.push(which);
				
				if (!container.contains(clip)) {
					container.addChild(clip);
					clip.balloon.y = 150;
					clip.bg.alpha = .8;
				}				
				clip.balloon.theText.text = messages[which];
				TweenMax.from(clip.balloon, 1, { y:768, ease:Bounce.easeOut } );
				TweenMax.from(clip.bg, 1, { alpha:0, delay:.5 } );
				
				switch(which) {
					case "espn":
						vo = new voESPN();
						channel = vo.play();
						break;
					case "hbo":
						vo = new voHBO();
						channel = vo.play();
						break;
					case "internet":
						vo = new voInternet();
						channel = vo.play();
						break;
					case "showtime":
						vo = new voShowtime();
						channel = vo.play();
						break;
					case "xfinity":
						vo = new voXfinity();
						channel = vo.play();
						break;
					case "tv":
						vo = new voTV();
						channel = vo.play();
						break;
					case "xod":
						vo = new voXOD();
						channel = vo.play();
						break;
				}				
				
				channel.addEventListener(Event.SOUND_COMPLETE, hide, false, 0, true);
				
				isShowingFlag = true;
			}			
		}
		
		
		/**
		 * Called by Main - used to determine if the player is a winner or not
		 * if shown.length == 2 the player is a winner since only unique icons
		 * are added to the array - per show()
		 * @return shown.length
		 */
		public function getShown():int
		{
			return shown.length;
		}
		
		
		public function isShowing():Boolean
		{
			return isShowingFlag;
		}
		
		
		private function hide(e:Event):void
		{
			channel.removeEventListener(Event.SOUND_COMPLETE, hide);
			TweenMax.to(clip.balloon, 1, { y:768, ease:Back.easeIn } );
			TweenMax.to(clip.bg, 1, { alpha:0, onComplete:kill} );
		}
		
		
		private function kill():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			isShowingFlag = false;
			dispatchEvent(new Event(POPUP_COMPLETE));
		}
	}
	
}