package com.gmrmarketing.comcast.streamgame2017
{	
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.net.*;
	
	public class Win extends EventDispatcher
	{
		public static const COMPLETE:String = "winComplete";
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
		
		
		public function hide():void
		{
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
		}
		
		
		public function show(numStars:int):void
		{
			if (!_container.contains(clip)){
				_container.addChild(clip);
			}
			
			clip.star1.alpha = 0;
			clip.star2.alpha = 0;
			clip.star3.alpha = 0;
			clip.logo.alpha = 0;
			
			clip.bg.x = 1080;
			clip.youWin.x = 1080;
			clip.pleaseSee.x = 1080;
			
			clip.pleaseSee.theText.text = "Please see an XFINITY expert\nto redeem your level " + numStars.toString() + " prize."
			
			TweenMax.to(clip.bg, .5, {x:0});
			TweenMax.to(clip.youWin, .4, {x:4, delay:.5, ease:Back.easeOut});
			TweenMax.to(clip.pleaseSee, .4, {x:4, delay:.75, ease:Back.easeOut});
			TweenMax.to(clip.logo, 3, {alpha:1, delay:1});
			
			if (numStars == 3){
				
				TweenMax.to(clip.star1, .3, {alpha:1, scaleX:1.75, scaleY:1.75, colorTransform:{tint:0xffffff, tintAmount:1}, delay:2});
				TweenMax.to(clip.star1, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, colorTransform:{tint:0x00b6f1, tintAmount:1}, delay:2.3});
				
				TweenMax.to(clip.star2, .3, {alpha:1, scaleX:1.75, scaleY:1.75, colorTransform:{tint:0xffffff, tintAmount:1}, delay:2.6});
				TweenMax.to(clip.star2, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, colorTransform:{tint:0x00b6f1, tintAmount:1}, delay:2.9});
				
				TweenMax.to(clip.star3, .3, {alpha:1, scaleX:1.75, scaleY:1.75, colorTransform:{tint:0xffffff, tintAmount:1}, delay:2.9});
				TweenMax.to(clip.star3, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, colorTransform:{tint:0x00b6f1, tintAmount:1}, delay:3.2});
				
			}else if (numStars == 2){
				
				TweenMax.to(clip.star1, .3, {alpha:1, scaleX:1.75, scaleY:1.75, colorTransform:{tint:0xffffff, tintAmount:1}, delay:2});
				TweenMax.to(clip.star1, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, colorTransform:{tint:0x00b6f1, tintAmount:1}, delay:2.3});
				
				TweenMax.to(clip.star2, .3, {alpha:1, scaleX:1.75, scaleY:1.75, colorTransform:{tint:0xffffff, tintAmount:1}, delay:2.6});
				TweenMax.to(clip.star2, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, colorTransform:{tint:0x00b6f1, tintAmount:1}, delay:2.9});
				
				TweenMax.to(clip.star3, .5, {alpha:.1, delay:3});
				
			}else{
				
				TweenMax.to(clip.star1, .3, {alpha:1, scaleX:1.75, scaleY:1.75, colorTransform:{tint:0xffffff, tintAmount:1}, delay:2});				
				TweenMax.to(clip.star1, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, colorTransform:{tint:0x00b6f1, tintAmount:1}, delay:2.3});
				
				TweenMax.to(clip.star2, .5, {alpha:.1, delay:2.5});
				TweenMax.to(clip.star3, .5, {alpha:.1, delay:3});
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
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			trace("IOError");
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}