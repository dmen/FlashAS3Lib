/**
 * Manages the view selector
 * This is the small selector with the three mower icons that appears at screen right
 */

package com.gmrmarketing.husqvarna
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenLite;
	import flash.events.EventDispatcher;
	import flash.events.*;

	
	public class ViewSelector extends EventDispatcher
	{
		public static const VIEW_CHANGED:String = "viewSelectionChanged";
		
		private var container:DisplayObjectContainer;
		private var currentView:String = "front"; //default view - front, side, top
		
		private var views:theViews; //lib clip of three mower views with 'view features' text
		
		private const GRAYED_OUT:Number = .5;
		
		
		
		public function ViewSelector($container:DisplayObjectContainer)
		{
			container = $container;
			
			views = new theViews();
			views.x = 730;
			views.y = 500;
			
			views.front.buttonMode = true;
			views.side.buttonMode = true;
			views.top.buttonMode = true;
			
			views.front.addEventListener(MouseEvent.CLICK, frontClick, false, 0, true);
			views.side.addEventListener(MouseEvent.CLICK, sideClick, false, 0, true);
			views.top.addEventListener(MouseEvent.CLICK, topClick, false, 0, true);
			
			views.front.addEventListener(MouseEvent.MOUSE_OVER, frontOver, false, 0, true);
			views.side.addEventListener(MouseEvent.MOUSE_OVER, sideOver, false, 0, true);
			views.top.addEventListener(MouseEvent.MOUSE_OVER, topOver, false, 0, true);
			
			views.front.addEventListener(MouseEvent.MOUSE_OUT, frontOut, false, 0, true);
			views.side.addEventListener(MouseEvent.MOUSE_OUT, sideOut, false, 0, true);
			views.top.addEventListener(MouseEvent.MOUSE_OUT, topOut, false, 0, true);
		}
		
		
		public function showSelector():void
		{
			views.alpha = 0;
			
			if(!container.contains(views)){
				container.addChild(views);
			}
			
			selectionChanged();			
			
			TweenLite.to(views, .75, { alpha:1 } );
		}
		
		
		
		/**
		 * Changes the alpha of the icons to show the current selection
		 */
		private function selectionChanged():void
		{
			views.front.alpha = GRAYED_OUT;
			views.side.alpha = GRAYED_OUT;
			views.top.alpha = GRAYED_OUT;
			
			switch(currentView) {
				case "front":
					views.front.alpha = 1;
					break;
				case "side":
					views.side.alpha = 1;
					break;
				case "top":
					views.top.alpha = 1;
					break;
			}
		}
		
		
		
		/**
		 * Returns the current view
		 * 
		 * @return currentView String
		 */
		public function getView():String
		{
			return currentView;
		}
		
		
		
		/**
		 * Moves the view selector to the front of the container
		 */
		public function bringToFront():void
		{
			container.setChildIndex(views, container.numChildren - 1);
		}
		
		
		public function hideSelector():void
		{
			if(container.contains(views)){
				TweenLite.to(views, .75, { alpha:0, onComplete:removeSelector } );
			}
		}
		
		
		private function removeSelector():void
		{
			container.removeChild(views);			
		}
		
		
		private function frontClick(e:MouseEvent):void
		{
			if(currentView != "front"){
				currentView = "front";
				selectionChanged();
				dispatchEvent(new Event(VIEW_CHANGED));
			}
		}
		
		
		private function sideClick(e:MouseEvent):void
		{
			if(currentView != "side"){
				currentView = "side";
				selectionChanged();
				dispatchEvent(new Event(VIEW_CHANGED));
			}
		}
		
		
		private function topClick(e:MouseEvent):void
		{
			if(currentView != "top"){
				currentView = "top";
				selectionChanged();
				dispatchEvent(new Event(VIEW_CHANGED));
			}
		}
		
		
		private function frontOver(e:MouseEvent):void
		{
			TweenLite.to(views.front, .25, { alpha:1 } );
		}
		
		
		private function sideOver(e:MouseEvent):void
		{
			TweenLite.to(views.side, .25, { alpha:1 } );
		}
		
		
		private function topOver(e:MouseEvent):void
		{
			TweenLite.to(views.top, .25, { alpha:1 } );
		}
		
		
		private function frontOut(e:MouseEvent):void
		{
			if(currentView != "front"){
				TweenLite.to(views.front, .25, { alpha:GRAYED_OUT } );
			}
		}
		
		
		private function sideOut(e:MouseEvent):void
		{
			if(currentView != "side"){
				TweenLite.to(views.side, .25, { alpha:GRAYED_OUT } );
			}
		}
		
		
		private function topOut(e:MouseEvent):void
		{
			if(currentView != "top"){
				TweenLite.to(views.top, .25, { alpha:GRAYED_OUT } );
			}
		}
		
	}
	
}