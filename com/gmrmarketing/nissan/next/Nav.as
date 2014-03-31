package com.gmrmarketing.nissan.next
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Nav extends EventDispatcher
	{
		public static const NAV_SELECTION:String = "newNavSelection";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var selection:String;
		
		
		public function Nav($container:DisplayObjectContainer)
		{
			container = $container;
			clip = new navClip();
			
			clip.btnSubmit.y = 35;
			clip.btnCreateOne.y = 35;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			selection = "";
			clip.y = 780; //661
			clip.pointer.x = 86;
			
			clip.btnInnovation.addEventListener(MouseEvent.MOUSE_DOWN, innoClick, false, 0, true);
			clip.btnModels.addEventListener(MouseEvent.MOUSE_DOWN, modClick, false, 0, true);
			clip.btnWhichCar.addEventListener(MouseEvent.MOUSE_DOWN, whichClick, false, 0, true);
			clip.btnCool.addEventListener(MouseEvent.MOUSE_DOWN, coolClick, false, 0, true);
			clip.btnLogout.addEventListener(MouseEvent.MOUSE_DOWN, logoutClick, false, 0, true);
			
			TweenMax.to(clip, .5, { y:661, ease:Back.easeOut } );
		}
		
		
		public function hide():void
		{
			clip.btnInnovation.removeEventListener(MouseEvent.MOUSE_DOWN, innoClick);
			clip.btnModels.removeEventListener(MouseEvent.MOUSE_DOWN, modClick);
			clip.btnWhichCar.removeEventListener(MouseEvent.MOUSE_DOWN, whichClick);
			clip.btnCool.removeEventListener(MouseEvent.MOUSE_DOWN, coolClick);
			clip.btnLogout.removeEventListener(MouseEvent.MOUSE_DOWN, logoutClick);
			
			TweenMax.to(clip, .5, { y:780, ease:Back.easeIn, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		/**
		 * Returns the nav selection
		 * innovation,models,whichCar,cool,coolEntry
		 * @return String 
		 */
		public function getNav():String
		{
			return selection;
		}
		
		
		public function disabeCreateOne():void
		{
			clip.btnCreateOne.removeEventListener(MouseEvent.MOUSE_DOWN, createOneClick);
			TweenMax.to(clip.btnCreateOne, .75, { y:35, ease:Back.easeIn } );
		}
		
		
		public function enableCreateOne():void
		{
			clip.btnCreateOne.addEventListener(MouseEvent.MOUSE_DOWN, createOneClick, false, 0, true);
			TweenMax.to(clip.btnCreateOne, .75, { y: -35, ease:Back.easeOut } );
		}
		
		
		public function enableSubmit():void
		{
			clip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, submitClick, false, 0, true);
			TweenMax.to(clip.btnSubmit, .75, { y: -35, ease:Back.easeOut } );
		}
		
		public function disableSubmit():void
		{
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submitClick);
			TweenMax.to(clip.btnSubmit, .75, { y:35, ease:Back.easeIn } );
		}
		
		
		private function createOneClick(e:MouseEvent):void
		{
			if(selection != "coolEntry"){
				selection = "coolEntry";				
				newSelection();
			}
		}
		
		
		private function innoClick(e:MouseEvent):void
		{
			if(selection != "innovation"){
				selection = "innovation";
				TweenMax.to(clip.pointer, 1, { x:310, ease:Back.easeOut } );
				newSelection();
			}
		}
		
		
		private function modClick(e:MouseEvent):void
		{
			//if(selection != "models"){
				selection = "models";
				TweenMax.to(clip.pointer, 1, { x:486, ease:Back.easeOut } );
				newSelection();
			//}
		}
		
		
		private function whichClick(e:MouseEvent):void
		{
			if(selection != "whichCar"){
				selection = "whichCar";
				TweenMax.to(clip.pointer, 1, { x:734, ease:Back.easeOut } );
				newSelection();
			}
		}
		
		
		private function coolClick(e:MouseEvent):void
		{
			if(selection != "cool"){
				selection = "cool";
				TweenMax.to(clip.pointer, 1, { x:1036, ease:Back.easeOut } );
				newSelection();
			}
		}
		
		
		private function submitClick(e:MouseEvent):void
		{
			if (selection != "submit") {
				selection = "submit";
				newSelection();
			}
		}
		
		private function logoutClick(e:MouseEvent):void
		{
			if (selection != "logout") {
				selection = "logout";
				newSelection();
			}
		}
		
		
		private function newSelection():void
		{
			//trace("nav.newSelection() currentSelection=", selection);
			dispatchEvent(new Event(NAV_SELECTION));
		}
		
	}
	
}