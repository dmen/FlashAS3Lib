package com.gmrmarketing.bcbs.findyourbalance
{	
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;	
	
	public class Avatars
	{
		public static const READY:String = "avatarPicked";
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var avatarNum:int;		
		
		public function Avatars()
		{
			clip = new mcAvatars();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}			
			clip.highlight.x = clip.a0.x;
			clip.highlight.y = clip.a0.y;
		}
		
		
		public function avatarClicked(i:int):void
		{
			var av:MovieClip = clip["a" + i];
			var toX:Boolean = false;
			if(clip.highlight.x != av.x){
				TweenMax.to(clip.highlight, .5, { x:av.x } );
				toX = true;
			}
			if (clip.highlight.y != av.y) {
				if(toX){
					TweenMax.to(clip.highlight, .5, { y:av.y, delay:.5 } );
				}else {
					TweenMax.to(clip.highlight, .5, { y:av.y } );
				}
			}
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
	}
	
}