package com.gmrmarketing.comcast.streamgame2017
{	
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.net.*;
	
	public class Win extends EventDispatcher
	{
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		
		
		public function Win()
		{
			clip = new mcWin();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			_container = c;
		}
		
		
		public function show(numStars:int):void
		{
			if (!_container.contains(clip)){
				_container.addChild(clip);
			}
			
			clip.star1.alpha = .3;
			clip.star2.alpha = .3;
			clip.star3.alpha = .3;
			
			clip.bg.alpha = 0;
			clip.youWin.x = 1080;
			clip.pleaseSee.x = 1080;
			
			TweenMax.to(clip.bg, .5, {alpha:1});
			TweenMax.to(clip.youWin, .5, {x:4, delay:.5, ease:Back.easeOut});
			TweenMax.to(clip.pleaseSee, .5, {x:4, delay:.75, ease:Back.easeOut});
			TweenMax.to(clip.logo, 1, {alpha:1, delay:1});
			
			if (numStars == 3){
				TweenMax.to(clip.star1, 1, {alpha:1, delay:1});
				TweenMax.to(clip.star2, 1, {alpha:1, delay:1.25});
				TweenMax.to(clip.star3, 1, {alpha:1, delay:1.5});
			}else if (numStars == 2){
				TweenMax.to(clip.star1, 1, {alpha:1, delay:1});
				TweenMax.to(clip.star2, 1, {alpha:1, delay:1.25});
			}else{
				TweenMax.to(clip.star1, 1, {alpha:1, delay:1});				
			}			
			
			var request:URLRequest = new URLRequest("http://xfinitynascartour.thesocialtab.net/service/prizewheel");
			
			var vars:URLVariables = new URLVariables();
			vars.stars = numStars;		
			
			request.data = vars;			
			request.method = URLRequestMethod.GET;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			lo.load(request);
		}
		
		
		private function dataPosted(e:Event):void
		{
			var lo:URLLoader = URLLoader(e.target);
			//trace(lo.data);//success
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			trace("IOError");
		}
		
	}
	
}