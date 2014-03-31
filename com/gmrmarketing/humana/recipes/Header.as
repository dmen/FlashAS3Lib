package com.gmrmarketing.humana.recipes
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	public class Header extends EventDispatcher
	{
		public static const VIEW_ALL:String = "viewAllPressed";
		public static const VIEW_ONE:String = "viewOnePressed";
		public static const BACK_PRESSED:String = "backFromDetail";
		public static const PRINT:String = "printRecipe";
		public static const EMAIL:String = "emailRecipe";
		public static const SLIDESHOW:String = "headerLogoClicked";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Header() 
		{
			clip = new mc_header();
			clip.btnLogo.addEventListener(MouseEvent.MOUSE_DOWN, logoClicked, false, 0, true);
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;	
		}
		
		
		/**
		 * Shows the humana logo and View all button
		 */
		public function showSlideshowView():void
		{			
			showWhite();
			showBottomWhite();
			
			container.addChild(clip);
			
			clip.listText.visible = false;
			
			clip.btnView.visible = true;
			clip.theText.visible = true;
			clip.slideLogo.visible = true;
			clip.btnViewAll.visible = true;
			clip.btnView.addEventListener(MouseEvent.MOUSE_DOWN, viewOne, false, 0, true);
			clip.btnViewAll.addEventListener(MouseEvent.MOUSE_DOWN, viewAll, false, 0, true);
			
			clip.detailButtons.visible = false;
			clip.detailButtons.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backFromDetail);
			clip.detailButtons.btnPrint.removeEventListener(MouseEvent.MOUSE_DOWN, printRecipe);
			clip.detailButtons.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, emailRecipe);
		}
		
		
		public function changeSlideshowTitle(title:String):void
		{
			clip.theText.text = title;
		}
		
		
		/**
		 * Shows the back to list and print buttons used at the bottom of detail view
		 */
		public function showDetailView():void
		{
			showWhite();
			hideBottomWhite();
			
			clip.listText.visible = false;
			
			clip.btnView.visible = false;
			clip.theText.visible = false;
			clip.slideLogo.visible = false;
			clip.btnViewAll.visible = false;
			clip.btnViewAll.removeEventListener(MouseEvent.MOUSE_DOWN, viewAll);
			clip.btnView.removeEventListener(MouseEvent.MOUSE_DOWN, viewOne);
			
			clip.detailButtons.visible = true;
			clip.detailButtons.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, backFromDetail, false, 0, true);
			clip.detailButtons.btnPrint.addEventListener(MouseEvent.MOUSE_DOWN, printRecipe, false, 0, true);
			clip.detailButtons.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, emailRecipe, false, 0, true);
		}
		
		
		/**
		 * Hides the footer for list view
		 */
		public function showListView():void
		{
			hideWhite();
			hideBottomWhite();
			
			clip.listText.visible = true;
			
			clip.btnView.visible = false;
			clip.theText.visible = false;
			clip.slideLogo.visible = false;
			clip.btnViewAll.visible = false;
			clip.btnViewAll.removeEventListener(MouseEvent.MOUSE_DOWN, viewAll);
			clip.btnView.removeEventListener(MouseEvent.MOUSE_DOWN, viewOne);
			
			clip.detailButtons.visible = false;
			clip.detailButtons.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backFromDetail);
			clip.detailButtons.btnPrint.removeEventListener(MouseEvent.MOUSE_DOWN, printRecipe);
			clip.detailButtons.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, emailRecipe);
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			TweenMax.killTweensOf(clip.whiteBG);
			
			clip.btnViewAll.removeEventListener(MouseEvent.MOUSE_DOWN, viewAll);
			clip.detailButtons.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backFromDetail);
			clip.detailButtons.btnPrint.removeEventListener(MouseEvent.MOUSE_DOWN, printRecipe);
			clip.detailButtons.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, emailRecipe);
		}
		
		
		private function showWhite():void
		{
			clip.whiteBG.visible = true;
			clip.whiteBG.alpha = 1;
		}
		
		
		private function showBottomWhite():void
		{
			clip.whiteBG_bottom.visible = true;
			clip.whiteBG_bottom.alpha = 1;
		}
		
		
		private function hideWhite():void
		{
			clip.whiteBG.visible = false;
		}
		
		private function hideBottomWhite():void
		{
			clip.whiteBG_bottom.visible = false;
		}
		
		
		/**
		 * Called by clicking the view all button in the slideshow footer
		 * @param	e
		 */
		private function viewAll(e:MouseEvent):void
		{
			dispatchEvent(new Event(VIEW_ALL));
		}
		
		private function viewOne(e:MouseEvent):void
		{
			dispatchEvent(new Event(VIEW_ONE));
		}
		
		private function backFromDetail(e:MouseEvent):void
		{
			dispatchEvent(new Event(BACK_PRESSED));
		}
		
		
		private function printRecipe(e:MouseEvent):void
		{
			dispatchEvent(new Event(PRINT));
		}
		
		
		private function emailRecipe(e:MouseEvent):void
		{
			dispatchEvent(new Event(EMAIL));
		}
		
		
		private function logoClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(SLIDESHOW));
		}
	}
	
}