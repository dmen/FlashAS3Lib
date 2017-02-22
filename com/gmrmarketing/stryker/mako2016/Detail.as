package com.gmrmarketing.stryker.mako2016
{
	import flash.events.*;
	import flash.display.*;
	
	
	public class Detail extends EventDispatcher
	{
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
			clip.fname.text = user.firstName;
		}
	}
	
}