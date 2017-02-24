package com.gmrmarketing.stryker.mako2016
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Detail extends EventDispatcher
	{
		public static const CLOSE_DETAIL:String = "backButtonPressed";
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		
		
		public function Detail()
		{
			clip = new mcGateDetail();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			_container = c;
		}
		
		
		/**
		 * 
		 * @param	whichClip String one of: 
		 * aCutAbove, kneet,  hipnotic, kneedeep, theBalconKnee, theJoint, experiencePredictability, operationMako, virtualReality, performanceSolutions
		 */
		public function show(whichClip:String, user:Object):void
		{
			var clips:Array = ["aCutAbove", "kneet",  "hipnotic", "kneedeep", "theBalconKnee", "theJoint", "experiencePredictability", "operationMako", "virtualReality", "performanceSolutions"];
			
			if (!_container.contains(clip)){
				_container.addChild(clip);
			}
			
			clip.gotoAndStop(clips.indexOf(whichClip) + 1);
			clip.detail.gotoAndStop(user.profileType);//1 - 4
			clip.detail.x = 0;//hide under the yellow bar
			
			clip.fname.text = user.firstName;
			
			clip.btnBack.x = 1920;
			clip.btnBack.alpha = 0;
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, backPressed, false, 0, true);
			
			clip.x = -clip.width;
			TweenMax.to(clip, .5, {x:0});
			TweenMax.to(clip.detail, .5, {x:666, delay:.5});
			TweenMax.to(clip.btnBack, .5, {x:1564, alpha:1, delay:1, ease:Back.easeOut});
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip.btnBack, .5, {x:1920, alpha:0});
			TweenMax.to(clip.detail, .3, {x:0});
			TweenMax.to(clip, .3, {x:-666, onComplete:kill});
		}
		
		
		private function kill():void
		{
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
		}
		
		
		private function backPressed(e:MouseEvent):void
		{
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backPressed);
			dispatchEvent(new Event(CLOSE_DETAIL));//caught by Main.showFullMap()
		}
	}
	
}