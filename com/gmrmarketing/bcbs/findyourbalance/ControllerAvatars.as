package com.gmrmarketing.bcbs.findyourbalance
{	
	import flash.display.*;
	import com.gmrmarketing.intel.girls20.ComboBox;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class ControllerAvatars extends EventDispatcher
	{
		public static const READY:String = "avatarPicked";
		public static const NEW_AVATAR:String = "newAvatar";
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var avatarNum:int;
		private var toX:int;
		private var toY:int;
		
		public function ControllerAvatars()
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
			
			clip.a0.addEventListener(MouseEvent.MOUSE_DOWN, avatarClicked, false, 0, true);
			clip.a1.addEventListener(MouseEvent.MOUSE_DOWN, avatarClicked, false, 0, true);
			clip.a2.addEventListener(MouseEvent.MOUSE_DOWN, avatarClicked, false, 0, true);
			clip.a3.addEventListener(MouseEvent.MOUSE_DOWN, avatarClicked, false, 0, true);
			clip.a4.addEventListener(MouseEvent.MOUSE_DOWN, avatarClicked, false, 0, true);
			clip.a5.addEventListener(MouseEvent.MOUSE_DOWN, avatarClicked, false, 0, true);
			clip.a6.addEventListener(MouseEvent.MOUSE_DOWN, avatarClicked, false, 0, true);
			clip.a7.addEventListener(MouseEvent.MOUSE_DOWN, avatarClicked, false, 0, true);
			clip.a8.addEventListener(MouseEvent.MOUSE_DOWN, avatarClicked, false, 0, true);
			clip.a9.addEventListener(MouseEvent.MOUSE_DOWN, avatarClicked, false, 0, true);
			
			avatarNum = 0;
			clip.highlight.x = clip.a0.x;
			clip.highlight.y = clip.a0.y;
			
			clip.btnReady.addEventListener(MouseEvent.MOUSE_DOWN, readyClicked, false, 0, true);
		}
		
		
		private function avatarClicked(e:MouseEvent):void
		{
			var m:MovieClip = MovieClip(e.currentTarget);
			var didX:Boolean = false;
			if(clip.highlight.x != m.x){
				TweenMax.to(clip.highlight, .5, { x:m.x } );
				didX = true;
			}
			if (clip.highlight.y != m.y) {
				if(didX){
					TweenMax.to(clip.highlight, .5, { y:m.y, delay:.5 } );
				}else {
					TweenMax.to(clip.highlight, .5, { y:m.y } );
				}
			}
			avatarNum = parseInt(m.name.substr(1)); // 0 - 9			
			dispatchEvent(new Event(NEW_AVATAR));
		}
		
		
		/**
		 * Returns the selected avatar number 0 - 9
		 * @return int
		 */
		public function getAvatar():int
		{
			return avatarNum;
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			clip.a0.removeEventListener(MouseEvent.MOUSE_DOWN, avatarClicked);
			clip.a1.removeEventListener(MouseEvent.MOUSE_DOWN, avatarClicked);
			clip.a2.removeEventListener(MouseEvent.MOUSE_DOWN, avatarClicked);
			clip.a3.removeEventListener(MouseEvent.MOUSE_DOWN, avatarClicked);
			clip.a4.removeEventListener(MouseEvent.MOUSE_DOWN, avatarClicked);
			clip.a5.removeEventListener(MouseEvent.MOUSE_DOWN, avatarClicked);
			clip.a6.removeEventListener(MouseEvent.MOUSE_DOWN, avatarClicked);
			clip.a7.removeEventListener(MouseEvent.MOUSE_DOWN, avatarClicked);
			clip.a8.removeEventListener(MouseEvent.MOUSE_DOWN, avatarClicked);
			clip.a9.removeEventListener(MouseEvent.MOUSE_DOWN, avatarClicked);
			clip.btnReady.removeEventListener(MouseEvent.MOUSE_DOWN, readyClicked);
		}
		
		
		private function readyClicked(e:MouseEvent):void
		{			
			dispatchEvent(new Event(READY));			
		}		
		
	}
	
}