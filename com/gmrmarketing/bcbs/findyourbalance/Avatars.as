package com.gmrmarketing.bcbs.findyourbalance
{	
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;	
	
	public class Avatars
	{		
		private const firstEdge:int = 251;
		private const iconSpacing:int = 186;
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;		
		private var avNum:int;
		
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
			clip.highlight.x = firstEdge;	//left edge of first icon
			avNum = 0;
		}
		
		
		public function getAvatarNumber():int
		{
			return avNum;
		}
		
		
		/**
		 * Called from Main when user selects a avatar on the controller
		 * ie - ***avpoint***n is received
		 * @param	i integer 0 - 7
		 */
		public function avatarClicked(i:int):void
		{			
			avNum = i;
			var toX:int = firstEdge + (iconSpacing * avNum);
			TweenMax.to(clip.highlight, 1, { x:toX } );
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
	}
	
}